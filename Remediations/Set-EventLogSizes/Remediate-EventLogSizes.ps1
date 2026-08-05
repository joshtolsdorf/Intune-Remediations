<#
.SYNOPSIS
    Configures selected Windows event logs with the required maximum size.

.DESCRIPTION
    Sets commonly used Windows troubleshooting and security event logs to a maximum size of 200 MB. Logs that do not exist on the device are skipped. Each updated log is verified after configuration.

    Exit code 0 indicates that all available logs were configured successfully.
    Exit code 1 indicates that one or more available logs could not be configured or failed verification.

.NOTES
    Script Name   : Remediate-EventLogSizes.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-08-05
    Requires      : Administrator or SYSTEM privileges
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

$Failures = [System.Collections.Generic.List[string]]::new()
$SkippedLogs = [System.Collections.Generic.List[string]]::new()
$UpdatedCount = 0
$AlreadyCompliantCount = 0

foreach ($Log in $Logs) {
    try {
        $LogConfiguration = Get-WinEvent -ListLog $Log -ErrorAction Stop
    }
    catch [System.Diagnostics.Eventing.Reader.EventLogNotFoundException] {
        Write-Output "Skipping unavailable log: $Log"
        $SkippedLogs.Add($Log)
        continue
    }
    catch {
        $Failures.Add("Unable to evaluate $Log - $($_.Exception.Message)")
        continue
    }

    if ([int64]$LogConfiguration.MaximumSizeInBytes -eq $RequiredSizeBytes) {
        Write-Output "Already compliant: $Log"
        $AlreadyCompliantCount++
        continue
    }

    try {
        $null = & "$env:SystemRoot\System32\wevtutil.exe" set-log $Log "/maxsize:$RequiredSizeBytes" 2>&1

        if ($LASTEXITCODE -ne 0) {
            throw "wevtutil.exe returned exit code $LASTEXITCODE."
        }

        $VerifiedConfiguration = Get-WinEvent -ListLog $Log -ErrorAction Stop

        if ([int64]$VerifiedConfiguration.MaximumSizeInBytes -ne $RequiredSizeBytes) {
            $ActualSizeMB = [math]::Round($VerifiedConfiguration.MaximumSizeInBytes / 1MB, 2)
            throw "Verification returned $ActualSizeMB MB instead of $SizeMB MB."
        }

        Write-Output "Configured: $Log ($SizeMB MB)"
        $UpdatedCount++
    }
    catch {
        $Failures.Add("Failed to configure $Log - $($_.Exception.Message)")
    }
}

if ($SkippedLogs.Count -gt 0) {
    Write-Output 'The following logs do not exist on this device and were skipped:'
    $SkippedLogs | ForEach-Object { Write-Output "  $_" }
}

if ($Failures.Count -gt 0) {
    Write-Output 'One or more event logs could not be configured:'
    $Failures | ForEach-Object { Write-Output "  $_" }
    exit 1
}

Write-Output "Event log remediation completed. Updated: $UpdatedCount; Already compliant: $AlreadyCompliantCount; Skipped: $($SkippedLogs.Count)."
exit 0
