#Requires -Version 7.0
<#
.SYNOPSIS
    The one File Save Log installer (MyCommandCenter kit).

.DESCRIPTION
    This is the kit's ONLY installer for the File Save Log module's
    computer-side piece: the scanner (Scan-FileSaves.ps1), run by the
    scheduled task "FileSaveLog-Scan" at logon and every 15 minutes.
    (An earlier kit design also installed a scan-request watcher; the
    manual Update chain does not use trigger files, so the watcher
    was removed from the kit. This installer neither installs nor
    manages it; it also does not remove one a machine may already
    have. Its scope is the scanner only.)

    There is no separate add-on installer, and no part of this module
    needs one: this script is safe to run on a fresh machine and safe
    to re-run on an installed one, because of the rule below.

    THE NEVER-DOWNGRADE RULE AND THE LEGACY RULE
    The packaged scanner carries a version marker near its top:

        $ScriptVersion = '1.0.0'

    The installer compares the packaged copy with the installed copy:

      - Identical content (same SHA256 hash): "already current",
        regardless of markers. An identical file needs no replacement.
      - Both copies carry a marker: the higher marker wins. Packaged
        newer: upgrade. Equal: already current, nothing copied.
        Installed newer: SKIP the replacement, leave the installed
        file untouched, and say so in the summary ("kept - installed
        is newer than the package"). The installer NEVER overwrites a
        marked installed script with an older packaged copy.
      - The installed copy has NO marker: it is LEGACY, never
        "newer", whatever its file date says. (Scripts from before
        the kit carried its own scanner, including one a setup
        generated on the spot, have no marker; their dates prove
        nothing.) The installer backs the legacy copy up, replaces it
        with the packaged script, and prints a clear warning that an
        unmarked (legacy) script was replaced.
      - The packaged copy has no marker but the installed one does:
        the marked installed copy stays. A package that cannot prove
        its freshness never displaces a marked install.

    File dates are never consulted. Before any script is replaced,
    the previous copy is backed up next to it as
    <name>.bak-<yyyyMMdd-HHmmss>, so a replacement can be undone by
    hand. A kept-newer script is never backed up or touched at all.

    WHAT ELSE IT DOES
    - Writes the windowless-launch VBScript wrapper
      (Run-FileSaveLog-Hidden.vbs for the scanner) into the install
      folder with THIS machine's resolved pwsh.exe path and install
      folder baked in, per spec/FILE-SAVE-LOG.md section 2c. The
      wrapper is generated, so re-writing it with identical content
      changes nothing. If wscript.exe is missing, the task falls back
      to conhost.exe --headless and the summary says so.
    - Installs FileSaveLog-Excludes.json (the shipped defaults; kit
      updates replace it) and creates FileSaveLog-Excludes.user.json
      from the shipped template ONLY when it does not exist yet,
      filling its selfPaths with the install folder and the outbox.
      An existing user file is NEVER overwritten.
    - Creates config.json on a fresh install (watched roots from
      -Roots, or the Documents / Downloads / Desktop defaults; the
      outbox from -OutboxPath, or the first Drive sync folder found,
      or a loud local fallback). An existing config.json is preserved
      exactly as it is: roots, outbox, and state paths are the user's.
    - Registers the scheduled task for the current user (interactive
      logon, Limited run level, task Hidden setting on, the launch
      hidden by the wrapper, never "run whether logged on or not").
      Re-registering with -Force writes the identical definition, so
      re-running changes nothing.
    - On a fresh install only, runs one baseline scan at the end.

    IDEMPOTENT: re-running this installer on an up-to-date install
    copies nothing, preserves every config, re-registers the tasks
    identically, exits 0, and prints a per-component summary using:
    installed / upgraded / already current / kept (installed is
    newer) / created / preserved / registered.

    No admin rights are needed; everything is for the current user.
    Run it from the kit's filesave-log folder (or any folder holding
    the three package files checked below). The real paths come from
    the pre-install diagnostic report (see INSTALL.md step 5 and
    prompts/05): pass them as parameters rather than editing this
    script.

