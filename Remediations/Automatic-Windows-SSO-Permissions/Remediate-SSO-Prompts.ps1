<#
.SYNOPSIS
    Enables automatic acceptance of Windows SSO permission prompts.

.DESCRIPTION
    Creates the AutoAcceptSsoPermission registry policy value and configures it as a DWORD with a value of 1.

.NOTES
    Script Name   : Remediate-SSO-Prompts.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-07-17
    Requires      : Administrative or SYSTEM context
#>

$RegistrySettings = @(
    @{ Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AAD'; Name = 'AutoAcceptSsoPermission'; Type = 'DWord'; Value = 1 }
)

foreach ($Setting in $RegistrySettings) {
    try {
        if (-not (Test-Path -LiteralPath $Setting.Path)) {
            New-Item `
                -Path $Setting.Path `
                -Force `
                -ErrorAction Stop | Out-Null

            Write-Output "Created registry path: $($Setting.Path)"
        }

        New-ItemProperty `
            -LiteralPath $Setting.Path `
            -Name $Setting.Name `
            -PropertyType $Setting.Type `
            -Value $Setting.Value `
            -Force `
            -ErrorAction Stop | Out-Null

        Write-Output "Configured $($Setting.Path)\$($Setting.Name) as $($Setting.Type) with a value of $($Setting.Value)."
    }
    catch {
        Write-Output "Failed to configure $($Setting.Path)\$($Setting.Name). $($_.Exception.Message)"
        exit 1
    }
}

Write-Output 'Remediation completed successfully.'
exit 0