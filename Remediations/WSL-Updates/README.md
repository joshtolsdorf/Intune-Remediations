# Update Windows Subsystem for Linux (WSL)

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207.x-5391FE?style=for-the-badge)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4?style=for-the-badge)
![Microsoft Intune](https://img.shields.io/badge/Microsoft-Intune-00A4EF?style=for-the-badge)
![Run As](https://img.shields.io/badge/Run%20As-SYSTEM-blue?style=for-the-badge)
![Type](https://img.shields.io/badge/Type-Proactive%20Remediation-success?style=for-the-badge)

Detects outdated installations of **Windows Subsystem for Linux (WSL)** and updates them through **Microsoft Intune Remediations**. Detection compares the installed WSL version against Microsoft's latest stable GitHub release, falling back to a predefined minimum version when the lookup fails.

---

## Overview

WSL can be updated independently of the Windows operating system. These scripts help keep existing WSL installations current without deploying a separate application package.

- **Detection:** Determines the installed WSL version, retrieves the latest stable release from GitHub, and compares versions.
- **Remediation:** Runs the native `wsl.exe --update` command and checks its exit code.
- **Scope:** Only devices with an identifiable installed WSL version are evaluated for updates. The scripts do not install WSL on devices where it is absent.

## Features

- Uses `wsl.exe --version` to identify the installed version.
- Checks the latest stable release through the official Microsoft WSL GitHub repository.
- Falls back to version **3.0.3** if the GitHub lookup fails.
- Handles null characters in the WSL command output.
- Uses native WSL updating rather than manually downloading an installer.
- Supports recurring execution through Intune Remediations.
- Reports actionable results and standard Intune exit codes.

## Requirements

- Windows 10 or Windows 11 with a supported, installed WSL version.
- Microsoft Intune Remediations.
- PowerShell with access to `wsl.exe`.
- **SYSTEM** execution context for remediation.
- Network access to `api.github.com` for live version detection; otherwise the fallback version is used.
- Network access to the appropriate WSL update source for remediation.

> **Important:** WSL must already be installed. This remediation does not enable Windows optional features, install a Linux distribution, or configure WSL settings.

## Configuration

The detection script defines a fallback version:

```powershell
$FallbackVersion = [Version]'3.0.3'
```

This value is used **only when the GitHub latest-release lookup fails**. It is not a fixed target when GitHub is accessible.

The latest stable release is retrieved from:

```text
https://api.github.com/repos/microsoft/WSL/releases/latest
```

The detection request uses a 15-second timeout and a custom `User-Agent` header.

## Detection Logic

`Detect-WSL-Update.ps1` performs the following checks:

1. Locates `wsl.exe` using `Get-Command`.
2. If WSL is unavailable, reports that it is not installed and exits `0`.
3. Runs `wsl.exe --version`, captures its output, and removes embedded null characters.
4. Extracts the first three numeric components from the `WSL version:` line.
5. If the installed version cannot be determined, exits `0`.
6. Queries the latest stable Microsoft WSL release from GitHub.
7. If the query fails or returns an invalid version, uses fallback version `3.0.3`.
8. Compares the installed version with the required version.

### Version Comparison

| Condition | Detection Result | Exit Code |
|---|---|---:|
| WSL executable not found | No remediation | `0` |
| Installed WSL version cannot be determined | No remediation | `0` |
| Installed version is lower than required | Update required | `1` |
| Installed version equals or exceeds required | Compliant | `0` |

Example non-compliant output:

```text
WSL is outdated. Installed: 2.6.3, Required: 3.0.3
```

Example compliant output:

```text
WSL is current. Installed: 3.0.3, Required: 3.0.3
```

If the GitHub lookup fails, the script reports the error before comparing against the fallback version:

```text
GitHub lookup failed: <error details>
```

> **Note:** An exit code of `0` can mean WSL is current, not installed, or that its version could not be determined. It should not be interpreted as proof that WSL is installed and up to date in every case.

## Remediation Logic

`Remediate-WSL-Update.ps1`:

1. Resolves `wsl.exe` with `Get-Command`.
2. Starts the native WSL updater.
3. Waits for the update command to finish.
4. Checks the process exit code.
5. Reports success for exit code `0`, or failure for any nonzero exit code or caught exception.

The update command is equivalent to:

```powershell
wsl.exe --update
```

The script launches it using:

```powershell
$Process = Start-Process `
    -FilePath $WSL.Source `
    -ArgumentList '--update' `
    -Wait `
    -PassThru `
    -NoNewWindow
```

Successful output:

```text
Starting WSL update...
WSL update command completed successfully.
```

Failed output:

```text
WSL remediation failed: <error details>
```

**The remediation validates the update command's exit code; it does not independently re-query the installed WSL version after updating.** The next detection cycle performs the version comparison again.

## Exit Codes

| Script | Exit Code | Meaning |
|---|---:|---|
| Detection | `0` | Current, not installed, or unable to determine installed version |
| Detection | `1` | Installed version is below the required version |
| Remediation | `0` | `wsl.exe --update` completed with exit code `0` |
| Remediation | `1` | Update command failed, returned a nonzero exit code, or raised an exception |

## Intune Configuration

| Setting | Recommended Value |
|---|---|
| Run this script using logged-on credentials | **No** |
| Enforce script signature check | Per organization policy |
| Run script in 64-bit PowerShell | **Yes** |
| Schedule | Daily or organization preference |

Deploy the detection and remediation scripts together as a Microsoft Intune Remediation package. Test against a pilot group before broad deployment.

## Files

```text
Detect-WSL-Update.ps1
Remediate-WSL-Update.ps1
README.md
```

## Example Workflow

1. Intune executes the detection script.
2. The script finds WSL version `2.6.3`.
3. The required version resolves to `3.0.3`.
4. Detection returns exit code `1`.
5. Intune executes the remediation script under SYSTEM.
6. The remediation runs `wsl.exe --update` and waits for completion.
7. If the updater exits successfully, remediation returns `0`.
8. A subsequent detection checks whether the installed version now meets the required version.

## Manual Testing

Run detection:

```powershell
.\Detect-WSL-Update.ps1
```

Run remediation from an elevated PowerShell session:

```powershell
.\Remediate-WSL-Update.ps1
```

Check the installed WSL version:

```powershell
wsl.exe --version
```

Manually request an update:

```powershell
wsl.exe --update
```

## Notes and Known Limitations

- The GitHub lookup requires network connectivity and may be affected by proxy, firewall, or API rate-limit restrictions.
- If GitHub cannot be reached, the fallback version can become outdated; review `$FallbackVersion` periodically.
- The detection script does not install WSL and intentionally treats missing WSL as compliant.
- The detection script also treats unrecognized WSL version output as compliant, preventing remediation when version detection is inconclusive.
- The detection script extracts three version components; it does not preserve a fourth component when present.
- The remediation does not check whether a reboot is required, restart WSL distributions, or verify the final installed version.
- WSL updates may be affected by enterprise update policies, network access, or device configuration.
- Test SYSTEM-context updates in your environment before production rollout.

## Version History

| Version | Date | Notes |
|---|---|---|
| 1.0 | 2026-10-14 | Initial WSL update detection and remediation scripts |
