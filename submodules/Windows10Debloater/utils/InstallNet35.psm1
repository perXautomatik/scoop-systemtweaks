function InstallNet35
 {

	Write-Host "Initializing the installation of .NET 3.5..."
	DISM /Online /Enable-Feature /FeatureName:NetFx3 /All
	Write-Host ".NET 3.5 has been successfully installed!"
    }
