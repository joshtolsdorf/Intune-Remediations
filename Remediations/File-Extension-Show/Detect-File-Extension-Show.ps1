<#
.SYNOPSIS
    Detects Show File Extensions is enabled for the current logged-on user.

.DESCRIPTION
    Intended for Intune Remediations running as SYSTEM. Detects whether the currently logged-on user's HKU policy registry value exists (HideFileExt) and is set to the required DWORD value of 0.

.NOTES
    Script Name   : Detect-File-Extension-Show.ps1
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
    Write-Output 'No logged-on user context found. Detection failed.'
    exit 1
}

$nonCompliant = @()

foreach ($item in $RegistryKeys) {
    $fullPath = Join-Path -Path $userContext.HkcuPath -ChildPath $item.Path

    try {
        if (-not (Test-Path -Path $fullPath)) {
            $nonCompliant += "Missing path: $fullPath"
            continue
        }

        $currentValue = Get-ItemProperty -Path $fullPath -Name $item.Name -ErrorAction Stop

        if ($currentValue.($item.Name) -ne $item.Value) {
            $nonCompliant += "Incorrect value: $fullPath\$($item.Name). Current: $($currentValue.($item.Name)); Expected: $($item.Value)"
        }
    }
    catch {
        $nonCompliant += "Missing or unreadable value: $fullPath\$($item.Name). $($_.Exception.Message)"
    }
}

if ($nonCompliant.Count -eq 0) {
    Write-Output "Compliant. All required registry settings are correct for $($userContext.UserName)."
    exit 0
}

Write-Output "Non-compliant registry settings found for $($userContext.UserName):"
$nonCompliant | ForEach-Object { Write-Output $_ }
exit 1
