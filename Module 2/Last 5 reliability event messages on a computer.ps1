
get-wmiobject Win32_ReliabilityRecords -computername 127.0.0.1 -property Message | 
  select-object -first 5 Message | 
  format-list *