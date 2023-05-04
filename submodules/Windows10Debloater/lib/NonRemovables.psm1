
#NonRemovable Apps that where getting attempted and the system would reject the uninstall, speeds up debloat and prevents 'initalizing' overlay when removing apps
$NonRemovables = Get-AppxPackage -AllUsers | Where-Object { $_.NonRemovable -eq $true } | ForEach { $_.Name }
$NonRemovables += Get-AppxPackage | Where-Object { $_.NonRemovable -eq $true } | ForEach { $_.Name }
$NonRemovables += Get-AppxProvisionedPackage -Online | Where-Object { $_.NonRemovable -eq $true } | ForEach { $_.DisplayName }
$NonRemovables = $NonRemovables | Sort-Object -Unique

if ($NonRemovables -eq $null ) {
    # the .NonRemovable property doesn't exist until version 18xx. Use a hard-coded list instead.
    #WARNING: only use exact names here - no short names or wildcards
    $NonRemovables = @(
	"1527c705-839a-4832-9118-54d4Bd6a0c89"
	"c5e2524a-ea46-4f67-841f-6a9465d9d515"
	"E2A4F912-2574-4A75-9BB0-0D023378592B"
	"F46D4000-FD22-4DB4-AC8E-4E1DDDE828FE"
	"InputApp"
	"Microsoft.AAD.BrokerPlugin"
	"Microsoft.AccountsControl"
	"Microsoft.BioEnrollment"
	"Microsoft.CredDialogHost"
	"Microsoft.ECApp"
	"Microsoft.LockApp"
	"Microsoft.MicrosoftEdgeDevToolsClient"
	"Microsoft.MicrosoftEdge"
	"Microsoft.PPIProjection"
	"Microsoft.Win32WebViewHost"
	"Microsoft.Windows.Apprep.ChxApp"
	"Microsoft.Windows.AssignedAccessLockApp"
	"Microsoft.Windows.CapturePicker"
	"Microsoft.Windows.CloudExperienceHost"
	"Microsoft.Windows.ContentDeliveryManager"
	"Microsoft.Windows.Cortana"
	"Microsoft.Windows.HolographicFirstRun"         # Added 1709
	"Microsoft.Windows.NarratorQuickStart"
	"Microsoft.Windows.OOBENetworkCaptivePortal"    # Added 1709
	"Microsoft.Windows.OOBENetworkConnectionFlow"   # Added 1709
	"Microsoft.Windows.ParentalControls"
	"Microsoft.Windows.PeopleExperienceHost"
	"Microsoft.Windows.PinningConfirmationDialog"
	"Microsoft.Windows.SecHealthUI"                 # Issue 117 Windows Defender
	"Microsoft.Windows.SecondaryTileExperience"     # Added 1709
	"Microsoft.Windows.SecureAssessmentBrowser"
	"Microsoft.Windows.ShellExperienceHost"
	"Microsoft.Windows.XGpuEjectDialog"
	"Microsoft.XboxGameCallableUI"                  # Issue 91
	"Windows.CBSPreview"
	"windows.immersivecontrolpanel"
	"Windows.PrintDialog"
	"Microsoft.VCLibs.140.00"
	"Microsoft.Services.Store.Engagement"
	"Microsoft.UI.Xaml.2.0"
    )
}