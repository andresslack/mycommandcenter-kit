<#
.SYNOPSIS
    MyCommandCenter File Save Log pre-install diagnostic for your main computer.

.DESCRIPTION
    Run this BEFORE installing the File Save Log module. It checks, and
    only checks, whether this computer meets the module's minimum
    requirements: Windows version, PowerShell 7, the windowless launch
    the scanner needs, Task Scheduler, the folders you want watched,
    and your log destination.

    It installs nothing, changes no settings, and leaves nothing
    running. The only things it writes are small test files that it
    deletes again in the same run (a folder write test, and one
    temporary scheduled task that it removes immediately), plus the
    report file described below.

    Scope, stated plainly: the core MyCommandCenter board, the Email
    Brief, and the AI Bridge do not need any of this. A failed check
    here does not block your board. It means the File Save Log module
    should be fixed first or parked, exactly as the kit's parking rule
    describes.

    The report: when it finishes, this script saves a plain text
    report next to itself (FileSaveLog-PreInstall-Report with a
    date and time in the name) and shows the same text on screen.
    Paste that report into your own Muse conversation and say
    "Here is my pre-install diagnostic report." Your Muse will read
    the results and either proceed or park the module, per the kit.

    Privacy: the report contains your user name, your computer name,
    and your folder paths, because your Muse needs the real paths to
    set the scanner up. Paste it only into your own Muse. Send it to
    no one else.

    This script runs in the Windows PowerShell that ships with
    Windows (5.1) on purpose, so it works even on a computer that does
    not have PowerShell 7 yet. Checking for PowerShell 7 is one of
    its jobs, so it must not require PowerShell 7 itself.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File .\Check-FileSaveLogRequirements.ps1

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File .\Check-FileSaveLogRequirements.ps1 -Folders "C:\Users\Me\Documents;C:\Users\Me\Downloads" -LogDestination "G:\My Drive\File Save Log"

.PARAMETER Folders
    The folders you plan to have watched. If you do not pass any, the
    script checks the usual defaults: Documents, Downloads, Desktop.
    Separate several folders with semicolons inside one quoted string,
    as in the second example above. That form survives being launched
    from another PowerShell window, where a comma separated list can
    be split apart at the spaces inside folder names before this
    script ever sees it (learned on the first live run, 2026-10-30).

.PARAMETER LogDestination
    Optional. The folder where the full log will live (for example a
    Drive folder). If passed, it is checked for existence and write
    access. If not passed, the script reports which cloud folders and
    sync apps it can see, as information for the setup interview.

.PARAMETER SkipTaskCreationTest
    Skips the temporary scheduled task test. The Task Scheduler check
    is then read-only, and the report says the creation test was
    skipped, so your Muse knows that requirement is unverified.
#>
[CmdletBinding()]
param(
    [string[]]$Folders,
    [string]$LogDestination,
    [switch]$SkipTaskCreationTest,
    [string]$ReportPath
)

$ErrorActionPreference = 'Continue'
$scriptVersion = '0.2'

$script:Results = New-Object System.Collections.ArrayList
$script:ReportLines = New-Object System.Collections.ArrayList

function Write-ReportLine {
    param([string]$Text = '')
    [void]$script:ReportLines.Add($Text)
    Write-Host $Text
}

function Add-Result {
    param(
        [Parameter(Mandatory = $true)][ValidateSet('PASS', 'WARN', 'FAIL', 'INFO', 'SKIP')][string]$Status,
        [Parameter(Mandatory = $true)][string]$Check,
        [Parameter(Mandatory = $true)][string]$Detail,
        [string]$NextStep = ''
    )
    [void]$script:Results.Add([pscustomobject]@{ Status = $Status; Check = $Check; Detail = $Detail; NextStep = $NextStep })
    Write-ReportLine ("[{0}] {1}: {2}" -f $Status, $Check, $Detail)
    if ($NextStep -ne '') { Write-ReportLine ("       Next step: {0}" -f $NextStep) }
}

