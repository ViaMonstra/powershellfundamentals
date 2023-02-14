# Default to table
Get-LocalGroup

# Format in a list
Get-LocalGroup | Format-List

# Format in a list and select only a few properties
Get-LocalGroup | Format-List -Property Name, Description


# Default to table
Get-CimInstance -ClassName Win32_ComputerSystem

# Format in a list (FL)
Get-CimInstance -ClassName Win32_ComputerSystem | FL
Get-CimInstance -ClassName Win32_ComputerSystem | Format-List

# Get network info (Show blog)
Get-NetIPAddress
Get-Command Get-NetIPAddress
Get-NetIPConfiguration
Get-NetIPConfiguration | Format-List *
Get-NetIPConfiguration | Out-GridView
Get-NetIPConfiguration | Out-HtmlView
Get-Command Get-NetIPConfiguration

gip # alias

# Format table
Get-NetIPConfiguration | Format-Table
Get-NetIPConfiguration | Format-Table -Wrap

# Group By
Get-Service
Get-Service | Sort-Object Status
Get-Service | Sort-Object Status | Format-Table -GroupBy Status