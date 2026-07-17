<#
.SYNOPSIS
    Triggers the Microsoft Teams cache remediation.

.DESCRIPTION
    Always returns exit code 1 so the associated remediation script runs. Intended for an on-demand or narrowly targeted Intune Remediation.

.NOTES
    Script Name   : Detect-TeamsCache.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-07-17
#>

Write-Output 'Microsoft Teams cache cleanup is required.'
exit 1