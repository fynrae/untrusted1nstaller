# Requires: Admin + SeDebugPrivilege
# Requires -Modules NtObjectManager

Start-Transcript -Path "$env:TEMP\untrusted1nstaller-log.txt" -Force
Write-Output "=============================="
Write-Output "  untrusted1nstaller-console "
Write-Output "==============================`n"

Write-Output "[*] Importing NtObjectManager..."
Install-Module NtObjectManager -Scope CurrentUser -Force -SkipPublisherCheck | Out-Null
Import-Module NtObjectManager -ErrorAction Stop

# Start TI service
Write-Output "[*] Restarting TrustedInstaller service..."
sc.exe stop TrustedInstaller | Out-Null
Start-Sleep -Seconds 2
sc.exe config TrustedInstaller binpath= "C:\Windows\servicing\TrustedInstaller.exe" | Out-Null
sc.exe start TrustedInstaller | Out-Null
Start-Sleep -Seconds 3

# Get actual TrustedInstaller PID
Write-Output "[*] Locating TrustedInstaller service process..."
$tiPID = (Get-CimInstance Win32_Service -Filter "Name='TrustedInstaller'").ProcessId
if (-not $tiPID -or $tiPID -eq 0) {
    Write-Error "[-] TrustedInstaller process not found. Service may not have started correctly."
    Stop-Transcript
    exit 1
}

$p = Get-NtProcess | Where-Object { $_.ProcessId -eq $tiPID }
if (-not $p) {
    Write-Error "[-] Could not get NT object for TrustedInstaller process (PID: $tiPID)."
    Stop-Transcript
    exit 1
}

# Launch cmd.exe as TrustedInstaller
Write-Output "[*] Launching cmd.exe as TrustedInstaller..."
try {
    $proc = New-Win32Process "cmd.exe" -CreationFlags NewConsole -ParentProcess $p
    Write-Output "[+] Process launched successfully!"
} catch {
    Write-Error "[-] Failed to launch process: $_"
}

Stop-Transcript
