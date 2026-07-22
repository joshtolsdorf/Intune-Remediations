<#
.SYNOPSIS
    Detects Microsoft Office default logging configuration and the Outlook Logging folder.

.DESCRIPTION
    Intended for Intune Remediations running as SYSTEM. Determines the currently logged-on user, checks the user's Outlook Logging folder, and verifies that DisableDefaultLogging is set to 1 for each configured Office application.

.NOTES
    Script Name   : Detect-OfficeDefaultLogging.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-07-22
    Requires      : Run as SYSTEM via Intune Remediation
#>

function Get-LoggedOnUserContext {
    [CmdletBinding()]
    param()

    try {
        $UserName = (Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop).UserName

        if ([string]::IsNullOrWhiteSpace($UserName)) {
            return $null
        }

        $SID = ([System.Security.Principal.NTAccount]$UserName).Translate(
            [System.Security.Principal.SecurityIdentifier]
        ).Value

        $ProfileListPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$SID"
        $ProfilePath = (Get-ItemPropertyValue `
            -Path $ProfileListPath `
            -Name 'ProfileImagePath' `
            -ErrorAction Stop).TrimEnd('\')

        [PSCustomObject]@{
            UserName    = $UserName
            SID         = $SID
            ProfilePath = $ProfilePath
            HkcuPath    = "Registry::HKEY_USERS\$SID"
        }
    }
    catch {
        Write-Output "Detection failed: unable to determine logged-on user context. $($_.Exception.Message)"
        return $null
    }
}

$RegistryValues = @(
    @{ Application = 'Outlook';    SubKey = 'Software\Policies\Microsoft\Office\16.0\Outlook\Logging' }
    @{ Application = 'Excel';      SubKey = 'Software\Policies\Microsoft\Office\16.0\Excel\Logging' }
    @{ Application = 'Word';       SubKey = 'Software\Policies\Microsoft\Office\16.0\Word\Logging' }
    @{ Application = 'OneNote';    SubKey = 'Software\Policies\Microsoft\Office\16.0\OneNote\Logging' }
    @{ Application = 'Access';     SubKey = 'Software\Policies\Microsoft\Office\16.0\Access\Logging' }
    @{ Application = 'PowerPoint'; SubKey = 'Software\Policies\Microsoft\Office\16.0\PowerPoint\Logging' }
    @{ Application = 'Publisher';  SubKey = 'Software\Policies\Microsoft\Office\16.0\Publisher\Logging' }
)

$UserContext = Get-LoggedOnUserContext

if (-not $UserContext) {
    exit 1
}

if (-not (Test-Path -LiteralPath $UserContext.HkcuPath)) {
    Write-Output "Detection failed: registry hive is not loaded for $($UserContext.UserName) [$($UserContext.SID)]."
    exit 1
}

$LoggingPath = Join-Path $UserContext.ProfilePath 'AppData\Local\Temp\Outlook Logging'
$FolderExists = Test-Path -LiteralPath $LoggingPath
$FolderSizeBytes = 0
$FileCount = 0

if ($FolderExists) {
    $LoggingFiles = @(Get-ChildItem -LiteralPath $LoggingPath -File -Recurse -Force -ErrorAction SilentlyContinue)
    $FolderSizeBytes = ($LoggingFiles | Measure-Object -Property Length -Sum).Sum

    if (-not $FolderSizeBytes) {
        $FolderSizeBytes = 0
    }

    $FileCount = $LoggingFiles.Count
}

$MissingValues = [System.Collections.Generic.List[string]]::new()
$ConfiguredValues = [System.Collections.Generic.List[string]]::new()

foreach ($Item in $RegistryValues) {
    $FullPath = Join-Path $UserContext.HkcuPath $Item.SubKey

    try {
        $Value = Get-ItemPropertyValue `
            -LiteralPath $FullPath `
            -Name 'DisableDefaultLogging' `
            -ErrorAction Stop

        if ($Value -eq 1) {
            $ConfiguredValues.Add($Item.Application)
        }
        else {
            $MissingValues.Add("$($Item.Application)=$Value")
        }
    }
    catch {
        $MissingValues.Add("$($Item.Application)=Missing")
    }
}

$FolderSizeMB = [math]::Round($FolderSizeBytes / 1MB, 2)

Write-Output "User: $($UserContext.UserName)"
Write-Output "Outlook Logging: Exists=$FolderExists; Files=$FileCount; Size=$FolderSizeMB MB"
Write-Output "Configured values: $($ConfiguredValues -join ', ')"

if ($MissingValues.Count -gt 0) {
    Write-Output "Missing or incorrect values: $($MissingValues -join ', ')"
}
else {
    Write-Output 'Missing or incorrect values: None'
}

if ($MissingValues.Count -gt 0) {
    Write-Output 'Status: Remediation required because one or more DisableDefaultLogging values are missing or incorrect.'
    exit 1
}

Write-Output 'Status: Compliant. All DisableDefaultLogging values are configured correctly.'
exit 0