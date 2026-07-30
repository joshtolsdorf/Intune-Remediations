<#
.SYNOPSIS
    Uninstalls a specified MSI application.

.DESCRIPTION
    Searches the 64-bit and 32-bit uninstall registry locations for the configured MSI Product Code and silently uninstalls the application.
    The script verifies that the application's Product Code is no longer present after the uninstall process completes.

.NOTES
    Script Name   : Remediate-ApplicationByProductCode.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-07-30
    Requires      : Windows PowerShell 5.1 or PowerShell 7.x
    Execution     : SYSTEM
#>

# ============================================================
# Configuration
# ============================================================

$ApplicationName = 'Application Name'
$ProductCode     = '{00000000-0000-0000-0000-000000000000}'

$UninstallExecutable = "$env:SystemRoot\System32\msiexec.exe"

$UninstallArguments = @(
    '/x'
    $ProductCode
    '/qn'
    '/norestart'
)

# ============================================================
# Application Detection
# ============================================================

$RegistryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$ProductCode"
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$ProductCode"
)

$DetectedPath = $RegistryPaths |
    Where-Object { Test-Path -LiteralPath $_ } |
    Select-Object -First 1

if (-not $DetectedPath) {
    Write-Output "$ApplicationName is not installed. No remediation required."
    exit 0
}

$Application = Get-ItemProperty -LiteralPath $DetectedPath -ErrorAction SilentlyContinue

$InstalledName    = if ($Application.DisplayName) { $Application.DisplayName } else { $ApplicationName }
$InstalledVersion = if ($Application.DisplayVersion) { $Application.DisplayVersion } else { 'Unknown' }

Write-Output "Detected $InstalledName version $InstalledVersion."
Write-Output "Beginning silent uninstall."

# ============================================================
# Application Uninstall
# ============================================================

try {
    $Process = Start-Process `
        -FilePath $UninstallExecutable `
        -ArgumentList $UninstallArguments `
        -Wait `
        -PassThru `
        -WindowStyle Hidden `
        -ErrorAction Stop
}
catch {
    Write-Output "Failed to start the uninstall process. $($_.Exception.Message)"
    exit 1
}

$SuccessfulExitCodes = @(
    0     # Successful uninstall
    1605  # Product is not installed
    1614  # Product is already uninstalled
    1641  # Successful uninstall; restart initiated
    3010  # Successful uninstall; restart required
)

if ($Process.ExitCode -notin $SuccessfulExitCodes) {
    Write-Output "The uninstall process failed with exit code $($Process.ExitCode)."
    exit 1
}

# ============================================================
# Post-Uninstall Verification
# ============================================================

$ApplicationStillInstalled = $RegistryPaths |
    Where-Object { Test-Path -LiteralPath $_ } |
    Select-Object -First 1

if ($ApplicationStillInstalled) {
    Write-Output "$ApplicationName is still detected after the uninstall process completed."
    exit 1
}

if ($Process.ExitCode -in 1641, 3010) {
    Write-Output "$ApplicationName was successfully uninstalled. A restart may be required."
}
else {
    Write-Output "$ApplicationName was successfully uninstalled."
}

exit 0