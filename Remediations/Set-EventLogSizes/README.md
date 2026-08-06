# Configure Windows Event Log Sizes

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207.x-5391FE?style=for-the-badge)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4?style=for-the-badge)
![Microsoft Intune](https://img.shields.io/badge/Microsoft-Intune-00A4EF?style=for-the-badge)
![Run As](https://img.shields.io/badge/Run%20As-SYSTEM-blue?style=for-the-badge)
![Type](https://img.shields.io/badge/Type-Proactive%20Remediation-success?style=for-the-badge)

Detects and configures selected Windows troubleshooting and security event logs with a maximum size of **200 MB** using **Microsoft Intune Remediations**.

The detection script evaluates every configured event log available on the device. The remediation script updates non-compliant logs, verifies each change, and safely skips event channels that are not installed or available.

---

## Overview

Windows event logs provide essential information for endpoint troubleshooting, security investigations, application control auditing, Intune diagnostics, and incident response.

Default log sizes may not retain enough historical information on active endpoints. When an event log reaches its maximum size, older events may be overwritten before administrators can review them.

This remediation standardizes selected event logs at:

```text
200 MB
```

The scripts manage logs associated with:

* Windows PowerShell
* PowerShell Core
* Microsoft Defender
* Windows Update
* Microsoft Intune and MDM
* AppLocker
* Windows Defender Application Control
* Windows Code Integrity

---

## Features

* Configures selected Windows event logs to **200 MB**
* Detects logs that do not match the required size
* Supports Windows PowerShell and PowerShell Core
* Includes Microsoft Defender and Windows Update logs
* Includes Intune and MDM diagnostic logs
* Includes AppLocker and Code Integrity logs
* Skips event logs that do not exist on the device
* Verifies each updated log after remediation
* Reports compliant, updated, skipped, and failed logs
* Safe to deploy repeatedly

---

## Use Case

This remediation is useful for organizations that want to:

* Preserve additional event history for troubleshooting
* Improve endpoint investigation capabilities
* Retain PowerShell activity for longer periods
* Improve visibility into Microsoft Defender events
* Preserve Intune enrollment and MDM diagnostics
* Support AppLocker and WDAC auditing
* Standardize event-log capacity across managed Windows devices

---

## Requirements

* Microsoft Intune Remediations
* Windows 10 or Windows 11
* Windows PowerShell 5.1 or PowerShell 7.x
* Administrator or SYSTEM permissions
* 64-bit PowerShell execution recommended

---

## Configured Size

The required maximum size is defined in both scripts:

```powershell
$SizeMB = 200
$RequiredSizeBytes = [int64]$SizeMB * 1MB
```

For a 200 MB event log, the resulting byte value is:

```text
209715200
```

To use a different size, update `$SizeMB` in both scripts.

Example:

```powershell
$SizeMB = 100
```

The detection and remediation scripts must use the same configured value.

---

## Managed Event Logs

### PowerShell

| Event Log                                  |
| ------------------------------------------ |
| `Windows PowerShell`                       |
| `PowerShellCore/Operational`               |
| `Microsoft-Windows-PowerShell/Operational` |

### Microsoft Defender

| Event Log                                        |
| ------------------------------------------------ |
| `Microsoft-Windows-Windows Defender/Operational` |

### Windows Update

| Event Log                                           |
| --------------------------------------------------- |
| `Microsoft-Windows-WindowsUpdateClient/Operational` |

### Intune and MDM

| Event Log                                                                        |
| -------------------------------------------------------------------------------- |
| `Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin`       |
| `Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Operational` |

### AppLocker

| Event Log                                             |
| ----------------------------------------------------- |
| `Microsoft-Windows-AppLocker/EXE and DLL`             |
| `Microsoft-Windows-AppLocker/MSI and Script`          |
| `Microsoft-Windows-AppLocker/Packaged app-Deployment` |
| `Microsoft-Windows-AppLocker/Packaged app-Execution`  |

### WDAC and Code Integrity

| Event Log                                     |
| --------------------------------------------- |
| `Microsoft-Windows-CodeIntegrity/Operational` |

---

## Detection Logic

The detection script processes each configured event log and performs the following actions:

1. Queries the event log using `Get-WinEvent`.
2. Determines whether the event log exists on the device.
3. Skips unavailable event logs.
4. Reads the current `MaximumSizeInBytes` value.
5. Compares the current size with the required size of 200 MB.
6. Records any logs that cannot be evaluated.
7. Reports every available log that does not exactly match the required size.

The event log is queried using:

```powershell
Get-WinEvent -ListLog $Log -ErrorAction SilentlyContinue
```

---

## Detection Results

### Compliant

The detection script returns **Exit 0** when every available event log is configured for exactly 200 MB.

Example output:

```text
All 11 available event logs are configured for 200 MB. Skipped: 1.
```

### Non-Compliant

The detection script returns **Exit 1** when one or more available logs do not match the required size.

Example output:

```text
Event logs requiring a maximum size of 200 MB:
  Windows PowerShell (15 MB)
  Microsoft-Windows-Windows Defender/Operational (50 MB)
```

### Evaluation Failure

The detection script returns **Exit 1** when an event log exists but cannot be evaluated.

Example output:

```text
Unable to evaluate one or more event logs:
  Microsoft-Windows-CodeIntegrity/Operational - Access is denied.
```

### Unavailable Logs

Logs that do not exist on the device are skipped and do not make the device non-compliant.

Example output:

```text
Skipping unavailable log: PowerShellCore/Operational
```

The script also provides a summary of all skipped logs:

```text
The following logs do not exist on this device and were skipped:
  PowerShellCore/Operational
```

This allows the same remediation package to be deployed across devices that may not have every Windows feature or PowerShell version installed.

---

## Remediation Logic

The remediation script processes each configured event log and performs the following actions:

1. Confirms that the event log exists.
2. Skips unavailable event logs.
3. Reads the current maximum size.
4. Skips logs that are already configured for 200 MB.
5. Configures non-compliant logs using `wevtutil.exe`.
6. Checks the exit code returned by `wevtutil.exe`.
7. Queries the event log again.
8. Verifies that the resulting size is exactly 200 MB.
9. Records any configuration or verification failures.
10. Reports a final remediation summary.

---

## Configuration Command

Non-compliant event logs are updated using:

```powershell
wevtutil.exe set-log <LogName> /maxsize:<SizeInBytes>
```

The script explicitly uses the native Windows executable:

```text
%SystemRoot%\System32\wevtutil.exe
```

The PowerShell implementation is:

```powershell
$WevtutilOutput = & "$env:SystemRoot\System32\wevtutil.exe" `
    set-log $Log `
    "/maxsize:$RequiredSizeBytes" 2>&1
```

---

## Error Handling

The remediation script captures both:

* The exit code returned by `wevtutil.exe`
* Any text written to standard output or standard error

If `wevtutil.exe` returns a nonzero exit code, the script records the failure.

Example:

```text
Failed to configure Windows PowerShell - wevtutil.exe returned exit code 5. Access is denied.
```

If no additional error information is returned, the script reports:

```text
No additional error information was returned.
```

---

## Verification

After each log is updated, the script queries it again:

```powershell
$VerifiedConfiguration = Get-WinEvent `
    -ListLog $Log `
    -ErrorAction Stop
```

It then verifies:

```powershell
[int64]$VerifiedConfiguration.MaximumSizeInBytes -eq $RequiredSizeBytes
```

A log is only counted as successfully updated when the verification result exactly matches the configured size.

Example verification failure:

```text
Failed to configure Windows PowerShell - Verification returned 100 MB instead of 200 MB.
```

---

## Remediation Results

### Updated Log

```text
Configured: Windows PowerShell (200 MB)
```

### Already Compliant

```text
Already compliant: Microsoft-Windows-Windows Defender/Operational
```

### Unavailable Log

```text
Skipping unavailable log: PowerShellCore/Operational
```

### Successful Summary

```text
Event log remediation completed. Updated: 4; Already compliant: 7; Skipped: 1.
```

### Failed Summary

When one or more available logs cannot be configured, the script returns **Exit 1** and reports each failure:

```text
One or more event logs could not be configured:
  Failed to configure Windows PowerShell - Access is denied.
```

---

## Exit Codes

### Detection Script

| Exit Code | Meaning                                                      |
| --------: | ------------------------------------------------------------ |
|       `0` | All available event logs are compliant                       |
|       `1` | One or more logs are non-compliant or could not be evaluated |

### Remediation Script

| Exit Code | Meaning                                                         |
| --------: | --------------------------------------------------------------- |
|       `0` | All available event logs were configured successfully           |
|       `1` | One or more logs could not be configured or failed verification |

Unavailable logs are skipped and do not cause either script to fail.

---

## Intune Configuration

| Setting                                     | Recommended Value                         |
| ------------------------------------------- | ----------------------------------------- |
| Run this script using logged-on credentials | **No**                                    |
| Enforce script signature check              | As required                               |
| Run script in 64-bit PowerShell             | **Yes**                                   |
| Schedule                                    | Daily, weekly, or organization preference |

Running the scripts using logged-on credentials should be disabled so the remediation executes under the **SYSTEM** account.

---

## Files

```text
Detect-EventLogSizes.ps1
Remediate-EventLogSizes.ps1
README.md
```

---

## Example Workflow

1. Intune runs `Detect-EventLogSizes.ps1`.
2. The script evaluates each configured event log available on the device.
3. Event logs that do not exist are skipped.
4. If every available log is configured for 200 MB, the device reports as compliant.
5. If one or more logs have an incorrect size, the device reports as non-compliant.
6. Intune runs `Remediate-EventLogSizes.ps1`.
7. Non-compliant event logs are updated using `wevtutil.exe`.
8. Each modified log is queried again for verification.
9. Intune records the remediation output.
10. The next detection cycle confirms whether the device is compliant.

---

## Manual Testing

### Run Detection

Open an elevated PowerShell session and run:

```powershell
.\Detect-EventLogSizes.ps1
```

### Run Remediation

Open an elevated PowerShell session and run:

```powershell
.\Remediate-EventLogSizes.ps1
```

### Check a Specific Event Log

```powershell
Get-WinEvent -ListLog 'Windows PowerShell' |
    Select-Object LogName, MaximumSizeInBytes
```

### Display the Size in Megabytes

```powershell
$LogConfiguration = Get-WinEvent -ListLog 'Windows PowerShell'

[pscustomobject]@{
    LogName       = $LogConfiguration.LogName
    MaximumSizeMB = [math]::Round(
        $LogConfiguration.MaximumSizeInBytes / 1MB,
        2
    )
}
```

### Check All Managed Logs

```powershell
$Logs = @(
    'Windows PowerShell'
    'PowerShellCore/Operational'
    'Microsoft-Windows-PowerShell/Operational'
    'Microsoft-Windows-Windows Defender/Operational'
    'Microsoft-Windows-WindowsUpdateClient/Operational'
    'Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin'
    'Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Operational'
    'Microsoft-Windows-AppLocker/EXE and DLL'
    'Microsoft-Windows-AppLocker/MSI and Script'
    'Microsoft-Windows-AppLocker/Packaged app-Deployment'
    'Microsoft-Windows-AppLocker/Packaged app-Execution'
    'Microsoft-Windows-CodeIntegrity/Operational'
)

foreach ($Log in $Logs) {
    $LogConfiguration = Get-WinEvent `
        -ListLog $Log `
        -ErrorAction SilentlyContinue

    if (-not $LogConfiguration) {
        [pscustomobject]@{
            LogName       = $Log
            MaximumSizeMB = 'Unavailable'
        }

        continue
    }

    [pscustomobject]@{
        LogName       = $Log
        MaximumSizeMB = [math]::Round(
            $LogConfiguration.MaximumSizeInBytes / 1MB,
            2
        )
    }
}
```

---

## Customization

### Change the Maximum Size

Update the following variable in both scripts:

```powershell
$SizeMB = 200
```

For example:

```powershell
$SizeMB = 100
```

### Add an Event Log

Add the event log's exact channel name to the `$Logs` array in both scripts:

```powershell
$Logs = @(
    'Windows PowerShell'
    'Microsoft-Windows-Sysmon/Operational'
)
```

### Remove an Event Log

Remove or comment out its entry in the `$Logs` array in both scripts.

### Find Available Event Logs

List every registered event log:

```powershell
Get-WinEvent -ListLog *
```

Search for PowerShell-related logs:

```powershell
Get-WinEvent -ListLog *PowerShell*
```

You can also enumerate event channels using:

```powershell
wevtutil.exe enum-logs
```

The name added to `$Logs` must exactly match the registered event channel name.

---

## Storage Considerations

The scripts manage up to 12 event logs, each configured for a maximum size of 200 MB.

The theoretical maximum combined capacity is:

```text
12 × 200 MB = 2,400 MB
```

This is approximately:

```text
2.34 GB
```

Actual disk usage will vary because:

* Some logs may not exist on every device.
* Event logs do not necessarily consume their full configured maximum immediately.
* Log growth depends on endpoint activity and enabled auditing.
* Windows manages event-log file allocation independently.
* Some channels may remain mostly empty.

Organizations should consider available disk capacity before increasing the configured size or adding additional event logs.

---

## Notes

* Designed specifically for Microsoft Intune Remediations.
* Executes under the SYSTEM account.
* Applies only to event logs listed in the `$Logs` array.
* Does not clear or delete existing event-log entries.
* Increasing the maximum size allows more events to be retained before older records are overwritten.
* Logs unavailable on a particular Windows edition or configuration are safely skipped.
* The remediation uses `wevtutil.exe` for configuration and `Get-WinEvent` for validation.
* The scripts are idempotent and can be safely deployed repeatedly.
* Detection requires an exact size match.
* Logs configured above or below 200 MB are considered non-compliant.

---

## Known Limitations

* The scripts configure only the maximum event-log size.
* Log retention and overwrite behavior are not changed.
* Event-log channel enablement is not modified.
* Disabled event channels remain disabled.
* Group Policy, Intune configuration profiles, or another management platform may overwrite the configured values.
* Event logs protected by another management authority may revert after remediation.
* A log configured above 200 MB is still considered non-compliant because the detection script requires an exact match.
* The scripts do not configure the standard `Application`, `System`, or `Security` logs unless they are manually added to the `$Logs` array.

---

## Version History

| Version | Date       | Notes                                     |
| ------- | ---------- | ----------------------------------------- |
| 1.0.0   | 2026-08-06 | Initial detection and remediation release |
