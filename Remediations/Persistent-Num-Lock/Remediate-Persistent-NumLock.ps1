<#
.SYNOPSIS
    Remediates Num Lock not persisting after shutdown or restart.

.DESCRIPTION
    Intended for Intune Remediations running as SYSTEM. Creates the required HKU policy registry path and sets InitialKeyboardIndicators to a value of 2.

.NOTES
    Script Name   : Remediate-Persistent-NumLock.ps1
    Author        : Josh Tolsdorf
    Version       : 1.0.0
    Created       : 2026-05-17
    Last Modified : 2026-06-20
    Requires      : Run as SYSTEM via Microsoft Intune Remediations
#>

$RegistryKeys = @(
    @{
        Path  = 'Registry::HKEY_USERS\.DEFAULT\Control Panel\Keyboard'
        Name  = 'InitialKeyboardIndicators'
        Type  = 'String'
        Value = 2
    }
)

foreach ($Key in $RegistryKeys) {
    try {
        if (-not (Test-Path -LiteralPath $Key.Path)) {
            Write-Output "$($Key.Path) does not exist. Creating..."
            New-Item -Path $Key.Path -Force -ErrorAction Stop | Out-Null
            Write-Output "Key created."
        }

        Write-Output "Setting $($Key.Name) in $($Key.Path) to $($Key.Value)"
        New-ItemProperty -Path $Key.Path -Name $Key.Name -Value $Key.Value -PropertyType $Key.Type -Force -ErrorAction Stop | Out-Null
        Write-Output "Value set successfully."
    }
    catch {
        Write-Output "Failed to set $($Key.Name) in $($Key.Path): $($_.Exception.Message)"
        exit 1
    }
}

exit 0