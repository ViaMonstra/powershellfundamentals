(Get-Item C:\Windows\System32\Lsasrv.dll).VersionInfo.FileVersionRaw

(get-item "E:\Demo\Intune\Win32Apps\CMTrace\Source\CMTrace.exe").VersionInfo

Set-Location "E:\MDTBuildLab\Tools\x64"
Get-ChildItem .\Microsoft.BDD.Utility.dll | Select *

(Get-ChildItem .\Microsoft.BDD.Utility.dll | Select *).VersionInfo

(Get-ChildItem .\Microsoft.BDD.Utility.dll | Select *).VersionInfo.FileVersion  