function Test-FolderAccess {
    # Returns 'ok', 'missing', 'noread', or 'nowrite' for a folder path.
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) { return 'missing' }
    try { $null = Get-ChildItem -LiteralPath $Path -ErrorAction Stop | Select-Object -First 1 }
    catch { return 'noread' }
    $testFile = Join-Path $Path ('mcc-preinstall-write-test-{0}.tmp' -f ([guid]::NewGuid().ToString('N')))
    try {
        Set-Content -LiteralPath $testFile -Value 'MyCommandCenter pre-install write test. Safe to delete.' -ErrorAction Stop
        Remove-Item -LiteralPath $testFile -Force -ErrorAction Stop
    }
    catch {
        if (Test-Path -LiteralPath $testFile) { Remove-Item -LiteralPath $testFile -Force -ErrorAction SilentlyContinue }
        return 'nowrite'
    }
    return 'ok'
}

# ---------------------------------------------------------------------------
# Header
# ---------------------------------------------------------------------------
$now = Get-Date
Write-ReportLine 'MyCommandCenter File Save Log pre-install diagnostic report'
Write-ReportLine ("Script version : {0}" -f $scriptVersion)
Write-ReportLine ("Run at         : {0}" -f $now.ToString('yyyy-MM-dd HH:mm:ss zzz'))
Write-ReportLine ("Computer       : {0}" -f $env:COMPUTERNAME)
Write-ReportLine ("User           : {0}\{1}" -f $env:USERDOMAIN, $env:USERNAME)
Write-ReportLine 'Scope          : the File Save Log module only. The core board, Email Brief, and AI Bridge do not require any check below.'
Write-ReportLine 'Other modules  : this diagnostic deliberately does not test the rest of the install, because'
Write-ReportLine '                 those requirements are not on this computer. They are checked where they live:'
Write-ReportLine '                 core board, in install step 1 with your Muse, which confirms your Muse'
Write-ReportLine '                 account and the kit files before building; Email Brief, in install step 3,'
Write-ReportLine '                 when you connect each email account inside your Muse; AI Bridge, in'
Write-ReportLine '                 install step 4, optional, which needs a Google account reached through'
Write-ReportLine '                 your Muse; daily reviews, in install step 5 part A, which need only your'
Write-ReportLine '                 times and habit and have no machine requirements at all.'
Write-ReportLine ''

# ---------------------------------------------------------------------------
# 1. Windows version
# ---------------------------------------------------------------------------
$os = $null
$build = 0
try { $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop } catch { $os = $null }
if ($null -eq $os) {
    Add-Result 'FAIL' 'Windows version' 'Could not read the Windows version from this machine.' 'Run this script on the Windows computer itself, signed in as yourself.'
}
else {
    $build = [int]$os.BuildNumber
    $winName = $os.Caption
    if ($build -ge 22000) {
        Add-Result 'PASS' 'Windows version' ("{0}, build {1}, {2}. This is Windows 11, so the headless fallback launch is available if it is ever needed." -f $winName, $build, $os.OSArchitecture)
    }
    elseif ($build -ge 19041) {
        Add-Result 'PASS' 'Windows version' ("{0}, build {1}, {2}. This is Windows 10. Note: there is no headless fallback launch on Windows 10, so the windowless check below must pass as it stands." -f $winName, $build, $os.OSArchitecture)
    }
    elseif ($build -ge 10240) {
        Add-Result 'WARN' 'Windows version' ("{0}, build {1}. This Windows 10 build is older than the kit targets. The module may work, but update Windows first if you can." -f $winName, $build) 'Consider updating Windows, then run this diagnostic again.'
    }
    else {
        Add-Result 'FAIL' 'Windows version' ("Build {0}. This is older than Windows 10, which this module does not support." -f $build) 'Install MyCommandCenter without the File Save Log module on this machine, or use a newer main computer.'
    }
}
$isWindows11 = ($build -ge 22000)

