# Microsoft Intune Remediations

![MIT License](https://img.shields.io/badge/License-MIT-green.svg)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207.x-5391FE)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4)
![Microsoft Intune](https://img.shields.io/badge/Microsoft-Intune-00A4EF)
![Status](https://img.shields.io/badge/Status-Actively%20Maintained-brightgreen)

A curated collection of **Microsoft Intune Proactive Remediations** built for enterprise endpoint management.

This repository focuses on **well-documented, reusable, and production-ready PowerShell remediations** with consistent standards, implementation guidance, and practical real-world solutions.

---

# Repository Goals

* 🚀 Enterprise-ready PowerShell remediations
* 📚 Comprehensive documentation
* 🔍 Consistent detection and remediation logic
* 🧩 Reusable templates for future projects
* 🎁 Share practical Microsoft Intune solutions
* 🗂️ Build a maintainable knowledge base for endpoint management

---

# Current Remediations

| Remediation             | Description                                                                                                |
| ----------------------- | ---------------------------------------------------------------------------------------------------------- |
| **Automatic Time Zone** | Enables Automatic Time Zone by configuring the `tzautoupdate` service and verifies successful remediation. |

Additional remediations will be added over time.

---

# Repository Structure

```text
Intune-Remediations
│
├── Docs
├── Images
├── Remediations
│   ├── Automatic-Time-Zone
│   ├── File-Extension-Show
│   ├── Persistent-Num-Lock
│   └── ...
|
├── .gitattributes
├── .gitignore
├── LICENSE
└── README.md
```

---

# Standards

Every remediation in this repository follows a consistent structure:

* ✅ Comment-based PowerShell help
* ✅ Semantic versioning
* ✅ Standardized error handling
* ✅ Verification after remediation
* ✅ Meaningful exit codes
* ✅ Consistent formatting
* ✅ Project-specific documentation

Each remediation contains:

```text
Remediation-Name/
│
├── Detect-RemediationName.ps1
├── Remediate-RemediationName.ps1
├── README.md
└── Images/
```

---

# Technologies

* Microsoft Intune
* PowerShell
* Windows 10 / Windows 11
* Microsoft Endpoint Manager
* Enterprise Automation

---

# Philosophy

This repository is intended to be more than a collection of scripts.

Each remediation is treated as a small project that includes:

* The problem being solved
* Detection methodology
* Remediation methodology
* Implementation guidance
* Verification logic
* Documentation and notes

The goal is to create a maintainable reference library for enterprise endpoint management.

---

# Contributing

Suggestions, improvements, and feedback are always welcome.

If you discover a better approach or identify an issue, feel free to open an issue or submit a pull request.

---

# About

Hi, I'm **Josh Tolsdorf**.

I'm an Infrastructure Engineer focused on Microsoft Intune, PowerShell, Microsoft 365, and enterprise automation.

This repository serves as a collection of reusable remediations, implementation notes, and practical solutions developed while managing modern Windows environments.

---

# License

This project is licensed under the **MIT License**. See the `LICENSE` file for details.
