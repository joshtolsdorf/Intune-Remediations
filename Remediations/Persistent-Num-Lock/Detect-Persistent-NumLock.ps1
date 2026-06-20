<#
.SYNOPSIS
    Detects if Num Lock is persisting after shutdown or restart.

.DESCRIPTION
    Intended for Intune Remediations running as SYSTEM. Detects whether the HKU policy registry value exists and is set to the required REG_SZ value of 2.

.NOTES
    Script Name   : Detect-Persistent-NumLock.ps1
    Author        : Josh Tolsdorf
    Version       : 1.0.0
    Created       : 2026-05-17
    Last Modified : 2026-06-20
    Requires      : Run as SYSTEM via Microsoft Intune Remediations
#>

$Compliant = $true

$RegistryKeys = @(
    @{
        Path  = 'Registry::HKEY_USERS\.DEFAULT\Control Panel\Keyboard'
        Name  = 'InitialKeyboardIndicators'
        Type  = 'String'
        Value = 2
    }
)

try {
    foreach ($Key in $RegistryKeys) {
        if (-not (Test-Path -LiteralPath $Key.Path)) {
            Write-Warning "Not Compliant: Registry path missing: $($Key.Path)"
            $Compliant = $false
            continue
        }

        $Item = Get-ItemProperty -Path $Key.Path -Name $Key.Name -ErrorAction SilentlyContinue

        if ($null -eq $Item) {
            Write-Warning "Not Compliant: Registry value missing: $($Key.Name) in $($Key.Path)"
            $Compliant = $false
            continue
        }

        $RegistryValue = $Item.$($Key.Name)

        if ($Key.Type -eq "DWORD") {
            $RegistryValue = [int]$RegistryValue
        }

        if ($RegistryValue -ne $Key.Value) {
            Write-Warning "Not Compliant: $($Key.Name) in $($Key.Path) is '$RegistryValue' but expected '$($Key.Value)'."
            $Compliant = $false
        }
    }

    if ($Compliant) {
        Write-Output "Compliant"
        exit 0
    }
    else {
        Write-Output "Non-Compliant"
        exit 1
    }
}
catch {
    Write-Warning "Not Compliant: $($_.Exception.Message)"
    exit 1
}