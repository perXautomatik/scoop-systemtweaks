# NTFS filesystem tweaks
# Thanks to: https://notes.ponderworthy.com/fsutil-tweaks-for-ntfs-performance-and-reliability
# NOTE: You may want to adapt your drive letters. This script assumes C: and D: letters are used

# Privilege Escalation
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
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

fsutil behavior set memoryusage 2
fsutil behavior set disablelastaccess 1
fsutil behavior set mftzone 2

$DriveLetters = (Get-WmiObject -Class Win32_Volume).DriveLetter
ForEach ($Drive in $DriveLetters){
    If (-not ([string]::IsNullOrEmpty($Drive))){
	Write-Host Optimizing "$Drive" Drive
	fsutil resource setavailable "$Drive":\
	fsutil resource setlog shrink 10 "$Drive":\
    }
}
