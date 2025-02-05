$UserBucket = "PerXautomatik"
if(!$env:SCOOP -and (test-path "$env:ProgramData\scoop\apps\scoop\current")) {
    $env:SCOOP = "$env:ProgramData\scoop"
}
if($env:SCOOP) {
    $currentScoopDirectory = "$env:SCOOP\apps\scoop\current"
    . (Join-Path $currentScoopDirectory 'libexec\scoop-search.ps1') > $null
}
else {
    Write-Warning '$env:SCOOP not found.'
}
Function Test-Command {
    [CmdletBinding()]
    param(
	[string]$command
    )
    return [bool](get-command $command -ErrorAction Ignore)
}
Function Test-ChocolateyPackageInstalled {
    [OutputType([bool])]
    [CmdletBinding()]
    param(
	[Parameter(Mandatory)][string]$PackageName
    )
    $installed = choco list $PackageName --local-only --no-progress | Where-Object {
	# Alternate filter
	#choco list  -localonly | Where-Object { ($_ -notmatch 'Chocolatey v[0-9\.]') -and $_ -notmatch '\d+ packages installed\.' }
	$_ -match "$PackageName\s.*"
    }
    Write-Output (@($installed).Count -gt 0)
}
Function Test-ScoopPackageInstalled {
    [OutputType([bool])]
    [CmdletBinding()]
    param(
	[Parameter(Mandatory)][string]$PackageName
    )
    $scoopOutput = scoop export $PackageName
    $installed = $scoopOutput | Where-Object {
	# Alternate filter
	#choco list  -localonly | Where-Object { ($_ -notmatch 'Chocolatey v[0-9\.]') -and $_ -notmatch '\d+ packages installed\.' }
	$_ -match "\s*$PackageName\s.*"
    }
    Write-Output (@($installed).Count -gt 0)
}
function choco {
    $installArgs = Get-InstallArgs @args
    if(
	($installArgs.Action -eq 'install') `
	-and ($installArgs.Options -notcontains '-f') `
	-and ($installArgs.Options -notcontains '--force') `
	-and (Test-ChocolateyPackageInstalled $installArgs.Arg1)
	) {
	Write-Warning "$($installArgs.Arg1) is already installed."
    }
    else {
	choco.exe @args
    }
}
function Get-LocalBucket {
    <#
    .SYNOPSIS
	List all local buckets.
    #>
    $bucketsdir = (Join-Path $env:scoop buckets)
    if($bucketsdir -ne (Split-Path (Find-BucketDirectory).Trim('bucket') -Parent)) {
	Write-Warning 'Bucket direcotry doesn''t match Find-BucketDirectory location.'
    }
    $buckets = (Get-ChildItem $bucketsdir -Directory).Name
    if($UserBucket) {
	$buckets = ,$UserBucket + ($buckets | Where-Object { $_ -ne $UserBucket })
    }
    Write-Output $buckets
}
<#
.SYNOPSIS
.DESCRIPTION
.EXAMPLE
choco install VisualStudio -y --force
.NOTES
The class should work for both scoop and chocolatey (choco), or any other
command broken into <original command> <subcommand> <arguments> <options>.
class InstallArgs {
    # The complete list of original arguments, including actions and options.
    [string[]]$OriginalArgs
    # All original arguments that begin with a dash.
    [string[]]$Options
    # All the original arguments that didn't begin with a dash.
    [string[]]$SubCommands
    # The first original argument that is not an option.
    [string]$Action
    # The first SubCommand that isn't an action (in other words the second subcommand)
    [string]$Arg1
    InstallArgs([string[]]$OriginalArgs) {
	[string[]]$localSubCommands = $OriginalArgs | Where-Object { $_ -notlike '-*'}
	$this.OriginalArgs = $OriginalArgs
	$this.Options = $OriginalArgs | Where-Object { $_ -like '-*'};
	$this.SubCommands = $localSubCommands
	$this.Action =  $localSubCommands | Select-Object -First 1;
	$this.Arg1 = $localSubCommands | Select-Object -Skip 1 | Select-Object -First 1
    }
}
function Get-InstallArgs {
    return [InstallArgs]::new($args)
}
function scoop {
    [InstallArgs]$scoopArgs = Get-InstallArgs @args
    $localArgs = $scoopArgs.OriginalArgs
    $cmd = $scoopArgs.Action
    $options = $scoopArgs.Options
    $arg1 = $scoopArgs.Arg1
    switch ($cmd) {
	'install' {
	    #Make the $UserBucket the priority.
	    $null, $bucket, $null = parse_app $arg1
	    if(-not $bucket) {
		scoop search $arg1 -PSCustomObject | Where-Object {
		    $_.name -match "^$args$"
		} | Where-Object {
			$_.Bucket -eq $UserBucket
		} | ForEach-Object {
		    $index = [array]::indexof($localArgs,$_.name)
		    $localArgs[$index] = "$UserBucket/$arg1"
		}
	    }
	    scoop.ps1 @localArgs
	}
	'search' {
	    if($options -contains '-PSCustomObject') {
		Get-LocalBucket | ForEach-Object {
		    $bucket = $_
		    search_bucket $_ $arg1 | ForEach-Object {
			$_['Bucket'] = $bucket
			Write-Output ([PSCustomObject]$_)
		    }
		}
	    }
	    else {
		scoop.ps1 @args
	    }
	}
	Default {
	    scoop.ps1 @args
	}
    }
}
Function Get-Program {
    [CmdletBinding()] param([string] $Filter = "*")
    $ProgramRegistryKeys = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
    "Microsoft.PowerShell.Core\Registry::HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Uninstall"
    # REview for 32/64 Bit
    # http://gallery.technet.microsoft.com/scriptcenter/PowerShell-Installed-70d0c0f4
    $ProgramRegistryKeys | Get-ChildItem | Get-ItemProperty |
    Select-Object  *, @{Name = "Name"; Expression = {
	    if ( ($_ | Get-Member "DisplayName") -and $_.DisplayName) {
		#Consider $_.PSObject.Properties.Match("DisplayName") as it may be faster
		$_.DisplayName
	    }
	    else {
		$_.PSChildName
	    }
	}
    } | Where-Object { ($_.Name -Like $Filter) -or ($_.PSChildName -Like $Filter) }
}
Function Import-ChocolateyModule {
    if (test-path env:ChocolateyInstall) {
	Import-Module (Resolve-Path -Path "$env:ChocolateyInstall\*\chocolateyInstaller.psm1").Path
	if (Test-Path Function:\Write-Host) {
	    Remove-Item Function:Write-Host # Chocolatey overwrites Write-Host.  This call removes the override.  It should still occur within Chocolatey.
	    # Note that this is necessary otherwise Write-Host attempts to write to the chocolatey log file in Program Data and doesn't have
	    # permission outside of an admin prompt.
	}
	$env:ChocolateyAllowEmptyChecksumsSecure = $true
	$env:ChocolateyAllowEmptyChecksums = $true
	$env:ChocolateyPackageFolder = "$env:ChocolateyInstall\Lib"
	Set-PackageSource -Name chocolatey -ProviderName Chocolatey -Trusted -Force
    }
    else {
	throw "Chocolatey is not installed"
    }
}
if (!(Test-Path function:Install-WebDownload)) {
    Function Install-WebDownloadOfZip {
	[CmdletBinding()]
	param(
	    [Parameter(Mandatory)][string] $PackageName,
	    [Parameter(Mandatory)][alias("Uri")][string] $url,
	    $UnzipLocation = "$env:ChocolateyInstall\lib\$PackageName"
	)
	Import-ChocolateyModule
	# See Chocolatey's Get-CheckSumValid.ps1 for more info.
	$originalChocolateyAllowEmptyChecksums = $env:ChocolateyAllowEmptyChecksums
	$originalChocolateyAllowEmptyChecksumsSecure = $env:ChocolateyAllowEmptyChecksumsSecure
	try {
	    # Needed because Chocolatey is not setting up context.
	    if (!(test-path variable:\helpersPath)) {
		$setHelpersPath = $true
		$global:helpersPath = $env:ChocolateyInstall
	    }
	    $env:ChocolateyAllowEmptyChecksums = 'true'
	    $env:ChocolateyAllowEmptyChecksumsSecure = 'true'
	    Install-ChocolateyZipPackage -packageName $PackageName -url $url -unzipLocation $UnzipLocation -specificFolder ''
	    Get-ChildItem $UnzipLocation *.exe | ForEach-Object { Install-BinFile -name TrayIt -path $_.FullName }
	}
	finally {
	    if ($setHelpersPath) {
		remove-item variable:\global:helpersPath
	    }
	    $env:ChocolateyAllowEmptyChecksums = $originalChocolateyAllowEmptyChecksums
	    $env:ChocolateyAllowEmptyChecksumsSecure = $originalChocolateyAllowEmptyChecksumsSecure
	}
    }
    Function Install-WebDownload {
	[CmdletBinding()] param(
	    [Parameter(Mandatory)][alias("Uri")][string] $url,
	    [Parameter(Mandatory)][string] $PackageName,
	    [Parameter(ParameterSetName = "CommandLine")] [string] $arguments = $null,
	    [Parameter(ParameterSetName = "ScriptBlock")][ScriptBlock] $postDownloadScriptBlock,
	    [Parameter(ParameterSetName = "UnattendedSilentSwitchFinder",
		HelpMessage = "Lookup the unattended silent switch for the setup program.")][switch]$ussf,
	    [string] $installFileName = [System.Management.Automation.WildcardPattern]::Escape((Split-Path $url -Leaf)),
	    [switch]$forceDownload )
	#TODO Switch to Get-ChocolateyWebFile and use Invoke-WebRequest as fallback.
	$tempPath = Get-TempPath
	if ([IO.Path]::GetExtension($InstallFileName) -eq ".zip") {
	    Install-WebDownloadOfZip -Uri $url -packageName $PackageName
	}
	else {
	    $installFileName = Join-Path $tempPath $installFileName
	    if ($forceDownload -OR ($installFileName -eq "Setup.exe") -OR !(Test-Path $installFileName) ) {
		Invoke-WebRequest $url -OutFile $installFileName
	    }
	    if ($ussf) {
		ussf $installFileName
	    }
	    else {
		If ( ([string]::IsNullOrWhiteSpace($PsCmdlet.ParameterSetName)) -or ($PsCmdlet.ParameterSetName -eq "CommandLine") ) {
		    $postDownloadScriptBlock = [ScriptBlock] {
			$process = Start-Process $installFileName $arguments -PassThru -wait
			return $process.ExitCode
		    }
		}
	    }
	    Write-Output (Invoke-Command $postDownloadScriptBlock)
	}
    }
}
Function EnsureEnvironmentVariable([String]$Name, [String]$Value) {
    $currentValue = [environment]::GetEnvironmentVariable($Name)
    if ($Value) {
	if ($currentValue) {
	    if ($currentValue -ne $Value) {
		DoUpdate "Environment variable '$Name' value was '$currentValue', set to '$Value'" {
		    [environment]::SetEnvironmentVariable($Name, $Value, 'User')
		    [environment]::SetEnvironmentVariable($Name, $Value, 'Process')
		}
	    } else {
		LogIdempotent "Environment variable '$Name' value is already set to '$Value'"
	    }
	} else {
	    DoUpdate "Environment variable '$Name' value was undefined, set to '$Value'" {
		[environment]::SetEnvironmentVariable($Name, $Value, 'User')
		[environment]::SetEnvironmentVariable($Name, $Value, 'Process')
	    }
	}
    } else {
	if ($currentValue) {
	    DoUpdate "Environment variable '$Name' removed, previous value was '$currentValue'" {
		[environment]::SetEnvironmentVariable($Name, $null, 'User')
		[environment]::SetEnvironmentVariable($Name, $null, 'Process')
	    }
	} else {
	    LogIdempotent "Environment variable '$Name' value is already undefined"
	}
    }
}

Function Restart {
    Write-Host "------------------------------------" -ForegroundColor Red
    Read-Host -Prompt "Setup is done, restart is needed, press [ENTER] to restart computer."
    Restart-Computer
}
Function KeyToValue($Key, $Values) {
    if (!$Values.ContainsKey($Key)) {
	throw "$Key is not recognized, should be '$( $Values.Keys -Join "' or '" )'"
    }
    return $Values[$Key]
}

Function EnsureRegistryKeyDeleted([String]$Path) {
    if (Test-Path -LiteralPath "Registry::$Path") {
	DoUpdate "Registry key $Path deleted" {
	    Remove-Item -LiteralPath "Registry::$Path" -Force -Recurse | Out-Null
	}
    } else {
	LogIdempotent "Registry key $Path is already missing"
    }
}

Function GetRegistryValue([String]$Path, [String]$Name) {
    try {
	return Get-ItemPropertyValue -LiteralPath "Registry::$Path" -Name "$Name" -ErrorAction SilentlyContinue
    } catch {
    }
}

Function EnsureRegistryValue([String]$Path, [String]$Name, [String]$Type, $Value) {
    $hasValue = ($null -ne $Value)
    if (!(Test-Path -LiteralPath "Registry::$Path")) {
	if (!$hasValue) {
	    LogIdempotent "Registry item $Path\$Name is already missing"
	    return
	}

	DoUpdate "Registry path $Path created" {
	    $newItem = New-Item -Path "Registry::$Path" -Force -ErrorAction:SilentlyContinue
	    if (!$newItem) {
		LogWarn "Registry key $Path cannot be created"
	    }
	}
    }


    $key = Get-Item -LiteralPath "Registry::$Path" -ErrorAction:SilentlyContinue
    if ($key) {
	try {
	    $item = $key.OpenSubKey("", $true)
	    $canWrite = $true
	}
	catch [System.Security.SecurityException] {
	    $item = $key.OpenSubKey("", $false)
	    $canWrite = $false
	}
	$currentValue = $item.GetValue($Name)

	if ($hasValue) {
	    if ($Value.GetType() -eq [ScriptBlock]) {
		$Value = $Value.InvokeReturnAsIs($currentValue)
		$hasValue = ($null -ne $Value)
	    }
	}
    } else {
	if (IsDryRun) {
	    $canWrite = $true
	} else {
	    LogWarn "Registry key $Path cannot be accessed"
	    return
	}
    }

    if ("Binary" -eq $Type) {
	$Value = [byte[]]$Value
	$areDifferent = @(Compare-Object $Value $currentValue -SyncWindow 0).Length -ne 0
    } else {
	$areDifferent = ($currentValue -ne $Value)
    }

    if ($areDifferent) {
	if ($hasValue) {
	    if ($null -ne $currentValue) {
		$msg = "Registry item $Path\$Name value was '$currentValue', set to '$Value'"
	    } else {
		$msg = "Registry item $Path\$Name value was not existing, created with '$Value'"
	    }

	    if ($canWrite) {
		DoUpdate $msg {
		    $item.SetValue($Name, $Value, $Type)
		}
	    } else {
		LogWarn "Registry item $Path\$Name cannot be updated"
	    }
	} else {
	    if ($canWrite) {
		DoUpdate "Registry item $Path\$Name removed, previous value was '$currentValue'" {
		    $item.DeleteValue($Name)
		}
	    } else {
		LogWarn "Registry item $Path\$Name cannot be deleted"
	    }
	}
    } else {
	if ($hasValue) {
	    LogIdempotent "Registry item $Path\$Name value is already set to '$Value'"
	} else {
	    LogIdempotent "Registry item $Path\$Name is already missing"
	}
    }
}

Function FileExtAssociate([String]$Ext, [String]$FileType, [String]$IfFileType) {
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\.$Ext" -Name "" -Type String -Value {
	param($CurrentFileType)

	if ($IfFileType -and ($CurrentFileType -ne $IfFileType)) {
	    return $CurrentFileType
	} else {
	    return $FileType
	}
    }
}

Function FileTypeDefine([String]$Type, [String]$Label, [String]$Command, [String]$CommandLabel, [String]$Icon) {
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\$Type" -Name "" -Type String -Value $Label
    if ($CommandLabel) {
	EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\$Type\shell\open" -Name "" -Type String -Value $CommandLabel
    }
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\$Type\shell\open\command" -Name "" -Type String -Value $Command
    if ($Icon) {
	EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\$Type\DefaultIcon" -Name "" -Type String -Value $Icon
    }
}

Function IncrementGlobalAssociationChangedCounter {
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "GlobalAssocChangedCounter" -Type DWORD -Value {
	Param($Value)
	return $Value + 1
    }
}
Function FileTypeUndefine([String]$Type) {
    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\$Type"

}

Function EnsureShellExtensionRegistered([String]$CLSID, [String]$Label, [String]$DLL64Path, [String]$DLL32Path) {
    if ($DLL64Path) {
	EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\CLSID\$CLSID" -Name "" -Type String -Value $Label
	EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\CLSID\$CLSID\InprocServer32" -Name "" -Type String -Value $DLL64Path
	EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\CLSID\$CLSID\InprocServer32" -Name "ThreadingModel" -Type String -Value "Apartment"
	EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" -Name $CLSID -Type String -Value $Label
    }

    if ($DLL32Path) {
	EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\WOW6432Node\CLSID\$CLSID" -Name "" -Type String -Value $Label
	EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\WOW6432Node\CLSID\$CLSID\InprocServer32" -Name "" -Type String -Value $DLL32Path
	EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\WOW6432Node\CLSID\$CLSID\InprocServer32" -Name "ThreadingModel" -Type String -Value "Apartment"
	EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" -Name $CLSID -Type String -Value $Label
    }
}

Function EnsureShellExtensionUnregistered([String]$CLSID) {
    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\CLSID\$clsid"
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" -Name "$clsid" -Type String -Value $null

    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\WOW6432Node\CLSID\$clsid"
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" -Name "$clsid" -Type String -Value $null
}

Function EnsureFirewallRule([String]$Name, [Boolean]$Activated) {
    Get-NetFirewallRule -Name $Name | ForEach-Object {
	$isEnabled = $_.Enabled -eq [Microsoft.PowerShell.Cmdletization.GeneratedTypes.NetSecurity.Enabled]::True
	if ($Activated) {
	    if ($isEnabled) {
		LogIdempotent "Firewall rule '$( $_.Name )' is already enabled"
	    } else {
		DoUpdate -RequireAdmin "Firewall rule '$( $_.Name )' was disabled, enabling it" {
		    Enable-NetFirewallRule -Name $_.Name
		}
	    }
	} else {
	    if ($isEnabled) {
		DoUpdate -RequireAdmin "Firewall rule '$( $_.Name )' was enabled, disabling it" {
		    Disable-NetFirewallRule -Name $_.Name
		}
	    } else {
		LogIdempotent "Firewall rule '$( $_.Name )' is already disabled"
	    }
	}
    }
}

# See https://docs.microsoft.com/en-us/windows-hardware/customize/power-settings/configure-power-settings
Function PowerSettingSubGUID($Setting) {
    return KeyToValue $Setting @{
	ScreenTimeout = "7516b95f-f776-4464-8c53-06167f40cc99"
	SleepTimeOut = "238c9fa8-0aad-41ed-83f4-97be242c8f20"
	PowerButtonAction = "4f971e89-eebd-4455-a8de-9e59040e7347"
	SleepButtonAction = "4f971e89-eebd-4455-a8de-9e59040e7347"
	LidButtonAction = "4f971e89-eebd-4455-a8de-9e59040e7347"
	ProcessorPerformanceBoostMode = "54533251-82be-4824-96c1-47b60b740d00"
    }
}

# See https://docs.microsoft.com/en-us/windows-hardware/customize/power-settings/configure-power-settings
Function PowerSettingGUID($Setting) {
    return KeyToValue $Setting @{
	ScreenTimeout = "3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e"
	SleepTimeOut = "29f6c1db-86da-48c5-9fdb-f2b67b1f44da"
	PowerButtonAction = "7648efa3-dd9c-4e3e-b566-50f929386280"
	SleepButtonAction = "96996bc0-ad50-47ec-923b-6f41874dd9eb"
	LidButtonAction = "5ca83367-6e45-459f-a27b-476b1d01c936"
	ProcessorPerformanceBoostMode = "be337238-0d82-4146-a960-4f3749d470c7"
    }
}

Function EnsurePowerManagementSetting($Setting, $Action) {
    $subGUID = PowerSettingSubGUID($Setting)
    $settingGUID = PowerSettingGUID($Setting)
    EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\$subGUID\$settingGUID" -Name "Attributes" -Type String -Value ( KeyToValue $Action @{
	Hide = {
	    Param($Value)
	    return $Value -band (-bnot2) -bor 1
	}
	Show = {
	    Param($Value)
	    return $Value -band (-bnot1) -bor 2
	}
    })
}

Function EnsurePowerConfigValue($Setting, $Source, $Value) {
    $subGUID = PowerSettingSubGUID($Setting)
    $settingGUID = PowerSettingGUID($Setting)

    $itemName = KeyToValue $Source @{
	AC = "AcSettingIndex"
	DC = "DcSettingIndex"
    }

    $actionName = KeyToValue $Source @{
	AC = "/SETACVALUEINDEX"
	DC = "/SETDCVALUEINDEX"
    }

    $timeoutToIndex = {
	Param($val)
	if ($val -eq "Never") {
	    return 0
	} else {
	    return $val * 60
	}
    }

    $buttonActionToIndex = {
	Param($val)
	KeyToValue $val @{
	    DoNothing = 0
	    Sleep = 1
	    Hibernate = 2
	    Shutdown = 3
	}
    }

    $valueToIndex = KeyToValue $Setting @{
	ScreenTimeout = $timeoutToIndex
	SleepTimeOut = $timeoutToIndex
	PowerButtonAction = $buttonActionToIndex
	SleepButtonAction = $buttonActionToIndex
	LidButtonAction = $buttonActionToIndex
    }

    $Value = & $valueToIndex $Value

    $currentSchemeGUID = GetRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\{025A5937-A6BE-4686-A844-36FE4BEC8B6D}" -Name "PreferredPlan"

    $currentValue = GetRegistryValue -Path "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes\$currentSchemeGUID\$subGUID\$settingGUID" -Name "$itemName"
    if ($null -eq $currentValue) {
	$currentValue = GetRegistryValue -Path "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\$subGUID\$settingGUID\DefaultPowerSchemeValues\$currentSchemeGUID" -Name "$itemName"
    }

    if ($Value -ne $currentValue) {
	DoUpdate "Power configuration $Setting on $Source value was '$currentValue', set to '$Value'" {
	    powercfg.exe $actionName $currentSchemeGUID $subGUID $settingGUID $Value
	}
    } else {
	LogIdempotent "Power configuration $Setting on $Source value is already set to '$Value'"
    }
}

Function EnsureWindowsFeature($Features) {
    if (!(IsAdmin)) {
	LogWarn "Windows features management requires administrator privileges"
	return
    }

    foreach ($feature in Get-WindowsOptionalFeature -Online) {
	$featureName = $feature.FeatureName
	$featureEnabled = $feature.State -eq [Microsoft.Dism.Commands.FeatureState]::Enabled

	$desiredState = $Features[$featureName]
	if ($null -ne $desiredState) {
	    $ensureEnabled = KeyToValue $desiredState @{
		Enabled = $true
		Disabled = $false
	    }

	    if ($ensureEnabled) {
		if ($featureEnabled) {
		    LogIdempotent "Windows feature '$featureName' is already enabled"
		} else {
		    DoUpdate "Windows feature '$featureName' has been enabled" {
			Enable-WindowsOptionalFeature -Online -FeatureName $featureName -All -NoRestart -WarningAction SilentlyContinue | Out-Null
		    }
		}
	    } else {
		if ($featureEnabled) {
		    DoUpdate "Windows feature '$featureName' has been disabled" {
			Disable-WindowsOptionalFeature -Online -FeatureName $featureName -NoRestart -WarningAction SilentlyContinue | Out-Null
		    }
		} else {
		    LogIdempotent "Windows feature '$featureName' is already disabled"
		}
	    }
	}
    }
}

Function EnsureWindowsCapability($Features) {
    if (!(IsAdmin)) {
	LogWarn "Windows capability management requires administrator privileges"
	return
    }

    foreach ($capability in Get-WindowsCapability -Online) {
	$capabilityName = $capability.Name
	$capabilityInstalled = $capability.State -eq "Installed"

	$desiredState = $Features[$capabilityName]
	if ($null -eq $desiredState) {
	    if ($capabilityName.IndexOf('~') -gt 0) {
		$desiredState = $Features[$capabilityName.Substring(0,$capabilityName.IndexOf('~'))]
	    }
	}
	if ($null -ne $desiredState) {
	    $ensureInstalled = KeyToValue $desiredState @{
		Installed = $true
		NotPresent = $false
	    }

	    if ($ensureInstalled) {
		if ($capabilityInstalled) {
		    LogIdempotent "Windows capability '$capabilityName' is already installed"
		} else {
		    DoUpdate "Windows capability '$capabilityName' has been installed" {
			Add-WindowsCapability -Online -Name $capabilityName | Out-Null
		    }
		}
	    } else {
		if ($capabilityInstalled) {
		    DoUpdate "Windows capability '$capabilityName' has been uninstalled" {
			Remove-WindowsCapability -Online -Name $capabilityName | Out-Null
		    }
		} else {
		    LogIdempotent "Windows capability '$capabilityName' is already uninstalled"
		}
	    }
	}
    }
}

Function EnsureWindowsApps($Apps) {
    foreach ($appName in $Apps.Keys) {
	$shouldBeInstalled = KeyToValue $Apps[$appName] @{
	    Installed = $true
	    Uninstalled = $false
	}
	$appInstalled = ($null -ne (Get-AppxPackage "$appName"))

	if ($shouldBeInstalled) {
	    if ($appInstalled) {
		LogIdempotent "App '$appName' is already installed"
	    } else {
		DoUpdate "App '$appName' has been installed" {
		    Get-AppxPackage -AllUsers "$appName" | ForEach-Object { Add-AppxPackage -DisableDevelopmentMode -Register "$( $_.InstallLocation )\AppXManifest.xml" }
		}
	    }
	} else {
	    if ($appInstalled) {
		DoUpdate "App '$appName' has been uninstalled" {
		    Get-AppxPackage "$appName" | Remove-AppxPackage
		}
	    } else {
		LogIdempotent "App '$appName' is already uninstalled"
	    }
	}
    }
}

Function EnsureWindowsDefenderExclusion($ExclusionPath) {
    $exclusions = $( Get-MpPreference ).ExclusionPath
    if (($null -eq $exclusions) -or ([Array]::IndexOf($exclusions, $ExclusionPath) -eq -1)) {
	DoUpdate -RequireAdmin "Windows defender exclusions has been updated to exclude '$ExclusionPath'" {
	    Add-MpPreference -ExclusionPath "$ExclusionPath"
	}
    } else {
	LogIdempotent "Windows defender exclusion already contains path '$ExclusionPath'"
    }
}

Function EnsureShortCut([String]$Shortcut, [String]$Target, [String]$Icon) {
    if (Test-Path -LiteralPath $Shortcut) {
	if ($Target) {
	    LogIdempotent "Shortcut '$Shortcut' already exists"
	} else {
	    DoUpdate "Shortcut '$Shortcut' deleted" {
		Remove-Item $Shortcut
	    }
	}
    } else {
	if ($Target) {
	    DoUpdate "Shortcut '$Shortcut' created" {
		$shortcutObj = (New-Object -comObject WScript.Shell).CreateShortcut($Shortcut)
		$shortcutObj.TargetPath = $Target
		if ($Icon) {
		    $shortcutObj.IconLocation = $Icon
		}
		$shortcutObj.Save()
	    }
	} else {
	    LogIdempotent "Shortcut '$Shortcut' is already missing"
	}
    }
}

Function EnsureLink([String]$LinkPath, [String]$TargetPath) {
    $linkItem = Get-Item -LiteralPath $LinkPath -ErrorAction:SilentlyContinue
    $isDirectory = (Get-Item $TargetPath) -is [System.IO.DirectoryInfo]
    if ($linkItem) {
	if ($linkItem.LinkType -eq "Junction" -or $linkItem.LinkType -eq "SymbolicLink") {
	    if ($linkItem.Target -eq $TargetPath) {
		LogIdempotent "Link '$LinkPath' is already targeting '$TargetPath'"
	    } else {
		DoUpdate "Changing link '$LinkPath' target from '$( $linkItem.Target )' to '$TargetPath'" {
		    if ($isDirectory) {
			attrib -R /L $LinkPath
			& "$env:COMSPEC" /c rmdir $LinkPath

			& "$env:COMSPEC" /c mklink /j $LinkPath $TargetPath | out-null
			attrib $LinkPath +R /L
		    } else {
			& "$env:COMSPEC" /c del $LinkPath

			& "$env:COMSPEC" /c sudo mklink $LinkPath $TargetPath | out-null
		    }
		}
	    }
	} else {
	    LogWarn "'$LinkPath' already exist but is not a junction link, cannot process it"
	}
    } else {
	EnsureDirectoryExist -Path (Split-Path -Parent $LinkPath)
	DoUpdate "Link created from '$LinkPath' to '$TargetPath'" {
	    if ($isDirectory) {
		& "$env:COMSPEC" /c mklink /j $LinkPath $TargetPath | out-null
		attrib $LinkPath +R /L
	    } else {
		& "$env:COMSPEC" /c sudo mklink $LinkPath $TargetPath | out-null
	    }
	}
    }
}

Function EnsureFileContent([String]$Path, [String]$Content, [switch]$Force, [String]$AllowForceHelpMessage) {
    if (Test-Path -LiteralPath $Path) {
	$currentContent = Get-Content -LiteralPath $Path -Encoding ASCII -Raw
	if ($currentContent -ne $Content) {
	    if ($Force) {
		DoUpdate "File '$Path' has been overwritten with the required content" {
		    $Content | Out-File -LiteralPath $Path -Encoding ASCII -NoNewline
		}
	    } else {
		LogWarn "File '$Path' exists but doesn't have the required content. $AllowForceHelpMessage"
	    }
	} else {
	    LogIdempotent "File '$Path' already exists with the required content"
	}
    } else {
	DoUpdate "File '$Path' created" {
	    $Content | Out-File -LiteralPath $Path -Encoding ASCII -NoNewline
	}
    }
}

Function EnsureFileDeleted([String]$Path) {
    if (Test-Path -LiteralPath $Path) {
	DoUpdate "File '$Path' has been deleted" {
	    Remove-Item -LiteralPath "$Path"
	}
    } else {
	LogIdempotent "File '$Path' is already missing"
    }
}

Function EnsureDirectoryExist([String]$Path) {
    if (Test-Path -LiteralPath $Path) {
	LogIdempotent "Directory '$Path' already exists"
    } else {
	DoUpdate "Directory '$Path' has been created" {
	    New-Item -ItemType Directory -Path "$Path" | Out-Null
	}
    }
}
