# Intune Remediations

[MIT License] [PowerShell] [Windows 10/11] [Microsoft Intune] [Actively Maintained]

A curated collection of enterprise-ready **Microsoft Intune Proactive Remediations** with documentation, reusable templates, and implementation guidance.

The goal of this repository is to provide well-documented, reusable remediations that solve real-world administrative challenges while following consistent PowerShell and documentation standards.

---

## Repository Goals

* 📦 Enterprise-ready PowerShell scripts
* 📚 Clear implementation documentation
* 🔍 Consistent detection and remediation logic
* 🔄 Reusable templates for future projects
* 💡 Share practical solutions and lessons learned

---

# Current Remediations

| Remediation         | Description                                                                                                |
| ------------------- | ---------------------------------------------------------------------------------------------------------- |
| Automatic Time Zone | Enables Automatic Time Zone by configuring the `tzautoupdate` service and verifies successful remediation. |

Additional remediations will be added over time.

---

# Repository Structure

```
Intune-Remediations
│
├── README.md
├── LICENSE
├── Remediations
│   ├── Automatic-Time-Zone
│   ├── Show-Hidden-File-Extensions
│   ├── Persistent-Num-Lock
│   └── ...
│
├── Templates
│
└── Images
```

Each remediation contains:

* Detection script
* Remediation script
* Project-specific README
* Supporting documentation

---

# Standards

Every remediation follows the same design principles:

* Comment-based PowerShell help
* Consistent script formatting
* Verification after remediation
* Meaningful exit codes
* Documentation of implementation details
* Version history

---

# Technologies

* Microsoft Intune
* PowerShell
* Windows 10 / Windows 11
* Microsoft Endpoint Management
* Enterprise Automation

---

# About

I'm **Josh Tolsdorf**, an Infrastructure Engineer focused on Microsoft Intune, PowerShell, Microsoft 365, and enterprise automation.

This repository serves as a collection of reusable remediations, implementation notes, and practical solutions developed while managing modern Windows environments.

---

# License

This project is licensed under the MIT License.

Feel free to use, modify, and improve these scripts for your own environments.
