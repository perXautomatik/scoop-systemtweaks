##Here is an addition to Shay Levi's suggestion (just add these lines at the beginning of a script):
##This results in the current script being passed to a new powershell process in Administrator mode (if current User has access to Administrator mode and the script is not launched as Administrator).
##Copied from: Running a command as Administrator using PowerShell? - Stack Overflow - 2020-10-15 14:23:14 - <https://stackoverflow.com/questions/7690994/running-a-command-as-administrator-using-powershell>

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}
