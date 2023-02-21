Get-Service | Sort-Object Status
Get-Service | Sort-Object Status | Format-Table -GroupBy Status

Get-ChildItem F:\Downloads | Sort-Object -Property LastWriteTime 

Get-ChildItem F:\Downloads | Sort-Object -Property LastWriteTime -Descending