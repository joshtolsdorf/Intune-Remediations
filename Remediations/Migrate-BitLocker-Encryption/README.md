# Migrate BitLocker to Full Drive Encryption

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207.x-5391FE)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4)
![Microsoft Intune](https://img.shields.io/badge/Microsoft-Intune-00A4EF)
![Run As](https://img.shields.io/badge/Run%20As-SYSTEM-blue)

Detects and remediates Windows devices that are encrypted using **BitLocker Used Space Only** encryption by migrating them to **Full Drive Encryption (XTS-AES 128)** using **Microsoft Intune Remediations**.

This remediation is designed to run as **SYSTEM** and automatically decrypts and re-encrypts the operating system drive when necessary to meet organizational encryption standards.

---

# Overview

Many organizations initially deploy BitLocker using **Used Space Only** encryption because it encrypts new devices much faster.

While this is appropriate for many scenarios, some security standards require **Full Drive Encryption**, ensuring that all sectors of the disk—including previously unused space—are encrypted.

This remediation identifies devices still using **Used Space Only** encryption and automatically migrates them to **Full Drive Encryption**.

---

# Use Case

This remediation is useful for organizations that want to:

* Standardize BitLocker encryption across managed devices
* Migrate existing devices from Used Space Only to Full Encryption
* Meet CIS, regulatory, or internal security requirements
* Ensure the operating system drive uses **XTS-AES 128**
* Deploy BitLocker remediation through Microsoft Intune

---

# Requirements

* Microsoft Intune Remediations
* Run scripts as **SYSTEM**
* Windows 10 or Windows 11 Pro, Enterprise, or Education
* TPM-enabled device with BitLocker support
* BitLocker PowerShell module available
* Administrative privileges

---

# Detection Logic

The detection script evaluates the operating system drive (`C:`) and verifies:

* The drive is encrypted using **XTS-AES 128**
* Encryption has completed successfully
* Protection is enabled
* The drive is unlocked
* A **Recovery Password** protector exists
* The volume is **not** using **Used Space Only** encryption

The script uses both the BitLocker PowerShell cmdlets and:

```text
manage-bde -status C:
```

to determine the current encryption method.

If any required condition is not met:

* Returns **Exit 1**
* Reports the device as **Non-Compliant**

Otherwise:

* Returns **Exit 0**
* Reports the device as **Compliant**

---

# Remediation Logic

If the device is using **Used Space Only** encryption, the remediation script performs the following steps:

## 1. Detect Current Encryption Type

Checks:

```text
manage-bde -status C:
```

for:

```text
Used Space Only
```

---

## 2. Disable BitLocker

The script begins decrypting the operating system drive:

```powershell
Disable-BitLocker -MountPoint C:
```

---

## 3. Monitor Decryption Progress

The remediation waits until decryption has completed by monitoring:

```powershell
Get-BitLockerVolume
```

and periodically reporting encryption progress.

---

## 4. Re-enable BitLocker

Once decryption is complete, BitLocker is re-enabled using:

```powershell
Enable-BitLocker `
    -MountPoint C: `
    -EncryptionMethod XtsAes128 `
    -UsedSpaceOnly:$false `
    -TpmProtector
```

This configures:

* **Full Drive Encryption**
* **XTS-AES 128**
* TPM protector

---

# Intune Configuration

| Setting                                     | Value                   |
| ------------------------------------------- | ----------------------- |
| Run this script using logged-on credentials | **No**                  |
| Run script in 64-bit PowerShell             | **Yes**                 |
| Enforce signature check                     | As required             |
| Schedule                                    | Organization preference |

> **Note:** Because full decryption and re-encryption can take many hours on larger drives, consider scheduling this remediation during maintenance windows or outside business hours.

---

# Files

```text
Detect-BitLockerEncryption.ps1
Remediate-BitLockerEncryption.ps1
README.md
```

---

# Example Workflow

1. Intune executes the detection script.
2. Devices using **Used Space Only** encryption are reported as **Non-Compliant**.
3. Intune runs the remediation script.
4. BitLocker begins decrypting the drive.
5. After decryption completes, BitLocker is re-enabled using **Full Drive Encryption (XTS-AES 128)**.
6. During the next detection cycle, the device reports as **Compliant**.

---

# Notes

* Designed specifically for **Microsoft Intune Remediations**.
* Executes under the **SYSTEM** account.
* Only remediates devices currently using **Used Space Only** encryption.
* Devices already using **Full Drive Encryption** are left unchanged.
* Progress is monitored automatically during decryption.
* Uses standard Intune remediation exit codes for accurate compliance reporting.

---

# Important Considerations

* Full disk decryption and re-encryption is a **time-consuming** operation and may take several hours depending on drive size, storage performance, and system activity.
* Devices should remain powered on throughout the remediation process.
* Encryption continues in the background after the remediation script completes if the process has been initiated successfully.
* Ensure BitLocker recovery keys are properly backed up (for example, to Microsoft Entra ID or Active Directory) before deploying this remediation broadly.
* Test the remediation with a small pilot group before deploying it organization-wide.

---

# Version History

| Version | Date       | Notes           |
| ------- | ---------- | --------------- |
| 1.0.0   | 2026-05-05 | Initial release |
