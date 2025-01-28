# Using Loops, Arrays, and Hash Tables

# Foreach Example
$names = @("Johan","Andrew","Jan","Sandy")
foreach ($name in $names){
    Write-Host "the name is $name"

}
$names.GetType()

# Do/While Example
$MaxLoopCount = 5
$Counter = 0
do
{
    $Counter++    
    Write-Host "Current count is: $Counter"
    Start-sleep -Seconds 2
}
while ($Counter -lt $MaxLoopCount)



ForEach-Object -InputObject (1..100000) { $_ } | Measure-Object
Measure-Command { $Result = ForEach-Object -InputObject (1..100000) { $_ } }

ForEach ($i in (1..100000)) { $i }
Measure-Command { $Result = ForEach ($i in (1..100000)) { $i } }



$array = @()
$array = $array + [PSCustomObject]@{ComputerName = "TEST1"; Version = "1.2" }
$array = $array + [PSCustomObject]@{ComputerName = "TEST2"; Version = "1.1" }
$array = $array + [PSCustomObject]@{ComputerName = "TEST3"; Version = "1.3" }

$HashTable = $array | Group-Object -Property ComputerName -AsHashTable


If ($HashTable.Contains("TEST3")){
    Write-Host "YAY" -ForegroundColor Green
}

$Result = $ht.Get_Item("TEST2")
$Result.version





$lines = [System.Io.File]::ReadLines('/path/to/file.txt')
$lines | Select-Object -Unique   # 6-12 minutes
$lines | Sort-Object -Unique    # 2-3 seconds