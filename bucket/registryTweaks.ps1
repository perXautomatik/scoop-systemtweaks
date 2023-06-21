# Miscellaneous registry modifications.
# Review before running.

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
}

# Sets clock to UTC, prevents time issues when dual booting Linux/OSX systems.
# Does not cause any regression when single booting.
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -Value 1

# Disable Fullscreen optimization in games, fixes fullscreen flickering with some display adapters.
# May improve gaming performance.
New-PSDrive HKU Registry HKEY_USERS
Set-Itemproperty -path "HKU:\*\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -Value 2
Set-Itemproperty -path "HKU:\*\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 2
Set-Itemproperty -path "HKU:\*\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 2
Remove-PSDrive -Name "HKU"

# Disable Malware Removal Tool installation
New-Item -Force -Path "HKLM:\SOFTWARE\Policies\Microsoft" -Name MRT
Set-Itemproperty -path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" -Name "DontOfferThroughWUAU" -Value 1

# Disable NetBIOS over TCP/IP service
# This legacy service (< Win2k) is vulnerable and shouldn't be used anymore.
# Do not remove if your computer belongs to your organization's network and you are not sure.
Set-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT" -Name "Start" -Value 4

# Disable Web Search on Windows 10 2004+
# https://winaero.com/disable-web-search-in-taskbar-in-windows-10-version-2004/
Set-Itemproperty -path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1

pause
