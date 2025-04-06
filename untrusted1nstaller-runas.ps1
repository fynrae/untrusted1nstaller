#Requires -RunAsAdministrator
#Requires -Modules NtObjectManager

$TIUX_VERSION = "1.0.0"

function Log($msg) {
    Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [INFO]  $msg"
}
function LogError($msg) {
    Write-Error "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [ERROR] $msg"
}
function LogStep($msg) {
    Write-Output "`n$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [STEP]  $msg"
}
function Check-Admin {
    $currentIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        LogError "This script must be run as Administrator."
        exit 1
    }
}

Check-Admin

if ($Args.Count -eq 1 -and ($Args[0] -eq "--version" -or $Args[0] -eq "-v")) {
    Write-Host "tiux version $TIUX_VERSION"
    exit 0
}
if ($Args.Count -lt 1) {
    Write-Host "Usage: tiux <ApplicationPath> or tiux --version"
    exit 1
}

$ApplicationPath = $Args -join " "

try {
    $resolved = Resolve-Path -Path $ApplicationPath -ErrorAction Stop
    $ApplicationPath = $resolved.Path
} catch {
    if (-not $ApplicationPath.EndsWith(".exe")) {
        try {
            $resolved = Resolve-Path -Path ($ApplicationPath + ".exe") -ErrorAction Stop
            $ApplicationPath = $resolved.Path
        } catch {
            LogError "Could not find file: $ApplicationPath"
            exit 1
        }
    } else {
        LogError "Could not find file: $ApplicationPath"
        exit 1
    }
}

$logPath = "$env:TEMP\tiux-log.txt"
Start-Transcript -Path $logPath -Force

LogStep "Initializing tiux run"
Log "ApplicationPath: $ApplicationPath"

try {
    if (-not (Get-Module -ListAvailable -Name NtObjectManager)) {
        Log "NtObjectManager not found. Installing..."
        Install-Module NtObjectManager -Scope CurrentUser -Force -SkipPublisherCheck | Out-Null
    }
    Import-Module NtObjectManager -ErrorAction Stop
    Log "NtObjectManager successfully imported."
} catch {
    LogError "Failed to load NtObjectManager: $_"
    Stop-Transcript
    exit 1
}

try {
    sc.exe stop TrustedInstaller | Out-Null
    sc.exe config TrustedInstaller binpath= "C:\Windows\servicing\TrustedInstaller.exe" | Out-Null
    sc.exe start TrustedInstaller | Out-Null
} catch {
    LogError "Could not restart TrustedInstaller: $_"
    Stop-Transcript
    exit 1
}

try {
    $tiPID = (Get-CimInstance Win32_Service -Filter "Name='TrustedInstaller'").ProcessId
    if (-not $tiPID) { throw "No PID for TrustedInstaller" }
    $p = Get-NtProcess | Where-Object { $_.ProcessId -eq $tiPID }
    if (-not $p) { throw "Could not get NT process object" }
} catch {
    LogError "Failed to acquire TrustedInstaller process: $_"
    Stop-Transcript
    exit 1
}

try {
    $proc = New-Win32Process $ApplicationPath -CreationFlags NewConsole -ParentProcess $p
    Log "Process launched → PID: $($proc.ProcessId)"
} catch {
    LogError "Failed to launch process: $_"
    Stop-Transcript
    exit 1
}

Log "Done. Log at $logPath"
Stop-Transcript
