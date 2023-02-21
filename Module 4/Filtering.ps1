$Path = "E:\Work\ViaMonstra Online Academy - Course - PowerShell Fundamentals\Module 4\SampleTextFile.txt"

Get-Content -Path $Path -First 5

Get-Content -Path $Path -TotalCount 5

Get-Content -Path $Path -Head 5

(Get-Content -Path $Path -Head 5)[-1]

(Get-Content -Path $Path -Head 5)[0]



Get-Content -Path $Path -Last 5

Get-Content -Path $Path -Tail 5

