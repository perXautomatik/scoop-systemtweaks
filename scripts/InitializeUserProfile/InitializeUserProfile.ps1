cd $env:USERPROFILE\Documents
md WindowsPowerShell -ErrorAction SilentlyContinue
cd WindowsPowerShell
New-Item Microsoft.PowerShell_profile.ps1 -ItemType "file" -ErrorAction SilentlyContinue
powershell_ise.exe .\Microsoft.PowerShell_profile.ps1