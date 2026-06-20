# Secure Boot 2023 Certificate Update

Detects and remediates the **Windows Secure Boot 2023 Certificate Update** using **Microsoft Intune Remediations**.

This remediation validates whether a device is applicable, checks the current Secure Boot servicing state, verifies the presence of the **Windows UEFI CA 2023** certificate when possible, and safely triggers the update by configuring the appropriate registry value.

---

## Overview

Microsoft's Secure Boot servicing updates require devices to receive the **Windows UEFI CA 2023** certificate to maintain compatibility with future Secure Boot security changes.

This remediation provides a safe and repeatable method of:

* Detecting the current Secure Boot certificate status
* Identifying devices that require remediation
* Triggering the update by setting the required registry value
* Avoiding devices that are already updated or actively processing the update

---

## Use Case

This remediation is useful for organizations that want to:

* Prepare Windows devices for Secure Boot certificate updates
* Identify devices missing the Windows UEFI CA 2023 certificate
* Trigger the Microsoft-supported update process through Intune
* Monitor deployment progress across managed devices
* Reduce manual registry modifications and troubleshooting

---

## Requirements

* Microsoft Intune Remediations
* Run scripts as **SYSTEM**
* Windows 10 or Windows 11
* UEFI firmware with Secure Boot enabled
* Administrative privileges

Devices without Secure Boot enabled are treated as **Not Applicable** and reported as compliant.

---

## Detection Logic

The detection script:

1. Verifies that Secure Boot is available and enabled
2. Reads Secure Boot servicing registry values
3. Checks for existing servicing errors
4. Verifies the presence of the **Windows UEFI CA 2023** certificate when possible
5. Evaluates whether remediation is required

The script returns:

| Exit Code | Result                                       |
| --------- | -------------------------------------------- |
| **0**     | Compliant / Already Updated / Not Applicable |
| **1**     | Non-Compliant / Remediation Required         |

---

## Remediation Logic

The remediation script:

1. Verifies that Secure Boot is available and enabled
2. Checks the current servicing status
3. Avoids overwriting updates that are already in progress
4. Sets:

```text
HKLM\SYSTEM\CurrentControlSet\Control\SecureBoot
AvailableUpdates = 0x5944
```

5. Allows the Windows Secure Boot servicing process to perform the update
6. Returns **Exit 0** on success

If remediation cannot be safely completed, the script returns **Exit 1**.

---

## Intune Configuration

| Setting                                     | Value                   |
| ------------------------------------------- | ----------------------- |
| Run this script using logged-on credentials | **No**                  |
| Run script in 64-bit PowerShell             | **Yes**                 |
| Enforce signature check                     | As required             |
| Schedule                                    | Organization preference |

---

## Registry

| Registry Path                                                | Name               | Type  | Purpose                                     |
| ------------------------------------------------------------ | ------------------ | ----- | ------------------------------------------- |
| `HKLM\SYSTEM\CurrentControlSet\Control\SecureBoot`           | `AvailableUpdates` | DWORD | Triggers the Secure Boot certificate update |
| `HKLM\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing` | `UEFICA2023Status` | DWORD | Tracks update status                        |
| `HKLM\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing` | `UEFICA2023Error`  | DWORD | Indicates update errors                     |

---

## Files

```text
Detect-SecureBootCerts.ps1
Remediate-SecureBootCerts.ps1
README.md
```

---

## Notes

* Designed specifically for **Microsoft Intune Proactive Remediations**.
* Safely skips devices that do not support Secure Boot or are not using UEFI.
* Includes logic to detect existing update progress and avoid unnecessary changes.
* Attempts to verify the presence of the **Windows UEFI CA 2023** certificate through Secure Boot database inspection when supported.
* Uses standard Intune detection and remediation exit codes for accurate compliance reporting.
* Safe to deploy repeatedly across enterprise environments.

---

## Version History

| Version | Date       | Notes           |
| ------- | ---------- | --------------- |
| 1.0.0   | 2026-06-20 | Initial release |