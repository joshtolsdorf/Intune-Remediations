# Remove Saved Wireless Network Profile

![Microsoft Intune](https://img.shields.io/badge/Microsoft-Intune-00A4EF?style=for-the-badge)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4?style=for-the-badge)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207.x-5391FE?style=for-the-badge)
![Run As](https://img.shields.io/badge/Run%20As-SYSTEM-blue?style=for-the-badge)
![Type](https://img.shields.io/badge/Type-Proactive%20Remediation-success?style=for-the-badge)

Detects and removes a specified **saved wireless network (Wi-Fi) profile** using **Microsoft Intune Remediations**.

This remediation is designed to run as **SYSTEM** and removes a configured Wi-Fi profile from Windows devices using the built-in **netsh** command.

---

# Overview

Windows stores previously connected wireless networks as saved profiles. While convenient, these profiles may no longer be desired due to:

* Guest wireless network decommissioning
* Security policy changes
* Network renaming
* Compliance requirements
* Preventing automatic reconnection to unauthorized networks

This remediation detects whether a specified wireless profile exists and removes it if found.

---

# Use Case

This remediation is useful for organizations that want to:

* Remove guest Wi-Fi profiles from corporate devices
* Prevent automatic reconnection to unauthorized wireless networks
* Clean up legacy wireless configurations
* Standardize wireless profiles across managed devices
* Deploy wireless profile cleanup through Microsoft Intune

---

# Requirements

* Microsoft Intune Remediations
* Run scripts as **SYSTEM**
* Windows 10 or Windows 11
* Wireless (Wi-Fi) adapter installed

---

# Configuration

Specify the wireless network (SSID) to remove by modifying the following variable in both scripts:

```powershell
$SsidName = 'Your-Network-Name-Here'
```

Replace **Your-Network-Name-Here** with the exact name of the saved wireless network profile.

Example:

```powershell
$SsidName = 'Guest-Network'
```

---

# Detection Logic

The detection script:

1. Enumerates all saved wireless profiles using:

```text
netsh wlan show profiles
```

2. Searches for the configured SSID.
3. Reports compliance based on whether the profile exists.

If the wireless profile is found:

* Returns **Exit 1**
* Reports the device as **Non-Compliant**

If the profile is not found:

* Returns **Exit 0**
* Reports the device as **Compliant**

---

# Remediation Logic

The remediation script:

1. Enumerates all saved wireless profiles.
2. Checks whether the configured SSID exists.
3. Removes the profile using:

```text
netsh wlan delete profile name="<SSID>"
```

4. Verifies that the profile has been successfully removed.

If the removal succeeds:

* Returns **Exit 0**

If the profile cannot be removed:

* Returns **Exit 1**

If the profile does not exist, no action is taken and the script returns **Exit 0**.

---

# Intune Configuration

| Setting                                     | Value                   |
| ------------------------------------------- | ----------------------- |
| Run this script using logged-on credentials | **No**                  |
| Run script in 64-bit PowerShell             | **Yes**                 |
| Enforce signature check                     | As required             |
| Schedule                                    | Organization preference |

---

# Files

```text
Detect-Network.ps1
Remediate-Network.ps1
README.md
```

---

# Example Workflow

1. Configure the target SSID in both scripts.
2. Deploy the detection and remediation scripts through Microsoft Intune.
3. Devices containing the specified saved Wi-Fi profile are reported as **Non-Compliant**.
4. Intune runs the remediation script.
5. The wireless profile is removed.
6. On the next detection cycle, the device reports as **Compliant**.

---

# Notes

* Designed specifically for **Microsoft Intune Remediations**.
* Executes under the SYSTEM account.
* Uses the built-in **netsh** utility—no additional modules or dependencies are required.
* Only the specified wireless profile is removed; all other saved networks remain unchanged.
* Safe to deploy repeatedly. If the profile does not exist, the remediation exits successfully without making changes.
* Uses standard Intune remediation exit codes for accurate compliance reporting.

---

# Known Limitations

* Only wireless profiles matching the configured SSID are removed.
* If the wireless profile is recreated (for example, by reconnecting to the network or via Group Policy), it may reappear.
* Devices without a wireless adapter will simply report the profile as not found.

---

# Version History

| Version | Date       | Notes           |
| ------- | ---------- | --------------- |
| 1.0.0   | 2026-05-20 | Initial release |
