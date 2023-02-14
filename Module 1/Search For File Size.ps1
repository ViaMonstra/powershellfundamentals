Get-ChildItem E:\Setup -recurse -Filter *.msi | where-object {(($_.length -gt 80MB) -and ($_.length -lt 120MB))} | Sort-Object length | ft fullname, length -auto



Get-ChildItem | Select-String -pattern "Microsoft.Policies.Sensors.WindowsLocationProvider" | group path | select name 