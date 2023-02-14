# Approved Verbs for PowerShell Commands
# https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.3

# Get reboot events
Get-Command -Name *event*
Get-Command -Name get*event*

Get-WinEvent -FilterHashtable @{logname = 'System'; id = 1074, 6005, 6006, 6008} -MaxEvents 6 | Format-Table -wrap