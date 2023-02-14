Function TimeTomorrow {
    $Date = Get-Date
    $DateTomorrow = $Date.AddDays(1)
    Write-Host $DateTomorrow
}

Function TimeTomorrowGlobal {
    $Date = Get-Date
    $Global:DateTomorrow = $Date.AddDays(1)
    Write-Host $DateTomorrow
}

TimeTomorrow

TimeTomorrowGlobal

Remove-Variable -Name DateTomorrow

Write-Host $DateTomorrow


# Check C:\Windows\Temp folder
$TempFolder = "C:\Windows\Temp"
$TempFilesCount = ( Get-ChildItem $TempFolder | Measure-Object ).Count
