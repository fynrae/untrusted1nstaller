# Untrusted1nstaller

**Untrusted1nstaller** is a set of PowerShell scripts designed to launch applications under the TrustedInstaller security context on Windows. This tool leverages advanced techniques—such as process token manipulation and parent process inheritance—using the [NtObjectManager](https://github.com/googleprojectzero/sandbox-attacksurface-analysis-tools) module. This can be useful for system administrators, security researchers, or penetration testers needing to interact with protected system resources.

> **Disclaimer:**  
> **Use this tool at your own risk.** Modifying or running applications with TrustedInstaller privileges bypasses normal security protections and can potentially destabilize your system or expose it to security risks. It is intended solely for research, testing, or recovery purposes in a controlled environment. Always ensure you have proper backups before using this tool.

---

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Scripts Overview](#scripts-overview)
  - [untrusted1nstaller-runas.ps1](#untrusted1nstaller-runasps1)
  - [untrusted1nstaller-console.ps1](#untrusted1nstaller-consoleps1)
- [Usage](#usage)
  - [Running an Application as TrustedInstaller](#running-an-application-as-trustedinstaller)
  - [Launching a TrustedInstaller Command Console](#launching-a-trustedinstaller-command-console)
- [Troubleshooting](#troubleshooting)
- [Security Considerations](#security-considerations)
- [License](#license)

---

## Features

- **Run Any Application as TrustedInstaller:**  
  The `untrusted1nstaller-runas.ps1` script accepts an application path as a parameter and launches it with the TrustedInstaller token.

- **TrustedInstaller Command Console:**  
  The `untrusted1nstaller-console.ps1` script demonstrates launching a command prompt with TrustedInstaller privileges, displaying a simple test message ("pwned!") upon startup.

- **Token & Process Manipulation:**  
  The scripts use the [NtObjectManager](https://www.powershellgallery.com/packages/NtObjectManager) module to manipulate processes at a low level, requiring advanced privileges.

---

## Requirements

- **Operating System:** Windows (Vista or later)
- **Privileges:** Must be run from an elevated (Administrator) PowerShell session.
- **Modules:**
  - [NtObjectManager](https://www.powershellgallery.com/packages/NtObjectManager)
- **PowerShell Version:** PowerShell 5.1 or later is recommended.
- **SeDebugPrivilege:** The scripts require that the user has SeDebugPrivilege enabled (available to administrators).

---

## Installation

1. **Clone or Download the Repository:**
   ```powershell
   git clone https://github.com/yourusername/untrusted1nstaller.git
