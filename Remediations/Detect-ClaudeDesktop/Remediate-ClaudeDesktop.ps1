<#
.SYNOPSIS
    Removes Claude Desktop installations for all users on the system.
.DESCRIPTION
    Intended for Intune Remediations running as SYSTEM. Removes Claude Desktop installations for the currently logged-on user and all users.
.NOTES
    Script Name   : Remediate-ClaudeDesktop.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-07-08
    Required      : Run as SYSTEM via Intune Remediation
#>

$ErrorActionPreference = 'Continue'

# Remove user-profile installs
$UserProfiles = Get-ChildItem 'C:\Users' -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notin @('Public', 'Default', 'Default User', 'All Users') }

foreach ($UserProfile in $UserProfiles) {
    $ClaudePath = Join-Path $UserProfile.FullName 'AppData\Local\AnthropicClaude'
    $UpdateExe  = Join-Path $ClaudePath 'Update.exe'

    if (Test-Path $UpdateExe) {
        Write-Host "Uninstalling Claude Desktop from: $ClaudePath"

        try {
            Start-Process `
                -FilePath $UpdateExe `
                -ArgumentList '--uninstall', '-s' `
                -Wait `
                -WindowStyle Hidden

            Start-Sleep -Seconds 5
        }
        catch {
            Write-Host "Failed to run uninstall for $ClaudePath. $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    if (Test-Path $ClaudePath) {
        Write-Host "Removing leftover Claude folder: $ClaudePath"
        Remove-Item -Path $ClaudePath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Remove MSIX / WindowsApps Claude package
$ClaudeAppx = Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -like '*Claude*' -or
        $_.PackageFullName -like 'Claude_*'
    }

foreach ($App in $ClaudeAppx) {
    Write-Host "Removing Claude MSIX package: $($App.PackageFullName)"

    try {
        Remove-AppxPackage -Package $App.PackageFullName -AllUsers -ErrorAction SilentlyContinue
    }
    catch {
        Write-Host "Failed AllUsers removal, trying per-package removal. $($_.Exception.Message)" -ForegroundColor Yellow

        try {
            Remove-AppxPackage -Package $App.PackageFullName -ErrorAction SilentlyContinue
        }
        catch {
            Write-Host "Failed to remove $($App.PackageFullName). $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "Claude Desktop remediation completed."
exit 0