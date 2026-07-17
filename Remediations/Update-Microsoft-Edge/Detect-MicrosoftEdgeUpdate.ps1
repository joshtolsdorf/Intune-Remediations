<#
.SYNOPSIS
    Detect whether Microsoft Edge matches the current official Stable version.

.DESCRIPTION
    This script checks the installed version of Microsoft Edge on a Windows machine and compares it to the latest stable version available from Microsoft's release notes.
    
.NOTES
    Script Name   : Detect-MicrosoftEdgeUpdate.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-07-17
    Requires      : PowerShell 5.1 or later

#>

$ErrorActionPreference = 'Stop'

try {
    $edgePath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
    if (-not (Test-Path $edgePath)) { $edgePath = 'C:\Program Files\Microsoft\Edge\Application\msedge.exe' }
    if (-not (Test-Path $edgePath)) {
        Write-Output 'Edge not installed.'
        exit 1
    }

    $installed = [version](Get-Item $edgePath).VersionInfo.ProductVersion

    $page = Invoke-WebRequest -Uri 'https://learn.microsoft.com/en-us/deployedge/microsoft-edge-relnote-stable-channel'
    $match = [regex]::Match($page.Content, 'Stable\s+(\d+\.\d+\.\d+\.\d+)')
    if (-not $match.Success) { throw 'Unable to determine latest Edge Stable version.' }
    $latest = [version]$match.Groups[1].Value

    Write-Output "Installed: $installed"
    Write-Output "Latest   : $latest"

    if ($installed -ge $latest) { exit 0 } else { exit 1 }
}
catch {
    Write-Output $_.Exception.Message
    exit 1
}