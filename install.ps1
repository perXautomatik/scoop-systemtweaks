$scoopTarget = 'D:\scoop'
$changeExecutionPolicy = (Get-ExecutionPolicy) -gt 'RemoteSigned' -or (Get-ExecutionPolicy) -eq 'ByPass'

$scoopTarget = Read-Host "Enter your Scoop installation directory (e.g. D:\scoop)"
$scoopPersistUrl = Read-Host "Enter your Scoop persist directory's Git repository URL (e.g. https://github.com/xfournet/scoop-persist.git)"
$scoopPersistBranch = Read-Host "Enter your Scoop persist directory's Git repository branch name (e.g. master)"

Write-Host "Scoop will be installed to $scoopTarget"
if ($changeExecutionPolicy) {
    Write-Host "Current user execution policy will be set to RemoteSigned"
} else {
    Write-Host "Current user execution policy don't need to be changed (current value is $( Get-ExecutionPolicy ))"
}
Write-Host ""

Write-Host "Do you want to proceed with the sboot installation ?"

$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

$decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
if ($decision -ne 0) {
    Write-Host 'Cancelled'
    return
}

$env:SCOOP = $scoopTarget
[environment]::setEnvironmentVariable('SCOOP', $scoopTarget, 'User')
if ($changeExecutionPolicy) {
  Set-ExecutionPolicy Bypass -Scope Process -Force
}

#Install Chocolatey
if (-not (Get-Command choco -ErrorAction Ignore)) {
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

#Install Scoop
if (-not (Get-Command scoop -ErrorAction Ignore)) {
  $env:SCOOP = "$env:ProgramData\scoop"
  [environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'Machine')
  Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
}


function Add-ScoopBucket {
  [CmdletBinding()]
  param(
    [string]$name,
    [string]$url
  )

  # Git is required when adding an additional scoop bucket.
  if (-not (Get-Command git -ErrorAction Ignore)) {
    choco install git -y --params "/GitOnlyOnPath /NoAutoCrlf /NoShellHereIntegration"
    # Set-Alias -Name git -Value "$env:ProgramFiles\Git\cmd\git.exe"
    $env:Path = "$env:Path;$env:ProgramFiles\Git\cmd\"
  }
scoop update
scoop update *
  if ((scoop bucket list) -notcontains $name) {
    Write-Host "scoop bucket add $name $url"
    # Run in new PowerShell process to ensure git path is enabled.
    # powershell -ExecutionPolicy unrestricted -Command scoop bucket add $name $url

if (Test-Path -LiteralPath "$scoopTarget\persist") {
    Remove-Item "$scoopTarget\persist" -Force
}
git clone -n "$scoopPersistUrl" "$scoopTarget\persist"
pushd "$scoopTarget\persist"
git checkout "$scoopPersistBranch"
popd

    scoop bucket add $name $url

  }
  else {
    Write-Information -MessageData "Scoopbucket $name is already added."
  }
}
Add-ScoopBucket -Name 'perXautomatik' -Url 'https://github.com/perXautomatik/ScoopBucket'
scoop install sboot/sboot
'OSBasePackages' | ForEach-Object {
  Write-Host "Installing $_..."
  scoop install $_
}
Write-Host ""
Write-Host "Scoop bootstrapped. If everything is OK, execute 'sboot apply *' command. If you are unsure, first execute 'sboot apply -n *'"
