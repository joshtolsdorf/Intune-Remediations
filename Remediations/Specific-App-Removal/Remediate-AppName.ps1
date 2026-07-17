<#
.SYNOPSIS
    This script will remove specific applications based on their name and version.

.NOTES
    Script Name   : Remove-AppName.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-06-01
#>

# Applications to remove (expand array as needed to accommodate all targeted applications)
$ApplicationsToRemove = @(
    @{ Name = 'Jabra Direct'; Version = '8.1.14601' }
)

$InstalledApps = Get-ItemProperty `
    HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* ,
    HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
    -ErrorAction SilentlyContinue

foreach ($App in $ApplicationsToRemove) {

    $MatchedApps = $InstalledApps | Where-Object {
        $_.DisplayName -like $App.Name -and
        $_.DisplayVersion -eq $App.Version
    }

    foreach ($Match in $MatchedApps) {

        Write-Output "Removing: $($Match.DisplayName) $($Match.DisplayVersion)"

        $UninstallString = $Match.UninstallString

        if ([string]::IsNullOrWhiteSpace($UninstallString)) {
            Write-Warning 'No uninstall string found.'
            continue
        }

        try {

            if ($UninstallString -match 'MsiExec') {

                $ProductCode = $Match.PSChildName

                Start-Process msiexec.exe `
                    -ArgumentList "/x $ProductCode /qn /norestart" `
                    -Wait
            }
            else {

                Start-Process cmd.exe `
                    -ArgumentList "/c $UninstallString /qn /norestart" `
                    -Wait
            }
        }
        catch {
            Write-Error $_
        }
    }
}

exit 0