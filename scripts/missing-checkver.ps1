<#
.SYNOPSIS
    Check if manifests have checkver  and autoupdate property.
.DESCRIPTION
    Check if manifests have checkver property.
.PARAMETER App
    Manifest name.
.PARAMETER Dir
    Directory where to search for manfiest.
    Default to bucket folder.
.PARAMETER Rest
    -s - Skip supported
.EXAMPLE
    PS BUCKETROOT >  .\bin\missing-checkver.ps1
    Check all manifests inside root of bucket.
.EXAMPLE
    PS BUCKETROOT >  .\bin\missing-checkver.ps1 TODO
    Check all manifests inside TODO directory.
.EXAMPLE
    PS BUCKETROOT >  .\bin\missing-checkver.ps1 -dir TODO
    Check all manifests inside TODO directory.
#>
param(
    [Parameter(ValueFromPipeline = $true)]
    [Alias('App')]
    [String] $Manifest = '*',
    [ValidateScript( { if ( Test-Path $_ -Type Container) { $true } else { $false } })]
    [String] $Dir = "$PSScriptRoot\..\bucket",   # checks the parent dir
    [Parameter(ValueFromRemainingArguments = $true)]
    [String[]] $Rest = ''
)

begin {
if(!$env:SCOOP_HOME) { $env:SCOOP_HOME = Resolve-Path (scoop prefix scoop) }
    $Dir = Resolve-Path $Dir
    $Rest = $Rest -join ' '
}
$missing_checkver = "$env:SCOOP_HOME/bin/missing-checkver.ps1"
process { Invoke-Expression -Command  "& '$missing_checkver' -Dir ""$Dir"" -App ""$Manifest"" $Rest" }

end { Write-Host 'DONE' -ForegroundColor Yellow }
