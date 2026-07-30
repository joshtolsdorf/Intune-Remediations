<#
.SYNOPSIS
    Detects whether a specified MSI application is installed.

.DESCRIPTION
    Searches the 64-bit and 32-bit uninstall registry locations for the configured MSI Product Code.
    When the application is detected, the script exits with code 1 to trigger the associated Intune remediation script.

.NOTES
    Script Name   : Detect-ApplicationByProductCode.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-07-30
    Requires      : Windows PowerShell 5.1 or PowerShell 7.x
#>

# ============================================================
# Configuration
# ============================================================

$ApplicationName = 'Application Name'
$ProductCode     = '{00000000-0000-0000-0000-000000000000}'

# ============================================================
# Detection
# ============================================================

$RegistryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$ProductCode"
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$ProductCode"
)

$DetectedPath = $RegistryPaths |
    Where-Object { Test-Path -LiteralPath $_ } |
    Select-Object -First 1

if ($DetectedPath) {
    $Application = Get-ItemProperty -LiteralPath $DetectedPath -ErrorAction SilentlyContinue

    $InstalledName    = if ($Application.DisplayName) { $Application.DisplayName } else { $ApplicationName }
    $InstalledVersion = if ($Application.DisplayVersion) { $Application.DisplayVersion } else { 'Unknown' }

    Write-Output "$InstalledName version $InstalledVersion is installed. Remediation required."
    exit 1
}

Write-Output "$ApplicationName is not installed. No remediation required."
exit 0