#Requires -Version 7.0
<#
.SYNOPSIS
    File Save Log scanner (MyCommandCenter kit).

.DESCRIPTION
    Enumerates the watched roots from config.json (next to this script),
    compares file metadata (LastWriteTime + Length only) against the saved
    state file, and, when files were added or changed, writes one batch JSON
    file to the outbox folder for the central aggregator to merge.

    Batch format v1:
    {"source": "user-pc", "generated_at": "<ISO8601 with offset>",
     "events": [{"path": "...", "name": "...", "folder": "...",
                 "area": "Dev" | "OneDrive" | "Downloads",
                 "save_time": "<ISO8601 with offset>",
                 "size": <int>, "is_new": <bool>}]}

    IMPORTANT DESIGN RULES
    - This script NEVER opens, reads, hashes, or copies a watched file.
      It only looks at names, LastWriteTime, and Length (metadata). That is
      deliberate: reading a OneDrive Files On-Demand placeholder would force
      Windows to download (hydrate) it. Metadata access does not.
    - BASELINE RULE: if there is no usable state file, the state is
      initialized with every current file and events are emitted ONLY for
      files whose LastWriteTime date (local time) is today. Without this,
      the first run would report the entire drive as "saved today".
    - State is written atomically: write to a temp file, then Move-Item.
    - EXCLUSIONS ARE CONFIG-DRIVEN (2026-11-02): FileSaveLog-Excludes.json
      (shipped defaults, replaced on kit update) plus
      FileSaveLog-Excludes.user.json (the user's own rules, never
      overwritten), both next to this script unless config.json points
      elsewhere. If a file is missing or invalid, a built-in minimal
      safe set is used and a warning is written to
      FileSaveLog-Scanner.log next to this script. The scan never
      crashes and never excludes everything on a config error.

.NOTES
    Aggregation into "one entry per file per day" is the aggregator's job.
    This scanner simply reports every add/change it sees; it may run every
    15 minutes and report the same file several times in one day.
#>
[CmdletBinding()]
param(
    [string]$ConfigPath = (Join-Path $PSScriptRoot 'config.json')
)

$ErrorActionPreference = 'Continue'

# Kit script version marker. Install-FileSaveLog.ps1 reads this value in
# the packaged copy and in the installed copy and never replaces an
# installed script whose marker is newer (see the installer header).
# Raise it whenever this script changes in the kit.
$ScriptVersion = '1.0.0'

# --------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------
function Expand-ConfigPath {
    param([AllowEmptyString()][string]$PathText)
    if ([string]::IsNullOrWhiteSpace($PathText)) { return $PathText }
    return [System.Environment]::ExpandEnvironmentVariables($PathText)
}

