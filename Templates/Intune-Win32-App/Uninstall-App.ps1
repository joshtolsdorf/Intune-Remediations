<#
.SYNOPSIS
    Generic Intune Win32 app uninstall script template.

.DESCRIPTION
    Uninstalls an application using configurable values. Designed as a reusable
    template for Microsoft Intune Win32 app deployments.

.NOTES
    Script Name   : Uninstall-App.ps1
    Author        : Josh Tolsdorf
    Version       : 1.0.0
    Created       : yyyy-MM-dd
    Last Modified : yyyy-MM-dd
    Requires      : Run as SYSTEM via Microsoft Intune Remediations
#>

$PackageName = "AppName-Version"

$ProcessNamesToStop = @(
    "ProcessName"
)

$UninstallerFile = "UninstallerFileName.exe"
$UninstallArguments = "/quiet /norestart"

$LogPath = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\$PackageName-uninstall.log"

Start-Transcript -Path $LogPath -Force

try {
    foreach ($ProcessName in $ProcessNamesToStop) {
        Write-Host "Stopping process if running: $ProcessName"
        Stop-Process -Name $ProcessName -Force -ErrorAction SilentlyContinue
    }

    Write-Host "Uninstalling $PackageName..."

    $Process = Start-Process -FilePath $UninstallerFile -ArgumentList $UninstallArguments -Wait -PassThru

    if ($Process.ExitCode -eq 0) {
        Write-Host "$PackageName uninstalled successfully."
        Stop-Transcript
        exit 0
    }
    else {
        Write-Host "$PackageName uninstall failed. Exit code: $($Process.ExitCode)"
        Stop-Transcript
        exit $Process.ExitCode
    }
}
catch {
    Write-Host "Uninstall failed: $($_.Exception.Message)"
    Stop-Transcript
    exit 1
}