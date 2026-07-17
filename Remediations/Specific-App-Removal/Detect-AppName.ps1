<#
.SYNOPSIS
    This script will detect the presence of specific applications on a Windows system.

.NOTES
    Script Name   : Detect-AppName.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-06-01
#>

# Applications to detect for removal (expand array as needed to accommodate all targeted applications)
$ApplicationsToRemove = @(
    @{ Name = 'Application Name'; Version = '1.0.0' }
)

$InstalledApps = Get-ItemProperty `
    HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* ,
    HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
    -ErrorAction SilentlyContinue

foreach ($App in $ApplicationsToRemove) {

    $Match = $InstalledApps | Where-Object {
        $_.DisplayName -like $App.Name -and
        $_.DisplayVersion -eq $App.Version
    }

    if ($Match) {
        Write-Output "Detected: $($App.Name) $($App.Version)"
        exit 1
    }
}

Write-Output 'No targeted applications detected.'
exit 0
