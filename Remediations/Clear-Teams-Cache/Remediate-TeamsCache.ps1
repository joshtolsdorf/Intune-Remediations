<#
.SYNOPSIS
    Clears Microsoft Teams cache for all local user profiles.

.DESCRIPTION
    Terminates running Microsoft Teams processes and clears cache data for both new Microsoft Teams and classic Microsoft Teams.
    Designed to run as an Intune Remediation under the SYSTEM account.

.NOTES
    Script Name   : Remediate-TeamsCache.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-07-17
#>

$ErrorActionPreference = 'Stop'
$RemediationFailed = $false

# ============================================================
# Terminate Microsoft Teams
# ============================================================

Write-Host 'Stopping Microsoft Teams processes...' -ForegroundColor Yellow

$TeamsProcesses = @(
    'ms-teams'
    'Teams'
)

foreach ($ProcessName in $TeamsProcesses) {
    $Instances = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue

    if (-not $Instances) {
        Write-Host "$ProcessName is not running." -ForegroundColor Cyan
        continue
    }

    try {
        $Instances | Stop-Process -Force -ErrorAction Stop
        Write-Host "Stopped $ProcessName." -ForegroundColor Green
    }
    catch {
        Write-Host "Unable to stop $ProcessName. $($_.Exception.Message)" -ForegroundColor Red
        $RemediationFailed = $true
    }
}

Start-Sleep -Seconds 3

# ============================================================
# Get Local User Profiles
# ============================================================

Write-Host 'Retrieving local user profiles...' -ForegroundColor Yellow

$UserProfiles = Get-CimInstance -ClassName Win32_UserProfile |
    Where-Object {
        -not $_.Special -and
        $_.LocalPath -like "$env:SystemDrive\Users\*" -and
        (Test-Path -LiteralPath $_.LocalPath)
    }

if (-not $UserProfiles) {
    Write-Host 'No applicable local user profiles were found.' -ForegroundColor Red
    exit 1
}

# ============================================================
# Clear Microsoft Teams Cache
# ============================================================

foreach ($UserProfile in $UserProfiles) {
    $ProfilePath = $UserProfile.LocalPath
    $UserName = Split-Path -Path $ProfilePath -Leaf

    Write-Host "Processing Teams cache for $UserName..." -ForegroundColor Yellow

    $CachePaths = @(
        # New Microsoft Teams
        (Join-Path -Path $ProfilePath -ChildPath 'AppData\Local\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams')

        # Classic Microsoft Teams
        (Join-Path -Path $ProfilePath -ChildPath 'AppData\Roaming\Microsoft\Teams')
    )

    foreach ($CachePath in $CachePaths) {
        if (-not (Test-Path -LiteralPath $CachePath)) {
            Write-Host "Cache path not present: $CachePath" -ForegroundColor Cyan
            continue
        }

        try {
            Remove-Item -Path (Join-Path -Path $CachePath -ChildPath '*') -Recurse -Force -ErrorAction Stop

            Write-Host "Cleared: $CachePath" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to clear: $CachePath" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            $RemediationFailed = $true
        }
    }
}

# ============================================================
# Return Result
# ============================================================

if ($RemediationFailed) {
    Write-Host 'Microsoft Teams cache remediation completed with one or more errors.' -ForegroundColor Red
    exit 1
}

Write-Host 'Microsoft Teams cache remediation completed successfully.' -ForegroundColor Green
exit 0