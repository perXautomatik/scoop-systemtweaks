<#
$EnableEdgePDFTakeover.Text = "Enable Edge PDF Takeover"
$EnableEdgePDFTakeover.Width = 185
$EnableEdgePDFTakeover.Height = 35
$EnableEdgePDFTakeover.Location = New-Object System.Drawing.Point(155, 260)
#>

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
$Form.ClientSize                 = New-Object System.Drawing.Point(500,570)
$Form.StartPosition              = 'CenterScreen'
$Form.FormBorderStyle            = 'FixedSingle'
$Form.MinimizeBox                = $false
$Form.ClientSize = '800,500'
$Form.MaximizeBox                = $false
$Form.ShowIcon                   = $false
$Form.Text = "Windows10Debloater"
$Form.TopMost = $false
$Form.BackColor                  = [System.Drawing.ColorTranslator]::FromHtml("#252525")

$DebloatPanel                    = New-Object system.Windows.Forms.Panel
$DebloatPanel.height             = 160
$DebloatPanel.width              = 480
$DebloatPanel.Anchor             = 'top,right,left'
$DebloatPanel.location           = New-Object System.Drawing.Point(10,10)
$RegistryPanel                   = New-Object system.Windows.Forms.Panel
$RegistryPanel.height            = 80
$RegistryPanel.width             = 480
$RegistryPanel.Anchor            = 'top,right,left'
$RegistryPanel.location          = New-Object System.Drawing.Point(10,180)
$CortanaPanel                    = New-Object system.Windows.Forms.Panel
$CortanaPanel.height             = 120
$CortanaPanel.width              = 153
$CortanaPanel.Anchor             = 'top,right,left'
$CortanaPanel.location           = New-Object System.Drawing.Point(10,270)
$EdgePanel                       = New-Object system.Windows.Forms.Panel
$EdgePanel.height                = 120
$EdgePanel.width                 = 154
$EdgePanel.Anchor                = 'top,right,left'
$EdgePanel.location              = New-Object System.Drawing.Point(173,270)
$DarkThemePanel                  = New-Object system.Windows.Forms.Panel
$DarkThemePanel.height           = 120
$DarkThemePanel.width            = 153
$DarkThemePanel.Anchor           = 'top,right,left'
$DarkThemePanel.location         = New-Object System.Drawing.Point(337,270)
$OtherPanel                      = New-Object system.Windows.Forms.Panel
$OtherPanel.height               = 160
$OtherPanel.width                = 480
$OtherPanel.Anchor               = 'top,right,left'
$OtherPanel.location             = New-Object System.Drawing.Point(10,400)
$Debloat = New-Object System.Windows.Forms.Label
$Debloat.Text = "Debloat Options"
$Debloat.AutoSize = $true
$Debloat.width                   = 457
$Debloat.height                  = 142
$Debloat.Anchor                  = 'top,right,left'
$Debloat.location                = New-Object System.Drawing.Point(10,9)
$Debloat.Font                    = New-Object System.Drawing.Font('Consolas',15,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
$Debloat.Font = 'Microsoft Sans Serif,12,style=Bold,Underline'
$Debloat.ForeColor               = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")

$CustomizeBlacklists = New-Object System.Windows.Forms.Button
$CustomizeBlacklists.FlatStyle   = 'Flat'
$CustomizeBlacklists.text        = "CUSTOMISE BLOCKLIST"
$CustomizeBlacklists.width       = 460
$CustomizeBlacklists.height      = 30
$CustomizeBlacklists.Anchor      = 'top,right,left'
$CustomizeBlacklists.location    = New-Object System.Drawing.Point(10,40)
$CustomizeBlacklists.Font        = New-Object System.Drawing.Font('Consolas',9)
$CustomizeBlacklists.Font = 'Microsoft Sans Serif,10'
$CustomizeBlacklists.ForeColor   = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")

$RemoveAllBloatware = New-Object System.Windows.Forms.Button
$RemoveAllBloatware.FlatStyle    = 'Flat'
$RemoveAllBloatware.Text = "Remove All Bloatware"
$RemoveAllBloatware.width        = 460
$RemoveAllBloatware.height       = 30
$RemoveAllBloatware.Anchor       = 'top,right,left'
$RemoveAllBloatware.location     = New-Object System.Drawing.Point(10,80)
$RemoveAllBloatware.Font         = New-Object System.Drawing.Font('Consolas',9)
$RemoveAllBloatware.Font = 'Microsoft Sans Serif,10'
$RemoveAllBloatware.ForeColor    = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")

$RemoveBlacklist = New-Object System.Windows.Forms.Button
$RemoveBlacklist.FlatStyle       = 'Flat'
$RemoveBlacklist.text            = "REMOVE BLOATWARE WITH CUSTOM BLOCKLIST"
$RemoveBlacklist.width           = 460
$RemoveBlacklist.height          = 30
$RemoveBlacklist.Anchor          = 'top,right,left'
$RemoveBlacklist.location        = New-Object System.Drawing.Point(10,120)
$RemoveBlacklist.Font            = New-Object System.Drawing.Font('Consolas',9)
$RemoveBlacklist.Font = 'Microsoft Sans Serif,10'
$RemoveBlacklist.ForeColor       = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")

$Registry                        = New-Object system.Windows.Forms.Label
$Registry.text                   = "REGISTRY CHANGES"
$Registry.AutoSize               = $true
$Registry.width                  = 457
$Registry.height                 = 142
$Registry.Anchor                 = 'top,right,left'
$Registry.location               = New-Object System.Drawing.Point(10,10)
$Registry.Font                   = New-Object System.Drawing.Font('Consolas',15,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
$Registry.ForeColor              = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")
$Label1 = New-Object System.Windows.Forms.Label
$Label1.Text = "Revert Registry Changes"
$Label1.AutoSize = $true
$Label1.Width = 25
$Label1.Height = 10
$Label1.Location = New-Object System.Drawing.Point(254, 7)
$Label1.Font = 'Microsoft Sans Serif,12,style=Bold,Underline'

$RevertChange = New-Object System.Windows.Forms.Button
$RevertChange.FlatStyle          = 'Flat'
$RevertChange.Text = "Revert Registry Changes"
$RevertChange.width              = 460
$RevertChange.height             = 30
$RevertChange.Anchor             = 'top,right,left'
$RevertChange.location           = New-Object System.Drawing.Point(10,40)
$RevertChange.Font               = New-Object System.Drawing.Font('Consolas',9)
$RevertChange.Font = 'Microsoft Sans Serif,10'
$RevertChange.ForeColor          = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")

$Cortana                         = New-Object system.Windows.Forms.Label
$Cortana.text                    = "CORTANA"
$Cortana.AutoSize                = $true
$Cortana.width                   = 457
$Cortana.height                  = 142
$Cortana.Anchor                  = 'top,right,left'
$Cortana.location                = New-Object System.Drawing.Point(10,10)
$Cortana.Font                    = New-Object System.Drawing.Font('Consolas',15,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
$Cortana.ForeColor               = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")
$Label2 = New-Object System.Windows.Forms.Label
$Label2.Text = "Optional Changes/Fixes"
$Label2.AutoSize = $true
$Label2.Width = 25
$Label2.Height = 10
$Label2.Location = New-Object System.Drawing.Point(9, 193)
$EnableCortana                   = New-Object system.Windows.Forms.Button
$EnableCortana.FlatStyle         = 'Flat'
$EnableCortana.text              = "ENABLE"
$EnableCortana.width             = 133
$EnableCortana.height            = 30
$EnableCortana.Anchor            = 'top,right,left'
$EnableCortana.location          = New-Object System.Drawing.Point(10,40)
$EnableCortana.Font              = New-Object System.Drawing.Font('Consolas',9)
$EnableCortana.ForeColor         = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")
$Label2.Font = 'Microsoft Sans Serif,12,style=Bold,Underline'

$DisableCortana = New-Object System.Windows.Forms.Button
$DisableCortana.FlatStyle        = 'Flat'
$DisableCortana.Text = "Disable Cortana"
$DisableCortana.width            = 133
$DisableCortana.height           = 30
$DisableCortana.Anchor           = 'top,right,left'
$DisableCortana.location         = New-Object System.Drawing.Point(10,80)
$DisableCortana.Font             = New-Object System.Drawing.Font('Consolas',9)
$DisableCortana.Font = 'Microsoft Sans Serif,10'
$DisableCortana.ForeColor        = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")

$Edge                            = New-Object system.Windows.Forms.Label
$Edge.text                       = "EDGE PDF"
$Edge.AutoSize                   = $true
$Edge.width                      = 457
$Edge.height                     = 142
$Edge.Anchor                     = 'top,right,left'
$Edge.location                   = New-Object System.Drawing.Point(10,10)
$Edge.Font                       = New-Object System.Drawing.Font('Consolas',15,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
$Edge.ForeColor                  = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")
$EnableCortana = New-Object System.Windows.Forms.Button
$EnableCortana.Text = "Enable Cortana"
$EnableCortana.Width = 112
$EnableCortana.Height = 36
$EnableCortana.Location = New-Object System.Drawing.Point(9, 260)
$EnableCortana.Font = 'Microsoft Sans Serif,10'
$EnableEdgePDFTakeover = New-Object System.Windows.Forms.Button
$EnableEdgePDFTakeover.FlatStyle = 'Flat'
$EnableEdgePDFTakeover.Text = "Enable Edge PDF Takeover"
$EnableEdgePDFTakeover.width     = 134
$EnableEdgePDFTakeover.height    = 30
$EnableEdgePDFTakeover.Anchor    = 'top,right,left'
$EnableEdgePDFTakeover.location  = New-Object System.Drawing.Point(10,40)
$EnableEdgePDFTakeover.Font      = New-Object System.Drawing.Font('Consolas',9)
$EnableEdgePDFTakeover.Font = 'Microsoft Sans Serif,10'
$EnableEdgePDFTakeover.ForeColor  = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")

$StopEdgePDFTakeover = New-Object System.Windows.Forms.Button
$StopEdgePDFTakeover.FlatStyle   = 'Flat'
$StopEdgePDFTakeover.Text = "Stop Edge PDF Takeover"
$StopEdgePDFTakeover.width       = 134
$StopEdgePDFTakeover.height      = 30
$StopEdgePDFTakeover.Anchor      = 'top,right,left'
$StopEdgePDFTakeover.location    = New-Object System.Drawing.Point(10,80)
$StopEdgePDFTakeover.Font        = New-Object System.Drawing.Font('Consolas',9)
$StopEdgePDFTakeover.Font = 'Microsoft Sans Serif,10'
$StopEdgePDFTakeover.ForeColor   = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")

$Theme                           = New-Object system.Windows.Forms.Label
$Theme.text                      = "DARK THEME"
$Theme.AutoSize                  = $true
$Theme.width                     = 457
$Theme.height                    = 142
$Theme.Anchor                    = 'top,right,left'
$Theme.location                  = New-Object System.Drawing.Point(10,10)
$Theme.Font                      = New-Object System.Drawing.Font('Consolas',15,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
$Theme.ForeColor                 = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")
$EnableDarkMode = New-Object System.Windows.Forms.Button
$EnableDarkMode.FlatStyle        = 'Flat'
$EnableDarkMode.Text = "Enable Dark Mode"
$EnableDarkMode.width            = 133
$EnableDarkMode.height           = 30
$EnableDarkMode.Anchor           = 'top,right,left'
$EnableDarkMode.location         = New-Object System.Drawing.Point(10,40)
$EnableDarkMode.Font             = New-Object System.Drawing.Font('Consolas',9)
$EnableDarkMode.Font = 'Microsoft Sans Serif,10'
$EnableDarkMode.ForeColor        = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")

$DisableDarkMode = New-Object System.Windows.Forms.Button
$DisableDarkMode.FlatStyle       = 'Flat'
$DisableDarkMode.Text = "Disable Dark Mode"
$DisableDarkMode.width           = 133
$DisableDarkMode.height          = 30
$DisableDarkMode.Anchor          = 'top,right,left'
$DisableDarkMode.location        = New-Object System.Drawing.Point(10,80)
$DisableDarkMode.Font            = New-Object System.Drawing.Font('Consolas',9)
$DisableDarkMode.Font = 'Microsoft Sans Serif,10'
$DisableDarkMode.ForeColor       = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")

$Other                           = New-Object system.Windows.Forms.Label
$Other.text                      = "OTHER CHANGES & FIXES"
$Other.AutoSize                  = $true
$Other.width                     = 457
$Other.height                    = 142
$Other.Anchor                    = 'top,right,left'
$Other.location                  = New-Object System.Drawing.Point(10,10)
$Other.Font                      = New-Object System.Drawing.Font('Consolas',15,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
$Other.ForeColor                 = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")

$RemoveOnedrive = New-Object System.Windows.Forms.Button
$RemoveOnedrive.FlatStyle        = 'Flat'
$RemoveOnedrive.Text = "Uninstall OneDrive"
$RemoveOnedrive.width            = 225
$RemoveOnedrive.height           = 30
$RemoveOnedrive.Anchor           = 'top,right,left'
$RemoveOnedrive.location         = New-Object System.Drawing.Point(10,40)
$RemoveOnedrive.Font             = New-Object System.Drawing.Font('Consolas',9)
$RemoveOnedrive.Font = 'Microsoft Sans Serif,10'
$RemoveOnedrive.ForeColor        = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")

$UnpinStartMenuTiles = New-Object System.Windows.Forms.Button
$UnpinStartMenuTiles.FlatStyle   = 'Flat'
$UnpinStartMenuTiles.Text = "Unpin Tiles From Start Menu"
$UnpinStartMenuTiles.width       = 225
$UnpinStartMenuTiles.height      = 30
$UnpinStartMenuTiles.Anchor      = 'top,right,left'
$UnpinStartMenuTiles.location    = New-Object System.Drawing.Point(245,40)
$UnpinStartMenuTiles.Font        = New-Object System.Drawing.Font('Consolas',9)
$UnpinStartMenuTiles.Font = 'Microsoft Sans Serif,10'
$UnpinStartMenuTiles.ForeColor   = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")


$DisableTelemetry = New-Object System.Windows.Forms.Button
$DisableTelemetry.FlatStyle      = 'Flat'
$DisableTelemetry.text           = "DISABLE TELEMETRY / TASKS"
$DisableTelemetry.width          = 225
$DisableTelemetry.height         = 30
$DisableTelemetry.Anchor         = 'top,right,left'
$DisableTelemetry.location       = New-Object System.Drawing.Point(10,80)
$DisableTelemetry.Font           = New-Object System.Drawing.Font('Consolas',9)
$DisableTelemetry.Font = 'Microsoft Sans Serif,10'
$DisableTelemetry.ForeColor      = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")

#$FixWhitelist = New-Object System.Windows.Forms.Button
#$FixWhitelist.Text = "Fix Whitelisted Apps"
#$FixWhitelist.Width = 130
#$FixWhitelist.Height = 37
#$FixWhitelist.Location = New-Object System.Drawing.Point(254, 74)
#$FixWhitelist.Font = 'Microsoft Sans Serif,10'
$RemoveRegkeys = New-Object System.Windows.Forms.Button
$RemoveRegkeys.FlatStyle         = 'Flat'
$RemoveRegkeys.Text = "Remove Bloatware Regkeys"
$RemoveRegkeys.width             = 225
$RemoveRegkeys.height            = 30
$RemoveRegkeys.Anchor            = 'top,right,left'
$RemoveRegkeys.location          = New-Object System.Drawing.Point(245,80)
$RemoveRegkeys.Font              = New-Object System.Drawing.Font('Consolas',9)
$RemoveRegkeys.Font = 'Microsoft Sans Serif,10'
$RemoveRegkeys.ForeColor         = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")

$InstallNet35 = New-Object System.Windows.Forms.Button
$InstallNet35.FlatStyle          = 'Flat'
$InstallNet35.Text = "Install .NET v3.5"
$InstallNet35.width              = 460
$InstallNet35.height             = 30
$InstallNet35.Anchor             = 'top,right,left'
$InstallNet35.location           = New-Object System.Drawing.Point(10,120)
$InstallNet35.Font               = New-Object System.Drawing.Font('Consolas',9)
$InstallNet35.Font = 'Microsoft Sans Serif,10'
$InstallNet35.ForeColor          = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")

$Form.controls.AddRange(@($RegistryPanel,$DebloatPanel,$CortanaPanel,$EdgePanel,$DarkThemePanel,$OtherPanel))
$DebloatPanel.controls.AddRange(@($Debloat,$CustomizeBlacklists,$RemoveAllBloatware,$RemoveBlacklist))
$RegistryPanel.controls.AddRange(@($Registry,$RevertChange))
$CortanaPanel.controls.AddRange(@($Cortana,$EnableCortana,$DisableCortana))
$EdgePanel.controls.AddRange(@($EnableEdgePDFTakeover,$StopEdgePDFTakeover,$Edge))
$DarkThemePanel.controls.AddRange(@($Theme,$DisableDarkMode,$EnableDarkMode))
$OtherPanel.controls.AddRange(@($Other,$RemoveOnedrive,$InstallNet35,$UnpinStartMenuTiles,$DisableTelemetry,$RemoveRegkeys))

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

Write-Output "Creating System Restore Point if one does not already exist. If one does, then you will receive a warning. Please wait..."
Checkpoint-Computer -Description "Before using W10DebloaterGUI.ps1"
#region gui events {
$CustomizeBlacklists.Add_Click( {
	$CustomizeForm = New-Object System.Windows.Forms.Form
	$CustomizeForm.ClientSize       = New-Object System.Drawing.Point(580,570)
	$CustomizeForm.StartPosition    = 'CenterScreen'
	$CustomizeForm.FormBorderStyle  = 'FixedSingle'
	$CustomizeForm.MinimizeBox      = $false
	$CustomizeForm.ClientSize = '600,400'
	$CustomizeForm.MaximizeBox      = $false
	$CustomizeForm.ShowIcon         = $false
	$CustomizeForm.Text             = "Customize Allowlist and Blocklist"
	$CustomizeForm.TopMost = $false
	$CustomizeForm.AutoScroll = $true
	$CustomizeForm.BackColor        = [System.Drawing.ColorTranslator]::FromHtml("#252525")

	$ListPanel                     = New-Object system.Windows.Forms.Panel
	$ListPanel.height              = 510
	$ListPanel.width               = 572
	$ListPanel.Anchor              = 'top,right,left'
	$ListPanel.location            = New-Object System.Drawing.Point(10,10)
	$ListPanel.AutoScroll          = $true
	$ListPanel.BackColor           = [System.Drawing.ColorTranslator]::FromHtml("#252525")
	$SaveList = New-Object System.Windows.Forms.Button
	$SaveList.FlatStyle             = 'Flat'
	$SaveList.Text = "Save custom Whitelist and Blacklist to custom-lists.ps1"
	$SaveList.width                 = 560
	$SaveList.height                = 30
	$SaveList.AutoSize = $true
	$SaveList.Location              = New-Object System.Drawing.Point(10, 530)
	$SaveList.Font                  = New-Object System.Drawing.Font('Consolas',9)
	$SaveList.ForeColor             = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")
	$CustomizeForm.controls.AddRange(@($SaveList,$ListPanel))

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
		[Parameter(Mandatory)]
		[bool] $autocheck,

		[string] $notes
	    )

	    $label = New-Object System.Windows.Forms.Label
	    $label.Location = New-Object System.Drawing.Point(-10, (2 + $position * 25))
	    $label.Text = $notes
	    $label.Font = New-Object System.Drawing.Font('Consolas',8)
	    $label.Width = 260
	    $label.Height = 27
	    $Label.TextAlign = [System.Drawing.ContentAlignment]::TopRight
	    $label.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#888888")
	    $CustomizeForm.controls.Add($label)

	    $Checkbox = New-Object System.Windows.Forms.CheckBox
	    $Checkbox.Text = $appName
	    $CheckBox.Font = New-Object System.Drawing.Font('Consolas',8)
	    $CheckBox.FlatStyle = 'Flat'
	    $CheckBox.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")
	    $Checkbox.Location = New-Object System.Drawing.Point(268, (0 + $position * 25))
	    $Checkbox.Autosize = 1;
	    $Checkbox.Checked = $checked
	    $Checkbox.Enabled = $enabled
	    $CheckBox.AutoCheck = $autocheck
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
	    $string += "  Non-Removable"
	    AddAppToCustomizeForm $checkboxCounter $item $true $false $false $string
	    ++$checkboxCounter
	}
	ForEach ( $item in $global:WhiteListedApps ) {
	    $string = ""
	    if ( $null -notmatch $NonRemovables -and $NonRemovables -cmatch $item ) { $string += " Conflict NonRemovables " }
	    if ( $null -notmatch $global:BloatwareRegex -and $item -cmatch $global:BloatwareRegex ) { $string += " ConflictBlacklist " }
	    if ( $null -notmatch $Installed -and $Installed -cmatch $item) { $string += "Installed" }
	    if ( $null -notmatch $AllUsers -and $AllUsers -cmatch $item) { $string += " AllUsers" }
	    if ( $null -notmatch $Online -and $Online -cmatch $item) { $string += " Online" }
	    AddAppToCustomizeForm $checkboxCounter $item $true $false $true $string
	    ++$checkboxCounter
	}
	ForEach ( $item in $global:Bloatware ) {
	    $string = ""
	    if ( $null -notmatch $NonRemovables -and $NonRemovables -cmatch $item ) { $string += " Conflict NonRemovables " }
	    if ( $null -notmatch $global:WhiteListedAppsRegex -and $item -cmatch $global:WhiteListedAppsRegex ) { $string += " Conflict Whitelist " }
	    if ( $null -notmatch $Installed -and $Installed -cmatch $item) { $string += "Installed" }
	    if ( $null -notmatch $AllUsers -and $AllUsers -cmatch $item) { $string += " AllUsers" }
	    if ( $null -notmatch $Online -and $Online -cmatch $item) { $string += " Online" }
	    AddAppToCustomizeForm $checkboxCounter $item $true $true $true $string
	    ++$checkboxCounter
	}
	ForEach ( $item in $AllUsers ) {
	    $string = "NEW   AllUsers"
	    if ( $null -notmatch $NonRemovables -and $NonRemovables -cmatch $item ) { continue }
	    if ( $null -notmatch $global:WhiteListedAppsRegex -and $item -cmatch $global:WhiteListedAppsRegex ) { continue }
	    if ( $null -notmatch $global:BloatwareRegex -and $item -cmatch $global:BloatwareRegex ) { continue }
	    if ( $null -notmatch $Installed -and $Installed -cmatch $item) { $string += " Installed" }
	    if ( $null -notmatch $Online -and $Online -cmatch $item) { $string += " Online" }
	    AddAppToCustomizeForm $checkboxCounter $item $true $true $true $string
	    ++$checkboxCounter
	}
	ForEach ( $item in $Installed ) {
	    $string = "NEW   Installed"
	    if ( $null -notmatch $NonRemovables -and $NonRemovables -cmatch $item ) { continue }
	    if ( $null -notmatch $global:WhiteListedAppsRegex -and $item -cmatch $global:WhiteListedAppsRegex ) { continue }
	    if ( $null -notmatch $global:BloatwareRegex -and $item -cmatch $global:BloatwareRegex ) { continue }
	    if ( $null -notmatch $AllUsers -and $AllUsers -cmatch $item) { continue }
	    if ( $null -notmatch $Online -and $Online -cmatch $item) { $string += " Online" }
	    AddAppToCustomizeForm $checkboxCounter $item $true $true $true $string
	    ++$checkboxCounter
	}
	ForEach ( $item in $Online ) {
	    $string = "NEW   Online "
	    if ( $null -notmatch $NonRemovables -and $NonRemovables -cmatch $item ) { continue }
	    if ( $null -notmatch $global:WhiteListedAppsRegex -and $item -cmatch $global:WhiteListedAppsRegex ) { continue }
	    if ( $null -notmatch $global:BloatwareRegex -and $item -cmatch $global:BloatwareRegex ) { continue }
	    if ( $null -notmatch $Installed -and $Installed -cmatch $item) { continue }
	    if ( $null -notmatch $AllUsers -and $AllUsers -cmatch $item) { continue }
	    AddAppToCustomizeForm $checkboxCounter $item $true $true $true $string
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
	Write-Host "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`nRemoving blocklisted Bloatware.`n"
	DebloatBlacklist
	Write-Host "Bloatware removed!"
    })

# see lib dependensies
$RemoveAllBloatware.Add_Click( Remove-All-Bloatware )
$RevertChange.Add_Click( Revert-Changes)
$DisableCortana.Add_Click( Disable-Cortana)
$StopEdgePDFTakeover.Add_Click(Stop-Edge-PDF-Takeover)

$EnableCortana.Add_Click(EnableCortana)

$EnableEdgePDFTakeover.Add_Click( Enable-EdgePdf )
$DisableTelemetry.Add_Click(DisableTelemetry )

$RemoveRegkeys.Add_Click( Remove-Keys )

$UnpinStartMenuTiles.Add_Click( UnpinStart)
$RemoveOnedrive.Add_Click( UninstallOneDrive  )

$InstallNet35.Add_Click( InstallNet35 )

$EnableDarkMode.Add_Click(  EnableDarkMode )

$DisableDarkMode.Add_Click( DisableDarkMode)

[void]$Form.ShowDialog()
