# Using Loops, Arrays, and Hash Tables

$names = @("Johan","Andrew","Jan","Sandy")

foreach ($name in $names){
    Write-Host "the name is $name"

}

$names.GetType()

ForEach-Object -InputObject (1..100000) { $_ } | Measure-Object
Measure-Command { $Result = ForEach-Object -InputObject (1..100000) { $_ } }

ForEach ($i in (1..100000)) { $i }
Measure-Command { $Result = ForEach ($i in (1..100000)) { $i } }



$ary = @()
$ary = $ary + [PSCustomObject]@{ComputerName = "TEST1"; Version = "1.2" }
$ary = $ary + [PSCustomObject]@{ComputerName = "TEST2"; Version = "1.1" }
$ary = $ary + [PSCustomObject]@{ComputerName = "TEST3"; Version = "1.3" }

$ht = $ary | Group-Object -Property ComputerName -AsHashTable



If ($ht.Contains("TEST3")){"YAY"}

$Result = $ht.Get_Item("TEST2")
$Result.version





$lines = [System.Io.File]::ReadLines('/path/to/file.txt')
$lines | Select-Object -Unique   # 6-12 minutes
$lines | Sort-Object -Unique    # 2-3 seconds