<#
	Synopsis: Detects whether WSL is out of date. Intended for Intune detection usage.
	Author: Josh Tolsdorf | Last Updated: 2026-10-14 | Version: 1.0

	Exit codes:
	Exit 0 = Compliant / Not installed / Unable to determine
	Exit 1 = Update required
#>

$FallbackVersion = [Version]'3.0.3'

# Check WSL availability and installed version.
$WSL = Get-Command wsl.exe -ErrorAction SilentlyContinue

if (-not $WSL) {
    Write-Output 'WSL is not installed.'
    exit 0
}

$VersionOutput = (& $WSL.Source --version 2>&1 | Out-String) -replace "`0", ""

if ($VersionOutput -notmatch 'WSL version:\s*(\d+\.\d+\.\d+)') {
    Write-Output 'Unable to determine installed WSL version.'
    exit 0
}

$InstalledVersion = [Version]$Matches[1]

# Retrieve latest stable WSL release.
[Version]$RequiredVersion = $null

try {
    $Release = Invoke-RestMethod `
        -Uri 'https://api.github.com/repos/microsoft/WSL/releases/latest' `
        -Headers @{ 'User-Agent' = 'Intune-WSL-Detection' } `
        -TimeoutSec 15 `
        -ErrorAction Stop

    $LatestTag = $Release.tag_name.TrimStart('v', 'V')

    if (-not [Version]::TryParse($LatestTag, [ref]$RequiredVersion)) {
        throw "Invalid GitHub release version: $LatestTag"
    }
}
catch {
    Write-Output "GitHub lookup failed: $($_.Exception.Message)"
    $RequiredVersion = $FallbackVersion
}

# Compare installed and required versions.
if ($InstalledVersion -lt $RequiredVersion) {
    Write-Output "WSL is outdated. Installed: $InstalledVersion, Required: $RequiredVersion"
    exit 1
}

Write-Output "WSL is current. Installed: $InstalledVersion, Required: $RequiredVersion"
exit 0