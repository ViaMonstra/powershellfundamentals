# Set Authentication info for to Microsoft Graph
$tenant = "replace-with-your-tenant-name"
$authority = "https://login.windows.net/$tenant"
$AppID = "replace-with-your-app-registration-id"
$AppSecret = Get-Content "C:\Setup\Credentials\secret.txt"

# Show the settings
Write-Host "Intune tenant is $tenant"
Write-Host "Authority tenant is $authority"
Write-Host "AppID is $AppID"
Write-Host "AppSecret is **Secret**"

# Connect to Microsoft Graph
Update-MSGraphEnvironment -AppId $AppID -Quiet
Update-MSGraphEnvironment -AuthUrl $authority -Quiet
Connect-MSGraph -ClientSecret $AppSecret -Quiet
