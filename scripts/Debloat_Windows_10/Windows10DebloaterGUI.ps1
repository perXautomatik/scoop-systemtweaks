<#
$EnableEdgePDFTakeover.Text = "Enable Edge PDF Takeover"
$EnableEdgePDFTakeover.Width = 185
$EnableEdgePDFTakeover.Height = 35
$EnableEdgePDFTakeover.Location = New-Object System.Drawing.Point(155, 260)
#>

#This will self elevate the script so with a UAC prompt since this script needs to be run as an Administrator in order to function properly.

$ErrorActionPreference = 'SilentlyContinue'

$Button = [System.Windows.MessageBoxButton]::YesNoCancel
$ErrorIco = [System.Windows.MessageBoxImage]::Error
$Ask = 'Do you want to run this as an Administrator?
	Select "Yes" to Run as an Administrator
	Select "No" to not run this as an Administrator

	Select "Cancel" to stop the script.'

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    $Prompt = [System.Windows.MessageBox]::Show($Ask, "Run as an Administrator or not?", $Button, $ErrorIco)
    Switch ($Prompt) {
	#This will debloat Windows 10
	Yes {
	    Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator and continue."
	    Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
	    Exit
	}
	No {
	    Break
	}
    }
}

#Unnecessary Windows 10 AppX apps that will be removed by the blacklist.
$global:Bloatware = @(
    "Microsoft.BingNews"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.Messaging"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.NetworkSpeedTest"
    "Microsoft.News"                                    # Issue 77
    "Microsoft.Office.Lens"                             # Issue 77
    "Microsoft.Office.OneNote"
    "Microsoft.Office.Sway"
    "Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.Print3D"
    "Microsoft.RemoteDesktop"                           # Issue 120
    "Microsoft.SkypeApp"
    "Microsoft.StorePurchaseApp"
    "Microsoft.Office.Todo.List"                        # Issue 77
    "Microsoft.Whiteboard"                              # Issue 77
    "Microsoft.WindowsAlarms"
    "microsoft.windowscommunicationsapps"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"

    #Sponsored Windows 10 AppX Apps
    #Add sponsored/featured apps to remove in the "*AppName*" format
    "EclipseManager"
    "ActiproSoftwareLLC"
    "AdobeSystemsIncorporated.AdobePhotoshopExpress"
    "Duolingo-LearnLanguagesforFree"
    "PandoraMediaInc"
    "CandyCrush"
    "BubbleWitch3Saga"
    "Wunderlist"
    "Flipboard"
    "Twitter"
    "Facebook"
    "Spotify"                                           # Issue 123
    "Minecraft"
    "Royal Revolt"
    "Sway"                                              # Issue 77
    "Dolby"                                             # Issue 78

    #Optional: Typically not removed but you can if you need to for some reason
    #"Microsoft.Advertising.Xaml_10.1712.5.0_x64__8wekyb3d8bbwe"
    #"Microsoft.Advertising.Xaml_10.1712.5.0_x86__8wekyb3d8bbwe"
    #"Microsoft.BingWeather"
)

#Valuable Windows 10 AppX apps that most people want to keep. Protected from DeBloat All.
#Credit to /u/GavinEke for a modified version of my whitelist code
$global:WhiteListedApps = @(
    "Microsoft.WindowsCalculator"               # Microsoft removed legacy calculator
    "Microsoft.WindowsStore"                    # Issue 1
    "Microsoft.Windows.Photos"                  # Microsoft disabled/hid legacy photo viewer
    "CanonicalGroupLimited.UbuntuonWindows"     # Issue 10
    "Microsoft.Xbox.TCUI"                       # Issue 25, 91  Many home users want to play games
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"               # Issue 25, 91  Many home users want to play games
    "Microsoft.XboxIdentityProvider"            # Issue 25, 91  Many home users want to play games
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.MicrosoftStickyNotes"            # Issue 33  New functionality.
    "Microsoft.MSPaint"                         # Issue 32  This is Paint3D, legacy paint still exists in Windows 10
    "Microsoft.WindowsCamera"                   # Issue 65  New functionality.
    "\.NET"
    "Microsoft.HEIFImageExtension"              # Issue 68
    "Microsoft.ScreenSketch"                    # Issue 55: Looks like Microsoft will be axing snipping tool and using Snip & Sketch going forward
    "Microsoft.StorePurchaseApp"                # Issue 68
    "Microsoft.VP9VideoExtensions"              # Issue 68
    "Microsoft.WebMediaExtensions"              # Issue 68
    "Microsoft.WebpImageExtension"              # Issue 68
    "Microsoft.DesktopAppInstaller"             # Issue 68
    "WindSynthBerry"                            # Issue 68
    "MIDIBerry"                                 # Issue 68
    "Slack"                                     # Issue 83
    "*Nvidia*"                                  # Issue 198
    "Microsoft.MixedReality.Portal"             # Issue 195
)