# ---------------------------------------------------------------------------
# 2. Interactive session (the scanner must run inside your logged-on session)
# ---------------------------------------------------------------------------
$sessionId = 0
try { $sessionId = (Get-Process -Id $PID -ErrorAction Stop).SessionId } catch { $sessionId = 0 }
if ([Environment]::UserInteractive -and $sessionId -ne 0) {
    Add-Result 'PASS' 'Logged-on session' ("Running interactively as {0} in session {1}. The scanner task can run inside this session, which is a requirement, not a preference: outside it, cloud drives may not be mounted." -f $env:USERNAME, $sessionId)
}
else {
    Add-Result 'FAIL' 'Logged-on session' 'This script is not running in an interactive desktop session (session 0 or a non interactive host). Results for the windowless and cloud checks are not trustworthy from here.' 'Run the diagnostic again from a normal PowerShell window on your desktop, signed in as yourself.'
}

# ---------------------------------------------------------------------------
# 3. PowerShell: this script runs on 5.1 by design; the scanner needs 7
# ---------------------------------------------------------------------------
Add-Result 'INFO' 'This diagnostic is running on' ("Windows PowerShell {0} at {1}. Running on the built-in version is expected and correct." -f $PSVersionTable.PSVersion.ToString(), (Get-Process -Id $PID).Path)
$pwshPath = $null
$pwshCmd = Get-Command pwsh.exe -ErrorAction SilentlyContinue
if ($pwshCmd) { $pwshPath = $pwshCmd.Source }
if (($null -eq $pwshPath) -and (Test-Path -LiteralPath 'C:\Program Files\PowerShell\7\pwsh.exe')) { $pwshPath = 'C:\Program Files\PowerShell\7\pwsh.exe' }
if ($null -eq $pwshPath) {
    Add-Result 'FAIL' 'PowerShell 7' 'pwsh.exe was not found. The File Save Log scanner requires PowerShell 7 or later, and the built-in Windows PowerShell 5.1 is not enough for the scanner (it is enough for this diagnostic).' 'Install PowerShell 7 from Microsoft (the free MSI or the Microsoft Store app), then run this diagnostic again. Your Muse can walk you through it. The rest of MyCommandCenter is unaffected.'
}
else {
    $pwshVersionText = ''
    try { $pwshVersionText = (& $pwshPath -NoProfile -Command '$PSVersionTable.PSVersion.ToString()' 2>$null | Out-String).Trim() } catch { $pwshVersionText = '' }
    if ($pwshVersionText -match '^(\d+)\.') {
        $pwshMajor = [int]$Matches[1]
        if ($pwshMajor -ge 7) {
            Add-Result 'PASS' 'PowerShell 7' ("Found version {0} at {1}. Record this exact path for the scanner setup; paths from another computer must not be copied." -f $pwshVersionText, $pwshPath)
        }
        else {
            Add-Result 'FAIL' 'PowerShell 7' ("pwsh.exe at {0} reports version {1}, which is older than 7." -f $pwshPath, $pwshVersionText) 'Update PowerShell to version 7 or later, then run this diagnostic again.'
        }
    }
    else {
        Add-Result 'WARN' 'PowerShell 7' ("pwsh.exe exists at {0} but its version could not be read." -f $pwshPath) 'Tell your Muse this line verbatim; it may mean the PowerShell 7 install is damaged.'
    }
}

