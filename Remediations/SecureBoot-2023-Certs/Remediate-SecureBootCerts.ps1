<#
.SYNOPSIS
Triggers the 2023 Secure Boot certificate update by setting AvailableUpdates to 0x5944.

.DESCRIPTION
This script is intended for use as an Intune remediation script or Proactive Remediations remediation script.
It validates Secure Boot applicability, checks current Secure Boot servicing state, avoids overwriting in-progress
states, and sets the SecureBoot\AvailableUpdates DWORD to 0x5944 when appropriate.

The script returns:
- Exit 0 = Success / No action needed / Not Applicable
- Exit 1 = Remediation failure

.NOTES
Author        : Josh Tolsdorf
Script Name   : Remediate-SecureBootCerts.ps1
Version       : 1.0.0
Created       : 2026-03-30
Last Modified : 2026-06-20
Purpose       : Remediate missing 2023 Secure Boot certificate update trigger
Requires      : PowerShell 5.1 or later, administrative/SYSTEM context recommended
Change Log    :
    1.0.0 - Initial cleaned and standardized version with improved error handling,
            platform checks, guarded remediation logic, and structured output.

.PARAMETER None
This script does not accept parameters.

.EXAMPLE
powershell.exe -ExecutionPolicy Bypass -File .\Remediate-SecureBootCerts.ps1

.LINK
https://support.microsoft.com/
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$RegSecureBoot = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot'
$RegServicing  = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing'
$ValueName     = 'AvailableUpdates'
$TargetValue   = 0x5944
$TaskPath      = '\Microsoft\Windows\PI\'
$TaskName      = 'Secure-Boot-Update'

function Get-RegistryValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Name
    )

    try {
        if (-not (Test-Path -LiteralPath $Path)) {
            return $null
        }

        $item = Get-ItemProperty -LiteralPath $Path -ErrorAction Stop
        if ($item.PSObject.Properties.Name -contains $Name) {
            return $item.$Name
        }

        return $null
    }
    catch {
        return $null
    }
}

function Test-SecureBootApplicable {
    [CmdletBinding()]
    param()

    try {
        if (-not (Get-Command -Name Confirm-SecureBootUEFI -ErrorAction SilentlyContinue)) {
            return $false
        }

        $result = Confirm-SecureBootUEFI -ErrorAction Stop
        return [bool]$result
    }
    catch {
        return $false
    }
}

function Test-UEFICA2023Present {
    [CmdletBinding()]
    param()

    try {
        if (-not (Get-Command -Name Get-SecureBootUEFI -ErrorAction SilentlyContinue)) {
            return $false
        }

        $db = Get-SecureBootUEFI -Name db -ErrorAction Stop
        if (-not $db -or -not $db.Bytes) {
            return $false
        }

        $dbText = [System.Text.Encoding]::ASCII.GetString($db.Bytes)
        return ($dbText -match 'Windows UEFI CA 2023')
    }
    catch {
        Write-Output "WARN: Unable to query Secure Boot db: $($_.Exception.Message)"
        return $false
    }
}

try {
    if (-not (Test-SecureBootApplicable)) {
        Write-Output 'OK: Secure Boot/UEFI not available or not enabled on this device. Remediation not applicable.'
        exit 0
    }

    $currentValue = Get-RegistryValue -Path $RegSecureBoot -Name $ValueName
    $status       = Get-RegistryValue -Path $RegServicing  -Name 'UEFICA2023Status'
    $errorValue   = Get-RegistryValue -Path $RegServicing  -Name 'UEFICA2023Error'

    if ($null -eq $currentValue) {
        $currentValue = 0
    }

    $currentInt = [int]$currentValue
    Write-Output ("INFO: Current AvailableUpdates = 0x{0:X4}." -f $currentInt)

    if ($status) {
        Write-Output "INFO: UEFICA2023Status = '$status'."
    }

    if ($null -ne $errorValue) {
        Write-Output ("INFO: UEFICA2023Error = 0x{0:X8}." -f [uint32]$errorValue)
    }

    if (($null -ne $errorValue) -and ([uint32]$errorValue -ne 0)) {
        Write-Output 'WARN: UEFICA2023Error is non-zero. Not forcing remediation until the underlying issue is investigated.'
        exit 0
    }

    $normalizedStatus = ''
    if ($status) {
        $normalizedStatus = (($status.ToString()) -replace '\s','').ToLowerInvariant()
    }

    if ($normalizedStatus -eq 'inprogress') {
        Write-Output 'OK: Update is already in progress. No changes made.'
        exit 0
    }

    if ($normalizedStatus -eq 'updated') {
        Write-Output 'OK: Update already reports as Updated. No changes made.'
        exit 0
    }

    if ($currentInt -eq 0x4100) {
        Write-Output 'OK: Reboot required (AvailableUpdates=0x4100). No changes made.'
        exit 0
    }

    if (($currentInt -ne 0) -and ($currentInt -ne $TargetValue)) {
        Write-Output ("OK: AvailableUpdates already reflects a processing/progress state (0x{0:X4}). No reset performed." -f $currentInt)
        exit 0
    }

    if ($currentInt -eq $TargetValue) {
        Write-Output ("OK: AvailableUpdates is already set to target value 0x{0:X4}. No change needed." -f $TargetValue)
        exit 0
    }

    if (Test-UEFICA2023Present) {
        Write-Output "INFO: Windows UEFI CA 2023 is already present in Secure Boot db."
    }

    if (-not (Test-Path -LiteralPath $RegSecureBoot)) {
        New-Item -Path $RegSecureBoot -Force | Out-Null
        Write-Output "INFO: Created registry path $RegSecureBoot."
    }

    New-ItemProperty -Path $RegSecureBoot -Name $ValueName -PropertyType DWord -Value $TargetValue -Force | Out-Null
    Write-Output ("FIX: Set {0}\{1} to 0x{2:X4}." -f $RegSecureBoot, $ValueName, $TargetValue)

    try {
        $scheduledTask = Get-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($scheduledTask) {
            Start-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName
            Write-Output "INFO: Triggered scheduled task '$TaskPath$TaskName'."
        }
        else {
            Write-Output "INFO: Scheduled task '$TaskPath$TaskName' was not found. Windows will process the update on its normal schedule."
        }
    }
    catch {
        Write-Output "WARN: Failed to start scheduled task '$TaskPath$TaskName': $($_.Exception.Message)"
    }

    exit 0
}
catch {
    Write-Output "ERROR: Remediation failed: $($_.Exception.Message)"
    exit 1
}