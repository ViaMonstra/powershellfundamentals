(Get-WmiObject -namespace root\wmi –class MSStorageDriver_FailurePredictStatus `
    -ErrorAction Silentlycontinue |  Select InstanceName, PredictFailure, Reason | `
    Format-Table –Autosize)

# Or

Get-Disk 0 | Get-StorageReliabilityCounter
Get-Disk | Get-StorageReliabilityCounter

# Or

Get-PhysicalDisk –FriendlyName PhysicalDisk1 | Get-StorageReliabilityCounter
