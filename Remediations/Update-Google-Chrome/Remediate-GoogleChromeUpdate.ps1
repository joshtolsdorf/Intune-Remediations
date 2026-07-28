<#
.SYNOPSIS
    Remediation script to trigger a Google Chrome update check via the Google Update engine.
.DESCRIPTION
    This script is designed to be run as SYSTEM via Intune Remediation. It checks for the presence of the Google Update executable and, if found, launches it with the appropriate arguments to trigger a background update check for Google Chrome.
.NOTES
    Script Name   : Remediate-GoogleChromeUpdate.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-07-28
    Required      : Run as SYSTEM via Intune Remediation
#>

$UpdatePath = "${env:ProgramFiles(x86)}\Google\Update\GoogleUpdate.exe"
$Arguments  = '/ua /installsource scheduler'

if (-not (Test-Path -LiteralPath $UpdatePath)) {
    Write-Error "Google Update executable was not found: $UpdatePath"
    exit 1
}

try {
    Write-Output 'Launching the Google Chrome background update process...'

    $Process = Start-Process `
        -FilePath $UpdatePath `
        -ArgumentList $Arguments `
        -WindowStyle Hidden `
        -Wait `
        -PassThru `
        -ErrorAction Stop

    if ($Process.ExitCode -ne 0) {
        Write-Error "Google Update returned exit code $($Process.ExitCode)."
        exit 1
    }

    Write-Output 'Google Chrome update check completed successfully.'
    exit 0
}
catch {
    Write-Error "Failed to execute Google Update. $($_.Exception.Message)"
    exit 1
}