Get-Service -DisplayName 'Windows Update'

Get-Service -DisplayName 'Windows Update' | Restart-Service

Get-Service -Name W* | Where-Object { $_.Status -eq "Running" }

Get-Service -Name W* | Where-Object { $_.Status -eq "Running" } | Select-Object Name, DisplayName



