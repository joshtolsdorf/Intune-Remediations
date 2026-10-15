<#
    Synopsis: Updates WSL using Intune Remediations.
	Author: Joshua Tolsdorf | Last Updated: 2026-10-14 | Version: 1.0

    Requirements:
    WSL must be installed.
    Script should be run under SYSTEM context.
    
    Exit codes: 
    Exit 0 = Update successful
    Exit 1 = Update failed
#>

try {
    $WSL = Get-Command wsl.exe -ErrorAction Stop

    Write-Output 'Starting WSL update...'

    $Process = Start-Process `
        -FilePath $WSL.Source `
        -ArgumentList '--update' `
        -Wait `
        -PassThru `
        -NoNewWindow

    if ($Process.ExitCode -ne 0) {
        throw "WSL update failed with exit code $($Process.ExitCode)."
    }

    Write-Output 'WSL update command completed successfully.'
    exit 0
}
catch {
    Write-Output "WSL remediation failed: $($_.Exception.Message)"
    exit 1
}