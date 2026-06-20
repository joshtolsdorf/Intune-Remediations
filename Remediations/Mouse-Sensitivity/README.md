# Maximum Mouse Pointer Speed

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207.x-5391FE)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4)
![Microsoft Intune](https://img.shields.io/badge/Microsoft-Intune-00A4EF)
![Run As](https://img.shields.io/badge/Run%20As-SYSTEM-blue)
![Reboot](https://img.shields.io/badge/Reboot-Not%20Required-success)

Automatically configures **Mouse Pointer Speed** to the maximum setting for the currently logged-on user using **Microsoft Intune Remediations**.

This remediation is designed to run as **SYSTEM** while safely modifying the **logged-on user's HKCU registry hive** by resolving the user's SID and writing directly to **HKEY_USERS**.

---

## Overview

Mouse pointer speed is a user-specific preference stored in the Windows registry. This remediation standardizes the setting by configuring the pointer speed to the maximum Windows value of **20**.

The solution is ideal for organizations that want a consistent pointer experience across managed devices while maintaining a user-targeted configuration deployed from Intune.

---

## Use Case

This remediation is useful for organizations that want to:

* Standardize mouse pointer speed across all users
* Improve usability for users who prefer faster pointer movement
* Automatically configure new devices without manual intervention
* Enforce a consistent endpoint configuration through Microsoft Intune

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

```text
HKCU\Control Panel\Mouse
MouseSensitivity = "20"
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

```text
MouseSensitivity = "20"
```

5. Verifies that the value was successfully written
6. Returns **Exit 0** on success

If verification fails or an error occurs, the script returns **Exit 1**.

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

| Registry Path              | Name               | Type   | Value |
| -------------------------- | ------------------ | ------ | ----- |
| `HKCU\Control Panel\Mouse` | `MouseSensitivity` | String | `20`  |

---

## Files

```text
Detect-Mouse-Sensitivity.ps1
Remediate-Mouse-Sensitivity.ps1
README.md
```

---

## Notes

* Uses **HKEY_USERS** instead of HKCU since Intune Remediations execute as SYSTEM.
* Automatically identifies the active user and safely targets only that user's profile.
* Includes verification logic to ensure the registry value is successfully applied.
* Follows a reusable registry remediation template for consistency across Intune projects.
* Safe to deploy repeatedly and will only make changes when the configured value differs from the desired state.

---

## Version History

| Version | Date       | Notes           |
| ------- | ---------- | --------------- |
| 1.0.0   | 2026-06-20 | Initial release |
