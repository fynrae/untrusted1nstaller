#Requires -RunAsAdministrator
#Requires -Modules NtObjectManager

param (
    [Parameter(Mandatory = $true)]
    [string]$ApplicationPath
)

Start-Transcript -Path "$env:TEMP\untrusted1nstaller-log.txt" -Force

Write-Output "Importing NtObjectManager..."
Install-Module NtObjectManager -Scope CurrentUser -Force -SkipPublisherCheck
Import-Module NtObjectManager -ErrorAction Stop

# Start TrustedInstaller service
Write-Output "Starting TrustedInstaller service..."
sc.exe config TrustedInstaller binpath= "C:\Windows\servicing\TrustedInstaller.exe" | Out-Null
sc.exe start TrustedInstaller | Out-Null
Start-Sleep -Seconds 3

# Get the TrustedInstaller process
$p = Get-NtProcess TrustedInstaller.exe | Select-Object -First 1
if (-not $p) {
    Write-Error "Failed to get TrustedInstaller process."
    Stop-Transcript
    exit 1
}

# Construct full command to run inside a TI parent
Write-Output "Launching: $ApplicationPath as TrustedInstaller"
$proc = New-Win32Process $ApplicationPath -CreationFlags NewConsole -ParentProcess $p

Write-Output "Process launched successfully!"
Stop-Transcript