#NonRemovable Apps that where getting attempted and the system would reject the uninstall, speeds up debloat and prevents 'initalizing' overlay when removing apps
$NonRemovables = Get-AppxPackage -AllUsers | Where-Object { $_.NonRemovable -eq $true } | ForEach { $_.Name }
$NonRemovables += Get-AppxPackage | Where-Object { $_.NonRemovable -eq $true } | ForEach { $_.Name }
$NonRemovables += Get-AppxProvisionedPackage -Online | Where-Object { $_.NonRemovable -eq $true } | ForEach { $_.DisplayName }
$NonRemovables = $NonRemovables | Sort-Object -Unique

if ($NonRemovables -eq $null ) {
    # the .NonRemovable property doesn't exist until version 18xx. Use a hard-coded list instead.
    #WARNING: only use exact names here - no short names or wildcards
    $NonRemovables = @(
	"1527c705-839a-4832-9118-54d4Bd6a0c89"
	"c5e2524a-ea46-4f67-841f-6a9465d9d515"
	"E2A4F912-2574-4A75-9BB0-0D023378592B"
	"F46D4000-FD22-4DB4-AC8E-4E1DDDE828FE"
	"InputApp"
	"Microsoft.AAD.BrokerPlugin"
	"Microsoft.AccountsControl"
	"Microsoft.BioEnrollment"
	"Microsoft.CredDialogHost"
	"Microsoft.ECApp"
	"Microsoft.LockApp"
	"Microsoft.MicrosoftEdgeDevToolsClient"
	"Microsoft.MicrosoftEdge"
	"Microsoft.PPIProjection"
	"Microsoft.Win32WebViewHost"
	"Microsoft.Windows.Apprep.ChxApp"
	"Microsoft.Windows.AssignedAccessLockApp"
	"Microsoft.Windows.CapturePicker"
	"Microsoft.Windows.CloudExperienceHost"
	"Microsoft.Windows.ContentDeliveryManager"
	"Microsoft.Windows.Cortana"
	"Microsoft.Windows.HolographicFirstRun"         # Added 1709
	"Microsoft.Windows.NarratorQuickStart"
	"Microsoft.Windows.OOBENetworkCaptivePortal"    # Added 1709
	"Microsoft.Windows.OOBENetworkConnectionFlow"   # Added 1709
	"Microsoft.Windows.ParentalControls"
	"Microsoft.Windows.PeopleExperienceHost"
	"Microsoft.Windows.PinningConfirmationDialog"
	"Microsoft.Windows.SecHealthUI"                 # Issue 117 Windows Defender
	"Microsoft.Windows.SecondaryTileExperience"     # Added 1709
	"Microsoft.Windows.SecureAssessmentBrowser"
	"Microsoft.Windows.ShellExperienceHost"
	"Microsoft.Windows.XGpuEjectDialog"
	"Microsoft.XboxGameCallableUI"                  # Issue 91
	"Windows.CBSPreview"
	"windows.immersivecontrolpanel"
	"Windows.PrintDialog"
	"Microsoft.VCLibs.140.00"
	"Microsoft.Services.Store.Engagement"
	"Microsoft.UI.Xaml.2.0"
    )
}

# import library code - located relative to this script
Function dotInclude() {
    Param(
	[Parameter(Mandatory)]
	[string]$includeFile
    )
    # Look for the file in the same directory as this script
    $scriptPath = $PSScriptRoot
    if ( $PSScriptRoot -eq $null -and $psISE) {
	$scriptPath = (Split-Path -Path $psISE.CurrentFile.FullPath)
    }
    if ( test-path $scriptPath\$includeFile ) {
	# import and immediately execute the requested file
	. $scriptPath\$includeFile
    }
}

# Override built-in blacklist/whitelist with user defined lists
dotInclude 'custom-lists.ps1'

#convert to regular expression to allow for the super-useful -match operator
$global:BloatwareRegex = $global:Bloatware -join '|'
$global:WhiteListedAppsRegex = $global:WhiteListedApps -join '|'


# This form was created using POSHGUI.com  a free online gui designer for PowerShell
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

#region begin GUI
$Form = New-Object System.Windows.Forms.Form
$Form.ClientSize = '800,500'
$Form.Text = "Windows10Debloater"
$Form.TopMost = $false

