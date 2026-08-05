<#
.SYNOPSIS
    Detects whether selected Windows event logs have the required maximum size.

.DESCRIPTION
    Checks commonly used Windows troubleshooting and security event logs to verify that each available log has a maximum size of 200 MB. Logs that do not exist on the device are skipped.

    Exit code 0 indicates that all available logs are compliant.
    Exit code 1 indicates that one or more available logs are not compliant or could not be evaluated.

.NOTES
    Script Name   : Detect-EventLogSizes.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-08-05
    Requires      : Windows PowerShell 5.1 or PowerShell 7.x
#>

$SizeMB = 200
$RequiredSizeBytes = [int64]$SizeMB * 1MB

$Logs = @(
    # PowerShell
    'Windows PowerShell'
    'PowerShellCore/Operational'
    'Microsoft-Windows-PowerShell/Operational'

    # Microsoft Defender
    'Microsoft-Windows-Windows Defender/Operational'

    # Windows Update
    'Microsoft-Windows-WindowsUpdateClient/Operational'

    # Intune and MDM
    'Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin'
    'Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Operational'

    # AppLocker
    'Microsoft-Windows-AppLocker/EXE and DLL'
    'Microsoft-Windows-AppLocker/MSI and Script'
    'Microsoft-Windows-AppLocker/Packaged app-Deployment'
    'Microsoft-Windows-AppLocker/Packaged app-Execution'

    # WDAC and Code Integrity
    'Microsoft-Windows-CodeIntegrity/Operational'
)

$NonCompliantLogs = [System.Collections.Generic.List[string]]::new()
$EvaluationFailures = [System.Collections.Generic.List[string]]::new()
$SkippedLogs = [System.Collections.Generic.List[string]]::new()
$AvailableLogCount = 0

foreach ($Log in $Logs) {
    try {
        $LogConfiguration = Get-WinEvent -ListLog $Log -ErrorAction Stop
        $AvailableLogCount++

        $CurrentSizeBytes = [int64]$LogConfiguration.MaximumSizeInBytes

        if ($CurrentSizeBytes -ne $RequiredSizeBytes) {
            $CurrentSizeMB = [math]::Round($CurrentSizeBytes / 1MB, 2)
            $NonCompliantLogs.Add("$Log ($CurrentSizeMB MB)")
        }
    }
    catch [System.Diagnostics.Eventing.Reader.EventLogNotFoundException] {
        Write-Output "Skipping unavailable log: $Log"
        $SkippedLogs.Add($Log)
    }
    catch {
        $EvaluationFailures.Add("$Log - $($_.Exception.Message)")
    }
}

if ($SkippedLogs.Count -gt 0) {
    Write-Output 'The following logs do not exist on this device and were skipped:'
    $SkippedLogs | ForEach-Object { Write-Output "  $_" }
}

if ($EvaluationFailures.Count -gt 0) {
    Write-Output 'Unable to evaluate one or more event logs:'
    $EvaluationFailures | ForEach-Object { Write-Output "  $_" }
    exit 1
}

if ($NonCompliantLogs.Count -gt 0) {
    Write-Output "Event logs requiring a maximum size of $SizeMB MB:"
    $NonCompliantLogs | ForEach-Object { Write-Output "  $_" }
    exit 1
}

Write-Output "All $AvailableLogCount available event logs are configured for $SizeMB MB."
exit 0
