$Date = Get-Date
Write-Host $Date

$Result = Start-Process cmd.exe -ArgumentList "/k hostname"
$Result

$Result = Start-Process cmd.exe -ArgumentList "/k hostname" -PassThru
$Result.ExitCode 

# Objects stored in a variable
$Service = Get-Service -Name wuauserv


Set-BranchCacheEventLogSize.ps1