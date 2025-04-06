#Requires -RunAsAdministrator
#Requires -Modules NtObjectManager

param (
    [Parameter(Mandatory = $true)]
    [string]$ApplicationPath
)

function Log {
    param([string]$msg)
    Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [INFO]  $msg"
}

function LogError {
    param([string]$msg)
    Write-Error "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [ERROR] $msg"
}

function LogStep {
    param([string]$msg)
    Write-Output "`n$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [STEP]  $msg"
}

# Begin transcript
$logPath = "$env:TEMP\untrusted1nstaller-log.txt"
Start-Transcript -Path $logPath -Force

LogStep "Initializing untrusted1nstaller run"
Log "Script invoked as: $($MyInvocation.MyCommand.Definition)"
Log "Current Directory: $(Get-Location)"
Log "Running User: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
Log "User SID: $((New-Object System.Security.Principal.NTAccount((whoami))).Translate([System.Security.Principal.SecurityIdentifier]).Value)"
Log "Command Line Argument: $ApplicationPath"
Log "Temporary Log File: $logPath"

# Step 1: Import NtObjectManager
LogStep "Importing NtObjectManager module"
try {
    Log "Checking if NtObjectManager is already installed..."
    # Check if the module is already installed
    $module = Get-Module -ListAvailable NtObjectManager
    if (-not $module) {
        Log "NtObjectManager not found. Installing module..."
        Install-Module NtObjectManager -Scope CurrentUser -Force -SkipPublisherCheck | Out-Null
    }
    Log "Importing module into session..."
    Import-Module NtObjectManager -ErrorAction Stop
    Log "NtObjectManager module successfully imported."
} catch {
    LogError "Failed to import NtObjectManager. Details: $_"
    Stop-Transcript
    exit 1
}

# Step 2: Restart TrustedInstaller service
LogStep "Restarting TrustedInstaller service"
try {
    Log "Attempting to stop TrustedInstaller..."
    $stopResult = sc.exe stop TrustedInstaller
    Log "sc stop output:`n$stopResult"

    Log "Resetting binary path to default..."
    $configResult = sc.exe config TrustedInstaller binpath= "C:\Windows\servicing\TrustedInstaller.exe"
    Log "sc config output:`n$configResult"

    Log "Attempting to start TrustedInstaller..."
    $startResult = sc.exe start TrustedInstaller
    Log "sc start output:`n$startResult"
} catch {
    LogError "Could not restart TrustedInstaller service. Exception: $_"
    Stop-Transcript
    exit 1
}

# Step 3: Find TrustedInstaller PID
LogStep "Querying TrustedInstaller process ID"
try {
    $tiService = Get-CimInstance Win32_Service -Filter "Name='TrustedInstaller'"
    $tiPID = $tiService.ProcessId
    Log "Service State: $($tiService.State), PID: $tiPID"

    if (-not $tiPID -or $tiPID -eq 0) {
        throw "TrustedInstaller service returned invalid PID: $tiPID"
    }
} catch {
    LogError "Failed to query TrustedInstaller service details: $_"
    Stop-Transcript
    exit 1
}

# Step 4: Get NT Process object
LogStep "Acquiring NT process object for TrustedInstaller (PID: $tiPID)"
try {
    $p = Get-NtProcess | Where-Object { $_.ProcessId -eq $tiPID }
    if (-not $p) {
        throw "Get-NtProcess did not return a process object for PID $tiPID"
    }

    Log "NT Process Retrieved: Name=$($p.Name), PID=$($p.ProcessId), Session=$($p.SessionId)"
    Log "Executable Path: $($p.Win32ImagePath)"
    Log "Token User: $($p.Token.User)"
    Log "Token Integrity Level: $($p.Token.IntegrityLevel)"
    Log "Token Elevation: $($p.Token.Elevated)"
} catch {
    LogError "Failed to retrieve NT process for PID ${tiPID}: $_"
    Stop-Transcript
    exit 1
}

# Step 5: Launch application
LogStep "Launching target application as TrustedInstaller"
Log "Requested Command: $ApplicationPath"

try {
    $proc = New-Win32Process $ApplicationPath -CreationFlags NewConsole -ParentProcess $p
    Log "[+] Process successfully launched."
    Log "    → PID: $($proc.ProcessId)"
    Log "    → Handle: $($proc.Handle)"
} catch {
    LogError "Failed to spawn process as TrustedInstaller: $_"
    Stop-Transcript
    exit 1
}

# Wrap up
LogStep "Execution complete."
Log "Check if the launched process (PID $($proc.ProcessId)) is running in Task Manager or Process Hacker."
Log "Log file stored at: $logPath"

Stop-Transcript
