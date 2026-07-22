# Clear Microsoft Teams Cache

![Microsoft Intune](https://img.shields.io/badge/Microsoft-Intune-00A4EF?style=for-the-badge)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4?style=for-the-badge)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207.x-5391FE?style=for-the-badge)
![Run As](https://img.shields.io/badge/Run%20As-SYSTEM-blue?style=for-the-badge)
![Type](https://img.shields.io/badge/Type-Proactive%20Remediation-success?style=for-the-badge)

Clears the **Microsoft Teams cache** for all local user profiles using **Microsoft Intune Remediations**.

This remediation is designed to run as **SYSTEM**, terminates all running Microsoft Teams processes, and removes cached data for both **new Microsoft Teams** and **classic Microsoft Teams**.

---

# Overview

Microsoft Teams cache corruption can cause a variety of issues, including:

* Missing or deleted Teams and channels
* Sign-in problems
* Stale SharePoint or OneDrive data
* Teams failing to load properly
* Missing chats or channel updates
* General application instability

This remediation provides a safe method for clearing Teams cache across all user profiles on a device without requiring manual intervention.

---

# Use Case

This remediation is useful for organizations that want to:

* Resolve Microsoft Teams caching issues
* Refresh Teams after SharePoint site changes or restores
* Troubleshoot synchronization problems
* Eliminate stale Teams data
* Standardize Teams cache cleanup across managed devices
* Execute an on-demand remediation through Microsoft Intune

---

# Requirements

* Microsoft Intune Remediations
* Run scripts as **SYSTEM**
* Windows 10 or Windows 11
* Microsoft Teams (new, classic, or both) installed

---

# Detection Logic

Unlike a traditional compliance remediation, this solution is designed to run **on demand**.

The detection script:

1. Always reports that remediation is required.
2. Returns:

```text
Exit 1
```

This causes Intune to execute the remediation script every time the package runs.

This approach is ideal when cache clearing is used as a troubleshooting tool rather than a compliance setting.

---

# Remediation Logic

The remediation script performs the following actions:

## 1. Stops Microsoft Teams

Terminates any running Teams processes, including:

* New Microsoft Teams (`ms-teams`)
* Classic Microsoft Teams (`Teams`)

A brief delay is introduced to ensure all processes have fully exited before cache removal begins.

---

## 2. Enumerates Local User Profiles

The script retrieves all non-system user profiles on the device using:

```powershell
Get-CimInstance Win32_UserProfile
```

Only valid local user profiles are processed.

---

## 3. Clears Teams Cache

For each user profile, the script clears cache data from both supported Teams installations.

### New Microsoft Teams

```text
%LocalAppData%\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams
```

### Classic Microsoft Teams

```text
%AppData%\Microsoft\Teams
```

If a cache directory is not present, the script skips it and continues processing.

---

## 4. Reports Completion

The script returns:

* **Exit 0** if all cache cleanup operations complete successfully.
* **Exit 1** if one or more errors occur during processing.

---

# Intune Configuration

| Setting                                     | Value                           |
| ------------------------------------------- | ------------------------------- |
| Run this script using logged-on credentials | **No**                          |
| Run script in 64-bit PowerShell             | **Yes**                         |
| Enforce signature check                     | As required                     |
| Schedule                                    | **Run On Demand** (recommended) |

---

# Cache Locations

| Teams Version           | Cache Location                                                               |
| ----------------------- | ---------------------------------------------------------------------------- |
| New Microsoft Teams     | `%LocalAppData%\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams` |
| Classic Microsoft Teams | `%AppData%\Microsoft\Teams`                                                  |

---

# Files

```text
Detect-TeamsCache.ps1
Remediate-TeamsCache.ps1
README.md
```

---

# Example Workflow

1. Deploy the remediation through Microsoft Intune.
2. Run the remediation on-demand against affected devices.
3. The detection script always returns **Exit 1**.
4. Intune launches the remediation script.
5. Running Teams processes are terminated.
6. Cache files are removed from all local user profiles.
7. Users launch Teams again, allowing a fresh cache to be created automatically.

---

# Notes

* Designed specifically for **Microsoft Intune Remediations**.
* Executes under the **SYSTEM** account.
* Supports both **new Microsoft Teams** and **classic Microsoft Teams**.
* Processes every local user profile on the device.
* Running Teams processes are terminated before cache removal to avoid locked files.
* Missing cache folders are skipped without generating errors.
* Intended for troubleshooting and maintenance rather than ongoing compliance.

---

# Known Limitations

* Users will need to reopen Microsoft Teams after remediation.
* Teams may take slightly longer to launch the first time while rebuilding its cache.
* Cached settings and temporary data are removed, but user accounts, chats, files, and Teams content remain unaffected because they are synchronized from Microsoft 365.
* If Teams is actively relaunched during remediation, some cache files may remain locked until the next execution.

---

# Version History

| Version | Date       | Notes           |
| ------- | ---------- | --------------- |
| 1.0.0   | 2026-07-17 | Initial release |
