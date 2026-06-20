# Show File Extensions

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207.x-5391FE)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4)
![Microsoft Intune](https://img.shields.io/badge/Microsoft-Intune-00A4EF)
![Run As](https://img.shields.io/badge/Run%20As-SYSTEM-blue)
![Reboot](https://img.shields.io/badge/Reboot-Not%20Required-success)

Automatically enables **Show File Extensions** for the currently logged-on user using **Microsoft Intune Remediations**.

This remediation is designed to run as **SYSTEM** while safely modifying the **logged-on user's HKCU registry hive** by resolving the user's SID and writing directly to **HKEY_USERS**.

---

## Overview

By default, Windows hides known file extensions, which can make it more difficult for users and IT staff to identify file types and potentially malicious files.

This remediation ensures that **Show File Extensions** is always enabled by setting:

| Setting         | Value                      |
| --------------- | -------------------------- |
| **HideFileExt** | `0` (Show file extensions) |

---

## Use Case

This remediation is useful for organizations that want to:

* Improve user awareness of file types
* Reduce phishing and malware risks caused by hidden extensions
* Standardize File Explorer behavior across managed devices
* Enforce security best practices without requiring user interaction

---

## Requirements

* Microsoft Intune Remediations
* Run scripts as **SYSTEM**
* Windows 10 or Windows 11
* A user must be logged on

---

## Detection Logic

The detection script:

1. Determines the currently logged-on user
2. Resolves the user's SID
3. Accesses the user's HKU registry hive
4. Verifies that

```
HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
HideFileExt = 0 (DWORD)
```

If the value is missing or incorrect:

* Returns **Exit 1**
* Reports the device as **Non-Compliant**

Otherwise:

* Returns **Exit 0**
* Reports the device as **Compliant**

---

## Remediation Logic

The remediation script:

1. Determines the currently logged-on user
2. Resolves the user's SID
3. Creates the registry path if necessary
4. Sets

```
HideFileExt = 0 (DWORD)
```

5. Returns **Exit 0** on success

If any operation fails, the script exits with **Exit 1**.

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

| Registry Path                                                      | Name          | Type  | Value |
| ------------------------------------------------------------------ | ------------- | ----- | ----- |
| `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced` | `HideFileExt` | DWORD | `0`   |

---

## Files

```
Detect-File-Extension-Show.ps1
Remediate-File-Extension-Show.ps1
README.md
```

---

## Notes

* Uses **HKEY_USERS** instead of HKCU since Intune Remediations execute as SYSTEM.
* Automatically identifies the active user and safely targets only that user's profile.
* Creates the registry path if it does not already exist.
* Follows a reusable registry remediation template for consistency across Intune projects.

---

## Version History

| Version | Date       | Notes           |
| ------- | ---------- | --------------- |
| 1.0.0   | 2026-06-20 | Initial release |