$Debloat = New-Object System.Windows.Forms.Label
$Debloat.Text = "Debloat Options"
$Debloat.AutoSize = $true
$Debloat.Width = 25
$Debloat.Height = 10
$Debloat.Location = New-Object System.Drawing.Point(9, 8)
$Debloat.Font = 'Microsoft Sans Serif,12,style=Bold,Underline'


$CustomizeBlacklists = New-Object System.Windows.Forms.Button
$CustomizeBlacklists.Text = "Customize Blacklist"
$CustomizeBlacklists.Width = 140
$CustomizeBlacklists.Height = 40
$CustomizeBlacklists.Location = New-Object System.Drawing.Point(9, 32)
$CustomizeBlacklists.Font = 'Microsoft Sans Serif,10'

$RemoveAllBloatware = New-Object System.Windows.Forms.Button
$RemoveAllBloatware.Text = "Remove All Bloatware"
$RemoveAllBloatware.Width = 142
$RemoveAllBloatware.Height = 40
$RemoveAllBloatware.Location = New-Object System.Drawing.Point(8, 79)
$RemoveAllBloatware.Font = 'Microsoft Sans Serif,10'

$RemoveBlacklist = New-Object System.Windows.Forms.Button
$RemoveBlacklist.Text = "Remove Bloatware With Customized Blacklist"
$RemoveBlacklist.Width = 205
$RemoveBlacklist.Height = 37
$RemoveBlacklist.Location = New-Object System.Drawing.Point(9, 124)
$RemoveBlacklist.Font = 'Microsoft Sans Serif,10'

$Label1 = New-Object System.Windows.Forms.Label
$Label1.Text = "Revert Registry Changes"
$Label1.AutoSize = $true
$Label1.Width = 25
$Label1.Height = 10
$Label1.Location = New-Object System.Drawing.Point(254, 7)
$Label1.Font = 'Microsoft Sans Serif,12,style=Bold,Underline'

$RevertChange = New-Object System.Windows.Forms.Button
$RevertChange.Text = "Revert Registry Changes"
$RevertChange.Width = 113
$RevertChange.Height = 36
$RevertChange.Location = New-Object System.Drawing.Point(254, 32)
$RevertChange.Font = 'Microsoft Sans Serif,10'

$Label2 = New-Object System.Windows.Forms.Label
$Label2.Text = "Optional Changes/Fixes"
$Label2.AutoSize = $true
$Label2.Width = 25
$Label2.Height = 10
$Label2.Location = New-Object System.Drawing.Point(9, 193)
$Label2.Font = 'Microsoft Sans Serif,12,style=Bold,Underline'

$DisableCortana = New-Object System.Windows.Forms.Button
$DisableCortana.Text = "Disable Cortana"
$DisableCortana.Width = 111
$DisableCortana.Height = 36
$DisableCortana.Location = New-Object System.Drawing.Point(9, 217)
$DisableCortana.Font = 'Microsoft Sans Serif,10'

$EnableCortana = New-Object System.Windows.Forms.Button
$EnableCortana.Text = "Enable Cortana"
$EnableCortana.Width = 112
$EnableCortana.Height = 36
$EnableCortana.Location = New-Object System.Drawing.Point(9, 260)
$EnableCortana.Font = 'Microsoft Sans Serif,10'

$StopEdgePDFTakeover = New-Object System.Windows.Forms.Button
$StopEdgePDFTakeover.Text = "Stop Edge PDF Takeover"
$StopEdgePDFTakeover.Width = 175
$StopEdgePDFTakeover.Height = 35
$StopEdgePDFTakeover.Location = New-Object System.Drawing.Point(155, 217)
$StopEdgePDFTakeover.Font = 'Microsoft Sans Serif,10'

$EnableEdgePDFTakeover = New-Object System.Windows.Forms.Button
$EnableEdgePDFTakeover.Text = "Enable Edge PDF Takeover"
$EnableEdgePDFTakeover.Width = 185
$EnableEdgePDFTakeover.Height = 35
$EnableEdgePDFTakeover.Location = New-Object System.Drawing.Point(155, 260)
$EnableEdgePDFTakeover.Font = 'Microsoft Sans Serif,10'

$DisableTelemetry = New-Object System.Windows.Forms.Button
$DisableTelemetry.Text = "Disable Telemetry/Tasks"
$DisableTelemetry.Width = 152
$DisableTelemetry.Height = 35
$DisableTelemetry.Location = New-Object System.Drawing.Point(365, 260)
$DisableTelemetry.Font = 'Microsoft Sans Serif,10'

$RemoveRegkeys = New-Object System.Windows.Forms.Button
$RemoveRegkeys.Text = "Remove Bloatware Regkeys"
$RemoveRegkeys.Width = 188
$RemoveRegkeys.Height = 35
$RemoveRegkeys.Location = New-Object System.Drawing.Point(540, 260)
$RemoveRegkeys.Font = 'Microsoft Sans Serif,10'

