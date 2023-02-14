Get-ChildItem -recurse | Select-String -pattern "serviceui" | group path | select name

$SearchString = "ISO"
Get-ChildItem *.ps1 -recurse | Select-String -pattern $SearchString | Group-Object path | Select-Object name

Get-ChildItem | Select-String -pattern "Microsoft.Policies.Sensors.WindowsLocationProvider" | group path | select name 

Get-ChildItem -recurse | Select-String -pattern "serviceui" | group path | select name

Get-ChildItem *.inf -recurse | Select-String -pattern "PID_0248" | group path | select name