.PARAMETER InstallDir
    Folder the scripts, wrappers, config, and scanner state live in.
    Default: <user profile>\tools\file-save-log. Setup passes the
    real folder from the diagnostic report.

.PARAMETER Roots
    Watched folders for a FRESH install's config.json, each entry in
    the form "Path|Area" (for example "C:\Users\me\Documents|
    Documents"). Ignored when config.json already exists: an existing
    config is preserved. When omitted on a fresh install, Documents,
    Downloads, and Desktop under the user profile are used.

.PARAMETER OutboxPath
    The folder scanner batches land in (normally the "File Save Log\
    Ingest" folder inside the user's Drive sync folder). Used only
    when config.json is created or when the user excludes file is
    created. When omitted, the installer probes the usual Drive sync
    roots and falls back to <InstallDir>\outbox with a loud warning.

.PARAMETER PwshPath
    The real pwsh.exe path from the diagnostic report. When omitted,
    resolved from PATH, then from the standard install location.

.PARAMETER TaskName
    The name of the scheduled task this installer registers.
    Default: FileSaveLog-Scan. A task name is the one name this
    installer uses that is not scoped to the install folder: task
    names live in the machine's shared task store, so registering
    under a name overwrites any task already carrying it. A
    rehearsal on a machine that already has a live install MUST
    pass a distinct -TaskName (and a scratch -InstallDir), so the
    rehearsal never reads, registers, or overwrites the live task.

.PARAMETER SkipBaselineScan
    Skips the one baseline scan a fresh install runs at the end.
#>
[CmdletBinding()]
param(
    [string]$InstallDir = (Join-Path $env:USERPROFILE 'tools\file-save-log'),
    [string[]]$Roots,
    [string]$OutboxPath,
    [string]$PwshPath,
    [string]$TaskName = 'FileSaveLog-Scan',
    [switch]$SkipBaselineScan
)

$ErrorActionPreference = 'Stop'

$SourceDir        = $PSScriptRoot
$ScannerSource    = Join-Path $SourceDir 'Scan-FileSaves.ps1'
$DefaultsSource   = Join-Path $SourceDir 'FileSaveLog-Excludes.json'
$TemplateSource   = Join-Path $SourceDir 'FileSaveLog-Excludes.user.template.json'

$ScannerDest      = Join-Path $InstallDir 'Scan-FileSaves.ps1'
$DefaultsDest     = Join-Path $InstallDir 'FileSaveLog-Excludes.json'
$UserExcludesDest = Join-Path $InstallDir 'FileSaveLog-Excludes.user.json'
$ConfigPath       = Join-Path $InstallDir 'config.json'
$StatePath        = Join-Path $InstallDir 'state.json'
$ScannerVbsDest   = Join-Path $InstallDir 'Run-FileSaveLog-Hidden.vbs'

$results = [System.Collections.Generic.List[object]]::new()
function Add-Result {
    param([string]$Component, [string]$Outcome, [string]$Detail = '')
    $results.Add([pscustomobject]@{ Component = $Component; Outcome = $Outcome; Detail = $Detail })
}

Write-Host 'Installing File Save Log (scanner)...'
Write-Host "Package folder : $SourceDir"
Write-Host "Install folder : $InstallDir"

foreach ($needed in @($ScannerSource, $DefaultsSource, $TemplateSource)) {
    if (-not (Test-Path -LiteralPath $needed)) {
        throw "Package file missing: $needed. Run this installer from the kit's filesave-log folder, which holds all the package files."
    }
}

# --------------------------------------------------------------------------
# Version comparison, the install decision in one place:
#   identical content (SHA256)      -> already current
#   both copies marked              -> the higher $ScriptVersion marker
#                                      wins; a marked installed script is
#                                      NEVER overwritten by an older
#                                      packaged copy
#   installed copy has no marker    -> LEGACY: backed up, replaced, and
#                                      warned about, whatever its file
#                                      date says (dates are never read)
#   packaged unmarked, installed
#     marked                        -> the marked installed copy stays
# --------------------------------------------------------------------------
function Get-ScriptVersionMarker {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    $text = Get-Content -LiteralPath $Path -Raw
    $match = [regex]::Match($text, "\`$ScriptVersion\s*=\s*'([0-9]+(?:\.[0-9]+){1,3})'")
    if ($match.Success) { return [version]$match.Groups[1].Value }
    return $null
}

function Test-SameFile {
    param([string]$A, [string]$B)
    return [System.IO.Path]::GetFullPath($A).Equals([System.IO.Path]::GetFullPath($B), [System.StringComparison]::OrdinalIgnoreCase)
}

function Install-KitScript {
    # Copies $Source to $Dest only under the rules in the header: the
    # packaged copy wins when both are marked and it is newer, and when
    # the installed copy is unmarked (legacy). A marked installed copy
    # is never displaced by an older or unmarked packaged copy.
    param([string]$Source, [string]$Dest, [string]$Component)

    if (Test-SameFile $Source $Dest) {
        Add-Result $Component 'already current' 'installer was run from the install folder'
        return
    }
    if (-not (Test-Path -LiteralPath $Dest)) {
        Copy-Item -LiteralPath $Source -Destination $Dest -Force
        Add-Result $Component 'installed' $Dest
        return
    }

    $sameContent = (Get-FileHash -LiteralPath $Source -Algorithm SHA256).Hash -eq
                   (Get-FileHash -LiteralPath $Dest   -Algorithm SHA256).Hash
    if ($sameContent) {
        Add-Result $Component 'already current' 'identical content (SHA256 match)'
        return
    }

    $srcMarker = Get-ScriptVersionMarker $Source
    $dstMarker = Get-ScriptVersionMarker $Dest

    if ($srcMarker -and $dstMarker) {
        $cmp = $srcMarker.CompareTo($dstMarker)
        if ($cmp -gt 0) {
            $backup = "$Dest.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Copy-Item -LiteralPath $Dest -Destination $backup -Force
            Copy-Item -LiteralPath $Source -Destination $Dest -Force
            Add-Result $Component 'upgraded' "version marker $dstMarker -> $srcMarker; previous copy backed up to $backup"
        }
        elseif ($cmp -eq 0) {
            Add-Result $Component 'already current' "version marker $srcMarker on both copies (content differs; the marker is the version of record)"
        }
        else {
            Add-Result $Component 'kept (installed is newer)' "installed marker $dstMarker is newer than packaged $srcMarker"
            Write-Warning "$Component KEPT: the installed script at $Dest is newer than the packaged copy and was left untouched (installed marker $dstMarker, packaged $srcMarker)."
        }
        return
    }

    if (-not $dstMarker) {
        # The installed copy carries no $ScriptVersion marker: it is a
        # legacy script (pre-marker kit, or one a setup generated), and
        # legacy is never "newer". File dates are NOT consulted: an
        # unmarked script's date proves nothing about its freshness.
        $backup = "$Dest.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item -LiteralPath $Dest -Destination $backup -Force
        Copy-Item -LiteralPath $Source -Destination $Dest -Force
        Add-Result $Component 'upgraded' "unmarked (legacy) installed script replaced with the packaged copy; legacy copy backed up to $backup"
        Write-Warning "$Component REPLACED: the installed script at $Dest carried no `$ScriptVersion marker, so it was treated as legacy and replaced with the packaged copy. The legacy copy was backed up to $backup. This is deliberate: an unmarked script is never treated as newer than the package, whatever its file date says."
        return
    }

    # Only the packaged copy lacks a marker: the marked installed copy
    # stays. A package that cannot prove its freshness never displaces
    # a marked install.
    Add-Result $Component 'kept (installed is newer)' "installed copy carries marker $dstMarker; the packaged copy carries none"
    Write-Warning "$Component KEPT: the packaged copy carries no `$ScriptVersion marker, so it cannot prove it is newer than the marked installed script at $Dest (marker $dstMarker), which was left untouched."
}

# --------------------------------------------------------------------------
# 1. Install folder and the scanner script (the never-downgrade and
#    legacy rules in Install-KitScript apply)
# --------------------------------------------------------------------------
New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

Install-KitScript -Source $ScannerSource -Dest $ScannerDest -Component 'Scanner (Scan-FileSaves.ps1)'

# --------------------------------------------------------------------------
# 2. Resolve the outbox (needed for a fresh config and for the user
#    excludes file's selfPaths). An existing config's outbox wins.
# --------------------------------------------------------------------------
$resolvedOutbox     = $null
$outboxIsFallback   = $false
$existingConfig     = $null
if (Test-Path -LiteralPath $ConfigPath) {
    try { $existingConfig = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json -ErrorAction Stop } catch { $existingConfig = $null }
}
if ($existingConfig -and -not [string]::IsNullOrWhiteSpace([string]$existingConfig.outboxPath)) {
    $resolvedOutbox = [System.Environment]::ExpandEnvironmentVariables([string]$existingConfig.outboxPath)
}
elseif (-not [string]::IsNullOrWhiteSpace($OutboxPath)) {
    $resolvedOutbox = $OutboxPath
}
else {
    $driveCandidates = @(
        (Join-Path $env:USERPROFILE 'Google Drive'),
        'G:\My Drive',
        (Join-Path $env:USERPROFILE 'My Drive')
    )
    foreach ($root in $driveCandidates) {
        if (Test-Path -LiteralPath $root -ErrorAction SilentlyContinue) {
            $resolvedOutbox = Join-Path $root 'File Save Log\Ingest'
            break
        }
    }
    if (-not $resolvedOutbox) {
        $resolvedOutbox   = Join-Path $InstallDir 'outbox'
        $outboxIsFallback = $true
    }
}
New-Item -ItemType Directory -Path $resolvedOutbox -Force | Out-Null

# --------------------------------------------------------------------------
# 3. Excludes files. Defaults are kit-owned and refreshed; the user's
#    own file is created once from the template and never overwritten.
# --------------------------------------------------------------------------
if (Test-SameFile $DefaultsSource $DefaultsDest) {
    Add-Result 'Excludes defaults (FileSaveLog-Excludes.json)' 'already current' 'installer was run from the install folder'
}
elseif (-not (Test-Path -LiteralPath $DefaultsDest)) {
    Copy-Item -LiteralPath $DefaultsSource -Destination $DefaultsDest -Force
    Add-Result 'Excludes defaults (FileSaveLog-Excludes.json)' 'installed' $DefaultsDest
}
elseif ((Get-FileHash -LiteralPath $DefaultsSource -Algorithm SHA256).Hash -eq (Get-FileHash -LiteralPath $DefaultsDest -Algorithm SHA256).Hash) {
    Add-Result 'Excludes defaults (FileSaveLog-Excludes.json)' 'already current' 'identical content'
}
else {
    Copy-Item -LiteralPath $DefaultsSource -Destination $DefaultsDest -Force
    Add-Result 'Excludes defaults (FileSaveLog-Excludes.json)' 'upgraded' 'shipped defaults replaced (kit updates always refresh this file)'
}

if (Test-Path -LiteralPath $UserExcludesDest) {
    Add-Result 'User excludes (FileSaveLog-Excludes.user.json)' 'preserved' 'existing user file is never overwritten'
}
else {
    $userExcludes = Get-Content -LiteralPath $TemplateSource -Raw | ConvertFrom-Json
    $userExcludes.selfPaths = @($InstallDir, $resolvedOutbox)
    $userExcludes | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $UserExcludesDest -Encoding utf8
    Add-Result 'User excludes (FileSaveLog-Excludes.user.json)' 'created' "from the template, selfPaths set to the install folder and the outbox"
}

# --------------------------------------------------------------------------
# 4. Config. Created on a fresh install; preserved exactly afterwards.
# --------------------------------------------------------------------------
$freshInstall = $false
if (Test-Path -LiteralPath $ConfigPath) {
    Add-Result 'Scanner config (config.json)' 'preserved' 'existing config kept exactly (roots, outbox, state paths are the user''s)'
}
else {
    $rootEntries = @()
    if ($Roots -and $Roots.Count -gt 0) {
        foreach ($entry in $Roots) {
            $parts = $entry -split '\|', 2
            $rootPath = $parts[0].Trim()
            $rootArea = if ($parts.Count -gt 1 -and -not [string]::IsNullOrWhiteSpace($parts[1])) { $parts[1].Trim() } else { Split-Path $rootPath -Leaf }
            $rootEntries += [ordered]@{ path = $rootPath; area = $rootArea }
        }
    }
    else {
        foreach ($pair in @(@('Documents', 'Documents'), @('Downloads', 'Downloads'), @('Desktop', 'Desktop'))) {
            $candidate = Join-Path $env:USERPROFILE $pair[0]
            if (Test-Path -LiteralPath $candidate) { $rootEntries += [ordered]@{ path = $candidate; area = $pair[1] } }
        }
    }
    if ($rootEntries.Count -eq 0) { throw 'No watched roots could be determined. Pass -Roots "Path|Area" entries from the setup interview.' }
    $config = [ordered]@{
        sourceName = $env:COMPUTERNAME
        roots      = $rootEntries
        outboxPath = $resolvedOutbox
        statePath  = $StatePath
        installDir = $InstallDir
    }
    $config | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $ConfigPath -Encoding utf8
    $freshInstall = $true
    Add-Result 'Scanner config (config.json)' 'created' "roots: $(($rootEntries | ForEach-Object { $_.path }) -join '; ')"
}

# --------------------------------------------------------------------------
# 5. Windowless-launch wrapper, generated with this machine's real
#    pwsh path and install folder (spec section 2c). Identical content
#    on a re-run is reported as already current.
# --------------------------------------------------------------------------
if (-not $PwshPath) {
    $pwshCommand = Get-Command pwsh.exe -ErrorAction SilentlyContinue
    if ($pwshCommand) { $PwshPath = $pwshCommand.Source }
    elseif (Test-Path -LiteralPath 'C:\Program Files\PowerShell\7\pwsh.exe') { $PwshPath = 'C:\Program Files\PowerShell\7\pwsh.exe' }
}
if (-not $PwshPath -or -not (Test-Path -LiteralPath $PwshPath)) {
    throw 'pwsh.exe (PowerShell 7) was not found. Install PowerShell 7, or pass -PwshPath with the path from the diagnostic report.'
}

function Write-Wrapper {
    # Writes one VBScript wrapper unless the content is already exact.
    param([string]$Dest, [string]$TargetScript, [string]$Component, [string]$Purpose)
    $lines = @(
        "' $Purpose",
        "' Launches a File Save Log script with no console window at all.",
        "' wscript.exe is a GUI-subsystem host, so it creates no window of",
        "' its own, and Shell.Run with window style 0 starts pwsh hidden",
        "' from the first moment, for the whole run. The third argument",
        "' (True) makes wscript wait until the script finishes, so Task",
        "' Scheduler still sees the real start and end of the run. The",
        "' script's exit code is passed back to Task Scheduler.",
        "' Generated by Install-FileSaveLog.ps1 with this machine's paths.",
        'Dim shell, cmd, rc',
        'Set shell = CreateObject("WScript.Shell")',
        ('cmd = """{0}"" -NoProfile -ExecutionPolicy Bypass -File ""{1}"""' -f $PwshPath, $TargetScript),
        'rc = shell.Run(cmd, 0, True)',
        'WScript.Quit rc'
    )
    $content = ($lines -join "`r`n") + "`r`n"
    if ((Test-Path -LiteralPath $Dest) -and ((Get-Content -LiteralPath $Dest -Raw) -eq $content)) {
        Add-Result $Component 'already current' $Dest
    }
    else {
        Set-Content -LiteralPath $Dest -Value $content -Encoding ascii -NoNewline
        Add-Result $Component 'installed' $Dest
    }
}

$wscriptPath  = Join-Path $env:SystemRoot 'System32\wscript.exe'
$useWrappers  = Test-Path -LiteralPath $wscriptPath
if (-not $useWrappers) { $wscriptPath = 'wscript.exe'; $useWrappers = [bool](Get-Command wscript.exe -ErrorAction SilentlyContinue) }
if ($useWrappers) {
    Write-Wrapper -Dest $ScannerVbsDest -TargetScript $ScannerDest -Component 'Scanner wrapper (Run-FileSaveLog-Hidden.vbs)' -Purpose 'Run-FileSaveLog-Hidden.vbs'
}
else {
    Add-Result 'Launch wrapper' 'fallback used' 'wscript.exe not found on this machine; the task uses the conhost.exe --headless fallback instead (spec section 2c)'
}

# --------------------------------------------------------------------------
# 6. Scheduled task. The identical definition on every run, registered
#    with -Force, so re-running changes nothing. Interactive logon,
#    Limited run level; never "run whether the user is logged on or
#    not" (spec section 2c: cloud drives may not be mounted outside
#    the user's session, and the failure would be silent).
# --------------------------------------------------------------------------
$userId    = "$env:USERDOMAIN\$env:USERNAME"
$principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Limited
$failures  = 0

function Register-FileSaveTask {
    param(
        [string]$TaskName,
        [string]$TargetScript,
        [string]$WrapperPath,
        [int]$RepeatMinutes,
        [string]$Description,
        [string]$Component
    )
    try {
        if ($useWrappers) {
            $action = New-ScheduledTaskAction -Execute $wscriptPath -Argument "`"$WrapperPath`""
        }
        else {
            $conhost = Join-Path $env:SystemRoot 'System32\conhost.exe'
            $action  = New-ScheduledTaskAction -Execute $conhost -Argument "--headless `"$PwshPath`" -NoProfile -ExecutionPolicy Bypass -File `"$TargetScript`""
        }
        $triggers = @(
            (New-ScheduledTaskTrigger -AtLogOn -User $userId),
            (New-ScheduledTaskTrigger -Once -At (Get-Date).Date -RepetitionInterval (New-TimeSpan -Minutes $RepeatMinutes) -RepetitionDuration (New-TimeSpan -Days 3650))
        )
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -Hidden -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Minutes 30)
        Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $triggers -Settings $settings -Principal $principal -Description $Description -Force | Out-Null
        $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop
        Add-Result $Component 'registered' "task state: $($task.State)"
    }
    catch {
        $script:failures++
        Add-Result $Component 'FAILED' $_.Exception.Message
    }
}

Register-FileSaveTask -TaskName $TaskName -TargetScript $ScannerDest -WrapperPath $ScannerVbsDest `
    -RepeatMinutes 15 -Component "Task $TaskName (logon + every 15 min)" `
    -Description 'File Save Log: scans the watched folders for saved files every 15 minutes and writes batch JSON to the outbox for the aggregator.'

# --------------------------------------------------------------------------
# 7. Baseline scan: fresh installs only. On a re-run the scheduled
#    task covers scanning, and skipping keeps a re-run change-free.
# --------------------------------------------------------------------------
if ($freshInstall -and -not $SkipBaselineScan) {
    try {
        $baselineOutput = (& $ScannerDest -ConfigPath $ConfigPath) -join ' '
        Add-Result 'Baseline scan' 'run' $baselineOutput
    }
    catch {
        $failures++
        Add-Result 'Baseline scan' 'FAILED' $_.Exception.Message
    }
}
elseif ($SkipBaselineScan) {
    Add-Result 'Baseline scan' 'skipped' '-SkipBaselineScan was passed'
}
else {
    Add-Result 'Baseline scan' 'skipped' 'existing install; the scheduled task covers scanning'
}

# --------------------------------------------------------------------------
# Summary
# --------------------------------------------------------------------------
Write-Host ''
Write-Host '================ File Save Log install summary ================'
foreach ($r in $results) {
    Write-Host ("{0,-58} {1}" -f $r.Component, $r.Outcome)
    if ($r.Detail) { Write-Host ("{0,-58} {1}" -f '', $r.Detail) }
}
Write-Host "Install folder : $InstallDir"
Write-Host "Outbox         : $resolvedOutbox"
if ($outboxIsFallback) {
    Write-Warning 'FALLBACK OUTBOX IN USE: no Drive sync folder was found on this machine. Batches wait in the local outbox above; they are NOT synced and the aggregator cannot merge them until a Drive sync folder exists, this installer is re-run (or config.json is corrected), and any waiting batches are moved into the Drive Ingest folder.'
}
Write-Host '================================================================='
if ($failures -gt 0) {
    Write-Warning "$failures component(s) FAILED; see the summary above."
    exit 1
}
exit 0
