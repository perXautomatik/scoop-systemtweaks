function DisableTemetry()
{
	$ErrorActionPreference = 'SilentlyContinue'
    #Creates a PSDrive to be able to access the 'HKCR' tree
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

	#Disables Windows Feedback Experience
	Write-Host "Disabling Windows Feedback Experience program"
	$Advertising = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
	If (Test-Path $Advertising) {
	Set-ItemProperty $Advertising -Name Enabled -Value 0 -Verbose
	}

	#Stops Cortana from being used as part of your Windows Search Function
	Write-Host "Stopping Cortana from being used as part of your Windows Search Function"
	$Search = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
	If (Test-Path $Search) {
	Set-ItemProperty $Search -Name AllowCortana -Value 0 -Verbose
	}

	#Disables Web Search in Start Menu
	Write-Host "Disabling Bing Search in Start Menu"
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
	$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
	$registryOEM = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
	If (!(Test-Path $registryPath)) {
	Mkdir $registryPath -ErrorAction SilentlyContinue
	}
	New-ItemProperty $registryPath -Name DisableWindowsConsumerFeatures -Value 1 -Verbose -ErrorAction SilentlyContinue

	If (!(Test-Path $registryOEM)) {
	    New-Item $registryOEM
	}
	Set-ItemProperty $registryOEM ContentDeliveryAllowed -Value 0
	Set-ItemProperty $registryOEM OemPreInstalledAppsEnabled -Value 0
	Set-ItemProperty $registryOEM PreInstalledAppsEnabled -Value 0
	Set-ItemProperty $registryOEM PreInstalledAppsEverEnabled -Value 0
	Set-ItemProperty $registryOEM SilentInstalledAppsEnabled -Value 0
	Set-ItemProperty $registryOEM SystemPaneSuggestionsEnabled -Value 0

	#Preping mixed Reality Portal for removal
	Write-Host "Setting Mixed Reality Portal value to 0 so that you can uninstall it in Settings"
    $Holo = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic'
	If (Test-Path $Holo) {
	Set-ItemProperty $Holo -Name FirstRunSucceeded -Value 0 -Verbose
	}

	#Disables Wi-fi Sense
	Write-Host "Disabling Wi-Fi Sense"
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
    }
	New-ItemProperty $Live -Name NoTileApplicationNotification -Value 1 -Verbose

	#Turns off Data Collection via the AllowTelemtry key by changing it to 0
	Write-Host "Turning off Data Collection"
	$DataCollection1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
	$DataCollection2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
	$DataCollection3 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
	If (Test-Path $DataCollection1) {
	Set-ItemProperty $DataCollection -Name AllowTelemetry -Value 0 -Verbose
	}
	If (Test-Path $DataCollection2) {
	    Set-ItemProperty $DataCollection2  AllowTelemetry -Value 0
	}
	If (Test-Path $DataCollection3) {
	    Set-ItemProperty $DataCollection3  AllowTelemetry -Value 0
	}

	#Disabling Location Tracking
	Write-Host "Disabling Location Tracking"
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
    Write-Output "Disabling suggestions on the Start Menu"
    $Suggestions = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
    If (Test-Path $Suggestions) {
	Set-ItemProperty $Suggestions -Name SystemPaneSuggestionsEnabled -Value 0 -Verbose
    }
	#Disables scheduled tasks that are considered unnecessary
	Write-Host "Disabling scheduled tasks"
    Get-ScheduledTask  XblGameSaveTaskLogon | Disable-ScheduledTask
	Get-ScheduledTask XblGameSaveTask | Disable-ScheduledTask
	Get-ScheduledTask Consolidator | Disable-ScheduledTask
	Get-ScheduledTask UsbCeip | Disable-ScheduledTask
	Get-ScheduledTask DmClient | Disable-ScheduledTask
	Get-ScheduledTask DmClientOnScenarioDownload | Disable-ScheduledTask

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

	Write-Host "Stopping and disabling Diagnostics Tracking Service"
	#Disabling the Diagnostics Tracking Service
	Stop-Service "DiagTrack"
	Set-Service "DiagTrack" -StartupType Disabled

     Write-Output "Removing CloudStore from registry if it exists"
     $CloudStore = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore'
     If (Test-Path $CloudStore) {
     Stop-Process -Name explorer -Force
     Remove-Item $CloudStore -Recurse -Force
     Start-Process Explorer.exe -Wait
	Write-Host "Telemetry has been disabled!"
    }
