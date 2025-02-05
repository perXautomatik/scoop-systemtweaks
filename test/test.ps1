#Requires -Version 5.1
#Requires -Modules @{ ModuleName = 'BuildHelpers'; ModuleVersion = '2.0.1' }
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.2.0' }
<#
.SYNOPSIS
    Execute Pester tests in repository root directory.
#>
if(!$env:SCOOP_HOME) { $env:SCOOP_HOME = resolve-path (split-path (split-path (scoop which scoop))) }

$pesterConfig = New-PesterConfiguration -Hashtable @{
    Run    = @{
	Path     = "$PSScriptRoot/.."
	PassThru = $true
    }
    Output = @{
	Verbosity = 'Detailed'
    }
}
$result = Invoke-Pester -Configuration $pesterConfig
exit $result.FailedCount
