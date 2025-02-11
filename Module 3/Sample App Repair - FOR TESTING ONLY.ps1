# For testing only, on a VM, when you have a checkpint

# Sample to repair only two apps
$InstalledApps = Get-AppxPackage

$IsFixed = $False
$AppNames = "Microsoft.Windows.ShellExperienceHost","Microsoft.Windows.Cortana"
Foreach ($App in $installedApps) {
                if ($appNames -Contains $App.Name) {
                $IsFixed = $true
                }
}

If ($IsFixed -eq $false) {
                $Sysapplist = dir "c:\Windows\SystemApps\"
                foreach ($appfolder in $sysapplist){
                                Add-AppXPackage -DisableDevelopmentMode -register "C:\Windows\SystemApps\$appfolder\AppxManifest.xml"}
}
else {Write-Host "All is Well regarding the Win 10 Start Menu!"}



# Sledge hammer approach sample
Get-AppxPackage -AllUsers Microsoft.Windows.ShellExperienceHost | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}