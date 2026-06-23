<#
.SYNOPSIS
    Configures battery optimization settings by tuning the active power plan (DC side only) for Windows devices via Intune Remediations.
.DESCRIPTION
    Runs in SYSTEM context from Intune. Applies Energy Saver, CPU throttle, and passive cooling settings on battery. AC (plugged-in) performance is untouched.
.NOTES
    Script Name   : Remediate-BatteryOptimization.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-06-23
    Required      : Run as SYSTEM via Intune Remediation
.LINK
    https://cloudsecop.com/optimizing-laptop-battery-life-with-microsoft-intune/
#>

$ErrorActionPreference = "Stop"

try {
    $PowerSettings = @(
        @{ Description = 'Energy Saver threshold on battery'; Subgroup = 'SUB_ENERGYSAVER'; Setting = 'ESBATTTHRESHOLD'; Value = 100 }
        @{ Description = 'Maximum processor state on battery'; Subgroup = 'SUB_PROCESSOR';    Setting = 'PROCTHROTTLEMAX'; Value = 99 }
        @{ Description = 'Minimum processor state on battery'; Subgroup = 'SUB_PROCESSOR';    Setting = 'PROCTHROTTLEMIN'; Value = 5 }
        @{ Description = 'System cooling policy on battery';    Subgroup = 'SUB_PROCESSOR';    Setting = 'SYSCOOLPOL';      Value = 1 }
    )

    foreach ($PowerSetting in $PowerSettings) {
        powercfg /setdcvalueindex SCHEME_CURRENT $PowerSetting.Subgroup $PowerSetting.Setting $PowerSetting.Value

        if ($LASTEXITCODE -ne 0) {
            throw "Failed to set $($PowerSetting.Description)."
        }
    }

    powercfg /setactive SCHEME_CURRENT

    if ($LASTEXITCODE -ne 0) {
        throw 'Failed to re-apply the active power scheme.'
    }

    Write-Output 'Battery optimization applied: Energy Saver ON, Turbo OFF, passive cooling enabled for battery power.'
    exit 0
}
catch {
    Write-Output "Failed to apply battery optimization: $($_.Exception.Message)"
    exit 1
}