$UnpinStartMenuTiles = New-Object System.Windows.Forms.Button
$UnpinStartMenuTiles.Text = "Unpin Tiles From Start Menu"
$UnpinStartMenuTiles.Width = 190
$UnpinStartMenuTiles.Height = 35
$UnpinStartMenuTiles.Location = New-Object System.Drawing.Point(540, 217)
$UnpinStartMenuTiles.Font = 'Microsoft Sans Serif,10'

$RemoveOnedrive = New-Object System.Windows.Forms.Button
$RemoveOnedrive.Text = "Uninstall OneDrive"
$RemoveOnedrive.Width = 152
$RemoveOnedrive.Height = 35
$RemoveOnedrive.Location = New-Object System.Drawing.Point(365, 217)
$RemoveOnedrive.Font = 'Microsoft Sans Serif,10'

#$FixWhitelist = New-Object System.Windows.Forms.Button
#$FixWhitelist.Text = "Fix Whitelisted Apps"
#$FixWhitelist.Width = 130
#$FixWhitelist.Height = 37
#$FixWhitelist.Location = New-Object System.Drawing.Point(254, 74)
#$FixWhitelist.Font = 'Microsoft Sans Serif,10'

$InstallNet35 = New-Object System.Windows.Forms.Button
$InstallNet35.Text = "Install .NET v3.5"
$InstallNet35.Width = 152
$InstallNet35.Height = 39
$InstallNet35.Location = New-Object System.Drawing.Point(169, 335)
$InstallNet35.Font = 'Microsoft Sans Serif,10'

$EnableDarkMode = New-Object System.Windows.Forms.Button
$EnableDarkMode.Text = "Enable Dark Mode"
$EnableDarkMode.Width = 152
$EnableDarkMode.Height = 39
$EnableDarkMode.Location = New-Object System.Drawing.Point(9, 335)
$EnableDarkMode.Font = 'Microsoft Sans Serif,10'

$DisableDarkMode = New-Object System.Windows.Forms.Button
$DisableDarkMode.Text = "Disable Dark Mode"
$DisableDarkMode.Width = 152
$DisableDarkMode.Height = 39
$DisableDarkMode.Location = New-Object System.Drawing.Point(9, 385)
$DisableDarkMode.Font = 'Microsoft Sans Serif,10'



$Form.controls.AddRange(@($Debloat, $CustomizeBlacklists, $RemoveAllBloatware, $RemoveBlacklist, $Label1, $RevertChange, $Label2, $DisableCortana, $EnableCortana, $StopEdgePDFTakeover, $EnableEdgePDFTakeover, $DisableTelemetry, $RemoveRegkeys, $UnpinStartMenuTiles, $RemoveOnedrive, $FixWhitelist, $RemoveBloatNoBlacklist, $InstallNet35, $EnableDarkMode, $DisableDarkMode))

$DebloatFolder = "C:\Temp\Windows10Debloater"
If (Test-Path $DebloatFolder) {
    Write-Host "${DebloatFolder} exists. Skipping."
}
Else {
    Write-Host "The folder ${DebloatFolder} doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path "${DebloatFolder}" -ItemType Directory
    Write-Host "The folder ${DebloatFolder} was successfully created."
}

Start-Transcript -OutputDirectory "${DebloatFolder}"

