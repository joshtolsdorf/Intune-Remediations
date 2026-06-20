# Automatic Time Zone

Enable Automatic Time Zone on Windows devices using Microsoft Intune Proactive Remediations.

---

## Overview

This remediation configures the **tzautoupdate** service to enable Automatic Time Zone on Windows devices.

It is useful for organizations with remote users, traveling employees, or devices that frequently change geographic locations.

---

## Detection Logic

The detection script verifies the following registry value:

| Registry Path                                          | Value   | Expected |
| ------------------------------------------------------ | ------- | -------- |
| `HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate` | `Start` | `3`      |

### Exit Codes

| Exit Code | Result                  |
| --------- | ----------------------- |
| `0`       | Device is compliant     |
| `1`       | Device is non-compliant |

---

## Remediation Logic

The remediation script:

1. Sets the registry value:

```powershell
HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate
Start = 3
```

2. Verifies the value after making the change.

3. Returns:

* `Exit 0` = Success
* `Exit 1` = Verification failed

---

## Intune Configuration

| Setting                                         | Recommended Value |
| ----------------------------------------------- | ----------------- |
| Run this script using the logged-on credentials | **No**            |
| Enforce script signature check                  | **No**            |
| Run script in 64-bit PowerShell                 | **Yes**           |

---

## Files

```text
Automatic-Time-Zone/
├── Detect-AutomaticTimeZone.ps1
├── Remediate-AutomaticTimeZone.ps1
└── README.md
```

---

## Requirements

* Windows 10 or Windows 11
* Microsoft Intune Proactive Remediations
* Scripts executed as **SYSTEM**

---

## Notes

* No reboot is required.
* The remediation verifies the registry value after making the change instead of assuming success.

---

## Author

**Josh Tolsdorf**

Infrastructure Engineer

Microsoft Intune • PowerShell • Microsoft 365 • Automation
