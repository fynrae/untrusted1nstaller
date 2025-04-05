#Requires -RunAsAdministrator
#Requires -Modules NtObjectManager

param (
    [Parameter(Mandatory = $true)]
    [string]$ApplicationPath
)

# Import the NtObjectManager module
Import-Module NtObjectManager -ErrorAction Stop

# Ensure TrustedInstaller service is running
if ((Get-Service -Name TrustedInstaller).Status -ne 'Running') {
    Write-Output "Starting TrustedInstaller service..."
    Start-Service -Name TrustedInstaller
    # Wait a bit to allow the service to initialize
    Start-Sleep -Seconds 5
}

# Get the TrustedInstaller process
$p = Get-NtProcess -Name TrustedInstaller.exe | Select-Object -First 1

if ($p -eq $null) {
    Write-Error "Failed to obtain TrustedInstaller process."
    exit 1
}

# Start the specified application as a child of the TrustedInstaller process
Write-Output "Launching application with TrustedInstaller privileges: $ApplicationPath"
$proc = New-Win32Process $ApplicationPath -CreationFlags NewConsole -ParentProcess $p

Write-Output "Process started successfully."
