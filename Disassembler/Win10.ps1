##########
# Win 10 / Server 2016 / Server 2019 Initial Setup Script - Main execution loop
# Author: Disassembler <disassembler@dasm.cz>
# Maintainer: Pontus Öwre <pontus@owre.se>
# Version: v3.11, 2021-03-16
# Source: https://github.com/owre/Win10-Initial-Setup-Script
##########
# Win10 Optimization Script With Extra GPD Win Tweaks
# Adapted version of https://github.com/Disassembler0/Win10-Initial-Setup-Script by Disassembler <disassembler@dasm.cz>
# Author: BlackDragonBE
# Version: v2.2.1 (2017-12-02)
# Copied from https://www.reddit.com/r/gpdwin/comments/6ipa6c/windows_10_optimization_script_for_gpd_win/
# Tweaked Win10 Initial Setup Script
# Primary Author: Disassembler <disassembler@dasm.cz>
# Modified by: alirobe <alirobe@alirobe.com> based on my personal preferences.
# Version: 2.20.2, 2018-09-14
# Primary Author Source: https://github.com/Disassembler0/Win10-Initial-Setup-Script
# Tweaked Source: https://gist.github.com/alirobe/7f3b34ad89a159e6daa1/
# Tweak difference:
#
#    @alirobe's version is a subset focused on safely disabling telemetry, some 'smart' features and 3rd party bloat ...
#    ... while retaining win10 defaults + security features. Aim to be suitable for end-user rollout.
#
#    If you're a power user looking to tweak your machinea, or doing larger roll-out..
#    Use the @Disassembler0 script instead. It'll probably be more up-to-date than mine:
#    https://github.com/Disassembler0/Win10-Initial-Setup-Script
#
#    Note from author: Never run scripts without reading them & understanding what they do.
#
##########
# Default preset
# As a workaround for disabled script execution, run this command (without #) in an elevated PowerShell windows first and choose "all" if you're asked where to apply this:
# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

<#
Release Notes:

v2.0
- Complete overhaul, fully based on https://github.com/Disassembler0/Win10-Initial-Setup-Script now
- Migrated my tweaks to the new system

v2.1
- More GPD Win service tweaks
- Even more services to disable
- More features/components removed
- Disable the compatibility appraiser
- Minor cleanup
- Enabled more default tweaks

v2.2
- Improved the way applications get installed by Ninite, you can now easily decide what apps (not) to install

v2.2.1
- Fixed Ninite install bug causing the script to endlessly loop (yikes!)
- Tried to keep some reg edits more silent

Copyright:

MIT License

Copyright (c) 2017 BlackDragonBE

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

#>
$tweaks = @()
$PSCommandArgs = @()

##########
# Auxiliary Functions
##########

# Relaunch the script with administrator privileges
Function RequireAdmin {
	If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
		Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -WorkingDirectory $pwd -Verb RunAs
		Exit
	}
}


# Wait for key press
Function WaitForKey {
	Write-Host
	Write-Host "Press any key to restart..." -ForegroundColor Black -BackgroundColor White
	[Console]::ReadKey($true) | Out-Null
}

# Restart computer
Function Restart {
	Write-Output "Restarting..."
	Restart-Computer
}

# Test if registry path exists
function Test-RegistryValue {
    param (

     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Path,

    [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Value
    )

    try {

    Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
     return $true
     }

    catch {

    return $false

    }
}


Function AddOrRemoveTweak($tweak) {
	If ($tweak[0] -eq "!") {
		# If the name starts with exclamation mark (!), exclude the tweak from selection
		$script:tweaks = $script:tweaks | Where-Object { $_ -ne $tweak.Substring(1) }
	} ElseIf ($tweak -ne "") {
		# Otherwise add the tweak
		$script:tweaks += $tweak
	}
}

##########
# Parse parameters and apply tweaks
##########

Write-Host
Write-Host
Write-Host "WIN 10 Optimization Script For Windows 10 by BlackDragonBE"
Write-Host "(Adapted version of https://github.com/Disassembler0/Win10-Initial-Setup-Script by Disassembler <disassembler@dasm.cz>)"
Write-Host "--------------------------------------------"
Write-Host "Make sure you've checked which tweaks are turned on before running this. Edit by placing # before anything you don't want to run."
Write-Host
$confirmation = Read-Host "If you're sure you want to run this, press y and ENTER. If not, just press ENTER to cancel."

if ($confirmation -ne 'y') {
    Write-Host
    Write-Host "Cancelled script execution."
    exit
}

Write-Host
Write-Host "Let's roll!"


# Normalize path to preset file
$preset = ""
$PSCommandArgs = $args
If ($args -And $args[0].ToLower() -eq "-preset") {
	$preset = Resolve-Path $($args | Select-Object -Skip 1)
	$PSCommandArgs = "-preset `"$preset`""
}

# Load function names from command line arguments or a preset file
If ($args) {
	$tweaks = $args
	If ($preset) {
		$tweaks = Get-Content $preset -ErrorAction Stop | ForEach { $_.Trim() } | Where { $_ -ne "" -and $_[0] -ne "#" }
	}

# Parse and resolve paths in passed arguments
$i = 0
While ($i -lt $args.Length) {
	If ($args[$i].ToLower() -eq "-include") {
		# Resolve full path to the included file
		$include = Resolve-Path $args[++$i] -ErrorAction Stop
		$PSCommandArgs += "-include `"$include`""
		# Import the included file as a module
		Import-Module -Name $include -ErrorAction Stop
	} ElseIf ($args[$i].ToLower() -eq "-preset") {
		# Resolve full path to the preset file
		$preset = Resolve-Path $args[++$i] -ErrorAction Stop
		$PSCommandArgs += "-preset `"$preset`""
		# Load tweak names from the preset file
		Get-Content $preset -ErrorAction Stop | ForEach-Object { AddOrRemoveTweak($_.Split("#")[0].Trim()) }
	} ElseIf ($args[$i].ToLower() -eq "-log") {
		# Resolve full path to the output file
		$log = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($args[++$i])
		$PSCommandArgs += "-log `"$log`""
		# Record session to the output file
		Start-Transcript $log
	} Else {
		$PSCommandArgs += $args[$i]
		# Load tweak names from command line
		AddOrRemoveTweak($args[$i])
	}
	$i++
}

# Call the desired tweak functions
$tweaks | ForEach-Object { Invoke-Expression $_ }
