Start-DedupJob -Type Optimization -Memory 75 -Priority High -Volume D: -Wait
Start-DedupJob -Type GarbageCollection -Full -Memory 75 -Priority High -Volume D: -Wait
Start-DedupJob -Type Scrubbing -Full -Memory 75 -Priority High -Volume D: -Wait