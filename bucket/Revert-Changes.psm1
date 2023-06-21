 {
	$ErrorActionPreference = 'SilentlyContinue'
	#This function will revert the changes you made when running the Start-Debloat function.

	#This line reinstalls all of the bloatware that was removed
	Get-AppxPackage -AllUsers | ForEach { Add-AppxPackage -Verbose -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" }

	#Tells Windows to enable your advertising information.
	Write-Host "Re-enabling key to show advertisement information"
	$Advertising = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
	If (Test-Path $Advertising) {
	    Set-ItemProperty $Advertising  Enabled -Value 1
	}

	#Enables Cortana to be used as part of your Windows Search Function
	Write-Host "Re-enabling Cortana to be used in your Windows Search"
	$Search = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
	If (Test-Path $Search) {
	    Set-ItemProperty $Search  AllowCortana -Value 1
	}

	#Re-enables the Windows Feedback Experience for sending anonymous data
	Write-Host "Re-enabling Windows Feedback Experience"
	$Period = "HKCU:\Software\Microsoft\Siuf\Rules"
	If (!(Test-Path $Period)) {
	    New-Item $Period
	}
	Set-ItemProperty $Period PeriodInNanoSeconds -Value 1

	#Enables bloatware applications
	Write-Host "Adding Registry key to allow bloatware apps to return"
	$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
	If (!(Test-Path $registryPath)) {
	    New-Item $registryPath
	}
	Set-ItemProperty $registryPath  DisableWindowsConsumerFeatures -Value 0

	#Changes Mixed Reality Portal Key 'FirstRunSucceeded' to 1
	Write-Host "Setting Mixed Reality Portal value to 1"
	$Holo = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic"
	If (Test-Path $Holo) {
	    Set-ItemProperty $Holo  FirstRunSucceeded -Value 1
	}

	#Re-enables live tiles
	Write-Host "Enabling live tiles"
	$Live = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
	If (!(Test-Path $Live)) {
	    New-Item $Live
	}
	Set-ItemProperty $Live  NoTileApplicationNotification -Value 0

	#Re-enables data collection
	Write-Host "Re-enabling data collection"
	$DataCollection = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
	If (!(Test-Path $DataCollection)) {
	    New-Item $DataCollection
	}
	Set-ItemProperty $DataCollection  AllowTelemetry -Value 1

	#Re-enables People Icon on Taskbar
	Write-Host "Enabling People Icon on Taskbar"
    $People = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
    If (!(Test-Path $People)) {
	New-Item $People
    }
	If (Test-Path $People) {
	    Set-ItemProperty $People -Name PeopleBand -Value 1 -Verbose
	}

	#Re-enables suggestions on start menu
	Write-Host "Enabling suggestions on the Start Menu"
	$Suggestions = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
	If (!(Test-Path $Suggestions)) {
	    New-Item $Suggestions
	}
	Set-ItemProperty $Suggestions  SystemPaneSuggestionsEnabled -Value 1

	#Re-enables scheduled tasks that were disabled when running the Debloat switch
	Write-Host "Enabling scheduled tasks that were disabled"
	Get-ScheduledTask XblGameSaveTaskLogon | Enable-ScheduledTask
	Get-ScheduledTask  XblGameSaveTask | Enable-ScheduledTask
	Get-ScheduledTask  Consolidator | Enable-ScheduledTask
	Get-ScheduledTask  UsbCeip | Enable-ScheduledTask
	Get-ScheduledTask  DmClient | Enable-ScheduledTask
	Get-ScheduledTask  DmClientOnScenarioDownload | Enable-ScheduledTask

	Write-Host "Re-enabling and starting WAP Push Service"
	#Enable and start WAP Push Service
	Set-Service "dmwappushservice" -StartupType Automatic
	Start-Service "dmwappushservice"

	Write-Host "Re-enabling and starting the Diagnostics Tracking Service"
	#Enabling the Diagnostics Tracking Service
	Set-Service "DiagTrack" -StartupType Automatic
	Start-Service "DiagTrack"
	Write-Host "Done reverting changes!"

    Write-Output "Restoring 3D Objects in the 'My Computer' submenu in explorer"
	$Objects32 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
	$Objects64 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
	If (!(Test-Path $Objects32)) {
	    New-Item $Objects32
	}
	If (!(Test-Path $Objects64)) {
	    New-Item $Objects64
	}
    #Restoring 3D Objects in the 'My Computer' submenu in explorer
    Restore3dObjects
}
Function Restore3dObjects {
    #Restores 3D Objects from the 'My Computer' submenu in explorer
    Write-Host "Restoring 3D Objects from explorer 'My Computer' submenu"
    $Objects32 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
	$Objects64 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
	If (!(Test-Path $Objects32)) {
	    New-Item $Objects32
	}
	If (!(Test-Path $Objects64)) {
	    New-Item $Objects64
	}
}
