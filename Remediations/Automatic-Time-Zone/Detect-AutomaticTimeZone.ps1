<#
.SYNOPSIS
    Detects whether automatic time zone is enabled.

.DESCRIPTION
    Checks the tzautoupdate service Start value. Automatic time zone is considered enabled when Start equals 3.

.NOTES
    Script Name   : Detect-AutomaticTimeZone.ps1
    Author        : Josh Tolsdorf
    Version       : 1.0.0
    Last Modified : 2026-06-20
    Requires      : Run as SYSTEM via Intune Remediations
#>

$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate'
$ValueName = 'Start'
$ExpectedValue = 3

try {
    $CurrentValue = Get-ItemPropertyValue -Path $RegistryPath -Name $ValueName -ErrorAction Stop

    if ($CurrentValue -eq $ExpectedValue) {
        Write-Output "Automatic time zone is enabled. $ValueName = $CurrentValue"
        exit 0
    }

    Write-Output "Automatic time zone is not enabled. $ValueName = $CurrentValue"
    exit 1
}
catch {
    Write-Output "Failed to read automatic time zone registry value. $($_.Exception.Message)"
    exit 1
}