$DLL = "F:\Setup\MDT 8456 HF\x64\microsoft.bdd.utility.dll"
Get-Item -Path $DLL
Get-Item -Path $DLL | Select-Object *
(Get-Item -Path $DLL).VersionInfo.FileVersion

$MSI = "F:\Setup\MDT 8456\MicrosoftDeploymentToolkit_x64.msi"
Get-AppLockerFileInformation -Path $MSI| Select-Object -ExpandProperty Publisher | Select-Object BinaryVersion
