[](https://stackoverflow.com/posts/29806921/timeline)
It's not a good idea to add this kind of thing directly to your `$env:WINDIR` powershell folders.  
The recommended way is to add it to your personal profile: 

```bash
cd $env:USERPROFILE\Documents
md WindowsPowerShell -ErrorAction SilentlyContinue
cd WindowsPowerShell
New-Item Microsoft.PowerShell_profile.ps1 -ItemType "file" -ErrorAction SilentlyContinue
powershell_ise.exe .\Microsoft.PowerShell_profile.ps1
```

Now add your alias to the Microsoft.PowerShell\_profile.ps1 file that is now opened:

```php
function Do-ActualThing {
    # do actual thing
}

Set-Alias MyAlias Do-ActualThing
```

Then save it, and refresh the current session with:

```bash
. $profile
```

**Note:** Just in case, if you get permission issue like

> CategoryInfo : SecurityError: (:) \[\], PSSecurityException + FullyQualifiedErrorId : UnauthorizedAccess

Try the below command and refresh the session again.

```coffeescript
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```

Url: https://stackoverflow.com/questions/24914589/how-to-create-permanent-powershell-aliases