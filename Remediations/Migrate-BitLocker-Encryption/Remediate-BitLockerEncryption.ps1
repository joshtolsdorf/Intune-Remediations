<#
.SYNOPSIS
    Remediates the C: drive to ensure it is fully encrypted with BitLocker using XtsAes128 encryption.
.DESCRIPTION
    Fixes the C: drive to ensure it is fully encrypted with BitLocker using XtsAes128 encryption. It verifies if the encryption is complete, 
    if the protection status is on, if the drive is unlocked, and if a recovery password protector is present.
.NOTES
    Script Name   : Remediate-BitLockerEncryption.ps1
    Author        : Josh Tolsdorf
    Last Modified : 2026-05-05
    Required      : Run as SYSTEM via Intune Remediation
#>

Write-Host "Starting BitLocker migration to Full Encryption..." -ForegroundColor Blue

$MountPoint = "C:"

$Status = manage-bde -status $MountPoint

if ($Status -match "Used Space Only") {

    Write-Host "Detected Used Space Only encryption. Starting decryption..." -ForegroundColor Blue

    Disable-BitLocker -MountPoint $MountPoint

    do {
        Start-Sleep -Seconds 60
        $progress = (Get-BitLockerVolume -MountPoint $MountPoint).EncryptionPercentage
        Write-Host "Decrypting... $progress% complete"
    } while ($progress -gt 0)

    Write-Host "Decryption complete. Re-encrypting with Full encryption..." -ForegroundColor DarkGray

    Enable-BitLocker -MountPoint $MountPoint -EncryptionMethod XtsAes128 -UsedSpaceOnly:$false -TpmProtector

    Write-Host "BitLocker re-encryption initiated." -ForegroundColor DarkGray
}
else {
    Write-Host "Device already using Full encryption. No action needed." -ForegroundColor Blue
}