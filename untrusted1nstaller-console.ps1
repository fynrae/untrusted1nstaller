# Requires: Admin + SeDebugPrivilege
Install-Module NtObjectManager -Scope CurrentUser -Force -SkipPublisherCheck
Import-Module NtObjectManager

echo "Starting TrustedInstaller..."
sc.exe config TrustedInstaller binpath= "C:\Windows\servicing\TrustedInstaller.exe"
sc.exe start TrustedInstaller
echo "Starting Command Line..."
$p = Get-NtProcess TrustedInstaller.exe | Select-Object -First 1
$proc = New-Win32Process "cmd.exe /K @echo off & echo pwned!" -CreationFlags NewConsole -ParentProcess $p
#$proc = New-Win32Process "notepad" -CreationFlags NewConsole -ParentProcess $p
echo "Done!"