function addToAutorun ($path,$name){

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" `
 -Name $name `
 -Value $path
}