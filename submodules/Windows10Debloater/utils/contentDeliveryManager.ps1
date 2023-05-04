# This scripts removes and disables Content Delivery Manager from the registry.
# This prevents Windows 10 from pushing unwanted advertisements and apps to your computer.

# Privilege Escalation
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator and continue."
    Start-Sleep 1
    Write-Host "                                               3"
    Start-Sleep 1
    Write-Host "                                               2"
    Start-Sleep 1
    Write-Host "                                               1"
    Start-Sleep 1
    Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

New-PSDrive HKU Registry HKEY_USERS

# Remove content delivery manager subkeys
Remove-Item -Path "HKU:\*\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\*" -Recurse

# Delete SubscribedContent values
Remove-ItemProperty -Path "HKU:\*\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\" -Name "SubscribedContent-*Enabled"

# Set all content delivery values to zero
Set-Itemproperty -path "HKU:\*\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Value 0
Set-Itemproperty -path "HKU:\*\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "FeatureManagementEnabled" -Value 0
Set-Itemproperty -path "HKU:\*\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Value 0
Set-Itemproperty -path "HKU:\*\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Value 0
Set-Itemproperty -path "HKU:\*\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Value 0
Set-Itemproperty -path "HKU:\*\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Value 0
Set-Itemproperty -path "HKU:\*\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Value 0
Set-Itemproperty -path "HKU:\*\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SlideshowEnabled" -Value 0
Set-Itemproperty -path "HKU:\*\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Value 0
Set-Itemproperty -path "HKU:\*\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SoftLandingEnabled" -Value 0
Set-Itemproperty -path "HKU:\*\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Value 0

Remove-PSDrive -Name "HKU"

pause
