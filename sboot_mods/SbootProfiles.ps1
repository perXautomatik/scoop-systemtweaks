. "$( sboot_mod "Utils" )"

Function EnsurePowershellProfileConfiguration {
if (!(Test-Path $PROFILE)) {
    $profileDir = Split-Path $PROFILE
DoUpdate -RequireAdmin "Creating default user profile PowerShell file: $PROFILE"
	if (!(Test-Path $profileDir)) {
	    New-Item -Path $profileDir -ItemType Directory | Out-Null
	}

	'' > $PROFILE
    }

    $text = &{If(Test-Path -Path $Profile) {(Get-Content $PROFILE)} Else {""}}

    if ($text | Select-String '#sboot-profiles') {
	LogIdempotent "sboot-profiles is already configured into user profile PowerShell file: $PROFILE"
    } else {
	DoUpdate -RequireAdmin "Add sboot-profiles to user profile PowerShell file: $PROFILE" {
	    # read and write whole profile to avoid problems with line endings and encodings
	    $new_profile = @($text) + "#sboot-profiles" + '. "$env:SCOOP\apps\sboot\current\bin\load-profiles.ps1"'
	    $new_profile > $PROFILE
	}
    }
}
