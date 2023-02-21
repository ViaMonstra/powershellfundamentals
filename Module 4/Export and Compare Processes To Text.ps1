Get-Process | Export-Csv C:\Temp\PC1.csv
Get-Process | Export-Csv C:\Temp\PC2.csv

# Compare
$CSVFile1 = Import-CSV -LiteralPath "E:\Work\ViaMonstra Online Academy - Course - PowerShell Fundamentals\Module 4\PC1.csv"
$CSVFile2 = Import-CSV -LiteralPath "E:\Work\ViaMonstra Online Academy - Course - PowerShell Fundamentals\Module 4\PC2.csv"
Compare-Object -ReferenceObject $CSVFile1 -DifferenceObject $CSVFile2 -Property Name