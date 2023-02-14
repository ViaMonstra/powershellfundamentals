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

