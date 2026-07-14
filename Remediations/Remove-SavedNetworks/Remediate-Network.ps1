<#
.SYNOPSIS
    Removes the specified guest wireless network profile if it is saved on the system.
.DESCRIPTION
    Intended for Intune Remediations running as SYSTEM. Deletes the specified guest wireless network profile from the saved profiles.
.NOTES
    Script Name   : Remediate-Network.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-05-20
    Required      : Run as SYSTEM via Intune Remediation
#>

$SsidName = 'Your-Network-Name-Here'

$profiles = netsh wlan show profiles

if ($profiles -match [regex]::Escape($SsidName)) {
    Write-Output "Removing saved wireless profile: $SsidName"

    netsh wlan delete profile name="$SsidName" | Out-Null

    $profilesAfter = netsh wlan show profiles

    if ($profilesAfter -match [regex]::Escape($SsidName)) {
        Write-Output "Failed to remove wireless profile: $SsidName"
        exit 1
    }
    else {
        Write-Output "Successfully removed wireless profile: $SsidName"
        exit 0
    }
}
else {
    Write-Output "$SsidName wireless profile not found. No remediation required."
    exit 0
}