function Test-PathUnderRoot {
    # True when $FullPath equals $Root or sits underneath it (case-insensitive).
    param([string]$FullPath, [string]$Root)
    if ([string]::IsNullOrWhiteSpace($Root)) { return $false }
    $rootFull = $Root.TrimEnd('\')
    if ($FullPath.Equals($rootFull, [System.StringComparison]::OrdinalIgnoreCase)) { return $true }
    return $FullPath.StartsWith($rootFull + '\', [System.StringComparison]::OrdinalIgnoreCase)
}

function Get-AreaForPath {
    # Fallback only, used if a config root is a plain string with no area.
    param([string]$PathText)
    if ($PathText -match 'OneDrive') { return 'OneDrive' }
    if ($PathText -match 'Downloads') { return 'Downloads' }
    return 'Dev'
}

# --------------------------------------------------------------------------
# Config-driven exclusions. Two JSON files, one design shared with the
# aggregator: shipped defaults + the user's own file. See the header.
# --------------------------------------------------------------------------
$script:ScannerLogPath = Join-Path $PSScriptRoot 'FileSaveLog-Scanner.log'

function Write-ScannerLog {
    param([string]$Message)
    try {
        $line = '{0} {1}' -f ([System.DateTimeOffset]::Now.ToString("yyyy-MM-dd'T'HH:mm:ss.fffzzz")), $Message
        Add-Content -LiteralPath $script:ScannerLogPath -Value $line -Encoding utf8 -ErrorAction Stop
    } catch { }
    Write-Warning $Message
}

function Get-MinimalExcludes {
    # Built-in fail-safe set, used for any config file that is missing
    # or invalid. Small on purpose: transient and lock artifacts only.
    return [ordered]@{
        extensions     = @('.tmp', '.temp', '.crdownload', '.partial', '.part', '.log')
        fileNames      = @('desktop.ini', 'Thumbs.db', '.DS_Store', '~$*')
        folderSegments = @('.git', 'node_modules', '__pycache__')
        segmentPairs   = @()
        selfPaths      = @()
        optional       = @{}
    }
}

function Read-ExcludesFile {
    param([string]$Path, [string]$Role)
    if (-not (Test-Path -LiteralPath $Path)) {
        Write-ScannerLog "File Save Log excludes: $Role file not found ($Path)"
        return $null
    }
    try {
        $parsed = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -AsHashtable -ErrorAction Stop
        if ($parsed -isnot [hashtable]) { throw 'top level is not a JSON object' }
        return $parsed
    }
    catch {
        Write-ScannerLog "File Save Log excludes: $Role file invalid ($Path): $($_.Exception.Message)"
        return $null
    }
}

function Merge-Excludes {
    param([System.Collections.IDictionary]$Into, [System.Collections.IDictionary]$From)
    foreach ($key in @('extensions', 'fileNames', 'folderSegments', 'selfPaths')) {
        foreach ($entry in @($From[$key])) {
            if ($null -ne $entry -and -not (@($Into[$key]) -contains [string]$entry)) {
                $Into[$key] = @($Into[$key]) + [string]$entry
            }
        }
    }
    foreach ($pair in @($From['segmentPairs'])) {
        if ($pair -is [System.Collections.IList] -and $pair.Count -eq 2) {
            $Into['segmentPairs'] = @($Into['segmentPairs']) + , @([string]$pair[0], [string]$pair[1])
        }
    }
}

function Get-Excludes {
    param([string]$DefaultsPath, [string]$UserPath)
    $merged = Get-MinimalExcludes
    $defaults = Read-ExcludesFile -Path $DefaultsPath -Role 'defaults'
    if ($null -ne $defaults) {
        # Defaults replace the minimal set wholesale when readable.
        $merged = Get-MinimalExcludes
        $merged['extensions'] = @(); $merged['fileNames'] = @()
        $merged['folderSegments'] = @(); $merged['segmentPairs'] = @(); $merged['selfPaths'] = @()
        Merge-Excludes -Into $merged -From $defaults
        if ($defaults['optional'] -is [hashtable]) { $merged['optional'] = $defaults['optional'] }
    }
    else {
        Write-ScannerLog 'File Save Log excludes: using the built-in minimal set for the defaults'
    }
    $user = Read-ExcludesFile -Path $UserPath -Role 'user'
    if ($null -ne $user) {
        Merge-Excludes -Into $merged -From $user
        foreach ($key in @($user['enableOptional'])) {
            if ($key -and $merged['optional'] -is [hashtable] -and $merged['optional'].ContainsKey([string]$key)) {
                Merge-Excludes -Into $merged -From $merged['optional'][[string]$key]
            }
            elseif ($key) {
                Write-ScannerLog "File Save Log excludes: enableOptional names an unknown group: $key"
            }
        }
    }
    # Expand environment variables in self paths once, up front.
    $merged['selfPaths'] = @($merged['selfPaths'] | ForEach-Object { Expand-ConfigPath ([string]$_) })
    return $merged
}

function Test-FileExcluded {
    # True when the config rules exclude this file. Case-insensitive.
    # Folder segments and pairs consider folder segments only, never
    # the file name itself; pairs require direct adjacency.
    param([string]$FullPath, [string]$Name, [System.Collections.IDictionary]$Excludes)
    $lowerName = $Name.ToLowerInvariant()
    foreach ($entry in @($Excludes['extensions'])) {
        $e = ([string]$entry).ToLowerInvariant()
        if ($e.StartsWith('.')) {
            if ([System.IO.Path]::GetExtension($Name).ToLowerInvariant() -eq $e) { return $true }
        }
        elseif ($lowerName.EndsWith($e)) { return $true }
    }
    foreach ($pattern in @($Excludes['fileNames'])) {
        if ($lowerName -like ([string]$pattern).ToLowerInvariant()) { return $true }
    }
    $segments = @($FullPath -split '[\\/]' | Where-Object { $_ -ne '' })
    if ($segments.Count -ge 2) {
        $folders = $segments[0..($segments.Count - 2)]
        foreach ($seg in $folders) {
            if (@($Excludes['folderSegments']) -contains $seg) { return $true }
        }
        for ($i = 0; $i -lt ($folders.Count - 1); $i++) {
            foreach ($pair in @($Excludes['segmentPairs'])) {
                if ($folders[$i] -ieq ([string]$pair[0]) -and $folders[$i + 1] -ieq ([string]$pair[1])) { return $true }
            }
        }
    }
    foreach ($self in @($Excludes['selfPaths'])) {
        if (Test-PathUnderRoot -FullPath $FullPath -Root ([string]$self)) { return $true }
    }
    return $false
}

# --------------------------------------------------------------------------
# Load config
# --------------------------------------------------------------------------
if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "File Save Log config not found: $ConfigPath. Run Install-FileSaveLog.ps1 first."
}
$config = $null
try {
    $config = Get-Content -LiteralPath $ConfigPath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
}
catch {
    Write-Error "File Save Log config could not be read or parsed: $ConfigPath ($($_.Exception.Message)). Fix config.json and run the scan again. No state or batch files were written."
    exit 1
}

$roots = @()
foreach ($r in @($config.roots)) {
    if ($r -is [string]) {
        $rootPath = Expand-ConfigPath $r
        if (-not [string]::IsNullOrWhiteSpace($rootPath)) {
            $roots += [pscustomobject]@{ Path = $rootPath; Area = (Get-AreaForPath $r) }
        }
    }
    else {
        $rootPath = Expand-ConfigPath ([string]$r.path)
        if (-not [string]::IsNullOrWhiteSpace($rootPath)) {
            $roots += [pscustomobject]@{ Path = $rootPath; Area = ([string]$r.area) }
        }
    }
}
if ($roots.Count -eq 0) {
    Write-Error "File Save Log config has no roots: $ConfigPath. Fix config.json and run the scan again. No state or batch files were written."
    exit 1
}

$outboxPath  = Expand-ConfigPath ([string]$config.outboxPath)
if ([string]::IsNullOrWhiteSpace($outboxPath)) { $outboxPath = Join-Path $PSScriptRoot 'outbox' }

$statePath   = Expand-ConfigPath ([string]$config.statePath)
if ([string]::IsNullOrWhiteSpace($statePath)) { $statePath = Join-Path $PSScriptRoot 'state.json' }

$installDir  = Expand-ConfigPath ([string]$config.installDir)
if ([string]::IsNullOrWhiteSpace($installDir)) { $installDir = $PSScriptRoot }

$excludesDefaultsPath = Expand-ConfigPath ([string]$config.excludesDefaultsPath)
if ([string]::IsNullOrWhiteSpace($excludesDefaultsPath)) { $excludesDefaultsPath = Join-Path $PSScriptRoot 'FileSaveLog-Excludes.json' }
$excludesUserPath = Expand-ConfigPath ([string]$config.excludesUserPath)
if ([string]::IsNullOrWhiteSpace($excludesUserPath)) { $excludesUserPath = Join-Path $PSScriptRoot 'FileSaveLog-Excludes.user.json' }
$excludes = Get-Excludes -DefaultsPath $excludesDefaultsPath -UserPath $excludesUserPath

$stateDir = Split-Path -Parent $statePath
if (-not (Test-Path -LiteralPath $stateDir)) {
    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
}

# --------------------------------------------------------------------------
# Load state (path -> @{ mtimeTicks; size }). Missing or unreadable = baseline.
# mtimeTicks is an Int64 (LastWriteTimeUtc.Ticks), NOT an ISO string: PowerShell 7
# ConvertFrom-Json coerces ISO date strings into DateTime objects on load, which
# broke string comparison and made every file look changed (fixed 2026-10-22).
# --------------------------------------------------------------------------
$oldState   = @{}
$isBaseline = $true
if (Test-Path -LiteralPath $statePath) {
    try {
        $parsed = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json -AsHashtable
        if ($parsed -is [hashtable]) {
            $oldState   = $parsed
            $isBaseline = $false
        }
        else {
            Write-Warning "State file did not contain a mapping, treating this run as a baseline: $statePath"
        }
    }
    catch {
        Write-Warning "State file unreadable ($($_.Exception.Message)), treating this run as a baseline: $statePath"
        $oldState = @{}
    }
}

$batchSource = [string]$config.sourceName
if ([string]::IsNullOrWhiteSpace($batchSource)) { $batchSource = $env:COMPUTERNAME }

$today  = (Get-Date).Date
$events = [System.Collections.Generic.List[object]]::new()
$newState = @{}

# --------------------------------------------------------------------------
# Enumerate each root. Metadata only: names, LastWriteTime, Length.
# Get-ChildItem does not open file contents and does not hydrate OneDrive
# placeholders. Per-file errors are caught so one bad file never stops a scan.
# --------------------------------------------------------------------------
foreach ($root in $roots) {
    $rootPath = $root.Path
    if (-not (Test-Path -LiteralPath $rootPath)) {
        Write-Warning "Watched root not found, skipping: $rootPath"
        continue
    }

    $files = $null
    try {
        $files = Get-ChildItem -LiteralPath $rootPath -Recurse -File -ErrorAction SilentlyContinue
    }
    catch {
        Write-Warning "Could not enumerate root $rootPath : $($_.Exception.Message)"
        continue
    }

    foreach ($file in $files) {
        try {
            $fullPath = $file.FullName
            $name     = $file.Name

            # --- Exclusions (config-driven) ----------------------------------
            if (Test-PathUnderRoot -FullPath $fullPath -Root $installDir) { continue }
            if (Test-PathUnderRoot -FullPath $fullPath -Root $outboxPath) { continue }
            if ($fullPath.Equals($statePath, [System.StringComparison]::OrdinalIgnoreCase)) { continue }
            if (Test-FileExcluded -FullPath $fullPath -Name $name -Excludes $excludes) { continue }

            # --- Metadata only from here on. No content is ever read. -------
            $mtimeTicks   = [int64]$file.LastWriteTimeUtc.Ticks
            $size         = [int64]$file.Length

            $newState[$fullPath] = @{ mtimeTicks = $mtimeTicks; size = $size }

            # --- Decide whether this file is an event -----------------------
            $emit = $false
            $isNew = $true
            if ($isBaseline) {
                # Baseline: state is being seeded, so report only today's files.
                if ($file.LastWriteTime.Date -eq $today) { $emit = $true; $isNew = $true }
            }
            else {
                $previous = $null
                if ($oldState.ContainsKey($fullPath)) { $previous = $oldState[$fullPath] }
                $isNew = ($null -eq $previous)
                if ($isNew) {
                    $emit = $true
                }
                elseif ( ([int64]$previous.mtimeTicks -ne $mtimeTicks) -or ([int64]$previous.size -ne $size) ) {
                    $emit = $true
                }
            }

            if ($emit) {
                $saveTime = ([System.DateTimeOffset]$file.LastWriteTime).ToString("yyyy-MM-dd'T'HH:mm:ss.fffzzz")
                $events.Add([ordered]@{
                    path      = $fullPath
                    name      = $name
                    folder    = $file.DirectoryName
                    area      = $root.Area
                    save_time = $saveTime
                    size      = $size
                    is_new    = [bool]$isNew
                })
            }
        }
        catch {
            # A file vanished mid-scan, is locked, is a broken placeholder, etc.
            # Skip it and keep going; it will be picked up on a later scan.
            continue
        }
    }
}

# --------------------------------------------------------------------------
# Write the batch file (only when there are events)
# --------------------------------------------------------------------------
$batchName = $null
if ($events.Count -gt 0) {
    if (-not (Test-Path -LiteralPath $outboxPath)) {
        New-Item -ItemType Directory -Path $outboxPath -Force | Out-Null
    }
    # Keep the exact name format; if a same-second file exists, wait for the
    # next second rather than inventing a different name pattern.
    $attempts = 0
    do {
        $batchName = 'FSL-Batch-{0}-{1}.json' -f $batchSource, (Get-Date -Format 'yyyyMMdd-HHmmss')
        $batchPath = Join-Path $outboxPath $batchName
        if (Test-Path -LiteralPath $batchPath) { Start-Sleep -Seconds 1 }
        $attempts++
    } while ((Test-Path -LiteralPath $batchPath) -and $attempts -lt 5)

    $batch = [ordered]@{
        source       = $batchSource.ToLowerInvariant()
        generated_at = [System.DateTimeOffset]::Now.ToString("yyyy-MM-dd'T'HH:mm:ss.fffzzz")
        events       = @($events)
    }
    $batch | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $batchPath -Encoding utf8
}

# --------------------------------------------------------------------------
# Update state atomically: write temp file, then replace in one move.
# --------------------------------------------------------------------------
$tempStatePath = "$statePath.tmp"
$newState | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath $tempStatePath -Encoding utf8
Move-Item -LiteralPath $tempStatePath -Destination $statePath -Force

# --------------------------------------------------------------------------
# One-line summary
# --------------------------------------------------------------------------
if ($batchName) {
    Write-Output "FileSaveLog scan: $($events.Count) event(s); batch $batchName written to $outboxPath; state entries: $($newState.Count); baseline: $isBaseline"
}
else {
    Write-Output "FileSaveLog scan: 0 event(s); no batch written; state entries: $($newState.Count); baseline: $isBaseline"
}
