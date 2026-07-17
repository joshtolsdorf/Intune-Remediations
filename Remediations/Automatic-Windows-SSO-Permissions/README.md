# Enable Automatic Windows SSO Permission Prompts

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207.x-5391FE)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4)
![Microsoft Intune](https://img.shields.io/badge/Microsoft-Intune-00A4EF)
![Run As](https://img.shields.io/badge/Run%20As-SYSTEM-blue)
![Reboot](https://img.shields.io/badge/Reboot-Not%20Required-success)

Enables **automatic acceptance of Windows Single Sign-On (SSO) permission prompts** using **Microsoft Intune Remediations**.

This remediation is designed to run as **SYSTEM** and configures the Windows policy responsible for automatically approving SSO permission requests from trusted applications.

---

# Overview

Windows can prompt users to approve **Single Sign-On (SSO)** requests when applications attempt to use their Microsoft Entra ID (Azure AD) credentials.

These prompts can interrupt users during application sign-in and create unnecessary help desk requests.

This remediation configures the Windows policy to automatically approve these requests by enabling the **AutoAcceptSsoPermission** policy.

---

# Use Case

This remediation is useful for organizations that want to:

* Eliminate unnecessary Windows SSO consent prompts
* Improve the Microsoft 365 sign-in experience
* Streamline authentication for Microsoft Entra ID applications
* Reduce user confusion during first-time application sign-in
* Standardize Windows authentication behavior across managed devices

---

# Requirements

* Microsoft Intune Remediations
* Run scripts as **SYSTEM**
* Windows 10 or Windows 11
* Microsoft Entra ID (Azure AD) joined or hybrid joined devices
* Administrative privileges

---

# Detection Logic

The detection script verifies that:

1. The registry path exists:

```text
HKLM\SOFTWARE\Policies\Microsoft\Windows\AAD
```

2. The registry value exists:

```text
AutoAcceptSsoPermission
```

3. The registry value:

* Is a **DWORD**
* Has a value of **1**

If any of these checks fail:

* Returns **Exit 1**
* Reports the device as **Non-Compliant**

If all checks succeed:

* Returns **Exit 0**
* Reports the device as **Compliant**

---

# Remediation Logic

The remediation script performs the following actions:

1. Creates the registry path if it does not already exist.
2. Creates or updates the policy value:

```text
HKLM\SOFTWARE\Policies\Microsoft\Windows\AAD
    AutoAcceptSsoPermission = 1 (DWORD)
```

3. Verifies successful execution.
4. Returns **Exit 0** upon successful remediation.

If an error occurs during configuration, the script returns **Exit 1**.

---

# Intune Configuration

| Setting                                     | Value                   |
| ------------------------------------------- | ----------------------- |
| Run this script using logged-on credentials | **No**                  |
| Run script in 64-bit PowerShell             | **Yes**                 |
| Enforce signature check                     | As required             |
| Schedule                                    | Organization preference |

---

# Registry

| Registry Path                                  | Name                      | Type  | Value |
| ---------------------------------------------- | ------------------------- | ----- | ----- |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\AAD` | `AutoAcceptSsoPermission` | DWORD | `1`   |

---

# Files

```text
Detect-SSO-Prompts.ps1
Remediate-SSO-Prompts.ps1
README.md
```

---

# Example Workflow

1. Deploy the detection and remediation scripts through Microsoft Intune.
2. Devices missing the policy or configured with an incorrect value are reported as **Non-Compliant**.
3. Intune executes the remediation script.
4. The required registry key and value are created or updated.
5. During the next detection cycle, the device reports as **Compliant**.

---

# Notes

* Designed specifically for **Microsoft Intune Remediations**.
* Executes under the **SYSTEM** account.
* Creates the required registry path automatically if it does not exist.
* Safe to deploy repeatedly and only changes the configured policy when necessary.
* Uses standard Intune remediation exit codes for accurate compliance reporting.
* This policy affects Windows SSO behavior for supported Microsoft Entra ID authentication scenarios.

---

# Known Limitations

* A user may need to sign out and back in, or restart affected applications, before the policy takes full effect.
* This remediation only configures the local Windows policy. Applications that implement their own authentication flows may continue to present their own consent or sign-in prompts.
* Devices that are not Microsoft Entra ID joined or hybrid joined may not benefit from this setting.

---

# Version History

| Version | Date       | Notes           |
| ------- | ---------- | --------------- |
| 1.0.0   | 2026-07-17 | Initial release |
