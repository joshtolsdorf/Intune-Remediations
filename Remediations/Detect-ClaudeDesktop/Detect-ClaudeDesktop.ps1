<#
.SYNOPSIS
    Detects if Claude Desktop is installed on the system, either via user-profile install or MSIX package.
.DESCRIPTION
    Intended for Intune Remediations running as SYSTEM. Detects Claude Desktop installations for the currently logged-on user and all users.
.NOTES
    Script Name   : Detect-ClaudeDesktop.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-07-08
    Required      : Run as SYSTEM via Intune Remediation
#>

$Found = $false

# Check user-profile installs
$UserProfiles = Get-ChildItem 'C:\Users' -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notin @('Public', 'Default', 'Default User', 'All Users') }

foreach ($UserProfile in $UserProfiles) {
    $ClaudePath = Join-Path $UserProfile.FullName 'AppData\Local\AnthropicClaude'

    if (Test-Path $ClaudePath) {
        Write-Host "Claude Desktop found at: $ClaudePath"
        $Found = $true
    }
}

# Check MSIX / WindowsApps install
$ClaudeAppx = Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -like '*Claude*' -or
        $_.PackageFullName -like 'Claude_*'
    }

if ($ClaudeAppx) {
    foreach ($App in $ClaudeAppx) {
        Write-Host "Claude MSIX package found: $($App.PackageFullName)"
    }

    $Found = $true
}

if ($Found) {
    exit 1
}

Write-Host "Claude Desktop not detected."
exit 0
