[string] $Thing1 = 5
[string] $Thing2 = 11

$Result = $Thing1 + $Thing2

$Thing1.GetType()

[int] $Thing1 = 5
[int] $Thing2 = 11

$Result = $Thing1 + $Thing2
$Thing1.GetType()

[int]::MaxValue
[int64]::MaxValue

[int] $Test = 2147483647
[int] $Test = 9223372036854775807
[int64] $Test = 9223372036854775807

[DateTime] $PartyTime = "May 11, 2023"

$Date = Get-Date

$CanWaitDays = ($PartyTime - $Date).Days 

$CollectedDate = Get-Date -Format "dd/MM/yyyy"

# Get free disk space on C: in GB
$FreeDiskspace = (Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'").freespace
$FreeDiskspaceGB = $FreeDiskspace/1GB
$FreeDiskspaceGB = [math]::Round($FreeDiskspaceGB,2)
$FreeDiskspaceGB = [math]::Round(((Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'").freespace/1GB),2)


$Service = Get-Service -Name peerdistsvc
$Service.Status

$Date = Get-Date
Write-Host $Date

$Result = Start-Process cmd.exe -ArgumentList "/k hostname"
$Result

$Result = Start-Process cmd.exe -ArgumentList "/k hostname" -PassThru
$Result.ExitCode 

# Objects stored in a variable
$Service = Get-Service -Name wuauserv
$Service | Start-Service




Function TimeTomorrow {
    $Date = Get-Date
    $DateTomorrow = $Date.AddDays(1)
    Write-Host $DateTomorrow
}

Function TimeTomorrowGlobal {
    $Date = Get-Date
    $Global:DateTomorrow = $Date.AddDays(1)
    Write-Host $DateTomorrow
}

TimeTomorrow

TimeTomorrowGlobal

Remove-Variable -Name DateTomorrow

Write-Host $DateTomorrow


# Check C:\Windows\Temp folder
$TempFolder = "C:\Windows\Temp"
$TempFilesCount = ( Get-ChildItem $TempFolder | Measure-Object ).Count




