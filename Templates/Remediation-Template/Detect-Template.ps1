<#
.SYNOPSIS
    Detects whether the target configuration is compliant.

.DESCRIPTION
    Intune Remediation detection script template.

.NOTES
    Script Name   : Detect-Template.ps1
    Author        : Josh Tolsdorf
    Version       : 1.0.0
    Created       : yyyy-MM-dd
    Last Modified : yyyy-MM-dd
    Requires      : Run as SYSTEM via Microsoft Intune Remediations
#>

$ErrorActionPreference = 'Stop'

$RegistryItems = @(
    @{ Path = 'HKLM:\SOFTWARE\Example'; Name = 'ExampleValue'; ExpectedValue = 1 }
)

try {
    foreach ($Item in $RegistryItems) {
        if (-not (Test-Path -Path $Item.Path)) {
            Write-Output "Non-compliant: Registry path not found: $($Item.Path)"
            exit 1
        }

        $CurrentValue = Get-ItemPropertyValue -Path $Item.Path -Name $Item.Name -ErrorAction Stop

        if ($CurrentValue -ne $Item.ExpectedValue) {
            Write-Output "Non-compliant: $($Item.Name) is $CurrentValue. Expected $($Item.ExpectedValue)."
            exit 1
        }

        Write-Output "Compliant: $($Item.Name) is set to $CurrentValue."
    }

    exit 0
}
catch {
    Write-Output "Non-compliant: Detection failed. $($_.Exception.Message)"
    exit 1
}