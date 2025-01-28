Get-WinEvent -FilterHashtable @{logname = 'System'; id = 1074, 6005, 6006, 6008, 6013 } -MaxEvents 50 | Format-Table -wrap 

Get-CimInstance -OperationTimeoutSec