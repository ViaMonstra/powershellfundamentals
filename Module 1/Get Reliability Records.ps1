# Get Reliability Records
Get-CimInstance -ClassName Win32_ReliabilityRecords -property Message | select-object -first 5 Message | format-list *
 
 # Find Restore Points with PowerShell
Get-EventLog -Logname Application -InstanceId 8194 -Newest 3