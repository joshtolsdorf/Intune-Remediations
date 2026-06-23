# Battery Optimization

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207.x-5391FE)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4)
![Microsoft Intune](https://img.shields.io/badge/Microsoft-Intune-00A4EF)
![Run As](https://img.shields.io/badge/Run%20As-SYSTEM-blue)
![Reboot](https://img.shields.io/badge/Reboot-Not%20Required-success)

Optimizes battery performance on Windows laptops by configuring **power management settings for battery (DC) mode only** using **Microsoft Intune Remediations**.

This remediation is designed to run as **SYSTEM** and modifies the currently active Windows power plan to improve battery life without affecting plugged-in (AC) performance.

---

## Overview

Windows power plans contain separate settings for:

* **AC Power (Plugged In)**
* **DC Power (Battery)**

This remediation targets only the **DC (battery) configuration** and applies a set of recommended settings designed to reduce power consumption while maintaining a usable user experience.

The script does **not** modify any AC power settings.

---

## Use Case

This remediation is useful for organizations that want to:

* Improve laptop battery life
* Reduce power consumption when devices are running on battery
* Standardize battery optimization settings across managed devices
* Maintain full performance when devices are plugged in
* Deploy power plan tuning through Microsoft Intune

---

## Requirements

* Microsoft Intune Remediations
* Run scripts as **SYSTEM**
* Windows 10 or Windows 11
* Device must support Windows power plans
* Applicable primarily to laptops and mobile devices

---

## Configured Settings

The remediation configures the following **battery (DC) settings** on the active power plan:

| Setting                 | Value       |
| ----------------------- | ----------- |
| Energy Saver Threshold  | **100%**    |
| Maximum Processor State | **99%**     |
| Minimum Processor State | **5%**      |
| System Cooling Policy   | **Passive** |

### Why These Settings?

#### Energy Saver Threshold = 100%

Ensures Windows enters Energy Saver mode whenever the device is operating on battery power.

#### Maximum Processor State = 99%

Limits the CPU to 99% utilization, which prevents processor turbo boost from activating and reduces power consumption.

#### Minimum Processor State = 5%

Allows Windows to aggressively reduce CPU usage during idle periods.

#### Passive Cooling Policy

Reduces fan usage by lowering processor performance before increasing cooling activity, helping conserve battery power.

---

## Detection Logic

The detection script:

1. Reads the active Windows power plan
2. Retrieves each configured DC power setting
3. Converts powercfg values from hexadecimal to decimal
4. Compares the current values against the expected configuration

If any setting differs from the expected value:

* Returns **Exit 1**
* Reports the device as **Non-Compliant**

Otherwise:

* Returns **Exit 0**
* Reports the device as **Compliant**

---

## Remediation Logic

The remediation script:

1. Configures each battery optimization setting using PowerCfg
2. Updates the currently active power plan
3. Re-applies the active power scheme
4. Verifies successful execution

The following commands are used:

```text
powercfg /setdcvalueindex
powercfg /setactive SCHEME_CURRENT
```

If all settings are successfully applied:

* Returns **Exit 0**

If any configuration step fails:

* Returns **Exit 1**

---

## Intune Configuration

| Setting                                     | Value                   |
| ------------------------------------------- | ----------------------- |
| Run this script using logged-on credentials | **No**                  |
| Run script in 64-bit PowerShell             | **Yes**                 |
| Enforce signature check                     | As required             |
| Schedule                                    | Organization preference |

---

## Files

```text
Detect-BatteryOptimization.ps1
Remediate-BatteryOptimization.ps1
README.md
```

---

## Notes

* Applies settings only to the currently active power plan.
* Only battery (DC) settings are modified.
* Plugged-in (AC) performance remains unchanged.
* Safe to deploy repeatedly.
* Uses standard Intune remediation exit codes for accurate compliance reporting.
* Particularly beneficial for mobile users and laptop fleets.

---

## Expected Results

After remediation:

* Energy Saver is always available while on battery
* CPU turbo boost is effectively disabled on battery power
* Lower processor utilization reduces battery drain
* Passive cooling prioritizes power efficiency over maximum performance
* Users experience longer battery runtime with minimal impact to productivity workloads

---

## Version History

| Version | Date       | Notes           |
| ------- | ---------- | --------------- |
| 1.0.0   | 2026-06-23 | Initial release |
