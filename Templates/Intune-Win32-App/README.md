# Intune Win32 App Install/Uninstall Script Templates

![PowerShell](https://img.shields.io/badge/PowerShell-7%2B-blue)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey)
![Management](https://img.shields.io/badge/Microsoft-Intune-0078D4)

## Overview

These templates provide a reusable foundation for creating **Microsoft Intune Win32 application install and uninstall scripts**.

Rather than starting from scratch for every deployment, simply update the configurable variables at the top of each script and package them with your application files.

## Use Case

Use these templates when deploying applications through **Microsoft Intune Win32 Apps** that require custom installation or removal logic.

Common scenarios include:

* MSI installers
* EXE installers
* Silent application deployments
* Custom uninstall commands
* Process termination before uninstall
* Standardized logging and exit codes

## Features

* Configurable variables for easy reuse
* Consistent logging with PowerShell transcripts
* Proper Intune-compatible exit codes
* Built-in error handling
* Minimal changes required for new applications
* Supports both EXE and MSI installers

## Configuration

### Install Script

Update the following variables:

| Variable            | Description                                |
| ------------------- | ------------------------------------------ |
| `$PackageName`      | Friendly application name used for logging |
| `$InstallerFile`    | Installer executable or MSI                |
| `$InstallArguments` | Silent install arguments                   |

### Uninstall Script

Update the following variables:

| Variable              | Description                                |
| --------------------- | ------------------------------------------ |
| `$PackageName`        | Friendly application name used for logging |
| `$ProcessNamesToStop` | Processes to terminate before uninstall    |
| `$UninstallerFile`    | Uninstaller executable or `msiexec.exe`    |
| `$UninstallArguments` | Silent uninstall arguments                 |

## Example (MSI)

### Install

```powershell
$PackageName = "Application 1.0"
$InstallerFile = "msiexec.exe"
$InstallArguments = "/i `"Application.msi`" /qn /norestart"
```

### Uninstall

```powershell
$PackageName = "Application 1.0"
$ProcessNamesToStop = @(
    "Application"
)

$UninstallerFile = "msiexec.exe"
$UninstallArguments = "/x `"{PRODUCT-CODE-GUID}`" /qn /norestart"
```

## Logging

Both scripts automatically create a PowerShell transcript in:

```
C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\
```

Example:

```
Application-install.log
Application-uninstall.log
```

## Exit Codes

| Exit Code | Meaning                                          |
| --------- | ------------------------------------------------ |
| `0`       | Success                                          |
| `1`       | Script failure                                   |
| Other     | Installer/uninstaller returned its own exit code |

Returning native installer exit codes can simplify troubleshooting within Intune.

## Files

```
Install-App.ps1
Uninstall-App.ps1
README.md
```

## Notes

* Designed to run in the **SYSTEM** context unless otherwise required.
* Package the scripts alongside the application installer when creating the `.intunewin` package.
* Modify only the configuration variables—no additional script changes should be required for most deployments.

## Version History

| Version | Date       | Changes                  |
| ------- | ---------- | ------------------------ |
| 1.0     | 2026-06-20 | Initial template release |