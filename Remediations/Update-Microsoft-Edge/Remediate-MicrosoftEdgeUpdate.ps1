<#
.SYNOPSIS
    Remediate Microsoft Edge to the latest current Stable version.

.DESCRIPTION
    This script remediates Microsoft Edge to the latest stable version available from Microsoft's release notes.
    
.NOTES
    Script Name   : Remediate-MicrosoftEdgeUpdate.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-07-17
    Requires      : PowerShell 5.1 or later
#>

$ErrorActionPreference = 'Stop'

try {
    $work = 'C:\ProgramData\BrowserUpdate'
    $msi  = Join-Path $work 'MicrosoftEdgeEnterpriseX64.msi'
    New-Item -Path $work -ItemType Directory -Force | Out-Null

    $edgePath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
    if (-not (Test-Path $edgePath)) { $edgePath = 'C:\Program Files\Microsoft\Edge\Application\msedge.exe' }

    $installed = if (Test-Path $edgePath) { [version](Get-Item $edgePath).VersionInfo.ProductVersion } else { [version]'0.0.0.0' }

    $page = Invoke-WebRequest -Uri 'https://learn.microsoft.com/en-us/deployedge/microsoft-edge-relnote-stable-channel'
    $match = [regex]::Match($page.Content, 'Stable\s+(\d+\.\d+\.\d+\.\d+)')
    if (-not $match.Success) { throw 'Unable to determine latest Edge Stable version.' }
    $latest = [version]$match.Groups[1].Value

    if ($installed -ge $latest) {
        Write-Output "Edge already current: $installed"
        exit 0
    }

    Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/?linkid=2093437' -OutFile $msi
    $p = Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /qn /norestart" -Wait -PassThru

    if ($p.ExitCode -notin 0,3010,1641) {
        throw "Edge install failed with exit code $($p.ExitCode)"
    }

    Start-Sleep -Seconds 10
    $newVersion = [version](Get-Item 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe').VersionInfo.ProductVersion
    Write-Output "Edge updated to $newVersion"

    if ($newVersion -ge $latest) { exit 0 } else { exit 1 }
}
catch {
    Write-Output $_.Exception.Message
    exit 1
}
finally {
    Remove-Item $msi -Force -ErrorAction SilentlyContinue
}