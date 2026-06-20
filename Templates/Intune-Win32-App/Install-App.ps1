<#
.SYNOPSIS
    Generic Intune Win32 app install script template.

.DESCRIPTION
    Installs an application using configurable values. Designed as a reusable
    template for Microsoft Intune Win32 app deployments.

.NOTES
    Script Name   : Install-App.ps1
    Author        : Josh Tolsdorf
    Version       : 1.0.0
    Created       : yyyy-MM-dd
    Last Modified : yyyy-MM-dd
    Requires      : Run as SYSTEM via Microsoft Intune Remediations
#>

$PackageName = "AppName-Version"
$InstallerFile = "InstallerFileName.exe"
$InstallArguments = "/quiet /norestart"

$LogPath = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\$PackageName-install.log"

Start-Transcript -Path $LogPath -Force

try {
    Write-Host "Installing $PackageName..."

    $Process = Start-Process -FilePath ".\$InstallerFile" -ArgumentList $InstallArguments -Wait -PassThru

    if ($Process.ExitCode -eq 0) {
        Write-Host "$PackageName installed successfully."
        Stop-Transcript
        exit 0
    }
    else {
        Write-Host "$PackageName install failed. Exit code: $($Process.ExitCode)"
        Stop-Transcript
        exit $Process.ExitCode
    }
}
catch {
    Write-Host "Install failed: $($_.Exception.Message)"
    Stop-Transcript
    exit 1
}