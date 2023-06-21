 {
	$ErrorActionPreference = 'SilentlyContinue'
	#This function finds any AppX/AppXProvisioned package and uninstalls it, except for Freshpaint, Windows Calculator, Windows Store, and Windows Photos.
	#Also, to note - This does NOT remove essential system services/software/etc such as .NET framework installations, Cortana, Edge, etc.

	#This is the switch parameter for running this script as a 'silent' script, for use in MDT images or any type of mass deployment without user interaction.
	    #Stops Cortana from being used as part of your Windows Search Function
	    Write-Host "Stopping Cortana from being used as part of your Windows Search Function"
    $Search = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
	    If (Test-Path $Search) {
	Set-ItemProperty $Search -Name AllowCortana -Value 0 -Verbose
    }

    #Disables Web Search in Start Menu
    Write-Output "Disabling Bing Search in Start Menu"
    $WebSearch = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" BingSearchEnabled -Value 0
    If (!(Test-Path $WebSearch)) {
	New-Item $WebSearch
    }
    Set-ItemProperty $WebSearch DisableWebSearch -Value 1

	    #Stops the Windows Feedback Experience from sending anonymous data
	    Write-Host "Stopping the Windows Feedback Experience program"
	    $Period1 = 'HKCU:\Software\Microsoft\Siuf'
	    $Period2 = 'HKCU:\Software\Microsoft\Siuf\Rules'
	    $Period3 = 'HKCU:\Software\Microsoft\Siuf\Rules\PeriodInNanoSeconds'
	    If (!(Test-Path $Period3)) {
	mkdir $Period1 -ErrorAction SilentlyContinue
	mkdir $Period2 -ErrorAction SilentlyContinue
	mkdir $Period3 -ErrorAction SilentlyContinue
	New-ItemProperty $Period3 -Name PeriodInNanoSeconds -Value 0 -Verbose -ErrorAction SilentlyContinue
	    }
    Set-ItemProperty $Period PeriodInNanoSeconds -Value 0

    #Prevents bloatware applications from returning and removes Start Menu suggestions
	    Write-Host "Adding Registry key to prevent bloatware apps from returning"
	    #Prevents bloatware applications from returning
    Write-Output "Adding Registry key to prevent bloatware apps from returning"
	    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    $registryOEM = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
	    If (!(Test-Path $registryPath)) {
	Mkdir $registryPath -ErrorAction SilentlyContinue
		New-ItemProperty $registryPath DisableWindowsConsumerFeatures -Value 1
	    }
	New-ItemProperty $registryPath -Name DisableWindowsConsumerFeatures -Value 1 -Verbose -ErrorAction SilentlyContinue

    If (!(Test-Path $registryOEM)) {
	New-Item $registryOEM
    }
    Set-ItemProperty $registryOEM  ContentDeliveryAllowed -Value 0
    Set-ItemProperty $registryOEM  OemPreInstalledAppsEnabled -Value 0
    Set-ItemProperty $registryOEM  PreInstalledAppsEnabled -Value 0
    Set-ItemProperty $registryOEM  PreInstalledAppsEverEnabled -Value 0
    Set-ItemProperty $registryOEM  SilentInstalledAppsEnabled -Value 0
    Set-ItemProperty $registryOEM  SystemPaneSuggestionsEnabled -Value 0

    #Preping mixed Reality Portal for removal
	    Write-Host "Setting Mixed Reality Portal value to 0 so that you can uninstall it in Settings"
	    $Holo = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic'
	    If (Test-Path $Holo) {
	Set-ItemProperty $Holo -Name FirstRunSucceeded -Value 0 -Verbose
    }

    #Disables Wi-fi Sense
    Write-Output "Disabling Wi-Fi Sense"
    $WifiSense1 = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting"
    $WifiSense2 = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots"
    $WifiSense3 = "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
    If (!(Test-Path $WifiSense1)) {
	New-Item $WifiSense1
    }
    Set-ItemProperty $WifiSense1  Value -Value 0
    If (!(Test-Path $WifiSense2)) {
	New-Item $WifiSense2
    }
    Set-ItemProperty $WifiSense2  Value -Value 0
    Set-ItemProperty $WifiSense3  AutoConnectAllowedOEM -Value 0

	    #Disables live tiles
	    Write-Host "Disabling live tiles"
    $Live = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
	    If (!(Test-Path $Live)) {
	mkdir $Live -ErrorAction SilentlyContinue
		New-ItemProperty $Live NoTileApplicationNotification -Value 1
	    }
	New-ItemProperty $Live -Name NoTileApplicationNotification -Value 1 -Verbose

	    #Turns off Data Collection via the AllowTelemtry key by changing it to 0
	    Write-Host "Turning off Data Collection"
    $DataCollection1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
    $DataCollection2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    $DataCollection3 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
	    $DataCollection = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'
    If (Test-Path $DataCollection1) {
	Set-ItemProperty $DataCollection -Name AllowTelemetry -Value 0 -Verbose
    }
    If (Test-Path $DataCollection2) {
	Set-ItemProperty $DataCollection2  AllowTelemetry -Value 0
    }
	    If (Test-Path $DataCollection) {
		Set-ItemProperty $DataCollection AllowTelemetry -Value 0
	    }
    If (Test-Path $DataCollection3) {
	Set-ItemProperty $DataCollection3  AllowTelemetry -Value 0
    }

    #Disabling Location Tracking
    Write-Output "Disabling Location Tracking"
    $SensorState = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}"
    $LocationConfig = "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration"
    If (!(Test-Path $SensorState)) {
	New-Item $SensorState
    }
    Set-ItemProperty $SensorState SensorPermissionState -Value 0
    If (!(Test-Path $LocationConfig)) {
	New-Item $LocationConfig
    }
    Set-ItemProperty $LocationConfig Status -Value 0

	    #Disables People icon on Taskbar
	    Write-Host "Disabling People icon on Taskbar"
	    $People = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People'
	    If (Test-Path $People) {
	Set-ItemProperty $People -Name PeopleBand -Value 0 -Verbose
	    }

	    #Disables suggestions on start menu
	    Write-Host "Disabling suggestions on the Start Menu"
	    $Suggestions = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
	    If (Test-Path $Suggestions) {
	Set-ItemProperty $Suggestions -Name SystemPaneSuggestionsEnabled -Value 0 -Verbose
	    }
    #Disables scheduled tasks that are considered unnecessary

    Write-Output "Disabling scheduled tasks"
    Get-ScheduledTask  XblGameSaveTaskLogon | Disable-ScheduledTask
    Get-ScheduledTask  XblGameSaveTask | Disable-ScheduledTask
    Get-ScheduledTask  Consolidator | Disable-ScheduledTask
    Get-ScheduledTask  UsbCeip | Disable-ScheduledTask
    Get-ScheduledTask  DmClient | Disable-ScheduledTask
    Get-ScheduledTask  DmClientOnScenarioDownload | Disable-ScheduledTask

	#Write-Host "Uninstalling Telemetry Windows Updates"
	#Uninstalls Some Windows Updates considered to be Telemetry. !WIP!
	#Wusa /Uninstall /KB:3022345 /norestart /quiet
	#Wusa /Uninstall /KB:3068708 /norestart /quiet
	#Wusa /Uninstall /KB:3075249 /norestart /quiet
	#Wusa /Uninstall /KB:3080149 /norestart /quiet

	Write-Host "Stopping and disabling WAP Push Service"
	#Stop and disable WAP Push Service
	Stop-Service "dmwappushservice"
	Set-Service "dmwappushservice" -StartupType Disabled

    Write-Output "Stopping and disabling Diagnostics Tracking Service"
    #Disabling the Diagnostics Tracking Service
    Stop-Service "DiagTrack"
    Set-Service "DiagTrack" -StartupType Disabled

	    Write-Host "Removing CloudStore from registry if it exists"
	    $CloudStore = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore'
	    If (Test-Path $CloudStore) {
     Stop-Process -Name explorer -Force
		Remove-Item $CloudStore -Recurse -Force
		Start-Process Explorer.exe -Wait
	    }

	    #Loads the registry keys/values below into the NTUSER.DAT file which prevents the apps from redownloading. Credit to a60wattfish
	    reg load HKU\Default_User C:\Users\Default\NTUSER.DAT
	    Set-ItemProperty -Path Registry::HKU\Default_User\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name SystemPaneSuggestionsEnabled -Value 0
	    Set-ItemProperty -Path Registry::HKU\Default_User\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name PreInstalledAppsEnabled -Value 0
	    Set-ItemProperty -Path Registry::HKU\Default_User\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name OemPreInstalledAppsEnabled -Value 0
	    reg unload HKU\Default_User

	    #Disables scheduled tasks that are considered unnecessary
	    Write-Host "Disabling scheduled tasks"
    #Get-ScheduledTask -TaskName XblGameSaveTaskLogon | Disable-ScheduledTask -ErrorAction SilentlyContinue
    Get-ScheduledTask -TaskName XblGameSaveTask | Disable-ScheduledTask -ErrorAction SilentlyContinue
    Get-ScheduledTask -TaskName Consolidator | Disable-ScheduledTask -ErrorAction SilentlyContinue
    Get-ScheduledTask -TaskName UsbCeip | Disable-ScheduledTask -ErrorAction SilentlyContinue
    Get-ScheduledTask -TaskName DmClient | Disable-ScheduledTask -ErrorAction SilentlyContinue
    Get-ScheduledTask -TaskName DmClientOnScenarioDownload | Disable-ScheduledTask -ErrorAction SilentlyContinue
}

	Function Begin-SysPrep {

	    Write-Host "Starting Sysprep Fixes"

	    # Disable Windows Store Automatic Updates
	    Write-Host "Adding Registry key to Disable Windows Store Automatic Updates"
	    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
	    If (!(Test-Path $registryPath)) {
		Mkdir $registryPath
		New-ItemProperty $registryPath AutoDownload -Value 2
	    }
	    Set-ItemProperty $registryPath AutoDownload -Value 2

	    #Stop WindowsStore Installer Service and set to Disabled
	    Write-Host "Stopping InstallService"
	    Stop-Service InstallService
	    Write-Host "Setting InstallService Startup to Disabled"
	    Set-Service InstallService -StartupType Disabled
	}

	Function CheckDMWService {

	    Param([switch]$Debloat)

	    If (Get-Service dmwappushservice | Where-Object { $_.StartType -eq "Disabled" }) {
		Set-Service dmwappushservice -StartupType Automatic
	    }

	    If (Get-Service dmwappushservice | Where-Object { $_.Status -eq "Stopped" }) {
		Start-Service dmwappushservice
	    }
	}

	Function DebloatAll {
	    #Removes AppxPackages
	    Get-AppxPackage | Where { !($_.Name -cmatch $global:WhiteListedAppsRegex) -and !($NonRemovables -cmatch $_.Name) } | Remove-AppxPackage
	    Get-AppxProvisionedPackage -Online | Where { !($_.DisplayName -cmatch $global:WhiteListedAppsRegex) -and !($NonRemovables -cmatch $_.DisplayName) } | Remove-AppxProvisionedPackage -Online
	    Get-AppxPackage -AllUsers | Where { !($_.Name -cmatch $global:WhiteListedAppsRegex) -and !($NonRemovables -cmatch $_.Name) } | Remove-AppxPackage
	}

	#Creates a PSDrive to be able to access the 'HKCR' tree
	New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

	Function Remove-Keys {
	    #These are the registry keys that it will delete.
	$ErrorActionPreference = 'SilentlyContinue'

	    $Keys = @(

	    New-PSDrive  HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
		#Remove Background Tasks
		"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
		"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
		"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
		"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
		"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
		"HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"

		#Windows File
		"HKCR:\Extensions\ContractId\Windows.File\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"

		#Registry keys to delete if they aren't uninstalled by RemoveAppXPackage/RemoveAppXProvisionedPackage
		"HKCR:\Extensions\ContractId\Windows.Launch\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
		"HKCR:\Extensions\ContractId\Windows.Launch\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
		"HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
		"HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
		"HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"

		#Scheduled Tasks to delete
		"HKCR:\Extensions\ContractId\Windows.PreInstalledConfigTask\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"

		#Windows Protocol Keys
		"HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
		"HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
		"HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
		"HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"

		#Windows Share Target
		"HKCR:\Extensions\ContractId\Windows.ShareTarget\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
	    )

	    #This writes the output of each key it is removing and also removes the keys listed above.
	    ForEach ($Key in $Keys) {
		Write-Host "Removing $Key from registry"
		Remove-Item $Key -Recurse
	    }
	}
	Write-Host "Additional bloatware keys have been removed!"
	Function Protect-Privacy {
	$ErrorActionPreference = 'SilentlyContinue'
	    #Creates a PSDrive to be able to access the 'HKCR' tree
	    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

	    #Disables Windows Feedback Experience
	    Write-Host "Disabling Windows Feedback Experience program"
	    $Advertising = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo'
	    If (Test-Path $Advertising) {
		Set-ItemProperty $Advertising Enabled -Value 0
	    }


	Function UnpinStart {
	    #Credit to Vikingat-Rage
	    #https://superuser.com/questions/1068382/how-to-remove-all-the-tiles-in-the-windows-10-start-menu
	    #Unpins all tiles from the Start Menu
	    Write-Host "Unpinning all tiles from the start menu"
	    (New-Object -Com Shell.Application).
	    NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').
	    Items() |
	    % { $_.Verbs() } |
	    ? { $_.Name -match 'Un.*pin from Start' } |
	    % { $_.DoIt() }
}

	Function Remove3dObjects {
	    #Removes 3D Objects from the 'My Computer' submenu in explorer
	    Write-Output "Removing 3D Objects from explorer 'My Computer' submenu"
	    $Objects32 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
	    $Objects64 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
	    If (Test-Path $Objects32) {
		Remove-Item $Objects32 -Recurse
	    }
	    If (Test-Path $Objects64) {
		Remove-Item $Objects64 -Recurse
	    }
	}

Function CheckDMWService {

  Param([switch]$Debloat)

If (Get-Service -Name dmwappushservice | Where-Object {$_.StartType -eq "Disabled"}) {
    Set-Service -Name dmwappushservice -StartupType Automatic}
	    }

If(Get-Service -Name dmwappushservice | Where-Object {$_.Status -eq "Stopped"}) {
   Start-Service -Name dmwappushservice}
  }
	}

Function CheckInstallService {
  Param([switch]$Debloat)
	  If (Get-Service -Name InstallService | Where-Object {$_.Status -eq "Stopped"}) {
	    Start-Service -Name InstallService
	    Set-Service -Name InstallService -StartupType Automatic
	    }
	}

	Write-Host "Initiating Sysprep"
	Begin-SysPrep
	Write-Host "Removing bloatware apps."
	DebloatAll
	Write-Host "Removing leftover bloatware registry keys."
	Remove-Keys
	Write-Host "Checking to see if any Whitelisted Apps were removed, and if so re-adding them."
	FixWhitelistedApps
	Write-Host "Stopping telemetry, disabling unneccessary scheduled tasks, and preventing bloatware from returning."
	Protect-Privacy
	Write-Host "Unpinning tiles from the Start Menu."
	UnpinStart
	Write-Host "Setting the 'InstallService' Windows service back to 'Started' and the Startup Type 'Automatic'."
	CheckDMWService
	CheckInstallService
	Write-Host "Finished all tasks. `n"

    }