<#
.SYNOPSIS
    Enables automatic time zone.

.DESCRIPTION
    Sets the tzautoupdate service Start value to 3 and verifies the value after remediation.

.NOTES
    Script Name   : Remediate-AutomaticTimeZone.ps1
    Author        : Josh Tolsdorf
    Version       : 1.0.0
    Last Modified : 2026-06-20
    Requires      : Run as SYSTEM via Intune Remediations
#>

$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate'
$ValueName = 'Start'
$ExpectedValue = 3

try {
    Set-ItemProperty -Path $RegistryPath -Name $ValueName -Value $ExpectedValue -Type DWord -Force -ErrorAction Stop

    $CurrentValue = Get-ItemPropertyValue -Path $RegistryPath -Name $ValueName -ErrorAction Stop

    if ($CurrentValue -eq $ExpectedValue) {
        Write-Output "Automatic time zone enabled successfully. $ValueName = $CurrentValue"
        exit 0
    }

    Write-Output "Automatic time zone remediation failed. Expected $ExpectedValue but found $CurrentValue."
    exit 1
}
catch {
    Write-Output "Failed to enable automatic time zone. $($_.Exception.Message)"
    exit 1
}