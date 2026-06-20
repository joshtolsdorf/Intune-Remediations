# Remediation Templates

This directory contains the standard templates used throughout the **Intune-Remediations** repository.

The goal is to provide a consistent structure for every remediation, making projects easier to maintain, document, and understand.

---

# Included Templates

| Template                   | Purpose                                     |
| -------------------------- | ------------------------------------------- |
| **Detect-Template.ps1**    | Standard Intune detection script template   |
| **Remediate-Template.ps1** | Standard Intune remediation script template |

---

# Repository Standards

Every remediation should include:

```text
Remediation-Name/
│
├── Detect-RemediationName.ps1
├── Remediate-RemediationName.ps1
├── README.md
└── Images/
```

---

# PowerShell Standards

Every script should include:

* Comment-based help
* Semantic versioning
* Standardized error handling
* Verification after remediation
* Meaningful output messages
* Consistent formatting

---

# Documentation Standards

Every remediation README should contain:

* Overview
* Use Case
* Detection Logic
* Remediation Logic
* Intune Configuration
* Requirements
* Notes
* Version History

---

# Development Workflow

When creating a new remediation:

1. Copy the appropriate template files.
2. Rename the scripts.
3. Update the configuration variables.
4. Test the detection script.
5. Test the remediation script.
6. Document the solution.
7. Commit changes with a meaningful message.

---

# Versioning

Semantic versioning is recommended.

| Version   | Meaning           |
| --------- | ----------------- |
| **1.0.0** | Initial release   |
| **1.1.0** | New functionality |
| **1.1.1** | Bug fixes         |
| **2.0.0** | Breaking changes  |

---

# Purpose

The intent of these templates is to encourage consistency, readability, and maintainability across all Microsoft Intune Proactive Remediations contained within this repository.