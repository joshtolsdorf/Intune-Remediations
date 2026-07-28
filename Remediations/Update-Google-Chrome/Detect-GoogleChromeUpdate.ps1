<#
.SYNOPSIS
    Detects if Google Chrome is installed and if the Google Update engine is present. If both are detected, it triggers an update check.
.DESCRIPTION
    Intended for use as an Intune Remediation. Detects if Google Chrome is installed and if the Google Update engine is present. If both are detected, it triggers an update check.
.NOTES
    Script Name   : Detect-GoogleChromeUpdate.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-07-28
    Required      : Run as SYSTEM via Intune Remediation
#>

$ChromePaths = @(
    "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe"
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
)

$UpdatePath = "${env:ProgramFiles(x86)}\Google\Update\GoogleUpdate.exe"

$ChromeInstalled = $ChromePaths | Where-Object {
    Test-Path -LiteralPath $_
} | Select-Object -First 1

if (-not $ChromeInstalled) {
    Write-Output 'Google Chrome is not installed.'
    exit 0
}

if (-not (Test-Path -LiteralPath $UpdatePath)) {
    Write-Output 'Google Chrome is installed, but the Google Update engine was not found.'
    exit 1
}

Write-Output 'Google Chrome and the Google Update engine were detected. Triggering an update check.'
exit 1