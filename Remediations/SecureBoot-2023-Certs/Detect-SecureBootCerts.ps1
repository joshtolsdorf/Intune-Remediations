<#
.SYNOPSIS
Detects whether the 2023 Secure Boot certificate update is applied or currently in progress.

.DESCRIPTION
This script checks the Secure Boot servicing registry values and, when possible,
verifies whether the "Windows UEFI CA 2023" certificate exists in the Secure Boot db.
It is intended for use as an Intune detection script or Proactive Remediations detection script.

The script returns:
- Exit 0 = Compliant / Not Applicable
- Exit 1 = Non-Compliant

.NOTES
Author        : Josh Tolsdorf
Script Name   : SecureBootCerts_Detect.ps1
Version       : 1.0.0
Created       : 2026-03-30
Last Modified : 2026-06-20
Purpose       : Detect 2023 Secure Boot certificate update status
Requires      : PowerShell 5.1 or later, administrative/SYSTEM context recommended
Change Log    :
    1.0.0 - Initial cleaned and standardized version with improved error handling,
            platform checks, safer registry access, and structured output.

.PARAMETER None
This script does not accept parameters.

.EXAMPLE
powershell.exe -ExecutionPolicy Bypass -File .\Detect-SecureBootCerts.ps1

.LINK
https://support.microsoft.com/
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$RegSecureBoot = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot'
$RegServicing  = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing'

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
        return $false
    }
}

try {
    if (-not (Test-SecureBootApplicable)) {
        Write-Output 'Compliant: Secure Boot/UEFI not available or not enabled on this device. Marking as not applicable.'
        exit 0
    }

    $availableUpdates = Get-RegistryValue -Path $RegSecureBoot -Name 'AvailableUpdates'
    $uefiCa2023Status = Get-RegistryValue -Path $RegServicing  -Name 'UEFICA2023Status'
    $uefiCa2023Error  = Get-RegistryValue -Path $RegServicing  -Name 'UEFICA2023Error'

    if ($null -eq $availableUpdates) {
        $availableUpdates = 0
    }

    $availableUpdatesInt = [int]$availableUpdates
    $availableUpdatesHex = ('0x{0:X4}' -f $availableUpdatesInt)

    if (($null -ne $uefiCa2023Error) -and ([uint32]$uefiCa2023Error -ne 0)) {
        Write-Output ("Non-Compliant: UEFICA2023Error=0x{0:X8} (AvailableUpdates={1})." -f [uint32]$uefiCa2023Error, $availableUpdatesHex)
        exit 1
    }

    if ($availableUpdatesInt -eq 0x4100) {
        Write-Output "Non-Compliant: Reboot required (AvailableUpdates=$availableUpdatesHex)."
        exit 1
    }

    $normalizedStatus = ''
    if ($null -ne $uefiCa2023Status) {
        $normalizedStatus = (($uefiCa2023Status.ToString()) -replace '\s','').ToLowerInvariant()
    }

    switch ($normalizedStatus) {
        'updated' {
            Write-Output "Compliant: UEFICA2023Status=$uefiCa2023Status (AvailableUpdates=$availableUpdatesHex)."
            exit 0
        }
        'inprogress' {
            Write-Output "Compliant: UEFICA2023Status=$uefiCa2023Status (AvailableUpdates=$availableUpdatesHex)."
            exit 0
        }
    }

    if (Test-UEFICA2023Present) {
        Write-Output "Compliant: Windows UEFI CA 2023 found in Secure Boot db (AvailableUpdates=$availableUpdatesHex)."
        exit 0
    }

    Write-Output "Non-Compliant: Windows UEFI CA 2023 not detected and servicing status is not updated/in progress (AvailableUpdates=$availableUpdatesHex)."
    exit 1
}
catch {
    Write-Output "Non-Compliant: Detection failed with error: $($_.Exception.Message)"
    exit 1
}