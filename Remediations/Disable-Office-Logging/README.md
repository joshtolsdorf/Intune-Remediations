# Disable Microsoft Office Default Logging

![Microsoft Intune](https://img.shields.io/badge/Microsoft-Intune-00A4EF?style=for-the-badge)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4?style=for-the-badge)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207.x-5391FE?style=for-the-badge)
![Run As](https://img.shields.io/badge/Run%20As-SYSTEM-blue?style=for-the-badge)
![Type](https://img.shields.io/badge/Type-Proactive%20Remediation-success?style=for-the-badge)

Detects and remediates Microsoft Office applications that have **Default Logging** enabled using **Microsoft Intune Remediations**.

The remediation configures the appropriate Office policy registry values to disable logging, terminates Office applications that may be locking log files, removes the **Outlook Logging** folder, and reports the amount of disk space recovered.

---

# Overview

Microsoft Office applications can generate diagnostic log files when default logging is enabled. Over time, these logs—particularly Outlook ETL files—can consume a significant amount of disk space and are generally unnecessary for normal production environments.

This remediation:

* Disables Microsoft Office default logging
* Creates missing registry keys automatically
* Stops running Office applications to release locked log files
* Deletes the Outlook Logging cache folder
* Reports reclaimed disk space
* Ensures all supported Office applications remain configured correctly

---

# Features

* Detects the currently logged-on user while running as **SYSTEM**
* Creates missing registry paths automatically
* Configures Office logging policies under the user's registry hive
* Supports multiple Microsoft Office applications
* Removes accumulated Outlook logging files
* Reports reclaimed storage
* Safe to deploy repeatedly

---

# Supported Applications

The remediation configures the following Office applications:

* Outlook
* Excel
* Word
* OneNote
* Access
* PowerPoint
* Publisher

---

# Use Case

This remediation is useful for organizations that want to:

* Prevent unnecessary Microsoft Office diagnostic logging
* Reclaim disk space consumed by Outlook ETL logs
* Reduce support cases related to oversized Outlook Logging folders
* Standardize Office logging behavior across managed devices
* Deploy Office configuration through Microsoft Intune

---

# Requirements

* Microsoft Intune Remediations
* Run scripts as **SYSTEM**
* Windows 10 or Windows 11
* Microsoft Office 2016 / Microsoft 365 Apps (Office 16.x)
* A logged-on user

---

# Detection Logic

The detection script performs the following checks:

1. Determines the currently logged-on user.
2. Resolves the user's SID and loaded registry hive.
3. Checks the following registry value for each supported Office application:

```text
DisableDefaultLogging = 1
```

under:

```text
HKCU\Software\Policies\Microsoft\Office\16.0\<Application>\Logging
```

4. Determines whether the Outlook Logging folder exists:

```text
%LOCALAPPDATA%\Temp\Outlook Logging
```

5. Reports:

* Number of log files
* Folder size
* Registry compliance status

If any registry value is missing or incorrect:

* Returns **Exit 1**
* Reports the device as **Non-Compliant**

Otherwise:

* Returns **Exit 0**
* Reports the device as **Compliant**

> **Note:** The presence of the Outlook Logging folder is reported for informational purposes. Compliance is based on the registry configuration.

---

# Remediation Logic

The remediation script performs the following operations.

## 1. Determines the Logged-On User

Because Intune executes as SYSTEM, the script resolves:

* Username
* SID
* Profile path
* HKU registry hive

---

## 2. Configures Office Logging Policies

For each supported Office application, the script creates (if necessary):

```text
HKCU\Software\Policies\Microsoft\Office\16.0\<Application>\Logging
```

and configures:

```text
DisableDefaultLogging = 1 (DWORD)
```

The value is immediately verified after creation.

---

## 3. Stops Running Office Applications

To ensure log files are not locked, the remediation closes supported Office processes, including:

* Outlook
* Word
* Excel
* PowerPoint
* OneNote
* Access
* Publisher
* Visio
* Project
* SDXHelper
* MSOSYNC

> **Warning:** Any unsaved work in Microsoft Office applications will be lost. Consider scheduling this remediation outside of business hours or notifying users beforehand.

---

## 4. Removes Outlook Logging Files

The remediation deletes:

```text
%LOCALAPPDATA%\Temp\Outlook Logging
```

It calculates:

* Number of files removed
* Total disk space recovered

These values are written to the remediation output.

---

## Intune Configuration

| Setting                                     | Value                   |
| ------------------------------------------- | ----------------------- |
| Run this script using logged-on credentials | **No**                  |
| Run script in 64-bit PowerShell             | **Yes**                 |
| Enforce signature check                     | As required             |
| Schedule                                    | Organization preference |

---

# Registry

Each supported application receives the following value:

| Registry Path                                                        | Name                    | Type  | Value |
| -------------------------------------------------------------------- | ----------------------- | ----- | ----- |
| `HKCU\Software\Policies\Microsoft\Office\16.0\<Application>\Logging` | `DisableDefaultLogging` | DWORD | `1`   |

---

# Outlook Logging Folder

The remediation removes:

```text
%LOCALAPPDATA%\Temp\Outlook Logging
```

Typical contents include:

* ETL diagnostic traces
* Outlook logging files
* Temporary troubleshooting logs

---

# Files

```text
Detect-OfficeDefaultLogging.ps1
Remediate-OfficeDefaultLogging.ps1
README.md
```

---

# Example Workflow

1. Intune runs the detection script.
2. Registry values are validated for each supported Office application.
3. If any required value is missing or incorrect, the device reports **Non-Compliant**.
4. Intune executes the remediation script.
5. Office applications are closed.
6. Required registry values are created or corrected.
7. Outlook Logging files are removed.
8. The next detection cycle reports the device as **Compliant**.

---

# Notes

* Designed specifically for **Microsoft Intune Remediations**.
* Executes under the **SYSTEM** account.
* Uses the logged-on user's registry hive (HKEY_USERS) rather than HKCU.
* Automatically creates missing registry paths and values.
* Reports reclaimed disk space after removing Outlook logging files.
* Uses standard Intune remediation exit codes for accurate compliance reporting.
* Safe to deploy repeatedly.

---

# Known Limitations

* A user must be logged on for the remediation to resolve the correct profile and registry hive.
* Running Office applications are forcibly terminated to allow log file cleanup.
* Unsaved Office work will be lost if applications are open during remediation.
* The remediation targets Office version **16.0** policy paths (Microsoft 365 Apps / Office 2016 and later).

---

# Version History

| Version | Date       | Notes           |
| ------- | ---------- | --------------- |
| 1.0.0   | 2026-07-22 | Initial release |
