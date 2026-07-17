<#
.SYNOPSIS
    Detects whether automatic acceptance of Windows SSO permission prompts is enabled.

.DESCRIPTION
    Verifies that the AutoAcceptSsoPermission registry policy value exists, is configured as a DWORD, and has a value of 1.

.NOTES
    Script Name   : Detect-SSO-Prompts.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-07-17
    Requires      : Administrative or SYSTEM context
#>

$RegistrySettings = @(
    @{ Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AAD'; Name = 'AutoAcceptSsoPermission'; Type = 'DWord'; Value = 1 }
)

foreach ($Setting in $RegistrySettings) {
    if (-not (Test-Path -LiteralPath $Setting.Path)) {
        Write-Output "Noncompliant: Registry path does not exist: $($Setting.Path)"
        exit 1
    }

    try {
        $RegistryKey = Get-Item `
            -LiteralPath $Setting.Path `
            -ErrorAction Stop

        $CurrentValue = $RegistryKey.GetValue(
            $Setting.Name,
            $null,
            [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames
        )

        if ($null -eq $CurrentValue) {
            Write-Output "Noncompliant: Registry value does not exist: $($Setting.Path)\$($Setting.Name)"
            exit 1
        }

        $CurrentType = $RegistryKey.GetValueKind($Setting.Name).ToString()
    }
    catch {
        Write-Output "Noncompliant: Unable to read $($Setting.Path)\$($Setting.Name). $($_.Exception.Message)"
        exit 1
    }

    if ($CurrentType -ne $Setting.Type) {
        Write-Output "Noncompliant: $($Setting.Name) is type $CurrentType; expected $($Setting.Type)."
        exit 1
    }

    if ($CurrentValue -ne $Setting.Value) {
        Write-Output "Noncompliant: $($Setting.Name) is set to $CurrentValue; expected $($Setting.Value)."
        exit 1
    }
}

Write-Output 'Compliant: Automatic SSO permission acceptance is enabled.'
exit 0