#region gui events {
$CustomizeBlacklists.Add_Click( {
	$CustomizeForm = New-Object System.Windows.Forms.Form
	$CustomizeForm.ClientSize = '600,400'
	$CustomizeForm.Text = "Customize Whitelist and Blacklist"
	$CustomizeForm.TopMost = $false
	$CustomizeForm.AutoScroll = $true

	$SaveList = New-Object System.Windows.Forms.Button
	$SaveList.Text = "Save custom Whitelist and Blacklist to custom-lists.ps1"
	$SaveList.AutoSize = $true
	$SaveList.Location = New-Object System.Drawing.Point(200, 5)
	$CustomizeForm.controls.Add($SaveList)

	$SaveList.Add_Click( {
		$ErrorActionPreference = 'SilentlyContinue'

		'$global:WhiteListedApps = @(' | Out-File -FilePath $PSScriptRoot\custom-lists.ps1 -Encoding utf8
		@($CustomizeForm.controls) | ForEach {
		    if ($_ -is [System.Windows.Forms.CheckBox] -and $_.Enabled -and !$_.Checked) {
			"    ""$( $_.Text )""" | Out-File -FilePath $PSScriptRoot\custom-lists.ps1 -Append -Encoding utf8
		    }
		}
		')' | Out-File -FilePath $PSScriptRoot\custom-lists.ps1 -Append -Encoding utf8

		'$global:Bloatware = @(' | Out-File -FilePath $PSScriptRoot\custom-lists.ps1 -Append -Encoding utf8
		@($CustomizeForm.controls) | ForEach {
		    if ($_ -is [System.Windows.Forms.CheckBox] -and $_.Enabled -and $_.Checked) {
			"    ""$($_.Text)""" | Out-File -FilePath $PSScriptRoot\custom-lists.ps1 -Append -Encoding utf8
		    }
		}
		')' | Out-File -FilePath $PSScriptRoot\custom-lists.ps1 -Append -Encoding utf8

		#Over-ride the white/blacklist with the newly saved custom list
		dotInclude custom-lists.ps1

		#convert to regular expression to allow for the super-useful -match operator
		$global:BloatwareRegex = $global:Bloatware -join '|'
		$global:WhiteListedAppsRegex = $global:WhiteListedApps -join '|'
	    })

	Function AddAppToCustomizeForm() {
	    Param(
		[Parameter(Mandatory)]
		[int] $position,
		[Parameter(Mandatory)]
		[string] $appName,
		[Parameter(Mandatory)]
		[bool] $enabled,
		[Parameter(Mandatory)]
		[bool] $checked,

		[string] $notes
	    )

	    $label = New-Object System.Windows.Forms.Label
	    $label.Location = New-Object System.Drawing.Point(2, (30 + $position * 16))
	    $label.Text = $notes
	    $label.Width = 300
	    $label.Height = 16
	    $Label.TextAlign = [System.Drawing.ContentAlignment]::TopRight
	    $CustomizeForm.controls.Add($label)

	    $Checkbox = New-Object System.Windows.Forms.CheckBox
	    $Checkbox.Text = $appName
	    $Checkbox.Location = New-Object System.Drawing.Point(320, (30 + $position * 16))
	    $Checkbox.Autosize = 1;
	    $Checkbox.Checked = $checked
	    $Checkbox.Enabled = $enabled
	    $CustomizeForm.controls.Add($CheckBox)
	}


	$Installed = @( (Get-AppxPackage).Name )
	$Online = @( (Get-AppxProvisionedPackage -Online).DisplayName )
	$AllUsers = @( (Get-AppxPackage -AllUsers).Name )
	[int]$checkboxCounter = 0

	ForEach ($item in $NonRemovables) {
	    $string = ""
	    if ( $null -notmatch $global:BloatwareRegex -and $item -cmatch $global:BloatwareRegex ) { $string += " ConflictBlacklist " }
	    if ( $null -notmatch $global:WhiteListedAppsRegex -and $item -cmatch $global:WhiteListedAppsRegex ) { $string += " ConflictWhitelist" }
	    if ( $null -notmatch $Installed -and $Installed -cmatch $item) { $string += "Installed" }
	    if ( $null -notmatch $AllUsers -and $AllUsers -cmatch $item) { $string += " AllUsers" }
	    if ( $null -notmatch $Online -and $Online -cmatch $item) { $string += " Online" }
	    $string += "  NONREMOVABLE"
	    AddAppToCustomizeForm $checkboxCounter $item $false $false $string
	    ++$checkboxCounter
	}
	ForEach ( $item in $global:WhiteListedApps ) {
	    $string = ""
	    if ( $null -notmatch $NonRemovables -and $NonRemovables -cmatch $item ) { $string += " Conflict NonRemovables " }
	    if ( $null -notmatch $global:BloatwareRegex -and $item -cmatch $global:BloatwareRegex ) { $string += " ConflictBlacklist " }
	    if ( $null -notmatch $Installed -and $Installed -cmatch $item) { $string += "Installed" }
	    if ( $null -notmatch $AllUsers -and $AllUsers -cmatch $item) { $string += " AllUsers" }
	    if ( $null -notmatch $Online -and $Online -cmatch $item) { $string += " Online" }
	    AddAppToCustomizeForm $checkboxCounter $item $true $false $string
	    ++$checkboxCounter
	}
	ForEach ( $item in $global:Bloatware ) {
	    $string = ""
	    if ( $null -notmatch $NonRemovables -and $NonRemovables -cmatch $item ) { $string += " Conflict NonRemovables " }
	    if ( $null -notmatch $global:WhiteListedAppsRegex -and $item -cmatch $global:WhiteListedAppsRegex ) { $string += " Conflict Whitelist " }
	    if ( $null -notmatch $Installed -and $Installed -cmatch $item) { $string += "Installed" }
	    if ( $null -notmatch $AllUsers -and $AllUsers -cmatch $item) { $string += " AllUsers" }
	    if ( $null -notmatch $Online -and $Online -cmatch $item) { $string += " Online" }
	    AddAppToCustomizeForm $checkboxCounter $item $true $true $string
	    ++$checkboxCounter
	}
	ForEach ( $item in $AllUsers ) {
	    $string = "NEW   AllUsers"
	    if ( $null -notmatch $NonRemovables -and $NonRemovables -cmatch $item ) { continue }
	    if ( $null -notmatch $global:WhiteListedAppsRegex -and $item -cmatch $global:WhiteListedAppsRegex ) { continue }
	    if ( $null -notmatch $global:BloatwareRegex -and $item -cmatch $global:BloatwareRegex ) { continue }
	    if ( $null -notmatch $Installed -and $Installed -cmatch $item) { $string += " Installed" }
	    if ( $null -notmatch $Online -and $Online -cmatch $item) { $string += " Online" }
	    AddAppToCustomizeForm $checkboxCounter $item $true $true $string
	    ++$checkboxCounter
	}
	ForEach ( $item in $Installed ) {
	    $string = "NEW   Installed"
	    if ( $null -notmatch $NonRemovables -and $NonRemovables -cmatch $item ) { continue }
	    if ( $null -notmatch $global:WhiteListedAppsRegex -and $item -cmatch $global:WhiteListedAppsRegex ) { continue }
	    if ( $null -notmatch $global:BloatwareRegex -and $item -cmatch $global:BloatwareRegex ) { continue }
	    if ( $null -notmatch $AllUsers -and $AllUsers -cmatch $item) { continue }
	    if ( $null -notmatch $Online -and $Online -cmatch $item) { $string += " Online" }
	    AddAppToCustomizeForm $checkboxCounter $item $true $true $string
	    ++$checkboxCounter
	}
	ForEach ( $item in $Online ) {
	    $string = "NEW   Online "
	    if ( $null -notmatch $NonRemovables -and $NonRemovables -cmatch $item ) { continue }
	    if ( $null -notmatch $global:WhiteListedAppsRegex -and $item -cmatch $global:WhiteListedAppsRegex ) { continue }
	    if ( $null -notmatch $global:BloatwareRegex -and $item -cmatch $global:BloatwareRegex ) { continue }
	    if ( $null -notmatch $Installed -and $Installed -cmatch $item) { continue }
	    if ( $null -notmatch $AllUsers -and $AllUsers -cmatch $item) { continue }
	    AddAppToCustomizeForm $checkboxCounter $item $true $true $string
	    ++$checkboxCounter
	}
	[void]$CustomizeForm.ShowDialog()

    })


