# Where to store the collected data points
$ExportPath = "\\cm01.corp.viamonstra.com\HealthCheck$\Clients"

#
# Begin data points area
#

# Get the computer name
$ComputerName = $env:computername

# Get the date
$CollectedDate = Get-Date -Format "dd/MM/yyyy"

# Get the IP address
$IPAddress=((Get-wmiObject Win32_networkAdapterConfiguration | Where-Object{$_.IPEnabled}).IPAddress)

# Get the operating system version
$OSVersion = (Get-WmiObject win32_operatingsystem).version

# Get free disk space on C: in GB
$FreeDiskspaceGB = [math]::Round(((Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'").freespace/1GB),2)

# Get ConfigMgr Client Version
$CMVersion = (Get-WmiObject -NameSpace Root\CCM -Class Sms_Client).clientversion

# Get status of BranchCache service
$BranchCacheServiceStatus = (Get-BCStatus).BranchCacheServiceStatus

# Check C:\Windows\Temp folder
$TempFolder = "C:\Windows\Temp"
$TempFilesCount = ( Get-ChildItem $TempFolder | Measure-Object ).Count

# Get full .NET Framework version
$Version = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
Get-ItemProperty -name Release -EA 0 |
Where { $_.PSChildName -eq "Full"} |
Select PSChildName, Version, Release, @{
  name="Product"
  expression={
      switch -regex ($_.Release) {
        "378389" { [Version]"4.5" }
        "378675|378758" { [Version]"4.5.1" }
        "379893" { [Version]"4.5.2" }
        "393295|393297" { [Version]"4.6" }
        "394254|394271" { [Version]"4.6.1" }
        "394802|394806" { [Version]"4.6.2" }
        "460798|460805" { [Version]"4.7" }
        "461308|461310" { [Version]"4.7.1" }
        "461808|461814" { [Version]"4.7.2" }
        "528040|528049" { [Version]"4.8" }
        {$_ -gt 528049} { [Version]"Undocumented version (> 4.8), please update script" }
      }
    }
}
$NETFrameworkVersion = $Version.Product.ToString() 

#
# End data points area
#

# Export the result to a CSV file
$ExportPath = "$($ExportPath)\$($computername).CSV"
if(test-path -Path $EXPORTPATH) {
    remove-item -path $EXPORTPATH
    }

$Hash = New-Object System.Collections.Specialized.OrderedDictionary
$Hash.Add("ComputerName",$ComputerName)
$Hash.Add("CollectedDate",$CollectedDate)
$Hash.Add("IPAddress", $IPAddress[0]) # Only get the first one
$Hash.Add("OSVersion", $OSVersion)
$Hash.Add("FreeDiskspaceGB", $FreeDiskspaceGB)
$Hash.Add("BranchCacheServiceStatus", $BranchCacheServiceStatus)
$Hash.Add("CMVersion",$CMVersion)
$Hash.Add("TempFilesCount", $TempFilesCount)
$Hash.Add("NETFrameworkVersion", $FrameworkVersion)

$CSVObject = New-Object -TypeName psobject -Property $Hash
$CSVObject | Export-Csv -Path $ExportPath -NoTypeInformation