<#
.SYNOPSIS
    Detects if the specified guest wireless network profile is saved on the system.
.DESCRIPTION
    Intended for Intune Remediations running as SYSTEM. Checks if the specified guest wireless network profile exists in the saved profiles.
.NOTES
    Script Name   : Detect-GuestNetwork.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-05-20
    Required      : Run as SYSTEM via Intune Remediation
#>

$SsidName = 'Your-Network-Name-Here'

$profiles = netsh wlan show profiles

if ($profiles -match [regex]::Escape($SsidName)) {
    Write-Output "Detected saved wireless profile: $SsidName"
    exit 1
}
else {
    Write-Output "Wireless profile not found: $SsidName"
    exit 0
}
