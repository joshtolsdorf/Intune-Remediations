# Remove Claude Desktop

![Microsoft Intune](https://img.shields.io/badge/Microsoft-Intune-00A4EF?style=for-the-badge)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4?style=for-the-badge)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207.x-5391FE?style=for-the-badge)
![Run As](https://img.shields.io/badge/Run%20As-SYSTEM-blue?style=for-the-badge)
![Type](https://img.shields.io/badge/Type-Proactive%20Remediation-success?style=for-the-badge)

Removes **Claude Desktop** from Windows devices using **Microsoft Intune Remediations**.

This remediation is designed to run as **SYSTEM** and removes both the **per-user installation** of Claude Desktop as well as the **MSIX (Microsoft Store)** installation if present.

---

# Overview

Claude Desktop can be installed in multiple ways depending on how the user obtained the application:

* Per-user installation under the user's AppData directory
* Microsoft Store (MSIX) installation

This remediation detects and removes both installation types to ensure Claude Desktop is completely removed from managed devices.

---

# Use Case

This remediation is useful for organizations that want to:

* Remove unauthorized AI applications
* Standardize approved software across managed devices
* Eliminate user-installed Claude Desktop instances
* Support application compliance initiatives
* Deploy automated software removal through Microsoft Intune

---

# Requirements

* Microsoft Intune Remediations
* Run scripts as **SYSTEM**
* Windows 10 or Windows 11
* Administrative privileges

---

# Detection Logic

The detection script checks for:

1. User-based Claude Desktop installations located under:

```text
C:\Users\<Username>\AppData\Local\AnthropicClaude
```

2. Microsoft Store (MSIX) installations by enumerating installed AppX packages matching Claude Desktop.

If either installation method is detected:

* Returns **Exit 1**
* Reports the device as **Non-Compliant**

If Claude Desktop is not found:

* Returns **Exit 0**
* Reports the device as **Compliant**

---

# Remediation Logic

The remediation script performs the following actions:

## Per-User Installations

For each local user profile:

1. Locates the Claude Desktop installation folder.
2. Executes:

```text
Update.exe --uninstall -s
```

3. Waits for the uninstall process to complete.
4. Removes any remaining installation directory.

---

## Microsoft Store Installation

The script then:

1. Enumerates all installed Claude AppX packages.
2. Attempts removal using:

```powershell
Remove-AppxPackage -AllUsers
```

3. If the All Users removal fails, attempts a standard AppX removal for the package.

---

# Intune Configuration

| Setting                                     | Value                   |
| ------------------------------------------- | ----------------------- |
| Run this script using logged-on credentials | **No**                  |
| Run script in 64-bit PowerShell             | **Yes**                 |
| Enforce signature check                     | As required             |
| Schedule                                    | Organization preference |

---

# Installation Types Removed

| Installation Type      | Location                                        |
| ---------------------- | ----------------------------------------------- |
| Per-user               | `C:\Users\<User>\AppData\Local\AnthropicClaude` |
| Microsoft Store (MSIX) | Installed AppX Package                          |

---

# Files

```text
Detect-ClaudeDesktop.ps1
Remediate-ClaudeDesktop.ps1
README.md
```

---

# Notes

* Designed specifically for **Microsoft Intune Remediations**.
* Executes under the SYSTEM account.
* Removes Claude Desktop from all local user profiles.
* Removes Microsoft Store (MSIX) installations when detected.
* Cleans up any remaining installation folders after uninstall.
* Uses standard Intune remediation exit codes for accurate compliance reporting.
* Safe to deploy repeatedly; devices without Claude Desktop are reported as compliant.

---

# Known Limitations

* Active Claude Desktop processes may prevent immediate removal until they exit.
* The remediation removes the application but does not delete user-generated data stored outside of the installation directory.
* Future installations by users are not prevented by this remediation alone. To prevent reinstallation, consider combining this remediation with Microsoft Intune application control policies, AppLocker, Windows Defender Application Control (WDAC), or Microsoft Store restrictions.

---

# Version History

| Version | Date       | Notes           |
| ------- | ---------- | --------------- |
| 1.0.0   | 2026-07-08 | Initial release |
