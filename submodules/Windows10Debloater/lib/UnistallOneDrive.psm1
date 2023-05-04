#   Description:
# This script will remove and disable OneDrive integration.

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\New-FolderForced.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\take-own.psm1
function UnistallOneDrive ()
{
	Write-Output "Kill OneDrive process"
	taskkill.exe /F /IM "OneDrive.exe"
	taskkill.exe /F /IM "explorer.exe"

	Write-Output "Remove OneDrive"
	if (Test-Path "$env:systemroot\System32\OneDriveSetup.exe") {
		& "$env:systemroot\System32\OneDriveSetup.exe" /uninstall
	}
	if (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
		& "$env:systemroot\SysWOW64\OneDriveSetup.exe" /uninstall
	}

    Write-Host "Checking for pre-existing files and folders located in the OneDrive folders..."
    Start-Sleep 1
	If (Test-Path "$env:USERPROFILE\OneDrive\*") {
	    Write-Host "Files found within the OneDrive folder! Checking to see if a folder named OneDriveBackupFiles exists."
	    Start-Sleep 1

	    If (Test-Path "$env:USERPROFILE\Desktop\OneDriveBackupFiles") {
		Write-Host "A folder named OneDriveBackupFiles already exists on your desktop. All files from your OneDrive location will be moved to that folder."
	    }
	    else {
		If (!(Test-Path "$env:USERPROFILE\Desktop\OneDriveBackupFiles")) {
		    Write-Host "A folder named OneDriveBackupFiles will be created and will be located on your desktop. All files from your OneDrive location will be located in that folder."
		    New-item -Path "$env:USERPROFILE\Desktop" -Name "OneDriveBackupFiles"-ItemType Directory -Force
		    Write-Host "Successfully created the folder 'OneDriveBackupFiles' on your desktop."
		}
	    }
	    Start-Sleep 1
	    Move-Item -Path "$env:USERPROFILE\OneDrive\*" -Destination "$env:USERPROFILE\Desktop\OneDriveBackupFiles" -Force
	    Write-Host "Successfully moved all files/folders from your OneDrive folder to the folder 'OneDriveBackupFiles' on your desktop."
	    Start-Sleep 1
	    Write-Host "Proceeding with the removal of OneDrive."
	    Start-Sleep 1
	}
	Else {
	    Write-Host "Either the OneDrive folder does not exist or there are no files to be found in the folder. Proceeding with removal of OneDrive."
	    Start-Sleep 1
	    Write-Host "Enabling the Group Policy 'Prevent the usage of OneDrive for File Storage'."
	    $OneDriveKey = 'HKLM:Software\Policies\Microsoft\Windows\OneDrive'
	    If (!(Test-Path $OneDriveKey)) {
		Mkdir $OneDriveKey
		Set-ItemProperty $OneDriveKey -Name OneDrive -Value DisableFileSyncNGSC
	    }
	    Set-ItemProperty $OneDriveKey -Name OneDrive -Value DisableFileSyncNGSC
	}

	Write-Host "Uninstalling OneDrive. Please wait..."


	New-PSDrive -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" -Name "HKCR"
	$onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
	$ExplorerReg1 = "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
	$ExplorerReg2 = "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
	Stop-Process -Name "OneDrive*"
	Start-Sleep 2
    If (!(Test-Path $onedrive)) {
	$onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"

	New-PSDrive  HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
	$onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
	$ExplorerReg1 = "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
	$ExplorerReg2 = "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
	Stop-Process -Name "OneDrive*"
	Start-Sleep 2
	If (!(Test-Path $onedrive)) {
	    $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
	}
	Start-Process $onedrive "/uninstall" -NoNewWindow -Wait
	Start-Sleep 2
	Write-Output "Stopping explorer"
	Start-Sleep 1
	taskkill.exe /F /IM explorer.exe
	Start-Sleep 3
	Write-Output "Removing leftover files"
	Remove-Item "$env:USERPROFILE\OneDrive" -Force -Recurse
	Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive" -Force -Recurse
	Remove-Item "$env:PROGRAMDATA\Microsoft OneDrive" -Force -Recurse
	If (Test-Path "$env:SYSTEMDRIVE\OneDriveTemp") {
	    Remove-Item "$env:SYSTEMDRIVE\OneDriveTemp" -Force -Recurse
	}
	Write-Output "Removing OneDrive from windows explorer"
	If (!(Test-Path $ExplorerReg1)) {
	    New-Item $ExplorerReg1
	}
	Set-ItemProperty $ExplorerReg1 System.IsPinnedToNameSpaceTree -Value 0
	If (!(Test-Path $ExplorerReg2)) {
	    New-Item $ExplorerReg2
	}
	Set-ItemProperty $ExplorerReg2 System.IsPinnedToNameSpaceTree -Value 0
	Write-Output "Restarting Explorer that was shut down before."
	Start-Process explorer.exe -NoNewWindow

	Write-Host "Enabling the Group Policy 'Prevent the usage of OneDrive for File Storage'."
	$OneDriveKey = 'HKLM:Software\Policies\Microsoft\Windows\OneDrive'
	If (!(Test-Path $OneDriveKey)) {
	    Mkdir $OneDriveKey
	}
	Start-Process $onedrive "/uninstall" -NoNewWindow -Wait
	Start-Sleep 2
	Write-Host "Stopping explorer"
	Start-Sleep 1
	taskkill.exe /F /IM explorer.exe
	Start-Sleep 3

	Write-Host "Removing leftover files"
	If (Test-Path "$env:USERPROFILE\OneDrive") {
	    Remove-Item "$env:USERPROFILE\OneDrive" -Force -Recurse
	}
	If (Test-Path "$env:LOCALAPPDATA\Microsoft\OneDrive") {
	    Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive" -Force -Recurse
	}
	If (Test-Path "$env:PROGRAMDATA\Microsoft OneDrive") {
	    Remove-Item "$env:PROGRAMDATA\Microsoft OneDrive" -Force -Recurse
	}
	If (Test-Path "$env:SYSTEMDRIVE\OneDriveTemp") {
	    Remove-Item "$env:SYSTEMDRIVE\OneDriveTemp" -Force -Recurse
	}
	# check if directory is empty before removing:
	If ((Get-ChildItem "$env:userprofile\OneDrive" -Recurse | Measure-Object).Count -eq 0) {
		Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:userprofile\OneDrive"
	}

	Write-Output "Disable OneDrive via Group Policies"

	New-FolderForced -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive"
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" "DisableFileSyncNGSC" 1

	Write-Output "Remove Onedrive from explorer sidebar"
	New-PSDrive -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" -Name "HKCR"

	Write-Host "Removing OneDrive from windows explorer"
	If (!(Test-Path $ExplorerReg1)) {
	    New-Item $ExplorerReg1
	}
	Set-ItemProperty $ExplorerReg1 System.IsPinnedToNameSpaceTree -Value 0
	If (!(Test-Path $ExplorerReg2)) {
	    New-Item $ExplorerReg2
	}
	Set-ItemProperty $ExplorerReg2 System.IsPinnedToNameSpaceTree -Value 0
Remove-PSDrive "HKCR"
	# Thank you Matthew Israelsson
	Write-Output "Removing run hook for new users"
	reg load "hku\Default" "C:\Users\Default\NTUSER.DAT"
	reg delete "HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f
	reg unload "hku\Default"

	Write-Output "Removing startmenu entry"
	Remove-Item -Force -ErrorAction SilentlyContinue "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"

	Write-Output "Removing scheduled task"
	Get-ScheduledTask -TaskPath '\' -TaskName 'OneDrive*' -ea SilentlyContinue | Unregister-ScheduledTask -Confirm:$false

	Write-Host "Restarting Explorer that was shut down before."
	Start-Process explorer.exe -NoNewWindow

	Write-Output "Waiting for explorer to complete loading"
	Start-Sleep 10

	Write-Output "Removing additional OneDrive leftovers"
	foreach ($item in (Get-ChildItem "$env:WinDir\WinSxS\*onedrive*")) {
    Takeown-Folder $item.FullName
    Remove-Item -Recurse -Force $item.FullName
	Write-Host "OneDrive has been successfully uninstalled!"

	Remove-item env:OneDrive
    }
