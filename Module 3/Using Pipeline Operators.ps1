$Demo = 1
$Demo -eq 1

7 -gt 5

(7 -gt 5) -and (11 -gt 10)

(5 -gt 7) -and (11 -gt 10)

(7 -gt 5) -or (11 -gt 10)

(5 -gt 7) -or (11 -gt 10)

# Where-Object
Get-Service 
Get-Service | Where-Object { $_.Status -eq "Running" }
Get-Service | Where-Object { $_.Status -eq "Running" } | Select-Object *
Get-Service | Where-Object { $_.StartType -like "Automatic*" }
Get-Service | Where-Object { ($_.StartType -like "Automatic*") -and -not ($_.Status -eq "Running") } 


# Pipeline
Get-Service | Stop-Service -WhatIf

# Combining it all
Invoke-StifleRClientMSILocalPackageRepair.ps1