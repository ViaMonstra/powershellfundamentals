$FilesNow = Get-ChildItem -Path "C:\Windows\Temp" -Recurse
$FilesTomorrow = Get-ChildItem -Path "C:\Windows\Temp" -Recurse
$FilesNow | Select Length, FullName
$FilesTomorrow | Select Length, FullName

Compare-Object -ReferenceObject $FilesNow -DifferenceObject $FilesTomorrow -Property Length, FullName