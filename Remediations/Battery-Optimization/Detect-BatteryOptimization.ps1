<#
.SYNOPSIS
    Detects whether battery optimization settings are configured on the active power plan.
.DESCRIPTION
    Runs in SYSTEM context from Intune. Checks DC-side power settings for Energy Saver, CPU throttle, and passive cooling.
.NOTES
    Script Name   : Detect-BatteryOptimization.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-06-23
    Required      : Run as SYSTEM via Intune Remediation
.LINK
    https://cloudsecop.com/optimizing-laptop-battery-life-with-microsoft-intune/
#>

$ErrorActionPreference = 'Stop'

try {
    $PowerSettings = @(
        @{ Description = 'Energy Saver threshold on battery'; Subgroup = 'SUB_ENERGYSAVER'; Setting = 'ESBATTTHRESHOLD'; ExpectedValue = 100 }
        @{ Description = 'Maximum processor state on battery'; Subgroup = 'SUB_PROCESSOR';    Setting = 'PROCTHROTTLEMAX'; ExpectedValue = 99 }
        @{ Description = 'Minimum processor state on battery'; Subgroup = 'SUB_PROCESSOR';    Setting = 'PROCTHROTTLEMIN'; ExpectedValue = 5 }
        @{ Description = 'System cooling policy on battery';    Subgroup = 'SUB_PROCESSOR';    Setting = 'SYSCOOLPOL';      ExpectedValue = 1 }
    )

    $NonCompliantSettings = @()

    foreach ($PowerSetting in $PowerSettings) {
        $CurrentValue = powercfg /query SCHEME_CURRENT $PowerSetting.Subgroup $PowerSetting.Setting |
            Select-String -Pattern 'Current DC Power Setting Index'

        if (-not $CurrentValue) {
            throw "Unable to read $($PowerSetting.Description)."
        }

        $CurrentHexValue = ($CurrentValue -split ':')[-1].Trim()
        $CurrentDecimalValue = [Convert]::ToInt32($CurrentHexValue, 16)

        if ($CurrentDecimalValue -ne $PowerSetting.ExpectedValue) {
            $NonCompliantSettings += "$($PowerSetting.Description): Current=$CurrentDecimalValue Expected=$($PowerSetting.ExpectedValue)"
        }
    }

    if ($NonCompliantSettings.Count -gt 0) {
        Write-Output "Battery optimization is not compliant."
        $NonCompliantSettings | ForEach-Object { Write-Output $_ }
        exit 1
    }

    Write-Output 'Battery optimization is compliant.'
    exit 0
}
catch {
    Write-Output "Failed to detect battery optimization settings: $($_.Exception.Message)"
    exit 1
}