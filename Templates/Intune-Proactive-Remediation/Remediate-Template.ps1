<#
.SYNOPSIS
    Remediates the target configuration.

.DESCRIPTION
    Intune Remediation remediation script template.

.NOTES
    Script Name   : Remediate-Template.ps1
    Author        : Josh Tolsdorf
    Version       : 1.0.0
    Created       : yyyy-MM-dd
    Last Modified : yyyy-MM-dd
    Requires      : Run as SYSTEM via Microsoft Intune Remediations
#>

$ErrorActionPreference = 'Stop'

$RegistryItems = @(
    @{ Path = 'HKLM:\SOFTWARE\Example'; Name = 'ExampleValue'; ExpectedValue = 1; Type = 'DWord' }
)

try {
    foreach ($Item in $RegistryItems) {
        if (-not (Test-Path -Path $Item.Path)) {
            New-Item -Path $Item.Path -Force | Out-Null
            Write-Output "Created registry path: $($Item.Path)"
        }

        Set-ItemProperty -Path $Item.Path -Name $Item.Name -Value $Item.ExpectedValue -Type $Item.Type -Force -ErrorAction Stop

        $CurrentValue = Get-ItemPropertyValue -Path $Item.Path -Name $Item.Name -ErrorAction Stop

        if ($CurrentValue -ne $Item.ExpectedValue) {
            Write-Output "Remediation failed: $($Item.Name) is $CurrentValue. Expected $($Item.ExpectedValue)."
            exit 1
        }

        Write-Output "Remediation successful: $($Item.Name) is set to $CurrentValue."
    }

    exit 0
}
catch {
    Write-Output "Remediation failed. $($_.Exception.Message)"
    exit 1
}