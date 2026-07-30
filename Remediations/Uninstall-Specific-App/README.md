# Remove MSI Application by Product Code

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207.x-5391FE?style=for-the-badge)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4?style=for-the-badge)
![Microsoft Intune](https://img.shields.io/badge/Microsoft-Intune-00A4EF?style=for-the-badge)
![Run As](https://img.shields.io/badge/Run%20As-SYSTEM-blue?style=for-the-badge)
![Type](https://img.shields.io/badge/Type-Proactive%20Remediation-success?style=for-the-badge)

Detects and silently uninstalls a specific **MSI-based application** by its **Windows Installer Product Code** using **Microsoft Intune Remediations**.

Unlike remediations that rely on application names or versions, this solution identifies software using its unique MSI Product Code, providing a reliable method for removing specific applications regardless of display name variations.

---

# Overview

MSI Product Codes uniquely identify Windows Installer applications. Because Product Codes remain consistent for a given MSI package, they provide a dependable method for detection and removal without relying on localized application names or version strings.

This remediation:

* Detects MSI applications by Product Code
* Searches both 64-bit and 32-bit uninstall registry locations
* Silently uninstalls the application using **msiexec.exe**
* Verifies successful removal after the uninstall completes
* Supports common Windows Installer success and reboot-required exit codes

---

# Features

* Detects applications using MSI Product Codes
* Supports both 32-bit and 64-bit applications
* Silent, unattended uninstall
* Executes under the **SYSTEM** account
* Verifies application removal before reporting success
* Safe to deploy repeatedly
* Easily reusable by updating two configuration variables

---

# Use Case

This remediation is useful for organizations that want to:

* Remove vulnerable MSI applications
* Retire legacy software
* Remove applications that have inconsistent display names
* Standardize software removal across managed devices
* Deploy application cleanup through Microsoft Intune

---

# Requirements

* Microsoft Intune Remediations
* Windows 10 or Windows 11
* Run scripts as **SYSTEM**
* Administrative privileges
* Target application installed using Windows Installer (MSI)

---

# Configuration

Both scripts contain the following configuration variables:

```powershell
$ApplicationName = 'Application Name'
$ProductCode     = '{00000000-0000-0000-0000-000000000000}'
```

Replace these values with the desired application name and MSI Product Code before deployment.

---

# Detection Logic

The detection script performs the following steps:

## 1. Searches the Uninstall Registry

The script checks both Windows uninstall registry locations:

```text
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall
```

using the configured Product Code.

---

## 2. Determines Compliance

If the Product Code is found:

* Retrieves the installed application's display name and version (when available)
* Reports the detected application
* Returns **Exit 1**
* Reports the device as **Non-Compliant**

If the Product Code is not present:

* Returns **Exit 0**
* Reports the device as **Compliant**

---

# Remediation Logic

The remediation script performs the following operations.

## 1. Detects the Application

The script searches both uninstall registry locations for the configured Product Code.

If the application is not installed:

* Reports success
* Returns **Exit 0**

---

## 2. Starts a Silent Uninstall

The application is removed using Windows Installer:

```text
msiexec.exe /x {ProductCode} /qn /norestart
```

The uninstall executes:

* Silently
* Hidden
* Under the SYSTEM account
* Waiting for completion before continuing

---

## 3. Validates Windows Installer Exit Codes

The following exit codes are considered successful:

| Exit Code | Meaning                     |
| --------- | --------------------------- |
| `0`       | Success                     |
| `1605`    | Product already removed     |
| `1614`    | Product already uninstalled |
| `1641`    | Success (Restart Initiated) |
| `3010`    | Success (Restart Required)  |

Any other exit code causes remediation to fail.

---

## 4. Verifies Removal

After the uninstall completes, the script checks both uninstall registry locations again.

If the Product Code still exists:

* Reports failure
* Returns **Exit 1**

Otherwise:

* Reports successful removal
* Returns **Exit 0**

---

# Intune Configuration

| Setting                                     | Value                   |
| ------------------------------------------- | ----------------------- |
| Run this script using logged-on credentials | **No**                  |
| Run script in 64-bit PowerShell             | **Yes**                 |
| Enforce signature check                     | As required             |
| Schedule                                    | Organization Preference |

---

# Registry Locations

The remediation searches the following registry paths:

```text
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall
```

This ensures both native 64-bit and 32-bit MSI applications are detected.

---

# Files

```text
Detect-ApplicationByProductCode.ps1
Remediate-ApplicationByProductCode.ps1
README.md
```

---

# Example Workflow

1. Configure the Product Code and application name.
2. Deploy the remediation through Microsoft Intune.
3. Detection searches the uninstall registry.
4. Devices containing the Product Code report as **Non-Compliant**.
5. Intune executes the remediation script.
6. The application is silently removed using **msiexec.exe**.
7. The uninstall is verified.
8. The next detection cycle reports the device as **Compliant**.

---

# Notes

* Designed specifically for **Microsoft Intune Remediations**.
* Executes under the **SYSTEM** account.
* Detects applications by MSI Product Code rather than display name.
* Supports both 32-bit and 64-bit uninstall registry locations.
* Verifies the application has been removed before reporting success.
* Uses standard Intune remediation exit codes for accurate compliance reporting.
* Easily reusable by updating the Product Code and Application Name variables.

---

# Known Limitations

* Only supports applications installed using **Windows Installer (MSI)**.
* Applications installed using EXE, MSIX, Microsoft Store, or per-user installers are not detected.
* The Product Code must exactly match the installed MSI package.
* Applications with custom uninstall behavior outside of Windows Installer are not supported by this remediation.

---

# Version History

| Version | Date       | Notes           |
| ------- | ---------- | --------------- |
| 1.0.0   | 2026-07-30 | Initial release |
