<#
.SYNOPSIS
    Detects if the C: drive is fully encrypted with BitLocker using XtsAes128 encryption and
    checks for specific conditions related to encryption status and key protectors.
.DESCRIPTION
    Checks if the C: drive is fully encrypted with BitLocker using XtsAes128 encryption. It verifies if the encryption is complete, 
    if the protection status is on, if the drive is unlocked, and if a recovery password protector is present.
.NOTES
    Script Name   : Detect-BitLockerEncryption.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-05-05
    Required      : Run as SYSTEM via Intune Remediation
#>

$vol = Get-BitLockerVolume -MountPoint "C:"

if ($vol.VolumeStatus -eq "FullyEncrypted" -and $vol.EncryptionMethod -like "*XtsAes*") {
    if ($vol.MetadataVersion -and $vol.EncryptionPercentage -eq 100) {
        if ($vol.VolumeStatus -ne "FullyEncrypted") {
            exit 1
        }
    }
}

if ($vol.EncryptionMethod -eq "XtsAes128" -and $vol.VolumeStatus -eq "EncryptionInProgress") {
    exit 1
}

if ($vol.EncryptionMethod -eq "XtsAes128" -and $vol.VolumeStatus -eq "FullyEncrypted") {
    if ($vol.ProtectionStatus -eq "On" -and $vol.LockStatus -eq "Unlocked") {
        if ($vol.KeyProtector.KeyProtectorType -contains "RecoveryPassword") {
            if ($vol.VolumeStatus -ne "FullyEncrypted") {
                exit 1
            }
        }
    }
}

# Key check
if ((manage-bde -status c: | Select-String "Used Space Only")) {
    exit 1
}

exit 0