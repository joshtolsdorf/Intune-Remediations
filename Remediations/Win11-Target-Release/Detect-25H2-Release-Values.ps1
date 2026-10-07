<#
.SYNOPSIS
    Detects whether the Windows 11 25H2 target release registry values are configured.

.DESCRIPTION
    Checks the registry to determine if the Windows 11 25H2 target release values are correctly set under the Windows Update policy path.
    Returns exit code 0 when all required registry values are present and configured correctly.
    Returns exit code 1 when the registry path or any required value is missing, or when a value does not match the expected configuration.

.NOTES
    Script Name   : Detect-25H2-Release-Values.ps1
    Author        : Joshua Tolsdorf
    Last Modified : 2026-10-07
    Required      : Run as SYSTEM via Intune Remediation
#>

$Compliant = $true

$RegistryKeys = @(
    @{ Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'; Name = 'TargetReleaseVersion'; Type = 'DWORD'; Value = 1 }
    @{ Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'; Name = 'ProductVersion'; Type = 'STRING'; Value = 'Windows 11' }
    @{ Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'; Name = 'TargetReleaseVersionInfo'; Type = 'STRING'; Value = '25H2' }
)

foreach ($Key in $RegistryKeys) {

    # Verify the registry path exists.
    if (-not (Test-Path -LiteralPath $Key.Path)) {
        Write-Warning "Not Compliant: Registry path missing: $($Key.Path)"
        $Compliant = $false
        continue
    }

    # Attempt to retrieve the individual registry value.
    try {
        $RegistryValue = Get-ItemPropertyValue `
            -LiteralPath $Key.Path `
            -Name $Key.Name `
            -ErrorAction Stop
    }
    catch {
        Write-Warning "Not Compliant: Registry value missing: $($Key.Name) in $($Key.Path)"
        $Compliant = $false
        continue
    }

    # Normalize DWORD values before comparison.
    if ($Key.Type -eq 'DWORD') {
        try {
            $RegistryValue = [int]$RegistryValue
        }
        catch {
            Write-Warning "Not Compliant: $($Key.Name) contains an invalid DWORD value: '$RegistryValue'."
            $Compliant = $false
            continue
        }
    }

    # Compare the current value against the expected value.
    if ($RegistryValue -ne $Key.Value) {
        Write-Warning "Not Compliant: $($Key.Name) in $($Key.Path) is '$RegistryValue' but expected '$($Key.Value)'."
        $Compliant = $false
    }
}

if ($Compliant) {
    Write-Output 'Compliant'
    exit 0
}
else {
    Write-Output 'Non-Compliant'
    exit 1
}