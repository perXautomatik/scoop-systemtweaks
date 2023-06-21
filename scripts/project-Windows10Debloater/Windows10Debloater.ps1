#This function finds any AppX/AppXProvisioned package and uninstalls it, except for Freshpaint, Windows Calculator, Windows Store, and Windows Photos.
#Also, to note - This does NOT remove essential system services/software/etc such as .NET framework installations, Cortana, Edge, etc.

#This is the switch parameter for running this script as a 'silent' script, for use in MDT images or any type of mass deployment without user interaction.
#This will self elevate the script so with a UAC prompt since this script needs to be run as an Administrator in order to function properly.
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\bloatwarelist.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\Disable-Cortana.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\DisableDarkMode.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\DisableTemetry.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\enableCortana.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\EnableDarkMode.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\Enable-EdgePDF.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\InstallNet35.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\NonRemovables.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\Remove-All-Bloatware.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\Remove-Keys.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\Revert-Changes.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\Stop-Edge-PDF-Takeover.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\UninstallOneDrive.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\UnpinStart.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\whitelist.psm1
Function DebloatBlacklist {

    foreach ($Bloat in $Bloatware) {
	Get-AppxPackage -Name $Bloat| Remove-AppxPackage
	Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat | Remove-AppxProvisionedPackage -Online
	Write-Output "Trying to remove $Bloat."
    }
}
param (
  [switch]$Debloat, [switch]$SysPrep
)
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

Function Begin-SysPrep {

    param([switch]$SysPrep)
	Write-Verbose -Message ('Starting Sysprep Fixes')

	# Disable Windows Store Automatic Updates
       <# Write-Verbose -Message "Adding Registry key to Disable Windows Store Automatic Updates"
	$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
	If (!(Test-Path $registryPath)) {
	    Mkdir $registryPath -ErrorAction SilentlyContinue
	    New-ItemProperty $registryPath -Name AutoDownload -Value 2
	}
	Else {
	    Set-ItemProperty $registryPath -Name AutoDownload -Value 2
	}
	#Stop WindowsStore Installer Service and set to Disabled
	Write-Verbose -Message ('Stopping InstallService')
	Stop-Service InstallService
	#>
 }

#Creates a PSDrive to be able to access the 'HKCR' tree
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

#no errors throughout
$ErrorActionPreference = 'silentlycontinue'

$DebloatFolder = "C:\Temp\Windows10Debloater"
If (Test-Path $DebloatFolder) {
    Write-Output "$DebloatFolder exists. Skipping."
}
Else {
    Write-Output "The folder '$DebloatFolder' doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path "$DebloatFolder" -ItemType Directory
    Write-Output "The folder $DebloatFolder was successfully created."
}

Start-Transcript -OutputDirectory "$DebloatFolder"

Add-Type -AssemblyName PresentationCore, PresentationFramework

