<#
.SYNOPSIS
    Remediates the Windows 11 25H2 target release registry values.

.DESCRIPTION
    Ensures the required Windows 11 25H2 target release registry values exist and are correctly configured under the Windows Update policy path.
    If the registry path does not exist, it will be created.
    Missing registry values will be created, and existing values containing incorrect data will be updated to the expected configuration.

.NOTES
    Script Name   : Remediate-25H2-Release-Values.ps1
    Author        : Joshua Tolsdorf
    Last Modified : 2026-10-07
    Required      : Run as SYSTEM via Intune Remediation
#>

$RegistryKeys = @(
    @{ Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'; Name = 'TargetReleaseVersion'; Type = 'DWORD'; Value = 1 }
    @{ Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'; Name = 'ProductVersion'; Type = 'STRING'; Value = 'Windows 11' }
    @{ Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'; Name = 'TargetReleaseVersionInfo'; Type = 'STRING'; Value = '25H2' }
)

foreach ($Key in $RegistryKeys) {
    try {

        # Create the registry path if it does not already exist.
        if (-not (Test-Path -LiteralPath $Key.Path)) {
            Write-Output "Registry path does not exist. Creating: $($Key.Path)"

            New-Item `
                -Path $Key.Path `
                -Force `
                -ErrorAction Stop |
                Out-Null

            Write-Output 'Registry path created successfully.'
        }

        # Create or correct the registry value.
        Write-Output "Setting $($Key.Name) to '$($Key.Value)'."

        New-ItemProperty `
            -LiteralPath $Key.Path `
            -Name $Key.Name `
            -Value $Key.Value `
            -PropertyType $Key.Type `
            -Force `
            -ErrorAction Stop |
            Out-Null

        Write-Output "$($Key.Name) configured successfully."
    }
    catch {
        Write-Warning "Failed to configure $($Key.Name) in $($Key.Path): $($_.Exception.Message)"
        exit 1
    }
}

Write-Output 'Remediation completed successfully.'
exit 0