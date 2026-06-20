# Automatic Time Zone

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207.x-5391FE)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4)
![Microsoft Intune](https://img.shields.io/badge/Microsoft-Intune-00A4EF)
![Run As](https://img.shields.io/badge/Run%20As-SYSTEM-blue)
![Reboot](https://img.shields.io/badge/Reboot-Not%20Required-success)

Enable Automatic Time Zone on Windows devices using Microsoft Intune Proactive Remediations.

---

# Overview

This remediation configures the **tzautoupdate** service to enable Automatic Time Zone on Windows devices.

The remediation verifies the configuration after applying the change and only exits successfully when the expected state is confirmed.

---

# Use Case

Organizations with remote employees, hybrid workers, or traveling users may encounter incorrect time zone settings.

This remediation ensures Automatic Time Zone is enabled consistently across managed Windows devices.

---

# Requirements

* Windows 10 or Windows 11
* Microsoft Intune Remediations
* Execute as **SYSTEM**
* 64-bit PowerShell recommended

---

# Detection Logic

The detection script verifies:

| Item          | Expected Value                                         |
| ------------- | ------------------------------------------------------ |
| Registry Path | `HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate` |
| Value         | `Start`                                                |
| Expected      | `3`                                                    |

Exit codes:

| Exit Code | Meaning       |
| --------- | ------------- |
| `0`       | Compliant     |
| `1`       | Non-compliant |

---

# Remediation Logic

The remediation script:

1. Creates the registry path if necessary.
2. Sets the expected value.
3. Verifies the value after remediation.
4. Returns success only after verification.

---

# Intune Configuration

| Setting                         | Value |
| ------------------------------- | ----- |
| Run using logged-on credentials | No    |
| Enforce script signature check  | No    |
| Run in 64-bit PowerShell        | Yes   |

---

# Files

```text
Automatic-Time-Zone/
│
├── Detect-AutomaticTimeZone.ps1
├── Remediate-AutomaticTimeZone.ps1
└── README.md
```

---

# Testing

| Scenario                         | Result |
| -------------------------------- | ------ |
| Registry value already compliant | Pass   |
| Registry value non-compliant     | Pass   |
| Registry path missing            | Pass   |

---

# Notes

* No reboot required.
* Designed for Microsoft Intune Proactive Remediations.
* Follows the repository PowerShell template and documentation standards.

---

# Related Resources

* Repository Templates
* Root Documentation
* Microsoft Intune Remediations