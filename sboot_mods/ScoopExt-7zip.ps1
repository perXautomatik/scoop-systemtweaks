. "$( sboot_mod "Utils" )"
. "$( sboot_mod "ScoopMod" )"
$sevenZipCLSID = "{23170F69-40C1-278A-1000-000100020000}"
$fileTypes = @{
    "7z" = 0
    "zip" = 1
    "bz2" = 2
    "bzip2" = 2
    "tbz" = 2
    "tbz2" = 2
    "rar" = 3
    "arj" = 4
    "z" = 5
    "taz" = 5
    "lzh" = 6
    "lha" = 6
    "cab" = 7
    "iso" = 8
    "001" = 9
    "rpm" = 10
    "deb" = 11
    "cpio" = 12
    "tar" = 13
    "gz" = 14
    "tgz" = 14
    "gzip" = 14
    "tpz" = 14
    "wim" = 15
    "swm" = 15
    "lzma" = 16
    "dmg" = 17
    "hfs" = 18
    "xar" = 19
    "vhd" = 20
    "fat" = 21
    "ntfs" = 22
    "xz" = 23
    "txz" = 23
    "squashfs" = 24
}

Function AppInstalled([String]$AppDir, $ExcludeExt = @()) {
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\7-Zip" -Name "LargePages" -Type DWORD -Value 1
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\7-Zip\Options" -Name "ContextMenu" -Type DWORD -Value -2147479177
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\7-Zip\Options" -Name "MenuIcons" -Type DWORD -Value 1
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\7-Zip\FM" -Name "ShowDots" -Type DWORD -Value 1
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\7-Zip\FM" -Name "ShowRealFileIcons" -Type DWORD -Value 1
    EnsureRegistryValue -Path "HKEY_CURRENT_USER\Software\7-Zip\FM" -Name "ShowSystemMenu" -Type DWORD -Value 1

    EnsureShellExtensionRegistered -CLSID $sevenZipCLSID -Label "7-Zip Shell Extension" -DLL64Path "$AppDir\7-zip.dll" -DLL32Path "$AppDir\7-zip32.dll"

    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\7-Zip" -Name "" -Type String -Value "$sevenZipCLSID"
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\Directory\shellex\ContextMenuHandlers\7-Zip" -Name "" -Type String -Value "$sevenZipCLSID"
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\Directory\shellex\DragDropHandlers\7-Zip" -Name "" -Type String -Value "$sevenZipCLSID"
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\Drive\shellex\DragDropHandlers\7-Zip" -Name "" -Type String -Value "$sevenZipCLSID"
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\Folder\shellex\ContextMenuHandlers\7-Zip" -Name "" -Type String -Value "$sevenZipCLSID"
	EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" -Name "$clsid" -Type String -Value "7-Zip Shell Extension"
	EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" -Name "$clsid" -Type String -Value "7-Zip Shell Extension"
	EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\CLSID\$clsid" -Name "" -Type String -Value "7-Zip Shell Extension"
	EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\CLSID\$clsid\InprocServer32" -Name "" -Type String -Value "$sevenZipPath\7-zip.dll"
	EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\CLSID\$clsid\InprocServer32" -Name "ThreadingModel" -Type String -Value "Apartment"
	EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\WOW6432Node\CLSID\$clsid" -Name "" -Type String -Value "7-Zip Shell Extension"
	EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\WOW6432Node\CLSID\$clsid\InprocServer32" -Name "" -Type String -Value "$sevenZipPath\7-zip32.dll"
	EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\WOW6432Node\CLSID\$clsid\InprocServer32" -Name "ThreadingModel" -Type String -Value "Apartment"
    EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\Folder\shellex\DragDropHandlers\7-Zip" -Name "" -Type String -Value "$sevenZipCLSID"

    foreach ($ext in $fileTypes.Keys) {
	if ( $ExcludeExt.Contains($ext)) {
	    FileTypeUndefine -Type "7-Zip.$ext"
	    FileExtAssociate -Ext "$ext" -FileType $null -IfFileType "7-Zip.$ext"
	} else {
	    $iconIndex = $fileTypes[$ext]
	    FileTypeDefine -Type "7-Zip.$ext" -Label "$ext Archive" -Command """$AppDir\7zFM.exe"" ""%1""" -Icon "$AppDir\7z.dll,$iconIndex"
	    FileExtAssociate -Ext "$ext" -FileType "7-Zip.$ext"
	}
    }
}


Function AppUninstalled($ExcludeExt = @()) {
    EnsureRegistryKeyDeleted -Path "HKEY_CURRENT_USER\Software\7-Zip"

    EnsureShellExtensionUnregistered -CLSID $sevenZipCLSID

    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\7-Zip"
    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\Directory\shellex\ContextMenuHandlers\7-Zip"
    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\Directory\shellex\DragDropHandlers\7-Zip"
    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\Drive\shellex\DragDropHandlers\7-Zip"
    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\Folder\shellex\ContextMenuHandlers\7-Zip"
	EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" -Name "$clsid" -Type String -Value $null
	EnsureRegistryValue -Path "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" -Name "$clsid" -Type String -Value $null
	EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\CLSID\$clsid"
	EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\WOW6432Node\CLSID\$clsid"
    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\Folder\shellex\DragDropHandlers\7-Zip"

    }
Function Ensure7ZipConfiguration($ExcludeExt = @()) {
    $count = GetUpdateCount
    $sevenZipCLSID = "{23170F69-40C1-278A-1000-000100020000}"
    $clsid = $sevenZipCLSID
    $isInstalled = ScoopIsInstalled "7zip"
    if ($isInstalled) {
	$sevenZipPath = scoop prefix "7zip"
	AppInstalled  $sevenZipPath $ExcludeExt
    } else {
AppUninstalled $ExcludeExt
    }
    foreach ($ext in $fileTypes.Keys) {
	if (! $ExcludeExt.Contains($ext)) {
	FileTypeUndefine -Type "7-Zip.$ext"
	FileExtAssociate -Ext "$ext" -FileType $null -IfFileType "7-Zip.$ext"
	    $iconIndex = $fileTypes[$ext]
	    if ($isInstalled) {
		EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\7-Zip.$ext" -Name "" -Type String -Value "$ext Archive"
		EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\7-Zip.$ext\shell\open\command" -Name "" -Type String -Value """$sevenZipPath\7zFM.exe"" ""%1"""
		EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\7-Zip.$ext\DefaultIcon" -Name "" -Type String -Value "$sevenZipPath\7z.dll,$iconIndex"
		EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\.$ext" -Name "" -Type String -Value "7-Zip.$ext"
	    } else {
		EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\7-Zip.$ext"
		EnsureRegistryValue -Path "HKEY_CLASSES_ROOT\.$ext" -Name "" -Type String -Value $null
	    }
	}
    }
    $count = (GetUpdateCount) - $count
    if ($count) {
	IncrementGlobalAssociationChangedCounter
    }
}
