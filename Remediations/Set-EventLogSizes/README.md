# Configure Windows Event Log Sizes

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207.x-5391FE?style=for-the-badge)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4?style=for-the-badge)
![Microsoft Intune](https://img.shields.io/badge/Microsoft-Intune-00A4EF?style=for-the-badge)
![Run As](https://img.shields.io/badge/Run%20As-SYSTEM-blue?style=for-the-badge)
![Type](https://img.shields.io/badge/Type-Proactive%20Remediation-success?style=for-the-badge)

Detects and configures selected Windows troubleshooting and security event logs with a maximum size of **200 MB** using **Microsoft Intune Remediations**.

The detection script evaluates every supported log available on the device. The remediation script updates non-compliant logs, verifies the resulting configuration, and safely skips event channels that are unavailable.

---

## Overview

Windows event logs are essential for endpoint troubleshooting, security investigations, application control auditing, Intune diagnostics, and incident response.

Default log sizes may be too small to retain enough historical data, particularly on actively used endpoints. When a log reaches its maximum size, older events may be overwritten before administrators have an opportunity to review them.

This remediation standardizes selected event logs at:

```text
200 MB
```

The scripts focus on logs associated with:

* PowerShell
* Microsoft Defender
* Windows Update
* Microsoft Intune and MDM
* AppLocker
* Windows Defender Application Control
* Windows Code Integrity

---

## Features

* Configures selected event logs to **200 MB**
* Detects logs that do not match the required size
* Supports Windows PowerShell and PowerShell Core logs
* Includes Microsoft Defender and Windows Update logs
* Includes Intune and MDM diagnostic logs
* Includes AppLocker and Code Integrity logs
* Skips event logs that are unavailable on a device
* Verifies every change after remediation
* Reports updated, compliant, and skipped log counts
* Safe to deploy repeatedly

---

## Use Case

This remediation is useful for organizations that want to:

* Preserve additional event history for troubleshooting
* Improve endpoint investigation capabilities
* Retain PowerShell activity for a longer period
* Improve visibility into Microsoft Defender events
* Retain Intune enrollment and MDM diagnostic information
* Support AppLocker or WDAC auditing
* Standardize event log capacity across managed devices

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

To use a different size, update `$SizeMB` in both the detection and remediation scripts.

For example:

```powershell
$SizeMB = 100
```

The scripts automatically convert the configured value from megabytes to bytes before evaluating or updating the event logs.

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

1. Queries the event log using:

```powershell
Get-WinEvent -ListLog $Log
```

2. Reads the current value of:

```powershell
MaximumSizeInBytes
```

3. Compares the current maximum size with the required size of **200 MB**.
4. Skips logs that do not exist on the device.
5. Records logs that could not be evaluated.
6. Reports every available log that is not compliant.

---

## Detection Results

### Compliant

The detection script returns **Exit 0** when every available event log is configured for exactly 200 MB.

Example output:

```text
All 12 available event logs are configured for 200 MB.
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

The detection script also returns **Exit 1** when an available event log cannot be evaluated.

Example output:

```text
Unable to evaluate one or more event logs:
  Microsoft-Windows-CodeIntegrity/Operational - Access is denied.
```

### Unavailable Logs

Logs that are not present on the device are skipped and do not make the device non-compliant.

Example:

```text
Skipping unavailable log: PowerShellCore/Operational
```

This allows the same scripts to be deployed across devices that may not have every Windows feature or PowerShell version installed.

---

## Remediation Logic

The remediation script processes each configured event log and performs the following actions:

1. Confirms that the event log exists.
2. Reads its current maximum size.
3. Skips logs that are already configured for 200 MB.
4. Configures non-compliant logs using `wevtutil.exe`.
5. Queries the event log again after configuration.
6. Verifies that the resulting size is exactly 200 MB.
7. Records any configuration or verification failures.
8. Reports a final remediation summary.

---

## Configuration Command

Non-compliant event logs are updated using:

```powershell
wevtutil.exe set-log <LogName> /maxsize:<SizeInBytes>
```

The script executes the command using the native 64-bit Windows utility:

```text
%SystemRoot%\System32\wevtutil.exe
```

For a 200 MB configuration, the byte value passed to `wevtutil.exe` is:

```text
209715200
```

---

## Verification

After each event log is updated, the script queries it again:

```powershell
$VerifiedConfiguration = Get-WinEvent -ListLog $Log
```

It then verifies:

```powershell
$VerifiedConfiguration.MaximumSizeInBytes -eq $RequiredSizeBytes
```

The log is only counted as successfully updated when the verification result matches the required size.

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

### Verification Failure

```text
Failed to configure Windows PowerShell - Verification returned 100 MB instead of 200 MB.
```

### Successful Summary

```text
Event log remediation completed. Updated: 4; Already compliant: 7; Skipped: 1.
```

---

## Exit Codes

### Detection Script

| Exit Code | Meaning                                                      |
| --------: | ------------------------------------------------------------ |
|       `0` | All available logs are compliant                             |
|       `1` | One or more logs are non-compliant or could not be evaluated |

### Remediation Script

| Exit Code | Meaning                                                         |
| --------: | --------------------------------------------------------------- |
|       `0` | All available logs were configured successfully                 |
|       `1` | One or more logs could not be configured or failed verification |

Unavailable event logs are skipped and do not cause either script to fail.

---

## Intune Configuration

| Setting                                     | Recommended Value                         |
| ------------------------------------------- | ----------------------------------------- |
| Run this script using logged-on credentials | **No**                                    |
| Enforce script signature check              | As required                               |
| Run script in 64-bit PowerShell             | **Yes**                                   |
| Schedule                                    | Daily, weekly, or organization preference |

Running the scripts using logged-on credentials should be disabled so that the remediation executes under the **SYSTEM** account.

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
3. Logs that do not exist are skipped.
4. If every available log is set to 200 MB, the device reports as compliant.
5. If one or more logs have an incorrect size, the device reports as non-compliant.
6. Intune runs `Remediate-EventLogSizes.ps1`.
7. Non-compliant logs are configured using `wevtutil.exe`.
8. Each updated log is queried again for verification.
9. The next detection cycle confirms the device is compliant.

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

### Check a Specific Log

```powershell
Get-WinEvent -ListLog 'Windows PowerShell' |
    Select-Object LogName, MaximumSizeInBytes
```

### Display the Size in Megabytes

```powershell
$Log = Get-WinEvent -ListLog 'Windows PowerShell'

[pscustomobject]@{
    LogName       = $Log.LogName
    MaximumSizeMB = [math]::Round($Log.MaximumSizeInBytes / 1MB, 2)
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
    try {
        $Configuration = Get-WinEvent -ListLog $Log -ErrorAction Stop

        [pscustomobject]@{
            LogName       = $Log
            MaximumSizeMB = [math]::Round(
                $Configuration.MaximumSizeInBytes / 1MB,
                2
            )
        }
    }
    catch [System.Diagnostics.Eventing.Reader.EventLogNotFoundException] {
        [pscustomobject]@{
            LogName       = $Log
            MaximumSizeMB = 'Unavailable'
        }
    }
}
```

---

## Customization

### Change the Maximum Size

Update the following value in both scripts:

```powershell
$SizeMB = 200
```

### Add an Event Log

Add the event log's exact channel name to the `$Logs` array in both scripts:

```powershell
$Logs = @(
    'Windows PowerShell'
    'Microsoft-Windows-Sysmon/Operational'
)
```

### Find Event Log Names

List available event logs using:

```powershell
Get-WinEvent -ListLog *
```

Search for a specific category:

```powershell
Get-WinEvent -ListLog *PowerShell*
```

You can also use:

```powershell
wevtutil.exe enum-logs
```

The channel name must match the event log's exact name.

---

## Notes

* Designed specifically for Microsoft Intune Remediations.
* Executes under the SYSTEM account.
* Applies only to event logs listed in the `$Logs` array.
* Does not clear or overwrite existing event log entries during remediation.
* Increasing the maximum size allows each log to retain more events before older records are overwritten.
* Logs unavailable on a particular Windows edition or configuration are safely skipped.
* The remediation uses `wevtutil.exe` for configuration and `Get-WinEvent` for verification.
* The script is idempotent and can be safely deployed repeatedly.
* Detection requires an exact size match rather than accepting any value greater than 200 MB.

---

## Storage Considerations

The scripts manage up to 12 event logs, each configured for a maximum size of 200 MB.

Theoretical maximum combined capacity:

```text
12 × 200 MB = 2,400 MB
```

This is approximately:

```text
2.34 GB
```

Actual disk usage will vary because:

* Some logs may not exist on every device.
* Event logs do not immediately consume their full configured maximum.
* Log growth depends on endpoint activity and enabled auditing.
* Windows manages event log file allocation independently.

Organizations should consider available disk capacity before increasing the configured size or adding additional logs.

---

## Known Limitations

* The scripts configure only maximum log size.
* Log retention and overwrite behavior are not modified.
* Event log channel enablement is not changed.
* Disabled event channels remain disabled.
* A log configured above 200 MB is considered non-compliant because detection requires an exact match.
* Event channels protected by another management authority may revert after remediation.
* Group Policy or another configuration platform may override the values configured by these scripts.

---

## Version History

| Version | Date       | Notes                                     |
| ------- | ---------- | ----------------------------------------- |
| 1.0.0   | 2026-08-04 | Initial detection and remediation release |
