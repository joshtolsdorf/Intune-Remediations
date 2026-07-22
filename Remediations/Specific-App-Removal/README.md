# Remove Specific Application by Name and Version

![Microsoft Intune](https://img.shields.io/badge/Microsoft-Intune-00A4EF?style=for-the-badge)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4?style=for-the-badge)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207.x-5391FE?style=for-the-badge)
![Run As](https://img.shields.io/badge/Run%20As-SYSTEM-blue?style=for-the-badge)
![Type](https://img.shields.io/badge/Type-Proactive%20Remediation-success?style=for-the-badge)

Detects and removes one or more **specific application versions** using **Microsoft Intune Remediations**.

This remediation is designed to run as **SYSTEM** and removes only the application versions explicitly defined in the script, making it ideal for retiring vulnerable or unsupported software while leaving newer versions installed.

---

# Overview

Organizations often need to remove a specific version of an application due to:

* Security vulnerabilities
* End-of-life software
* Vendor compatibility issues
* Migration to a newer release
* Compliance requirements

Rather than removing every version of an application, this remediation targets only the versions specified in the configuration array.

---

# Features

* Supports one or multiple applications
* Targets specific application versions
* Automatically detects both 32-bit and 64-bit installed applications
* Supports MSI-based and EXE-based uninstallers
* Quiet, unattended removal
* Easily expandable by adding additional entries to the configuration array

---

# Use Case

This remediation is useful for organizations that want to:

* Remove vulnerable application versions
* Enforce minimum supported software versions
* Retire legacy applications
* Automate application cleanup through Microsoft Intune
* Maintain version compliance across managed devices

---

# Requirements

* Microsoft Intune Remediations
* Run scripts as **SYSTEM**
* Windows 10 or Windows 11
* Administrative privileges

---

# Configuration

Applications are configured using the following array:

```powershell
$ApplicationsToRemove = @(
    @{ Name = 'Application Name'; Version = '1.0.0' }
)
```

Multiple applications can be added:

```powershell
$ApplicationsToRemove = @(
    @{ Name = 'Application One'; Version = '1.0.0' }
    @{ Name = 'Application Two'; Version = '5.2.1' }
    @{ Name = 'Application Three'; Version = '10.4.7' }
)
```

The detection and remediation scripts should contain identical application lists.

---

# Detection Logic

The detection script:

1. Enumerates installed applications from:

* `HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall`
* `HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall`

2. Compares each installed application against the configured array using:

* Display Name
* Display Version

If a matching application and version is found:

* Returns **Exit 1**
* Reports the device as **Non-Compliant**

If no matching applications are detected:

* Returns **Exit 0**
* Reports the device as **Compliant**

---

# Remediation Logic

For each configured application, the remediation script:

1. Searches installed applications.
2. Locates matching name and version.
3. Retrieves the application's uninstall command.
4. Determines the uninstall type.

### MSI Applications

MSI-based applications are removed using:

```text
msiexec.exe /x {ProductCode} /qn /norestart
```

### EXE Applications

Executable uninstallers are launched silently using:

```text
cmd.exe /c <UninstallString> /qn /norestart
```

The remediation processes every configured application before exiting.

---

# Intune Configuration

| Setting                                     | Value                   |
| ------------------------------------------- | ----------------------- |
| Run this script using logged-on credentials | **No**                  |
| Run script in 64-bit PowerShell             | **Yes**                 |
| Enforce signature check                     | As required             |
| Schedule                                    | Organization preference |

---

# Supported Installer Types

The remediation supports:

| Installer Type      | Supported |
| ------------------- | --------- |
| MSI                 | ✔         |
| EXE                 | ✔         |
| 32-bit Applications | ✔         |
| 64-bit Applications | ✔         |

---

# Files

```text
Detect-AppName.ps1
Remediate-AppName.ps1
README.md
```

---

# Example Workflow

1. Configure the application name and version in both scripts.
2. Deploy the remediation through Microsoft Intune.
3. Devices containing the specified application version are reported as **Non-Compliant**.
4. Intune executes the remediation script.
5. The targeted application version is silently uninstalled.
6. During the next detection cycle, the device reports as **Compliant**.

---

# Notes

* Designed specifically for **Microsoft Intune Remediations**.
* Executes under the **SYSTEM** account.
* Supports removing multiple applications in a single deployment.
* Only configured application versions are removed; newer or older versions remain installed unless explicitly specified.
* Automatically detects both MSI and EXE uninstall methods.
* Uses standard Intune remediation exit codes for accurate compliance reporting.
* Easily reusable by updating the `$ApplicationsToRemove` array.

---

# Known Limitations

* EXE uninstallers must support silent uninstall parameters. If a vendor uses different switches than `/qn /norestart`, the remediation script may require customization.
* Applications without a valid uninstall string cannot be removed automatically.
* Per-user applications installed outside the machine-wide uninstall registry (for example, some applications installed under `%LocalAppData%`) are not detected by this remediation.
* Display names and versions must exactly match the installed application's registry values.

---

# Version History

| Version | Date       | Notes           |
| ------- | ---------- | --------------- |
| 1.0.0   | 2026-06-01 | Initial release |