# ---------------------------------------------------------------------------
# 4. Windowless launch: script host present, not disabled, and a live test
#    The scanner must show no window at all. The test below uses the exact
#    pattern the scanner uses: wscript.exe runs a VBScript wrapper, which
#    starts a process with window style 0 (hidden from creation), waits for
#    it, and returns its exit code. The test target does nothing except
#    exit with the code 42, so a correct result file proves three things at
#    once: script host runs, hidden launch works, and exit codes come back.
# ---------------------------------------------------------------------------
$systemRootPath = $env:SystemRoot
if (($null -eq $systemRootPath) -or ($systemRootPath -eq '')) { $systemRootPath = 'C:\Windows' }
$wscriptPath = Join-Path $systemRootPath 'System32\wscript.exe'
$conhostPath = Join-Path $systemRootPath 'System32\conhost.exe'
$fallbackAvailable = ($isWindows11 -and (Test-Path -LiteralPath $conhostPath))
if ($fallbackAvailable) {
    Add-Result 'INFO' 'Headless fallback' 'conhost.exe is present on this Windows 11 machine, so the fallback windowless launch (conhost --headless) is available if script host is ever blocked.'
}
else {
    Add-Result 'INFO' 'Headless fallback' 'Not available on this machine (it needs Windows 11). If the script host test below fails, there is no fallback and the module should be parked.'
}

$wshDisabled = $false
foreach ($hive in @('HKCU:\Software\Microsoft\Windows Script Host\Settings', 'HKLM:\Software\Microsoft\Windows Script Host\Settings')) {
    try {
        $val = (Get-ItemProperty -LiteralPath $hive -Name Enabled -ErrorAction Stop).Enabled
        if ($val -eq 0) { $wshDisabled = $true }
    }
    catch { }
}

if (-not (Test-Path -LiteralPath $wscriptPath)) {
    if ($fallbackAvailable) {
        Add-Result 'WARN' 'Windowless launch (script host)' 'wscript.exe was not found. The preferred windowless launch cannot be used, but the Windows 11 headless fallback is available.' 'Tell your Muse; setup should use the fallback launch and verify it with you watching the desktop.'
    }
    else {
        Add-Result 'FAIL' 'Windowless launch (script host)' 'wscript.exe was not found, and no fallback is available on this machine. A scanner window would appear every 15 minutes, which the kit treats as a setup failure.' 'Park the File Save Log module. The rest of MyCommandCenter is unaffected.'
    }
}
elseif ($wshDisabled) {
    if ($fallbackAvailable) {
        Add-Result 'WARN' 'Windowless launch (script host)' 'Windows Script Host is disabled by a policy setting on this machine (Enabled = 0). That is common on employer or school managed machines. The Windows 11 headless fallback is available instead.' 'Tell your Muse; do not change policy settings yourself if this is a managed machine. Setup should use the fallback launch.'
    }
    else {
        Add-Result 'FAIL' 'Windowless launch (script host)' 'Windows Script Host is disabled by a policy setting on this machine (Enabled = 0), and no fallback is available. That is common on employer or school managed machines.' 'If this is a managed machine, ask your IT team whether script host may be enabled; otherwise park the File Save Log module.'
    }
}
else {
    $testDir = Join-Path ([System.IO.Path]::GetTempPath()) ('mcc-preinstall-{0}' -f ([guid]::NewGuid().ToString('N')))
    $testOutcome = 'error'
    $testDetail = ''
    try {
        New-Item -ItemType Directory -Path $testDir -Force | Out-Null
        $resultFile = Join-Path $testDir 'result.txt'
        $vbsFile = Join-Path $testDir 'wrapper-test.vbs'
        $vbsTemplate = @'
Dim shell, rc, fso, f
Set shell = CreateObject("WScript.Shell")
rc = shell.Run("cmd.exe /c exit 42", 0, True)
Set fso = CreateObject("Scripting.FileSystemObject")
Set f = fso.CreateTextFile("__RESULT__", True)
f.Write CStr(rc)
f.Close
WScript.Quit 0
'@
        $vbsContent = $vbsTemplate.Replace('__RESULT__', $resultFile)
        Set-Content -LiteralPath $vbsFile -Value $vbsContent -Encoding Ascii
        $proc = Start-Process -FilePath $wscriptPath -ArgumentList ('"{0}"' -f $vbsFile) -PassThru -ErrorAction Stop
        if (-not $proc.WaitForExit(30000)) {
            try { $proc.Kill() } catch { }
            $testOutcome = 'timeout'
        }
        elseif (Test-Path -LiteralPath $resultFile) {
            $got = (Get-Content -LiteralPath $resultFile -Raw).Trim()
            if ($got -eq '42') { $testOutcome = 'ok' }
            else { $testOutcome = 'wrongcode'; $testDetail = $got }
        }
        else { $testOutcome = 'noresult' }
    }
    catch { $testOutcome = 'error'; $testDetail = $_.Exception.Message }
    finally {
        if (Test-Path -LiteralPath $testDir) { Remove-Item -LiteralPath $testDir -Recurse -Force -ErrorAction SilentlyContinue }
    }

    if ($testOutcome -eq 'ok') {
        Add-Result 'PASS' 'Windowless launch (script host)' 'Live test passed: wscript.exe ran the wrapper pattern, launched a process hidden with window style 0, waited for it, and returned its exit code (42) exactly. No window was created. This is the launch the scanner will use.'
    }
    elseif ($fallbackAvailable) {
        Add-Result 'WARN' 'Windowless launch (script host)' ("Live test did not pass (outcome: {0}). The Windows 11 headless fallback is available instead." -f $testOutcome) 'Tell your Muse, including this outcome word. Setup should use the fallback launch, or park the module if the fallback also fails. Security software blocking the test is a common cause; if yours prompted you, that prompt is the likely explanation.'
    }
    else {
        Add-Result 'FAIL' 'Windowless launch (script host)' ("Live test did not pass (outcome: {0}), and no fallback is available on this machine. A common cause is security software blocking a script host launching a hidden process, because the pattern resembles malware." -f $testOutcome) 'If your security software prompted you, you may allow the test and run this diagnostic once more. If it still fails, park the File Save Log module rather than accepting a visible scanner window.'
    }
}

