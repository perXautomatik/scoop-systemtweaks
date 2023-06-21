# This script removes all the unwanted applications that come with Windows 10.
# Please note I have chosen to remove most of the apps as I don't need them. This script might not fit your needs.

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

# Xbox apps
Get-AppxPackage -AllUsers *Microsoft.XboxIdentityProvider* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Microsoft.XboxSpeechToTextOverlay* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Microsoft.XboxGamingOverlay* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Microsoft.XboxGameOverlay* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Microsoft.XboxApp* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Microsoft.Xbox.TCUI* | Remove-AppxPackage

# Other unwanted apps
Get-AppxPackage -AllUsers *Microsoft.BingWeather* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Microsoft.GetHelp* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Microsoft.Getstarted* | Remove-AppxPackage

Get-AppxPackage -AllUsers *Microsoft.Microsoft3DViewer* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Microsoft.MicrosoftOfficeHub* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Microsoft.MicrosoftSolitaireCollection* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Microsoft.MixedReality.Portal* | Remove-AppxPackage

Get-AppxPackage -AllUsers *Microsoft.MSPaint* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Microsoft.Office.OneNote* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Microsoft.People* | Remove-AppxPackage

Get-AppxPackage -AllUsers *Microsoft.Wallet* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Microsoft.WindowsFeedbackHub* | Remove-AppxPackage

Get-AppxPackage -AllUsers *Microsoft.WindowsMaps* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Microsoft.WindowsSoundRecorder* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Microsoft.YourPhone* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Microsoft.ZuneMusic* | Remove-AppxPackage

Get-AppxPackage -AllUsers *Microsoft.ZuneVideo* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Microsoft.SkypeApp* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Microsoft.YourPhone* | Remove-AppxPackage

Get-AppxPackage -AllUsers *microsoft.windowscommunicationsapps* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Microsoft.WindowsCamera* | Remove-AppxPackage

Get-AppxPackage -AllUsers *Microsoft.OneConnect* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Microsoft.Messaging* | Remove-AppxPackage

# Uninstalls cortana on Windows 10 build 2004+
# Yes, you can fully remove her now!
Get-AppxPackage -AllUsers *Microsoft.549981C3F5F10* | Remove-AppxPackage

pause
