#This function finds any AppX/AppXProvisioned package and uninstalls it, except for Freshpaint, Windows Calculator, Windows Store, and Windows Photos.
#Also, to note - This does NOT remove essential system services/software/etc such as .NET framework installations, Cortana, Edge, etc.

#This will self elevate the script so with a UAC prompt since this script needs to be run as an Administrator in order to function properly.
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
    }
}