$RemoveBlacklist.Add_Click( {
	$ErrorActionPreference = 'SilentlyContinue'
	Function DebloatBlacklist {
	    Write-Host "Requesting removal of $global:BloatwareRegex"
	    Write-Host "--- This may take a while - please be patient ---"
	    Get-AppxPackage | Where-Object Name -cmatch $global:BloatwareRegex | Remove-AppxPackage
	    Write-Host "...now starting the silent ProvisionedPackage bloatware removal..."
	    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -cmatch $global:BloatwareRegex | Remove-AppxProvisionedPackage -Online
	    Write-Host "...and the final cleanup..."
	    Get-AppxPackage -AllUsers | Where-Object Name -cmatch $global:BloatwareRegex | Remove-AppxPackage
	}
	Write-Host "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`nRemoving blacklisted Bloatware.`n"
	DebloatBlacklist
	Write-Host "Bloatware removed!"
    })
$RemoveAllBloatware.Add_Click( {
	$ErrorActionPreference = 'SilentlyContinue'
	#This function finds any AppX/AppXProvisioned package and uninstalls it, except for Freshpaint, Windows Calculator, Windows Store, and Windows Photos.
	#Also, to note - This does NOT remove essential system services/software/etc such as .NET framework installations, Cortana, Edge, etc.

	#This is the switch parameter for running this script as a 'silent' script, for use in MDT images or any type of mass deployment without user interaction.




	#Creates a PSDrive to be able to access the 'HKCR' tree
	New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT



	    #Stops Cortana from being used as part of your Windows Search Function
	    Write-Host "Stopping Cortana from being used as part of your Windows Search Function"
	    $Search = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'
	    If (Test-Path $Search) {
		Set-ItemProperty $Search AllowCortana -Value 0

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
		mkdir $Period1
		mkdir $Period2
		mkdir $Period3
		New-ItemProperty $Period3 PeriodInNanoSeconds -Value 0
	    }
    Set-ItemProperty $Period PeriodInNanoSeconds -Value 0

	    Write-Host "Adding Registry key to prevent bloatware apps from returning"
    #Prevents bloatware applications from returning and removes Start Menu suggestions
    Write-Output "Adding Registry key to prevent bloatware apps from returning"
	    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    $registryOEM = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
	    If (!(Test-Path $registryPath)) {
		Mkdir $registryPath
		New-ItemProperty $registryPath DisableWindowsConsumerFeatures -Value 1
    }
    Set-ItemProperty $registryPath DisableWindowsConsumerFeatures -Value 1

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
    Write-Output "Setting Mixed Reality Portal value to 0 so that you can uninstall it in Settings"
    $Holo = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic"
    If (Test-Path $Holo) {
	Set-ItemProperty $Holo  FirstRunSucceeded -Value 0
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
	    $Live = 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications'
	    If (!(Test-Path $Live)) {
		mkdir $Live
		New-ItemProperty $Live NoTileApplicationNotification -Value 1
	    }
    Set-ItemProperty $Live  NoTileApplicationNotification -Value 1

	    #Turns off Data Collection via the AllowTelemtry key by changing it to 0
	    Write-Host "Turning off Data Collection"
    $DataCollection1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
    $DataCollection2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    $DataCollection3 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
	    $DataCollection = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'
    If (Test-Path $DataCollection1) {
	Set-ItemProperty $DataCollection1  AllowTelemetry -Value 0
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
	Set-ItemProperty $People -Name PeopleBand -Value 0
	    }

	    #Disables suggestions on start menu
	    Write-Host "Disabling suggestions on the Start Menu"
	    $Suggestions = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
	    If (Test-Path $Suggestions) {
		Set-ItemProperty $Suggestions SystemPaneSuggestionsEnabled -Value 0
	    }

    #Disables scheduled tasks that are considered unnecessary
    Write-Output "Disabling scheduled tasks"
    Get-ScheduledTask  XblGameSaveTaskLogon | Disable-ScheduledTask
    Get-ScheduledTask  XblGameSaveTask | Disable-ScheduledTask
    Get-ScheduledTask  Consolidator | Disable-ScheduledTask
    Get-ScheduledTask  UsbCeip | Disable-ScheduledTask
    Get-ScheduledTask  DmClient | Disable-ScheduledTask
    Get-ScheduledTask  DmClientOnScenarioDownload | Disable-ScheduledTask

    Write-Output "Stopping and disabling Diagnostics Tracking Service"
    #Disabling the Diagnostics Tracking Service
    Stop-Service "DiagTrack"
    Set-Service "DiagTrack" -StartupType Disabled


	    Write-Host "Removing CloudStore from registry if it exists"
	    $CloudStore = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore'
	    If (Test-Path $CloudStore) {
		Stop-Process Explorer.exe -Force
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
	    #Get-ScheduledTask -TaskName XblGameSaveTaskLogon | Disable-ScheduledTask
	    Get-ScheduledTask -TaskName XblGameSaveTask | Disable-ScheduledTask
	    Get-ScheduledTask -TaskName Consolidator | Disable-ScheduledTask
	    Get-ScheduledTask -TaskName UsbCeip | Disable-ScheduledTask
	    Get-ScheduledTask -TaskName DmClient | Disable-ScheduledTask
	    Get-ScheduledTask -TaskName DmClientOnScenarioDownload | Disable-ScheduledTask
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

    } )
$RevertChange.Add_Click(  Revert-Changes  )
$DisableCortana.Add_Click( {
	$ErrorActionPreference = 'SilentlyContinue'
	Write-Host "Disabling Cortana"
	$Cortana1 = "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"
	$Cortana2 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
	$Cortana3 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
	If (!(Test-Path $Cortana1)) {
	    New-Item $Cortana1
	}
	Set-ItemProperty $Cortana1 AcceptedPrivacyPolicy -Value 0
	If (!(Test-Path $Cortana2)) {
	    New-Item $Cortana2
	}
	Set-ItemProperty $Cortana2 RestrictImplicitTextCollection -Value 1
	Set-ItemProperty $Cortana2 RestrictImplicitInkCollection -Value 1
	If (!(Test-Path $Cortana3)) {
	    New-Item $Cortana3
	}
	Set-ItemProperty $Cortana3 HarvestContacts -Value 0
	Write-Host "Cortana has been disabled."
    })
$StopEdgePDFTakeover.Add_Click( {
	$ErrorActionPreference = 'SilentlyContinue'
	#Stops edge from taking over as the default .PDF viewer
	Write-Host "Stopping Edge from taking over as the default .PDF viewer"
	$NoPDF = "HKCR:\.pdf"
	$NoProgids = "HKCR:\.pdf\OpenWithProgids"
	$NoWithList = "HKCR:\.pdf\OpenWithList"
	If (!(Get-ItemProperty $NoPDF  NoOpenWith)) {
	    New-ItemProperty $NoPDF NoOpenWith
	}
	If (!(Get-ItemProperty $NoPDF  NoStaticDefaultVerb)) {
	    New-ItemProperty $NoPDF  NoStaticDefaultVerb
	}
	If (!(Get-ItemProperty $NoProgids  NoOpenWith)) {
	    New-ItemProperty $NoProgids  NoOpenWith
	}
	If (!(Get-ItemProperty $NoProgids  NoStaticDefaultVerb)) {
	    New-ItemProperty $NoProgids  NoStaticDefaultVerb
	}
	If (!(Get-ItemProperty $NoWithList  NoOpenWith)) {
	    New-ItemProperty $NoWithList  NoOpenWith
	}
	If (!(Get-ItemProperty $NoWithList  NoStaticDefaultVerb)) {
	    New-ItemProperty $NoWithList  NoStaticDefaultVerb
	}

	#Appends an underscore '_' to the Registry key for Edge
	$Edge = "HKCR:\AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723_"
	If (Test-Path $Edge) {
	    Set-Item $Edge AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723_
	}
	Write-Host "Edge should no longer take over as the default .PDF."
    })
$EnableCortana.Add_Click( {
	$ErrorActionPreference = 'SilentlyContinue'
	Write-Host "Re-enabling Cortana"
	$Cortana1 = "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"
	$Cortana2 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
	$Cortana3 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
	If (!(Test-Path $Cortana1)) {
	    New-Item $Cortana1
	}
	Set-ItemProperty $Cortana1 AcceptedPrivacyPolicy -Value 1
	If (!(Test-Path $Cortana2)) {
	    New-Item $Cortana2
	}
	Set-ItemProperty $Cortana2 RestrictImplicitTextCollection -Value 0
	Set-ItemProperty $Cortana2 RestrictImplicitInkCollection -Value 0
	If (!(Test-Path $Cortana3)) {
	    New-Item $Cortana3
	}
	Set-ItemProperty $Cortana3 HarvestContacts -Value 1
	Write-Host "Cortana has been enabled!"
    })
$EnableEdgePDFTakeover.Add_Click( Enable-EdgePDF )

$DisableTelemetry.Add_Click( {
	Protect-Privacy


	#Stops Cortana from being used as part of your Windows Search Function
	Write-Host "Stopping Cortana from being used as part of your Windows Search Function"
	$Search = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
	If (Test-Path $Search) {
	    Set-ItemProperty $Search AllowCortana -Value 0
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
	$Period = "HKCU:\Software\Microsoft\Siuf\Rules"
	If (!(Test-Path $Period)) {
	    New-Item $Period
	}
	Set-ItemProperty $Period PeriodInNanoSeconds -Value 0

	#Prevents bloatware applications from returning and removes Start Menu suggestions
	Write-Host "Adding Registry key to prevent bloatware apps from returning"
	$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
	$registryOEM = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
	If (!(Test-Path $registryPath)) {
	    New-Item $registryPath
	}
	Set-ItemProperty $registryPath DisableWindowsConsumerFeatures -Value 1

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
	$Holo = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic"
	If (Test-Path $Holo) {
	    Set-ItemProperty $Holo  FirstRunSucceeded -Value 0
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
	    New-Item $Live
	}
	Set-ItemProperty $Live  NoTileApplicationNotification -Value 1

	#Turns off Data Collection via the AllowTelemtry key by changing it to 0
	Write-Host "Turning off Data Collection"
	$DataCollection1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
	$DataCollection2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
	$DataCollection3 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
	If (Test-Path $DataCollection1) {
	    Set-ItemProperty $DataCollection1  AllowTelemetry -Value 0
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
	    Set-ItemProperty $People -Name PeopleBand -Value 0
	}

	#Disables scheduled tasks that are considered unnecessary
	Write-Host "Disabling scheduled tasks"
	#Get-ScheduledTask XblGameSaveTaskLogon | Disable-ScheduledTask
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
	Write-Host "Telemetry has been disabled!"
    })
$RemoveRegkeys.Add_Click( Remove-Keys )
$UnpinStartMenuTiles.Add_Click( UnpinStart)

$RemoveOnedrive.Add_Click( UninstallOneDrive  )

$InstallNet35.Add_Click( InstallNet35 )

$EnableDarkMode.Add_Click(  EnableDarkMode )

$DisableDarkMode.Add_Click( DisableDarkMode)

[void]$Form.ShowDialog()
