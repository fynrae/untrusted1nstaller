# Requires: Admin + SeDebugPrivilege
# Requires -Modules NtObjectManager

Start-Transcript -Path "$env:TEMP\untrusted1nstaller-console-log.txt" -Force
Write-Output "=============================="
Write-Output "  untrusted1nstaller-console  "
Write-Output "==============================`n"

function Log {
    param([string]$msg)
    Write-Host "[*] $msg"
}

function LogSuccess {
    param([string]$msg)
    Write-Host "[+] $msg" -ForegroundColor Green
}

function LogError {
    param([string]$msg)
    Write-Host "[-] $msg" -ForegroundColor Red
}

Log "Importing NtObjectManager..."
try {
    if (-not (Get-Module -ListAvailable -Name NtObjectManager)) {
        Install-Module NtObjectManager -Scope CurrentUser -Force -SkipPublisherCheck -ErrorAction Stop | Out-Null
    }
    Import-Module NtObjectManager -ErrorAction Stop
    LogSuccess "NtObjectManager module loaded."
} catch {
    LogError "Failed to import NtObjectManager module: $_"
    Stop-Transcript
    exit 1
}

# Restart TI service
Log "Restarting TrustedInstaller service..."
try {
    sc.exe stop TrustedInstaller | Out-Null
    Log "Stopped service."

    sc.exe config TrustedInstaller binpath= "C:\Windows\servicing\TrustedInstaller.exe" | Out-Null
    Log "Set binpath to default."

    sc.exe start TrustedInstaller | Out-Null
    Log "Service started."
} catch {
    LogError "Error restarting TrustedInstaller service: $_"
    Stop-Transcript
    exit 1
}

# Get TI PID
Log "Retrieving TrustedInstaller PID..."
try {
    $tiService = Get-CimInstance Win32_Service -Filter "Name='TrustedInstaller'"
    $tiPID = $tiService.ProcessId
    if (-not $tiPID -or $tiPID -eq 0) {
        throw "Service process ID is invalid."
    }
    LogSuccess "TrustedInstaller is running with PID $tiPID."
} catch {
    LogError "Could not get PID of TrustedInstaller: $_"
    Stop-Transcript
    exit 1
}

# Get NT process object
Log "Retrieving NT object for PID $tiPID..."
try {
    $p = Get-NtProcess | Where-Object { $_.ProcessId -eq $tiPID }
    if (-not $p) {
        throw "Get-NtProcess returned nothing for PID ${tiPID}."
    }
    LogSuccess "NT process object acquired."
} catch {
    LogError "Failed to retrieve NT process for PID ${tiPID}: $_"
    Stop-Transcript
    exit 1
}

# Launch cmd.exe
Log "Launching 'cmd.exe' as TrustedInstaller..."
try {
    $proc = New-Win32Process "cmd.exe" -CreationFlags NewConsole -ParentProcess $p
    LogSuccess "cmd.exe launched successfully!"
    Log "Launched process ID: $($proc.ProcessId)"
} catch {
    LogError "Failed to launch cmd.exe: $_"
}

Stop-Transcript
