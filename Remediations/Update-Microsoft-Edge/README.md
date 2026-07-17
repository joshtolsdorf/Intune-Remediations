# Update Microsoft Edge to the Latest Stable Release

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207.x-5391FE)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4)
![Microsoft Intune](https://img.shields.io/badge/Microsoft-Intune-00A4EF)
![Run As](https://img.shields.io/badge/Run%20As-SYSTEM-blue)
![Reboot](https://img.shields.io/badge/Reboot-Not%20Required-success)

Detects outdated installations of **Microsoft Edge** and automatically updates them to the latest **Stable Channel** release using **Microsoft Intune Remediations**.

This remediation is designed to run as **SYSTEM**, compares the installed Edge version against Microsoft's published Stable release, and performs a silent Enterprise MSI upgrade when an update is available.

---

# Overview

Although Microsoft Edge updates automatically by default, devices can occasionally fall behind due to:

* Disabled or unhealthy Microsoft Edge Update services
* Network restrictions
* Devices that have been offline for extended periods
* Enterprise environments where automatic updates are managed
* Failed or interrupted update attempts

This remediation ensures that managed devices remain on the current Microsoft Edge Stable release by comparing the installed version with Microsoft's official release information and performing an update when necessary.

---

# Use Case

This remediation is useful for organizations that want to:

* Keep Microsoft Edge fully patched
* Reduce browser security vulnerabilities
* Standardize browser versions across managed devices
* Supplement or repair automatic Edge update failures
* Deploy browser updates through Microsoft Intune

---

# Requirements

* Microsoft Intune Remediations
* Run scripts as **SYSTEM**
* Windows 10 or Windows 11
* Internet connectivity
* Microsoft Edge installed (or available for installation)

---

# Detection Logic

The detection script performs the following steps:

1. Locates the installed Microsoft Edge executable.
2. Retrieves the installed product version.
3. Downloads Microsoft's official Edge Stable release notes.
4. Determines the latest published Stable version.
5. Compares the installed version against the latest available release.

If the installed version is older than the latest Stable release:

* Returns **Exit 1**
* Reports the device as **Non-Compliant**

If the installed version is current or newer:

* Returns **Exit 0**
* Reports the device as **Compliant**

If Microsoft Edge is not installed, the script reports the device as **Non-Compliant**.

---

# Remediation Logic

When remediation is required, the script:

## 1. Creates a Temporary Working Folder

Creates:

```text
C:\ProgramData\BrowserUpdate
```

to store the temporary installer.

---

## 2. Determines the Latest Stable Version

The script downloads Microsoft's current Edge Stable release information and compares it with the locally installed version.

---

## 3. Downloads the Enterprise Installer

Downloads the latest Microsoft Edge Enterprise MSI package directly from Microsoft.

---

## 4. Performs a Silent Upgrade

Executes:

```text
msiexec.exe /i MicrosoftEdgeEnterpriseX64.msi /qn /norestart
```

Accepted installer exit codes include:

| Exit Code | Meaning                     |
| --------- | --------------------------- |
| `0`       | Success                     |
| `3010`    | Success (Restart Required)  |
| `1641`    | Success (Restart Initiated) |

---

## 5. Verifies the Installation

After installation completes, the script:

* Reads the newly installed Edge version
* Confirms it matches or exceeds the latest published Stable release
* Removes the downloaded installer

If verification succeeds:

* Returns **Exit 0**

Otherwise:

* Returns **Exit 1**

---

# Intune Configuration

| Setting                                     | Value                             |
| ------------------------------------------- | --------------------------------- |
| Run this script using logged-on credentials | **No**                            |
| Run script in 64-bit PowerShell             | **Yes**                           |
| Enforce signature check                     | As required                       |
| Schedule                                    | Weekly or Organization preference |

---

# Files

```text
Detect-MicrosoftEdgeUpdate.ps1
Remediate-MicrosoftEdgeUpdate.ps1
README.md
```

---

# Internet Resources Used

The scripts retrieve information directly from Microsoft:

| Purpose                         | Resource                               |
| ------------------------------- | -------------------------------------- |
| Determine latest Stable version | Microsoft Edge Stable Release Notes    |
| Download latest installer       | Microsoft Edge Enterprise MSI download |

No third-party repositories are used.

---

# Example Workflow

1. Intune runs the detection script.
2. The installed Microsoft Edge version is compared with Microsoft's current Stable release.
3. Outdated devices are reported as **Non-Compliant**.
4. Intune executes the remediation script.
5. The latest Microsoft Edge Enterprise installer is downloaded silently.
6. Edge is upgraded.
7. The installer is removed.
8. On the next detection cycle, the device reports as **Compliant**.

---

# Notes

* Designed specifically for **Microsoft Intune Remediations**.
* Executes under the **SYSTEM** account.
* Uses Microsoft's official Stable release information to determine compliance.
* Downloads the installer directly from Microsoft each time remediation is required.
* Automatically removes the downloaded installer after completion.
* Uses standard Intune remediation exit codes for accurate compliance reporting.
* Safe to deploy repeatedly. Devices already running the latest Stable version are left unchanged.

---

# Known Limitations

* Internet access to Microsoft download and documentation endpoints is required.
* If a newer version of Edge becomes available after detection but before remediation completes, the device may briefly report as non-compliant until the next detection cycle.
* A reboot is generally not required, but Microsoft Installer may return **3010** or **1641** if one is recommended or initiated.
* Devices with active browser sessions may continue using the previous version until Microsoft Edge is restarted.

---

# Version History

| Version | Date       | Notes           |
| ------- | ---------- | --------------- |
| 1.0.0   | 2026-07-17 | Initial release |
