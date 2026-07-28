# Google Chrome Update Remediation

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207.x-5391FE?style=for-the-badge)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4?style=for-the-badge)
![Microsoft Intune](https://img.shields.io/badge/Microsoft-Intune-00A4EF?style=for-the-badge)
![Run As](https://img.shields.io/badge/Run%20As-SYSTEM-blue?style=for-the-badge)
![Type](https://img.shields.io/badge/Type-Proactive%20Remediation-success?style=for-the-badge)

Detects Google Chrome installations that have a functional **Google Update** engine and triggers a silent background update using **Microsoft Intune Remediations**.

The remediation leverages Google's built-in update mechanism rather than downloading installers or reinstalling Chrome, making it lightweight and suitable for routine compliance checks.

---

# Overview

Google Chrome normally updates automatically through the **Google Update** service. However, update checks may not occur as expected if devices are offline, users rarely restart their computers, or scheduled update tasks fail.

This remediation verifies that:

* Google Chrome is installed.
* The Google Update engine is present.
* A background update check can be initiated.

If all requirements are met, the remediation launches Google's supported update process silently.

---

# Features

* Detects Google Chrome installations
* Verifies the Google Update engine exists
* Triggers Google's native background update mechanism
* Runs silently without user interaction
* Executes under the **SYSTEM** account
* Safe to run repeatedly
* Ideal for scheduled Intune Remediations

---

# Use Case

This remediation is useful for organizations that want to:

* Keep Google Chrome patched
* Supplement Chrome's automatic update process
* Reduce browser security vulnerabilities
* Improve update compliance reporting
* Automate Chrome update checks through Microsoft Intune

---

# Requirements

* Microsoft Intune Remediations
* Windows 10 or Windows 11
* Run scripts as **SYSTEM**
* Google Chrome installed
* Google Update installed

---

# Detection Logic

The detection script performs the following checks:

## 1. Verify Google Chrome Installation

The script checks for Chrome in the standard installation locations:

```text
C:\Program Files\Google\Chrome\Application\chrome.exe
C:\Program Files (x86)\Google\Chrome\Application\chrome.exe
```

If Chrome is **not installed**, the script returns:

* **Exit 0**
* Device is considered **Compliant**

Since Chrome is absent, there is nothing to remediate.

---

## 2. Verify Google Update

The script verifies that the Google Update engine exists:

```text
C:\Program Files (x86)\Google\Update\GoogleUpdate.exe
```

If the update engine is missing:

* **Exit 1**
* Device reports **Non-Compliant**

---

## 3. Trigger Remediation

If both Chrome and Google Update are present:

* **Exit 1**
* Intune executes the remediation script to initiate a background update check.

---

# Remediation Logic

The remediation script performs the following actions.

## 1. Verify Google Update Exists

The script confirms the presence of:

```text
C:\Program Files (x86)\Google\Update\GoogleUpdate.exe
```

If the executable is missing, remediation fails.

---

## 2. Launch Google Update

The remediation starts Google's supported background updater using:

```text
GoogleUpdate.exe /ua /installsource scheduler
```

Parameters used:

| Parameter                  | Purpose                                                   |
| -------------------------- | --------------------------------------------------------- |
| `/ua`                      | Perform an update check for installed Google applications |
| `/installsource scheduler` | Indicates the update was initiated by a scheduled process |

The updater runs:

* Hidden
* Synchronously (the script waits for completion)
* Under the SYSTEM account

---

## 3. Validate Completion

After Google Update exits:

* Exit Code `0` → Success
* Any other exit code → Remediation failure

The script reports the final result to Intune.

---

# Intune Configuration

| Setting                                     | Value                            |
| ------------------------------------------- | -------------------------------- |
| Run this script using logged-on credentials | **No**                           |
| Run script in 64-bit PowerShell             | **Yes**                          |
| Enforce signature check                     | As required                      |
| Schedule                                    | Daily or Organization Preference |

---

# Files

```text
Detect-GoogleChromeUpdate.ps1
Remediate-GoogleChromeUpdate.ps1
README.md
```

---

# Example Workflow

1. Intune runs the detection script.
2. Chrome installation is verified.
3. Google Update is verified.
4. If remediation is required, Intune launches the remediation script.
5. Google Update performs a silent background update check.
6. Google Update exits successfully.
7. The next remediation cycle repeats the compliance check.

---

# Notes

* Designed specifically for **Microsoft Intune Remediations**.
* Executes under the **SYSTEM** account.
* Uses Google's native update mechanism instead of reinstalling Chrome.
* Does not interrupt users or display prompts.
* Safe to run on a recurring schedule.
* Uses standard Intune remediation exit codes for accurate compliance reporting.

---

# Known Limitations

* This remediation **initiates** a Google Chrome update check but does not verify that Chrome was upgraded to a specific version.
* Devices without the Google Update engine installed cannot be remediated.
* Internet connectivity is required for Google Update to download available updates.
* Organizations that disable or replace Google's update mechanism may require a different remediation approach.

---

# Version History

| Version | Date       | Notes           |
| ------- | ---------- | --------------- |
| 1.0.0   | 2026-07-28 | Initial release |
