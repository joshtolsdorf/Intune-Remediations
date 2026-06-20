<#
.SYNOPSIS
    Remediates Show File Extensions for the current logged-on user.

.DESCRIPTION
    Intended for Intune Remediations running as SYSTEM. Creates the required HKU policy registry path for the currently logged-on user and sets HideFileExt to DWORD 0.

.NOTES
    Script Name   : Remediate-File-Extension-Show.ps1
    Author        : Josh Tolsdorf
    Version       : 1.0.0
    Created       : 2026-05-05
    Last Modified : 2026-06-20
    Requires      : Run as SYSTEM via Microsoft Intune Remediations
#>

function Get-LoggedOnUserContext {
    [CmdletBinding()]
    param()

    try {
        $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
        $userName = $computerSystem.UserName

        if ([string]::IsNullOrWhiteSpace($userName)) {
            return $null
        }

        $sid = ([System.Security.Principal.NTAccount]$userName).Translate(
            [System.Security.Principal.SecurityIdentifier]
        ).Value

        $userNameParts = $userName.Split('\', 2)
        $samAccountName = if ($userNameParts.Count -eq 2) { $userNameParts[1] } else { $userName }

        $candidateProfiles = Get-ChildItem -Path 'C:\Users' -Directory -Force -ErrorAction SilentlyContinue |
            Where-Object {
                $_.Name -notin @('Public', 'Default', 'Default User', 'All Users', 'defaultuser0') -and
                $_.Name -ieq $samAccountName
            }

        $profilePath = $null
        if ($candidateProfiles.Count -ge 1) {
            $profilePath = $candidateProfiles[0].FullName
        }

        [PSCustomObject]@{
            UserName       = $userName
            SID            = $sid
            SamAccountName = $samAccountName
            ProfilePath    = $profilePath
            HkcuPath       = "Registry::HKEY_USERS\$sid"
        }
    }
    catch {
        Write-Output "Failed to determine logged-on user context. $($_.Exception.Message)"
        return $null
    }
}

$RegistryKeys = @(
    @{
        Path  = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
        Name  = 'HideFileExt'
        Type  = 'DWORD'
        Value = 0
    }
)

$userContext = Get-LoggedOnUserContext

if (-not $userContext) {
    Write-Output 'No logged-on user context found. Remediation failed.'
    exit 1
}

foreach ($item in $RegistryKeys) {
    $fullPath = Join-Path -Path $userContext.HkcuPath -ChildPath $item.Path

    try {
        if (-not (Test-Path -Path $fullPath)) {
            New-Item -Path $fullPath -Force -ErrorAction Stop | Out-Null
            Write-Output "Created registry path: $fullPath"
        }

        New-ItemProperty `
            -Path $fullPath `
            -Name $item.Name `
            -Value $item.Value `
            -PropertyType $item.Type `
            -Force `
            -ErrorAction Stop | Out-Null

        Write-Output "Set $($item.Name) to $($item.Value) at $fullPath"
    }
    catch {
        Write-Output "Failed to remediate $($item.Name) at $fullPath. $($_.Exception.Message)"
        exit 1
    }
}

Write-Output "Remediation complete. All required registry settings configured for $($userContext.UserName)."
exit 0