# ---------------------------------------------------------------------------
# 5. Task Scheduler: service running, and (unless skipped) a real
#    create-and-remove test under your own account
# ---------------------------------------------------------------------------
$schedService = Get-Service -Name Schedule -ErrorAction SilentlyContinue
if ($null -eq $schedService) {
    Add-Result 'FAIL' 'Task Scheduler service' 'The Task Scheduler service was not found on this machine.' 'Park the File Save Log module on this machine.'
}
elseif ($schedService.Status -ne 'Running') {
    Add-Result 'WARN' 'Task Scheduler service' ("The service exists but its status is {0}. A scanner task cannot run reliably unless it is running." -f $schedService.Status) 'Tell your Muse; on a managed machine this may be an IT setting.'
}
else {
    Add-Result 'PASS' 'Task Scheduler service' 'Running.'
}

if ($SkipTaskCreationTest) {
    Add-Result 'SKIP' 'Task creation test' 'Skipped because -SkipTaskCreationTest was used. Whether you may create a scheduled task under your own account is therefore unverified, and setup may still fail at this requirement.' 'Run this diagnostic again without the switch, or let setup discover it and park the module if it fails.'
}
else {
    $testTaskName = 'MyCommandCenter-PreInstall-Test'
    $taskCreated = $false
    try {
        $testAction = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument '/c exit 0' -ErrorAction Stop
        $testTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddDays(7) -ErrorAction Stop
        $testPrincipal = New-ScheduledTaskPrincipal -UserId ("{0}\{1}" -f $env:USERDOMAIN, $env:USERNAME) -LogonType Interactive -RunLevel Limited -ErrorAction Stop
        Register-ScheduledTask -TaskName $testTaskName -Action $testAction -Trigger $testTrigger -Principal $testPrincipal -Description 'Temporary test task created by the MyCommandCenter File Save Log pre-install diagnostic. It removes itself from your records when the diagnostic deletes it seconds later; it never runs.' -Force -ErrorAction Stop | Out-Null
        $taskCreated = $true
        $readBack = Get-ScheduledTask -TaskName $testTaskName -ErrorAction Stop
        if ($readBack) {
            Add-Result 'PASS' 'Task creation test' 'A temporary scheduled task was created under your account (interactive, limited), read back, and deleted. The real scanner task uses the same permissions, so this requirement is verified, not assumed.'
        }
    }
    catch {
        Add-Result 'FAIL' 'Task creation test' ("Creating a scheduled task under your own account failed: {0}" -f $_.Exception.Message) 'On a managed machine this is usually a policy; ask IT, or park the File Save Log module. Do not try to work around a workplace policy.'
    }
    finally {
        if ($taskCreated) { Unregister-ScheduledTask -TaskName $testTaskName -Confirm:$false -ErrorAction SilentlyContinue }
    }
}

