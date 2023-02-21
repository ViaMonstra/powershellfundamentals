$Path = "E:\Work\ViaMonstra Online Academy - Course - PowerShell Fundamentals\Module 4\SampleTextFile.txt"
$OutPutPath = "C:\Temp\Output.txt"

Get-Content -Path $Path -Head 5 | Set-Content -Path $OutPutPath 