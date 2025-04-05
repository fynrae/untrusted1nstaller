# 🔐 TrustedInstaller Privilege Escalation Console Scripts

![PowerShell](https://img.shields.io/badge/PowerShell-Scripts-blue) ![Security](https://img.shields.io/badge/Privilege%20Escalation-Advanced-red)

## 📌 Description
This project provides two advanced PowerShell scripts that demonstrate how to spawn processes under the security context of the `TrustedInstaller` service using the `NtObjectManager` module. These scripts are meant for **educational and administrative purposes only**.

> ⚠️ **Warning**: These scripts require administrative privileges and the use of `SeDebugPrivilege`. Misuse can lead to system instability or security violations.

---

## 🧰 Files Included

### `untrusted1nstaller-console.ps1`
- Spawns a `cmd.exe` (or any application) as a child of the `TrustedInstaller` process.
- Useful for quick testing and command line access under elevated context.

### `untrusted1installer-runas.ps1`
- Accepts an `ApplicationPath` as a parameter.
- Gracefully checks the `TrustedInstaller` service status, starts it if necessary.
- Launches any user-specified application under `TrustedInstaller` privileges.

---

## 🔧 Requirements
- **Windows** with PowerShell
- **Administrator Rights**
- **SeDebugPrivilege** (granted by default for Admins on most systems)
- [`NtObjectManager`](https://www.powershellgallery.com/packages/NtObjectManager)

### 📦 Installing NtObjectManager
```powershell
Install-Module NtObjectManager -Scope CurrentUser -Force -SkipPublisherCheck
```

> You may need to bypass the PowerShell script execution policy:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

---

## 🚀 Usage Instructions

### 1️⃣ `untrusted1nstaller-console.ps1`
Launches a command prompt as TrustedInstaller.

```powershell
# Run as Administrator
.\untrusted1nstaller-console.ps1
```

This script:
- Starts the TrustedInstaller service if not running.
- Uses `Get-NtProcess` to fetch the TrustedInstaller process.
- Uses `New-Win32Process` to launch `cmd.exe` with a custom message.

✅ Example Output:
```plaintext
Starting TrustedInstaller...
Starting Command Line...
Done!
```

You’ll get a new `cmd.exe` window running as TrustedInstaller.

---

### 2️⃣ `untrusted1installer-runas.ps1`
Run any application with TrustedInstaller privileges.

```powershell
# Run as Administrator
.\untrusted1installer-runas.ps1 -ApplicationPath "C:\Windows\System32\notepad.exe"
```

This script:
- Validates the `TrustedInstaller` service is running.
- Retrieves the `TrustedInstaller.exe` process.
- Uses it as a parent to spawn the specified application.

✅ Example Output:
```plaintext
Starting TrustedInstaller service...
Launching application with TrustedInstaller privileges: C:\Windows\System32\notepad.exe
Process started successfully.
```

---

## 🛡️ Security Warning
These scripts leverage high-level access to Windows internal mechanisms. Use them **only on systems you own or manage**. Unauthorized usage can be considered a violation of terms of service or even illegal in certain contexts.

---

## 🧪 Use Cases
- Advanced system administration
- Exploring Windows privilege boundaries

---

## 📄 License
These scripts are open-source under the [MIT License](LICENSE). Use at your own risk.

---

## 📬 Feedback & Contributions
Feel free to open issues or pull requests if you find bugs or want to improve the functionality.

---

## 🙏 Acknowledgement
Special thanks to the creators and maintainers of the **NtObjectManager** module and the contributors in the **PowerShell security community**, whose knowledge and tools have made this kind of research and learning possible:

- John Hammond : https://www.youtube.com/watch?v=Vj1uh89v-Sc
- https://www.tiraniddo.dev/2017/08/the-art-of-becoming-trustedinstaller.html

---