# ---------------------------------------------------------------------------
# 6. Watched folders: exist, readable, writable
# ---------------------------------------------------------------------------
# Accept folders as one semicolon separated string as well as an array (see
# the -Folders help above for why the string form is the reliable one).
if ($null -ne $Folders) {
    $Folders = @($Folders | ForEach-Object { $_ -split ';' } | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' })
}
$foldersSpecified = ($null -ne $Folders -and $Folders.Count -gt 0)
if (-not $foldersSpecified) {
    $docsPath = [Environment]::GetFolderPath('MyDocuments')
    $deskPath = [Environment]::GetFolderPath('Desktop')
    $downPath = ''
    if (($null -ne $env:USERPROFILE) -and ($env:USERPROFILE -ne '')) { $downPath = Join-Path $env:USERPROFILE 'Downloads' }
    $Folders = @($docsPath, $downPath, $deskPath) | Where-Object { $_ -ne '' }
    Write-ReportLine 'No -Folders were passed, so the standard folders are being checked: Documents, Downloads, Desktop.'
    Write-ReportLine 'At setup you will choose your real folders; rerun this diagnostic with -Folders if yours differ.'
    Write-ReportLine ''
}
foreach ($folder in $Folders) {
    $access = Test-FolderAccess -Path $folder
    $label = "Watched folder: {0}" -f $folder
    if ($access -eq 'ok') {
        Add-Result 'PASS' $label 'Exists, can be read, and a test file could be written and deleted. Record this exact path for setup.'
    }
    elseif ($access -eq 'missing') {
        if ($foldersSpecified) {
            Add-Result 'FAIL' $label 'This folder does not exist on this machine.' 'Check the path for a typo, or pick a different folder at setup and rerun with the corrected -Folders list.'
        }
        else {
            Add-Result 'WARN' $label 'This standard folder does not exist here (it may be redirected to a cloud location under a different path). Not a failure, just use your real folders at setup.'
        }
    }
    elseif ($access -eq 'noread') {
        Add-Result 'FAIL' $label 'The folder exists but could not be read with your permissions.' 'The scanner runs as you, so it would miss these files silently. Pick another folder, or ask whoever manages this machine about read access.'
    }
    else {
        Add-Result 'FAIL' $label 'The folder can be read but a test file could not be written and deleted.' 'The scanner needs to write its state near its own files, not in your work folders, so tell your Muse this result; it may still be workable, but it must be understood before setup, not after.'
    }
}

# ---------------------------------------------------------------------------
# 7. Log destination and cloud visibility
# ---------------------------------------------------------------------------
if (($null -ne $LogDestination) -and ($LogDestination -ne '')) {
    $destAccess = Test-FolderAccess -Path $LogDestination
    if ($destAccess -eq 'ok') {
        Add-Result 'PASS' 'Log destination' ("{0} exists, can be read, and can be written. Record this exact path for setup." -f $LogDestination)
    }
    elseif ($destAccess -eq 'missing') {
        Add-Result 'FAIL' 'Log destination' ("{0} does not exist on this machine. If it is a cloud folder, the usual cause is that the sync app is not running in this session, or uses a different drive letter or folder on this machine." -f $LogDestination) 'Open your sync app, confirm the folder is visible in File Explorer, note its real path, and run this diagnostic again with that path.'
    }
    else {
        Add-Result 'FAIL' 'Log destination' ("{0} could not be fully accessed (result: {1})." -f $LogDestination, $destAccess) 'Tell your Muse; choosing a local file for the log instead is a valid setup choice.'
    }
}
else {
    Write-ReportLine ''
    Write-ReportLine 'No -LogDestination was passed. The following is information for your setup interview, not a pass or fail:'
    $odPaths = @()
    foreach ($odVar in @('OneDrive', 'OneDriveConsumer', 'OneDriveCommercial')) {
        $odVal = [Environment]::GetEnvironmentVariable($odVar)
        if (($null -ne $odVal) -and ($odVal -ne '')) { $odPaths += ("{0} = {1} (exists: {2})" -f $odVar, $odVal, (Test-Path -LiteralPath $odVal)) }
    }
    if ($odPaths.Count -gt 0) { Add-Result 'INFO' 'OneDrive as seen from this session' ($odPaths -join '; ') }
    else { Add-Result 'INFO' 'OneDrive as seen from this session' 'No OneDrive folder variables found. If you use OneDrive, it may not be signed in or running in this session.' }

    $gdriveNotes = @()
    $gfs = Get-Process -Name 'GoogleDriveFS' -ErrorAction SilentlyContinue
    if ($gfs) { $gdriveNotes += 'Google Drive for Desktop (GoogleDriveFS) is running in this session' }
    else { $gdriveNotes += 'Google Drive for Desktop is not running in this session' }
    foreach ($drive in (Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue)) {
        $myDrive = Join-Path $drive.Root 'My Drive'
        if (Test-Path -LiteralPath $myDrive) { $gdriveNotes += ("a 'My Drive' folder was found at {0}" -f $myDrive) }
    }
    if (($null -ne $env:USERPROFILE) -and ($env:USERPROFILE -ne '')) {
        $profileDrive = Join-Path $env:USERPROFILE 'Google Drive'
        if (Test-Path -LiteralPath $profileDrive) { $gdriveNotes += ("a Google Drive folder was found at {0}" -f $profileDrive) }
    }
    Add-Result 'INFO' 'Google Drive as seen from this session' ($gdriveNotes -join '; ')

    $odProc = Get-Process -Name 'OneDrive' -ErrorAction SilentlyContinue
    if ($odProc) { Add-Result 'INFO' 'Sync app running in this session' 'OneDrive is running. Cloud folders are only reachable while their sync app runs in your logged-on session, which is why the scanner task must run in this session too.' }
    elseif ($gfs) { Add-Result 'INFO' 'Sync app running in this session' 'Google Drive is running. Cloud folders are only reachable while their sync app runs in your logged-on session, which is why the scanner task must run in this session too.' }
    else { Add-Result 'INFO' 'Sync app running in this session' 'Neither OneDrive nor Google Drive is running in this session. That is fine if your log will be a local file; if it will live in the cloud, start the sync app and run this diagnostic again so the destination can be checked for real.' }
}

# ---------------------------------------------------------------------------
# 8. Information that shapes setup, not pass or fail gates
# ---------------------------------------------------------------------------
try {
    $effPolicy = Get-ExecutionPolicy
    Add-Result 'INFO' 'Script execution policy (effective)' ("{0}. The scanner task launches PowerShell with its own bypass for its own script, so a restrictive policy does not by itself block the module, but a managed AllSigned or Restricted policy is a useful signal that this machine is policy managed." -f $effPolicy)
}
catch { Add-Result 'INFO' 'Script execution policy (effective)' 'Could not be read.' }

try {
    $avProducts = Get-CimInstance -Namespace 'root/SecurityCenter2' -ClassName AntiVirusProduct -ErrorAction Stop
    if ($avProducts) {
        $avNames = ($avProducts | ForEach-Object { $_.displayName }) -join ', '
        Add-Result 'INFO' 'Security software present' ("{0}. This is recorded because security software sometimes blocks the windowless launch pattern; if yours prompted you during the script host test above, tell your Muse." -f $avNames)
    }
}
catch { Add-Result 'SKIP' 'Security software present' 'Could not be enumerated on this machine. Not a problem by itself.' }

try {
    $sysDriveName = $env:SystemDrive.TrimEnd(':')
    $sysDrive = Get-PSDrive -Name $sysDriveName -ErrorAction Stop
    $freeGB = [math]::Round($sysDrive.Free / 1GB, 1)
    if ($freeGB -lt 2) {
        Add-Result 'WARN' 'Free space on the system drive' ("Only {0} GB free. The log files are small, but a nearly full system drive makes every scheduled tool unreliable." -f $freeGB) 'Free up space before installing modules that run on a schedule.'
    }
    else {
        Add-Result 'INFO' 'Free space on the system drive' ("{0} GB free." -f $freeGB)
    }
}
catch { }

try {
    $tz = Get-TimeZone
    Add-Result 'INFO' 'Time zone' ("{0}. Board schedules and the scanner both use this machine's local time; a wrong time zone makes 15 minute cycles and daily dates land at odd moments." -f $tz.DisplayName)
}
catch { }

# ---------------------------------------------------------------------------
# Summary and verdict
# ---------------------------------------------------------------------------
Write-ReportLine ''
Write-ReportLine 'Summary'
$failItems = @($script:Results | Where-Object { $_.Status -eq 'FAIL' })
$warnItems = @($script:Results | Where-Object { $_.Status -eq 'WARN' })
$passCount = @($script:Results | Where-Object { $_.Status -eq 'PASS' }).Count
Write-ReportLine ("Passed: {0}   Warnings: {1}   Failed: {2}" -f $passCount, $warnItems.Count, $failItems.Count)
if ($failItems.Count -gt 0) {
    Write-ReportLine 'Verdict: NOT READY for the File Save Log module yet. The failed requirements are:'
    foreach ($item in $failItems) { Write-ReportLine (" - {0}" -f $item.Check) }
    Write-ReportLine 'Your core board, Email Brief, and AI Bridge are not blocked by any of this. Paste this report to your Muse; it will either walk you through a fix and a rerun, or park the File Save Log module cleanly and finish the rest of your install.'
}
elseif ($warnItems.Count -gt 0) {
    Write-ReportLine 'Verdict: READY WITH WARNINGS for the File Save Log module. The warnings are:'
    foreach ($item in $warnItems) { Write-ReportLine (" - {0}" -f $item.Check) }
    Write-ReportLine 'Paste this report to your Muse before setup; it will build the setup around the warnings (for example, using a fallback launch) rather than discovering them mid-install.'
}
else {
    Write-ReportLine 'Verdict: READY for the File Save Log module. Every minimum requirement checked here passed on this machine.'
    Write-ReportLine 'Paste this report to your Muse before setup, so it uses these exact paths and results instead of asking you again.'
}
Write-ReportLine ''
Write-ReportLine 'End of report.'

# ---------------------------------------------------------------------------
# Save the report next to this script (or where -ReportPath says)
# ---------------------------------------------------------------------------
if (($null -eq $ReportPath) -or ($ReportPath -eq '')) {
    $baseDir = $PSScriptRoot
    if (($null -eq $baseDir) -or ($baseDir -eq '')) { $baseDir = (Get-Location).Path }
    $ReportPath = Join-Path $baseDir ('FileSaveLog-PreInstall-Report-{0}.txt' -f $now.ToString('yyyyMMdd-HHmmss'))
}
try {
    [System.IO.File]::WriteAllLines($ReportPath, [string[]]$script:ReportLines, [System.Text.Encoding]::ASCII)
    Write-Host ''
    Write-Host ("Report saved to: {0}" -f $ReportPath)
    Write-Host 'Paste the whole report into your own Muse conversation to continue the install.'
}
catch {
    Write-Host ''
    Write-Host ("The report file could not be saved ({0}). Copy the full text above from this window instead and paste that into your Muse." -f $_.Exception.Message)
}

if ($failItems.Count -gt 0) { exit 1 } else { exit 0 }
