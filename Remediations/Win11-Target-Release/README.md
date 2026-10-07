# Configure Windows 11 25H2 Target Release

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207.x-5391FE?style=for-the-badge)
![Windows](https://img.shields.io/badge/Windows-11-0078D4?style=for-the-badge)
![Microsoft Intune](https://img.shields.io/badge/Microsoft-Intune-00A4EF?style=for-the-badge)
![Run As](https://img.shields.io/badge/Run%20As-SYSTEM-blue?style=for-the-badge)
![Type](https://img.shields.io/badge/Type-Proactive%20Remediation-success?style=for-the-badge)

Detects and configures the Windows Update policy registry values required to target **Windows 11, version 25H2** using **Microsoft Intune Remediations**.

The detection script verifies that all required registry values exist and contain the expected data. The remediation script creates the Windows Update policy registry path when necessary and creates or corrects each required value.

---

## Overview

Windows provides Target Release Version policies that allow administrators to specify the Windows product and feature update version a device should remain on or upgrade to.

This remediation configures the device to target:

```text
Windows 11
Version 25H2
```

The configuration is stored under the Windows Update policy registry path:

```text
HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate
```

The scripts ensure that all three required Target Release Version values are present and correctly configured.

---

## Features

- Targets **Windows 11, version 25H2**
- Detects missing Windows Update policy registry paths
- Detects missing registry values
- Detects incorrectly configured registry values
- Validates DWORD values before comparison
- Creates the Windows Update policy registry path when necessary
- Creates missing registry values
- Corrects existing values containing incorrect data
- Executes under the **SYSTEM** account
- Safe to deploy repeatedly
- Uses standard Intune Remediation exit codes

---

## Use Case

This remediation is useful for organizations that want to:

- Target Windows 11 25H2 across managed endpoints
- Standardize the Windows feature update target
- Correct missing or incorrectly configured Target Release Version values
- Maintain the required registry configuration through Intune
- Prepare devices for a controlled Windows 11 25H2 rollout

---

## Requirements

- Microsoft Intune Remediations
- Windows 11
- Windows PowerShell 5.1 or PowerShell 7.x
- Run scripts as **SYSTEM**
- Administrator permissions
- 64-bit PowerShell execution recommended

---

## Registry Configuration

The scripts manage the following registry path:

```text
HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate
```

The following values are required:

| Value Name | Type | Required Value |
|---|---|---|
| `TargetReleaseVersion` | `REG_DWORD` | `1` |
| `ProductVersion` | `REG_SZ` | `Windows 11` |
| `TargetReleaseVersionInfo` | `REG_SZ` | `25H2` |

The resulting configuration is equivalent to:

```text
HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate

TargetReleaseVersion       REG_DWORD    1
ProductVersion             REG_SZ       Windows 11
TargetReleaseVersionInfo   REG_SZ       25H2
```

---

## Detection Logic

The detection script stores the required registry configuration in a reusable array:

```powershell
$RegistryKeys = @(
    @{ Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'; Name = 'TargetReleaseVersion'; Type = 'DWORD'; Value = 1 }
    @{ Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'; Name = 'ProductVersion'; Type = 'STRING'; Value = 'Windows 11' }
    @{ Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'; Name = 'TargetReleaseVersionInfo'; Type = 'STRING'; Value = '25H2' }
)
```

Each configured value is evaluated independently.

---

### 1. Verify the Registry Path

The script first verifies that the Windows Update policy path exists:

```powershell
Test-Path -LiteralPath $Key.Path
```

If the path does not exist:

- A warning is generated
- The device is marked non-compliant
- Detection continues checking the remaining configured entries

Example:

```text
Not Compliant: Registry path missing: HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate
```

---

### 2. Retrieve the Registry Value

The script retrieves each individual value using:

```powershell
Get-ItemPropertyValue `
    -LiteralPath $Key.Path `
    -Name $Key.Name `
    -ErrorAction Stop
```

If a required value does not exist:

- A warning is generated
- The device is marked non-compliant

Example:

```text
Not Compliant: Registry value missing: TargetReleaseVersionInfo in HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate
```

---

### 3. Normalize DWORD Values

DWORD values are explicitly converted to integers before comparison:

```powershell
$RegistryValue = [int]$RegistryValue
```

This ensures that `TargetReleaseVersion` is evaluated as a numeric value.

If the existing value cannot be interpreted as a valid integer:

```text
Not Compliant: TargetReleaseVersion contains an invalid DWORD value.
```

The device is marked non-compliant.

---

### 4. Compare Expected Values

Each existing value is compared against its required configuration.

For example:

```text
TargetReleaseVersion = 1
ProductVersion = Windows 11
TargetReleaseVersionInfo = 25H2
```

If an existing value does not match:

```text
Not Compliant: TargetReleaseVersionInfo in HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate is '24H2' but expected '25H2'.
```

The device is marked non-compliant.

---

## Detection Results

### Compliant

When all three values exist and contain the expected data:

```text
Compliant
```

The script returns:

```text
Exit 0
```

---

### Non-Compliant

If the registry path is missing, a required value is missing, or any value contains incorrect data:

```text
Non-Compliant
```

The script returns:

```text
Exit 1
```

Intune then executes the remediation script.

---

## Remediation Logic

The remediation script uses the same `$RegistryKeys` configuration array as the detection script.

For each required value, the script:

1. Verifies that the registry path exists.
2. Creates the path when necessary.
3. Creates or overwrites the required registry value.
4. Applies the correct registry data type.
5. Reports the result.
6. Returns a failure if any registry operation cannot be completed.

---

### 1. Create the Registry Path

If the Windows Update policy path does not exist, the script creates it using:

```powershell
New-Item `
    -Path $Key.Path `
    -Force `
    -ErrorAction Stop
```

Example output:

```text
Registry path does not exist. Creating: HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate
Registry path created successfully.
```

---

### 2. Create or Correct Registry Values

Each required value is configured using:

```powershell
New-ItemProperty `
    -LiteralPath $Key.Path `
    -Name $Key.Name `
    -Value $Key.Value `
    -PropertyType $Key.Type `
    -Force `
    -ErrorAction Stop
```

The `-Force` parameter allows the same operation to:

- Create a missing value
- Correct an existing value
- Replace incorrect data

This makes the remediation idempotent and safe to run repeatedly.

---

## Expected Remediation Output

A successful remediation may produce output similar to:

```text
Setting TargetReleaseVersion to '1'.
TargetReleaseVersion configured successfully.

Setting ProductVersion to 'Windows 11'.
ProductVersion configured successfully.

Setting TargetReleaseVersionInfo to '25H2'.
TargetReleaseVersionInfo configured successfully.

Remediation completed successfully.
```

---

## Error Handling

Each registry operation is protected by a `try/catch` block.

If a value cannot be configured:

```text
Failed to configure TargetReleaseVersionInfo in HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate: <error>
```

The remediation immediately returns:

```text
Exit 1
```

This prevents Intune from reporting a successful remediation when the required registry configuration could not be applied.

---

## Exit Codes

### Detection Script

| Exit Code | Meaning |
|---:|---|
| `0` | All required Windows 11 25H2 registry values are configured correctly |
| `1` | Registry path/value is missing or one or more values are incorrect |

### Remediation Script

| Exit Code | Meaning |
|---:|---|
| `0` | All required registry values were configured successfully |
| `1` | One or more registry values could not be configured |

---

## Intune Configuration

| Setting | Recommended Value |
|---|---|
| Run this script using logged-on credentials | **No** |
| Enforce script signature check | As required |
| Run script in 64-bit PowerShell | **Yes** |
| Schedule | Organization preference |

Running the scripts using logged-on credentials should be disabled so that the remediation executes under the **SYSTEM** account and can modify `HKLM`.

---

## Files

```text
Detect-25H2-Release-Values.ps1
Remediate-25H2-Release-Values.ps1
README.md
```

---

## Example Workflow

1. Intune runs `Detect-25H2-Release-Values.ps1`.
2. The script checks the Windows Update policy registry path.
3. Each required Target Release Version value is retrieved.
4. Existing values are compared against the required Windows 11 25H2 configuration.
5. A fully configured device returns **Exit 0**.
6. A device with missing or incorrect configuration returns **Exit 1**.
7. Intune runs `Remediate-25H2-Release-Values.ps1`.
8. The registry path is created if necessary.
9. All three registry values are created or corrected.
10. The next detection cycle confirms the device is compliant.

---

## Manual Testing

### Run Detection

Open an elevated PowerShell session and run:

```powershell
.\Detect-25H2-Release-Values.ps1
```

A correctly configured device should return:

```text
Compliant
```

---

### Run Remediation

Open an elevated PowerShell session and run:

```powershell
.\Remediate-25H2-Release-Values.ps1
```

After successful remediation:

```text
Remediation completed successfully.
```

---

### Verify the Registry Configuration

Use PowerShell:

```powershell
Get-ItemProperty `
    -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' |
    Select-Object TargetReleaseVersion, ProductVersion, TargetReleaseVersionInfo
```

Expected result:

```text
TargetReleaseVersion ProductVersion TargetReleaseVersionInfo
-------------------- -------------- ------------------------
                   1 Windows 11     25H2
```

You can also query the values individually:

```powershell
Get-ItemPropertyValue `
    -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' `
    -Name 'TargetReleaseVersion'

Get-ItemPropertyValue `
    -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' `
    -Name 'ProductVersion'

Get-ItemPropertyValue `
    -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' `
    -Name 'TargetReleaseVersionInfo'
```

---

## Customization

The scripts can be adapted for future Windows feature releases by changing the values in `$RegistryKeys`.

For example, the target release is controlled by:

```powershell
@{
    Path  = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
    Name  = 'TargetReleaseVersionInfo'
    Type  = 'STRING'
    Value = '25H2'
}
```

When adapting the scripts for another release, ensure the `$RegistryKeys` array remains identical between the detection and remediation scripts.

---

## Notes

- Designed specifically for **Microsoft Intune Remediations**.
- Executes under the **SYSTEM** account.
- Configures machine-level Windows Update policy under `HKLM`.
- Detection checks every configured registry value before determining overall compliance.
- A single missing or incorrect value causes the device to report as non-compliant.
- The remediation creates the registry path automatically when necessary.
- Existing values are overwritten with the expected configuration using `New-ItemProperty -Force`.
- The scripts are idempotent and can be safely deployed repeatedly.
- The scripts configure the Windows Target Release Version policy; they do not directly initiate a Windows feature update installation.

---

## Important Considerations

The registry configuration established by these scripts specifies the **target Windows release** for Windows Update.

It does not guarantee that a device will immediately upgrade to Windows 11 25H2. Feature update availability can also depend on factors such as:

- Windows Update scan and policy processing
- Device eligibility
- Microsoft safeguard holds
- Hardware compatibility
- Other Windows Update policies
- Intune Feature Update deployment policies
- Update deferral or pause configuration

Organizations should ensure that this remediation does not conflict with other Windows Update management policies.

---

## Known Limitations

- The scripts are specifically configured for **Windows 11 25H2**.
- They do not verify the currently installed Windows version.
- They do not initiate an update scan.
- They do not initiate the 25H2 installation.
- They do not determine whether the device is eligible for Windows 11 25H2.
- They do not detect Microsoft safeguard holds.
- Group Policy, Intune configuration profiles, Feature Update policies, or other management platforms may configure or overwrite the same registry values.
- Detection requires an exact match for all three configured values.

---

## Version History

| Version | Date | Notes |
|---|---|---|
| 1.0.0 | 2026-10-07 | Initial release for Windows 11 25H2 Target Release Version configuration |
