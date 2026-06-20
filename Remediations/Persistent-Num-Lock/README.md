# Persistent Num Lock

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207.x-5391FE)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4)
![Microsoft Intune](https://img.shields.io/badge/Microsoft-Intune-00A4EF)

Automatically enables **Num Lock at sign-in and after restart** using **Microsoft Intune Remediations**.

This remediation is designed to run as **SYSTEM** and configures the Windows registry so that **Num Lock remains enabled** at the logon screen and for new user sessions.

---

## Overview

Windows does not always preserve the Num Lock state across restarts or at the sign-in screen, which can create frustration for users who rely on the numeric keypad.

This remediation standardizes the behavior by ensuring that **InitialKeyboardIndicators** is configured to keep Num Lock enabled.

---

## Use Case

This remediation is useful for organizations that want to:

* Provide a consistent sign-in experience
* Eliminate user confusion caused by disabled Num Lock
* Reduce help desk tickets related to numeric keypad functionality
* Standardize keyboard behavior across managed devices

---

## Requirements

* Microsoft Intune Remediations
* Run scripts as **SYSTEM**
* Windows 10 or Windows 11

---

## Detection Logic

The detection script:

1. Reads the system registry value controlling the default Num Lock state
2. Verifies that the configured value matches the organization's desired setting
3. Returns a compliance status based on the current configuration

If the value is missing or incorrect:

* Returns **Exit 1**
* Reports the device as **Non-Compliant**

Otherwise:

* Returns **Exit 0**
* Reports the device as **Compliant**

---

## Remediation Logic

The remediation script:

1. Creates the required registry path if necessary
2. Sets the **InitialKeyboardIndicators** value to the desired configuration
3. Verifies that the change was successfully applied
4. Returns **Exit 0** on success

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

| Registry Path                                | Name                        | Type   | Purpose                                        |
| -------------------------------------------- | --------------------------- | ------ | ---------------------------------------------- |
| `HKEY_USERS\.DEFAULT\Control Panel\Keyboard` | `InitialKeyboardIndicators` | String | Controls the default Num Lock state at sign-in |

---

## Files

```text
Detect-Persistent-NumLock.ps1
Remediate-Persistent-NumLock.ps1
README.md
```

---

## Notes

* Configures the default Windows profile used at the sign-in screen.
* Designed for deployment through Microsoft Intune Remediations.
* Includes verification logic to ensure the registry value was successfully applied.
* Uses standard Intune detection/remediation exit codes for accurate compliance reporting.
* Can be safely deployed repeatedly without adverse effects.

---

## Version History

| Version | Date       | Notes           |
| ------- | ---------- | --------------- |
| 1.0.0   | 2026-06-20 | Initial release |