Function DebloatAll {

    param([switch]$Debloat)

    #Removes AppxPackages
    #Credit to Reddit user /u/GavinEke for a modified version of my whitelist code
    [regex]$WhitelistedApps = 'Microsoft.ScreenSketch|Microsoft.Paint3D|Microsoft.WindowsCalculator|Microsoft.WindowsStore|Microsoft.Windows.Photos|CanonicalGroupLimited.UbuntuonWindows|`
    Microsoft.XboxGameCallableUI|Microsoft.XboxGamingOverlay|Microsoft.Xbox.TCUI|Microsoft.XboxGamingOverlay|Microsoft.XboxIdentityProvider|
    Microsoft.MicrosoftStickyNotes|Microsoft.MSPaint|Microsoft.WindowsCamera|.NET|Framework|`
    Microsoft.HEIFImageExtension|Microsoft.ScreenSketch|Microsoft.StorePurchaseApp|Microsoft.VP9VideoExtensions|Microsoft.WebMediaExtensions|Microsoft.WebpImageExtension|Microsoft.DesktopAppInstaller|WindSynthBerry|MIDIBerry|Slack'
    #NonRemovable Apps that where getting attempted and the system would reject the uninstall, speeds up debloat and prevents 'initalizing' overlay when removing apps
    $NonRemovable = '1527c705-839a-4832-9118-54d4Bd6a0c89|c5e2524a-ea46-4f67-841f-6a9465d9d515|E2A4F912-2574-4A75-9BB0-0D023378592B|F46D4000-FD22-4DB4-AC8E-4E1DDDE828FE|InputApp|Microsoft.AAD.BrokerPlugin|Microsoft.AccountsControl|`
    Microsoft.BioEnrollment|Microsoft.CredDialogHost|Microsoft.ECApp|Microsoft.LockApp|Microsoft.MicrosoftEdgeDevToolsClient|Microsoft.MicrosoftEdge|Microsoft.PPIProjection|Microsoft.Win32WebViewHost|Microsoft.Windows.Apprep.ChxApp|`
    Microsoft.Windows.AssignedAccessLockApp|Microsoft.Windows.CapturePicker|Microsoft.Windows.CloudExperienceHost|Microsoft.Windows.ContentDeliveryManager|Microsoft.Windows.Cortana|Microsoft.Windows.NarratorQuickStart|`
    Microsoft.Windows.ParentalControls|Microsoft.Windows.PeopleExperienceHost|Microsoft.Windows.PinningConfirmationDialog|Microsoft.Windows.SecHealthUI|Microsoft.Windows.SecureAssessmentBrowser|Microsoft.Windows.ShellExperienceHost|`
    Microsoft.Windows.XGpuEjectDialog|Microsoft.XboxGameCallableUI|Windows.CBSPreview|windows.immersivecontrolpanel|Windows.PrintDialog|Microsoft.VCLibs.140.00|Microsoft.Services.Store.Engagement|Microsoft.UI.Xaml.2.0|*Nvidia*'
    Get-AppxPackage -AllUsers | Where-Object {$_.Name -NotMatch $WhitelistedApps -and $_.Name -NotMatch $NonRemovable} | Remove-AppxPackage -ErrorAction SilentlyContinue
    # Run this again to avoid error on 1803 or having to reboot.
    Get-AppxPackage -AllUsers | Where-Object {$_.Name -NotMatch $WhitelistedApps -and $_.Name -NotMatch $NonRemovable} | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -NotMatch $WhitelistedApps -and $_.PackageName -NotMatch $NonRemovable} | Remove-AppxProvisionedPackage -Online
}





Function Protect-Privacy {

    Param([switch]$Debloat)

    #Creates a PSDrive to be able to access the 'HKCR' tree
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

    #Disables Windows Feedback Experience
    Write-Output "Disabling Windows Feedback Experience program"
    $Advertising = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
    If (Test-Path $Advertising) {
	Set-ItemProperty $Advertising -Name Enabled -Value 0 -Verbose
    }
}


Function CheckDMWService {

    Param([switch]$Debloat)

    If (Get-Service -Name dmwappushservice | Where-Object {$_.StartType -eq "Disabled"}) {
	Set-Service -Name dmwappushservice -StartupType Automatic
    }

    If (Get-Service -Name dmwappushservice | Where-Object {$_.Status -eq "Stopped"}) {
	Start-Service -Name dmwappushservice
    }
}


#This includes fixes by xsisbest
Function FixWhitelistedApps {

    Param([switch]$Debloat)

    If(!(Get-AppxPackage -AllUsers | Select Microsoft.Paint3D, Microsoft.MSPaint, Microsoft.WindowsCalculator, Microsoft.WindowsStore, Microsoft.MicrosoftStickyNotes, Microsoft.WindowsSoundRecorder, Microsoft.Windows.Photos)) {

    #Credit to abulgatz for the 4 lines of code
    Get-AppxPackage -allusers Microsoft.Paint3D | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
    Get-AppxPackage -allusers Microsoft.MSPaint | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
    Get-AppxPackage -allusers Microsoft.WindowsCalculator | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
    Get-AppxPackage -allusers Microsoft.WindowsStore | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
    Get-AppxPackage -allusers Microsoft.MicrosoftStickyNotes | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
    Get-AppxPackage -allusers Microsoft.WindowsSoundRecorder | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
    Get-AppxPackage -allusers Microsoft.Windows.Photos | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
}

#Interactive prompt Debloat/Revert options
$Button = [Windows.MessageBoxButton]::YesNoCancel
$ErrorIco = [Windows.MessageBoxImage]::Error
$Warn = [Windows.MessageBoxImage]::Warning
$Ask = 'The following will allow you to either Debloat Windows 10 or to revert changes made after Debloating Windows 10.
	Select "Yes" to Debloat Windows 10
	Select "No" to Revert changes made by this script

	Select "Cancel" to stop the script.'

$EverythingorSpecific = "Would you like to remove everything that was preinstalled on your Windows Machine? Select Yes to remove everything, or select No to remove apps via a blacklist."
$EdgePdf = "Do you want to stop edge from taking over as the default PDF viewer?"
$EdgePdf2 = "Do you want to revert changes that disabled Edge as the default PDF viewer?"
$Reboot = "For some of the changes to properly take effect it is recommended to reboot your machine. Would you like to restart?"
$OneDriveDelete = "Do you want to uninstall One Drive?"
$Unpin = "Do you want to unpin all items from the Start menu?"
$InstallNET = "Do you want to install .NET 3.5?"
$Prompt1 = [Windows.MessageBox]::Show($Ask, "Debloat or Revert", $Button, $ErrorIco)
Switch ($Prompt1) {
    #This will debloat Windows 10
    Yes {
	#Everything is specific prompt
	$Prompt2 = [Windows.MessageBox]::Show($EverythingorSpecific, "Everything or Specific", $Button, $Warn)
	switch ($Prompt2) {
	    Yes {
Write-Output "Initiating Sysprep"
Begin-SysPrep
		#Creates a "drive" to access the HKCR (HKEY_CLASSES_ROOT)
		Write-Host "Creating PSDrive 'HKCR' (HKEY_CLASSES_ROOT). This will be used for the duration of the script as it is necessary for the removal and modification of specific registry keys."
		New-PSDrive  HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
		Start-Sleep 1
		Write-Host "Uninstalling bloatware, please wait."
		DebloatAll
		Write-Host "Bloatware removed."
		Start-Sleep 1
		Write-Host "Removing specific registry keys."
		Remove-Keys
		Write-Host "Leftover bloatware registry keys removed."
		Start-Sleep 1
		Write-Host "Checking to see if any Whitelisted Apps were removed, and if so re-adding them."
		Start-Sleep 1
		FixWhitelistedApps
		Start-Sleep 1
		Write-Host "Disabling Cortana from search, disabling feedback to Microsoft, and disabling scheduled tasks that are considered to be telemetry or unnecessary."
		Protect-Privacy
		Start-Sleep 1
		DisableCortana
		Write-Host "Cortana disabled and removed from search, feedback to Microsoft has been disabled, and scheduled tasks are disabled."
		Start-Sleep 1
		Write-Host "Stopping and disabling Diagnostics Tracking Service"
		DisableDiagTrack
		Write-Host "Diagnostics Tracking Service disabled"
		Start-Sleep 1
		Write-Host "Disabling WAP push service"
		DisableWAPPush
		Start-Sleep 1
		Write-Host "Re-enabling DMWAppushservice if it was disabled"
		CheckDMWService
		Start-Sleep 1
		Write-Host "Removing 3D Objects from the 'My Computer' submenu in explorer"
		Remove3dObjects
		Start-Sleep 1
	    }
	    No {
		#Creates a "drive" to access the HKCR (HKEY_CLASSES_ROOT)
		Write-Host "Creating PSDrive 'HKCR' (HKEY_CLASSES_ROOT). This will be used for the duration of the script as it is necessary for the removal and modification of specific registry keys."
		New-PSDrive  HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
		Start-Sleep 1
		Write-Host "Uninstalling bloatware, please wait."
		DebloatBlacklist
		Write-Host "Bloatware removed."
		Start-Sleep 1
		Write-Host "Removing specific registry keys."
		Remove-Keys
		Write-Host "Leftover bloatware registry keys removed."
		Start-Sleep 1
		Write-Host "Checking to see if any Whitelisted Apps were removed, and if so re-adding them."
		Start-Sleep 1
		FixWhitelistedApps
		Start-Sleep 1
		Write-Host "Disabling Cortana from search, disabling feedback to Microsoft, and disabling scheduled tasks that are considered to be telemetry or unnecessary."
		Protect-Privacy
		Start-Sleep 1
		DisableCortana
		Write-Host "Cortana disabled and removed from search, feedback to Microsoft has been disabled, and scheduled tasks are disabled."
		Start-Sleep 1
		Write-Host "Stopping and disabling Diagnostics Tracking Service"
		DisableDiagTrack
		Write-Host "Diagnostics Tracking Service disabled"
		Start-Sleep 1
		Write-Host "Disabling WAP push service"
		Start-Sleep 1
		DisableWAPPush
		Write-Host "Re-enabling DMWAppushservice if it was disabled"
		CheckDMWService
		Start-Sleep 1
	    }
	}
	#Disabling EdgePDF prompt
	$Prompt3 = [Windows.MessageBox]::Show($EdgePdf, "Edge PDF", $Button, $Warn)
	Switch ($Prompt3) {
	    Yes {
		Stop-EdgePDF
		Write-Host "Edge will no longer take over as the default PDF viewer."
	    }
	    No {
		Write-Host "You chose not to stop Edge from taking over as the default PDF viewer."
	    }
	}
	#Prompt asking to delete OneDrive
	$Prompt4 = [Windows.MessageBox]::Show($OneDriveDelete, "Delete OneDrive", $Button, $ErrorIco)
	Switch ($Prompt4) {
	    Yes {
		UninstallOneDrive
		Write-Host "OneDrive is now removed from the computer."
	    }
	    No {
		Write-Host "You have chosen to skip removing OneDrive from your machine."
	    }
	}
	#Prompt asking if you'd like to unpin all start items
	$Prompt5 = [Windows.MessageBox]::Show($Unpin, "Unpin", $Button, $ErrorIco)
	Switch ($Prompt5) {
	    Yes {
		UnpinStart
		Write-Host "Start Apps unpined."
	    }
	    No {
		Write-Host "Apps will remain pinned to the start menu."

	    }
	}
	#Prompt asking if you want to install .NET
	$Prompt6 = [Windows.MessageBox]::Show($InstallNET, "Install .Net", $Button, $Warn)
	Switch ($Prompt6) {
	    Yes {
		Write-Host "Initializing the installation of .NET 3.5..."
		DISM /Online /Enable-Feature /FeatureName:NetFx3 /All
		Write-Host ".NET 3.5 has been successfully installed!"
	    }
	    No {
		Write-Host "Skipping .NET install."
	    }
	}
	#Prompt asking if you'd like to reboot your machine
	$Prompt7 = [Windows.MessageBox]::Show($Reboot, "Reboot", $Button, $Warn)
	Switch ($Prompt7) {
	    Yes {
		Write-Host "Unloading the HKCR drive..."
		Remove-PSDrive HKCR
		Start-Sleep 1
		Write-Host "Initiating reboot."
		Stop-Transcript
		Start-Sleep 2
		Restart-Computer
	    }
	    No {
		Write-Host "Unloading the HKCR drive..."
		Remove-PSDrive HKCR
		Start-Sleep 1
		Write-Host "Script has finished. Exiting."
		Stop-Transcript
		Start-Sleep 2
		Exit
	    }
	}
    }
    No {
	Write-Host "Reverting changes..."
	Write-Host "Creating PSDrive 'HKCR' (HKEY_CLASSES_ROOT). This will be used for the duration of the script as it is necessary for the modification of specific registry keys."
	New-PSDrive  HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
	Revert-Changes
	#Prompt asking to revert edge changes as well
	$Prompt6 = [Windows.MessageBox]::Show($EdgePdf2, "Revert Edge", $Button, $ErrorIco)
	Switch ($Prompt6) {
	    Yes {
		Enable-EdgePDF
		Write-Host "Edge will no longer be disabled from being used as the default Edge PDF viewer."
	    }
	    No {
		Write-Host "You have chosen to keep the setting that disallows Edge to be the default PDF viewer."
	    }
	}
	#Prompt asking if you'd like to reboot your machine
	$Prompt7 = [Windows.MessageBox]::Show($Reboot, "Reboot", $Button, $Warn)
	Switch ($Prompt7) {
	    Yes {
		Write-Host "Unloading the HKCR drive..."
		Remove-PSDrive HKCR
		Start-Sleep 1
		Write-Host "Initiating reboot."
		Stop-Transcript
		Start-Sleep 2
		Restart-Computer
	    }
	    No {
		Write-Host "Unloading the HKCR drive..."
		Remove-PSDrive HKCR
		Start-Sleep 1
		Write-Host "Script has finished. Exiting."
		Stop-Transcript
		Start-Sleep 2
		Exit
	    }
	}
#Write-Output "Stopping Edge from taking over as the default PDF Viewer."
#Stop-EdgePDF
CheckDMWService
CheckInstallService
Write-Output "Finished all tasks."
    }
}
