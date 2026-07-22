<#
.SYNOPSIS
    Disables Microsoft Office default logging and removes accumulated Outlook logs.

.DESCRIPTION
    Intended for Intune Remediations running as SYSTEM. Determines the currently logged-on user, creates any missing DisableDefaultLogging registry values, stops processes that can lock the Outlook Logging folder, removes the folder,
    and reports the amount of disk space recovered.

.NOTES
    Script Name   : Remediate-OfficeDefaultLogging.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-07-22
    Requires      : Run as SYSTEM via Intune Remediation

    WARNING:
    This remediation closes running Microsoft Office applications so locked ETL files can be removed. Unsaved work may be lost.
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
        Write-Output "Remediation failed: unable to determine logged-on user context. $($_.Exception.Message)"
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

$OfficeProcesses = @(
    'OUTLOOK',
    'WINWORD',
    'EXCEL',
    'POWERPNT',
    'ONENOTE',
    'MSACCESS',
    'MSPUB',
    'VISIO',
    'WINPROJ',
    'MSOSYNC',
    'SDXHelper'
)

$UserContext = Get-LoggedOnUserContext

if (-not $UserContext) {
    exit 1
}

if (-not (Test-Path -LiteralPath $UserContext.HkcuPath)) {
    Write-Output "Remediation failed: registry hive is not loaded for $($UserContext.UserName) [$($UserContext.SID)]."
    exit 1
}

$CreatedValues = [System.Collections.Generic.List[string]]::new()
$CorrectedValues = [System.Collections.Generic.List[string]]::new()
$ExistingValues = [System.Collections.Generic.List[string]]::new()
$FailedValues = [System.Collections.Generic.List[string]]::new()

foreach ($Item in $RegistryValues) {
    $FullPath = Join-Path $UserContext.HkcuPath $Item.SubKey
    $PreviousValue = $null
    $ValueExisted = $false

    try {
        if (Test-Path -LiteralPath $FullPath) {
            try {
                $PreviousValue = Get-ItemPropertyValue `
                    -LiteralPath $FullPath `
                    -Name 'DisableDefaultLogging' `
                    -ErrorAction Stop

                $ValueExisted = $true
            }
            catch {}
        }

        New-Item -Path $FullPath -Force -ErrorAction Stop | Out-Null

        New-ItemProperty `
            -Path $FullPath `
            -Name 'DisableDefaultLogging' `
            -PropertyType DWord `
            -Value 1 `
            -Force `
            -ErrorAction Stop | Out-Null

        $VerifiedValue = Get-ItemPropertyValue `
            -LiteralPath $FullPath `
            -Name 'DisableDefaultLogging' `
            -ErrorAction Stop

        if ($VerifiedValue -ne 1) {
            throw "Verification returned '$VerifiedValue' instead of '1'."
        }

        if (-not $ValueExisted) {
            $CreatedValues.Add($Item.Application)
        }
        elseif ($PreviousValue -ne 1) {
            $CorrectedValues.Add("$($Item.Application):$PreviousValue->1")
        }
        else {
            $ExistingValues.Add($Item.Application)
        }
    }
    catch {
        $FailedValues.Add("$($Item.Application): $($_.Exception.Message)")
    }
}

$LoggingPath = Join-Path $UserContext.ProfilePath 'AppData\Local\Temp\Outlook Logging'
$RecoveredBytes = 0
$RemovedFiles = 0
$FolderRemoved = $false
$CleanupError = $null

if (Test-Path -LiteralPath $LoggingPath) {
    $LoggingFiles = @(Get-ChildItem -LiteralPath $LoggingPath -File -Recurse -Force -ErrorAction SilentlyContinue)
    $RecoveredBytes = ($LoggingFiles | Measure-Object -Property Length -Sum).Sum

    if (-not $RecoveredBytes) {
        $RecoveredBytes = 0
    }

    $RemovedFiles = $LoggingFiles.Count

    Get-Process -Name $OfficeProcesses -ErrorAction SilentlyContinue |
        Stop-Process -Force -ErrorAction SilentlyContinue

    Start-Sleep -Seconds 3

    $SearchService = Get-Service -Name 'WSearch' -ErrorAction SilentlyContinue
    $RestartSearchService = $SearchService -and $SearchService.Status -eq 'Running'

    if ($RestartSearchService) {
        Stop-Service -Name 'WSearch' -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    }

    try {
        Remove-Item -LiteralPath $LoggingPath -Recurse -Force -ErrorAction Stop
        $FolderRemoved = -not (Test-Path -LiteralPath $LoggingPath)

        if (-not $FolderRemoved) {
            throw 'The folder still exists after the removal attempt.'
        }
    }
    catch {
        $CleanupError = $_.Exception.Message
        $RecoveredBytes = 0
        $RemovedFiles = 0
    }
    finally {
        if ($RestartSearchService) {
            Start-Service -Name 'WSearch' -ErrorAction SilentlyContinue
        }
    }
}
else {
    $FolderRemoved = $true
}

$RecoveredMB = [math]::Round($RecoveredBytes / 1MB, 2)
$RecoveredGB = [math]::Round($RecoveredBytes / 1GB, 2)

Write-Output "User: $($UserContext.UserName)"
Write-Output "Registry created: $(if ($CreatedValues.Count) { $CreatedValues -join ', ' } else { 'None' })"
Write-Output "Registry corrected: $(if ($CorrectedValues.Count) { $CorrectedValues -join ', ' } else { 'None' })"
Write-Output "Registry already compliant: $(if ($ExistingValues.Count) { $ExistingValues -join ', ' } else { 'None' })"

if ($FolderRemoved) {
    Write-Output "Cleanup: Removed $RemovedFiles file(s); restored $RecoveredMB MB ($RecoveredGB GB)."
}
else {
    Write-Output "Cleanup failed: $CleanupError"
}

if ($FailedValues.Count -gt 0) {
    Write-Output "Registry failures: $($FailedValues -join ' | ')"
}

if ($FailedValues.Count -gt 0 -or -not $FolderRemoved) {
    Write-Output 'Status: Remediation failed or incomplete.'
    exit 1
}

Write-Output 'Status: Remediation completed successfully.'
exit 0
