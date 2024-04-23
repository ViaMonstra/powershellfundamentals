<#
.SYNOPSIS
  This script collects information on distribution points regarding branch cache and other important data points for DP health. 

.DESCRIPTION
  This script is a collaboration effort between Mars, TrueSec and 2Pint Software to create a solution that retrieves information on distirbution points for branch cache.
  This script is designed to work for a specific customer at this point however it can be generalized by removing or adding a couple of fields specific to site information. 
  The result of this script produces a CSV that is stored in a network share. There a consolidation script is executed to merge all of the CSV's together. The script uses a path variable 
  called "ExportPath" to export all of the needed infromation.
  
.LINK
  https://P2intSoftware.com

.NOTES
          FileName: CollectDPInfo.ps1
          Authors: Todd Anderson, Jordan Benzing, and Johan Arwidmark
          Contact: @2PintSoftware
          Created: 07-11-2019
          Modified: 04-04-2022

.PARAMETER EXPORTPATH
    The export path variable is required and determines WHERE the content will go. If you would like to remove the parameter it is recommended that you instead change mandatory to FALSE and set the default value of ExportPath
    instead. 

 .Example
  .\CollectDPInfo.PS1 -ExportPath "\\ServerName.DomainName.Com\DPInfo"

#>

[cmdletbinding()]
param(
    [Parameter(HelpMessage = "Enter the path you would like the CSV to be exported to.", Mandatory = $true)]
    [string]$ExportPath
)
begin { }
process {
    
    $ComputerName = ([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname

    # OS Version
    $OS = (Get-WmiObject win32_operatingsystem).caption

    # LEDBAT
    $LEDBATEnabled = Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\SMS\DP -Name LEDBATEnabled
    If ($LEDBATEnabled.LEDBATEnabled -eq 1){
        $LEDBATEnabledDP = "True"
    }
    Else{
        $LEDBATEnabledDP = "False"
    }
    $LEDBATHostHeader = C:\Windows\System32\inetsrv\appcmd.exe list config -section:system.webserver/httpProtocol | Select-String -Pattern 'name="LEDBAT" value="true"' -Quiet
    If ($LEDBATHostHeader -eq $True){
        $LEDBATHostHeaderEnabled = "True"
    }

    # Check for Updates
    $LastSecurityUpdate = Get-WmiObject win32_quickfixengineering | sort installedon -desc | Where-Object { $_.Description -eq "Security Update" } | Select -First 1
    $DateForLastSecurityUpdate = $LastSecurityUpdate.InstalledOn
    $LastSecurityUpdateKB = $LastSecurityUpdate.HotFixID
    $LastUpdate = Get-WmiObject win32_quickfixengineering | sort installedon -desc | Where-Object { $_.Description -eq "Update" } | Select -First 1
    $DateForLastUpdate = $LastUpdate.InstalledOn
    $LastUpdateKB = $LastUpdate.HotFixID


    # System Disk 
    $SystemDisk_Free = ((Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'").freespace / 1GB)
    $SystemDisk_Free = [math]::Round($SystemDisk_Free, 2)

    $SystemDisk_Total = ((Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'").size / 1GB)
    $SystemDisk_Total = [math]::Round($SystemDisk_Total, 2)
    $SystemDisk_Total = [decimal]$SystemDisk_Total


    # Content Library Disk 

    $ContentLibraryDriveLetter = Get-PSDrive | Where {$_.Root -match ":"} |% {if (Test-Path ($_.Root + "SCCMContentLib")){$_.Root}}
    $ContentLibraryDriveLetter = $ContentLibraryDriveLetter.TrimEnd('\')

    $ContentLibraryDisk_Free = ((Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='$ContentLibraryDriveLetter'").freespace / 1GB)
    $ContentLibraryDisk_Free = [math]::Round($ContentLibraryDisk_Free, 2)

    $ContentLibraryDisk_Total = ((Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='$ContentLibraryDriveLetter'").size / 1GB)
    $ContentLibraryDisk_Total = [math]::Round($ContentLibraryDisk_Total, 2)
    $ContentLibraryDisk_Total = [decimal]$ContentLibraryDisk_Total

    # BranchCache Generic Info

    $BC_BranchCacheServiceStatus = (Get-BCStatus).BranchCacheServiceStatus
    $BC_BranchCacheServiceStartType = (Get-BCStatus).BranchCacheServiceStartType
    $BC_ContentServerIsEnabled = (Get-BCContentServerConfiguration).contentserverisenabled
    $BC_MaxCacheSizeAsPercentageOfDiskVolume = (Get-BCHashCache).MaxCacheSizeAsPercentageOfDiskVolume
    $BC_MaxCacheSizeAsNumberOfBytes = ((Get-BCHashCache).MaxCacheSizeAsNumberOfBytes / 1GB) 
    $BC_MaxCacheSizeAsNumberOfBytes = [math]::Round($BC_MaxCacheSizeAsNumberOfBytes, 4)
    $BC_CurrentActiveCacheSize = ((Get-BCHashCache).CurrentActiveCacheSize / 1GB)
    $BC_CurrentActiveCacheSize = [math]::Round($BC_CurrentActiveCacheSize, 4)
    $BC_PublicationCacheFileDirectoryPath = (Get-BCHashCache).CacheFileDirectoryPath
    $BC_PublicationCachePDSFileSizeInMB = [math]::Round((Get-ChildItem "$BC_PublicationCacheFileDirectoryPath\PeerDistPubCatalog.pds").Length/1MB,2)
    $BC_PublicationCachePDSFileCreationDate = (Get-ChildItem "$BC_PublicationCacheFileDirectoryPath\PeerDistPubCatalog.pds").CreationTime
    $BC_PublicationCacheTempFileCount = (Get-ChildItem -Path $BC_PublicationCacheFileDirectoryPath -Filter *.tmp -Recurse | Measure-Object ).Count
    
    # Get BranchCache Server Secret Key
    $ServerSecret = [System.BitConverter]::ToString((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PeerDist\SecurityManager\Restricted\' -Name Seed).Seed).Replace("-","")

    # Get BranchCache Error 13 for thelast 7 days
    $Last7Days = (Get-Date).AddDays(-7)
    $Events = Get-WinEvent -FilterHashTable @{ LogName="*BranchCache*"; ID=13 } -ErrorAction SilentlyContinue | foreach {
        $_ | Add-Member -MemberType NoteProperty -Name name -Value $_.Properties[1].Value -PassThru;
    } 
    #$TotalCount = ($events | Measure-Object).count
    #Write-Host "Total BranchCache Error 13 events is: $TotalCount"
    $i = 0
    $EventsTimeList = $Events | Select TimeCreated
    foreach ($Event in $EventsTimeList){
        $LogTime = $Event.TimeCreated
        #Write-host $LogTime
        If ($LogTime -ge $Last7Days){
            #Write-host "Entry $LogTime is from the week, increase count by one"
            ++$i
        }
    }
    $BCError13CountLastWeek = $i

    # Get BranchCache Error 13 for thelast 2 days
    $Last2Days = (Get-Date).AddDays(-2)
    $i = 0
    $EventsTimeList = $Events | Select TimeCreated
    foreach ($Event in $EventsTimeList){
        $LogTime = $Event.TimeCreated
        #Write-host $LogTime
        If ($LogTime -ge $Last2Days){
            #Write-host "Entry $LogTime is from the week, increase count by one"
            ++$i
        }
    }
    $BCError13CountLast2Days = $i


    # Get IIS Log info
    $DefaultWebSite = Get-Website -Name "Default Web Site"
    $DefaultWebSiteLogPath = "$($DefaultWebSite.logFile.directory)\w3svc$($DefaultWebSite.id)".replace("%SystemDrive%",$env:SystemDrive)
    If ($DefaultWebSiteLogPath -eq "\w3svc"){
        $DefaultWebSiteLogPath = "NA"
        $DefaultWebSiteLogFilesSizeInMB = 0
        $DefaultWebSiteLogFilesCount = 0
    }
    Else{
        $DefaultWebSiteLogFilesSizeInMB = [math]::Round((Get-ChildItem $DefaultWebSiteLogPath -Recurse | measure Length -s).Sum/1MB,2)
        $DefaultWebSiteLogFilesCount = (Get-ChildItem -Path $DefaultWebSiteLogPath -Filter *.log -Recurse | Measure-Object ).Count
    }

    $CacheNodeService = Get-Website -Name "CacheNodeService*"
    $CacheNodeServiceLogPath = "$($CacheNodeService.logFile.directory)\w3svc$($CacheNodeService.id)".replace("%SystemDrive%",$env:SystemDrive)
    If ($CacheNodeServiceLogPath -eq "\w3svc"){
        $CacheNodeServiceLogPath = "NA"
        $CacheNodeServiceLogFilesSize = 0
        $CacheNodeServiceLogFilesCount = 0
    }
    Else{
        $CacheNodeServiceLogFilesSize = [math]::Round((Get-ChildItem "$CacheNodeServiceLogPath" -Recurse | measure Length -s).Sum/1MB,2)
        $CacheNodeServiceLogFilesCount = (Get-ChildItem -Path $CacheNodeServiceLogPath -Filter *.log -Recurse | Measure-Object ).Count
    }

    # Get Network Info
    $DefaultGty = ((Get-wmiObject Win32_networkAdapterConfiguration | ? { $_.IPEnabled }).DefaultIPGateway)
    $IPAddress = ((Get-wmiObject Win32_networkAdapterConfiguration | ? { $_.IPEnabled }).IPAddress)

    #Get Connection Type
    $WirelessConnected = $null
    $WiredConnected = $null
    $VPNConnected = $null

    # Detecting PowerShell version, and call the best cmdlets
    if ($PSVersionTable.PSVersion.Major -gt 2)
    {
        # PowerShell 3.0 and above supports Get-CimInstance, and PowerShell 6 and above does not support Get-WmiObject, so using Get-CimInstance.
        $WirelessAdapters =  Get-CimInstance -Namespace "root\WMI" -Class MSNdis_PhysicalMediumType -Filter 'NdisPhysicalMediumType = 9'
        $WiredAdapters =  Get-CimInstance -Namespace "root\WMI" -Class MSNdis_PhysicalMediumType -Filter "NdisPhysicalMediumType = 0 and NOT InstanceName like '%pangp%' and NOT InstanceName like '%cisco%' and NOT InstanceName like '%juniper%' and NOT InstanceName like '%vpn%' and NOT InstanceName like 'Hyper-V%' and NOT InstanceName like 'VMware%' and NOT InstanceName like 'VirtualBox Host-Only%'" 
        $ConnectedAdapters =  Get-CimInstance -Class win32_NetworkAdapter -Filter 'NetConnectionStatus = 2'
        $VPNAdapters =  Get-CimInstance -Class Win32_NetworkAdapterConfiguration -Filter "Description like '%pangp%' or Description like '%cisco%' or Description like '%juniper%' or Description like '%vpn%'" 
    }
    else
    {
        # Needed this script to work on PowerShell 2.0 (don't ask)
        $WirelessAdapters = Get-WmiObject -Namespace "root\WMI" -Class MSNdis_PhysicalMediumType -Filter 'NdisPhysicalMediumType = 9'
        $WiredAdapters = Get-WmiObject -Namespace "root\WMI" -Class MSNdis_PhysicalMediumType -Filter "NdisPhysicalMediumType = 0 and NOT InstanceName like '%pangp%' and NOT InstanceName like '%cisco%' and NOT InstanceName like '%juniper%' and NOT InstanceName like '%vpn%' and NOT InstanceName like 'Hyper-V%' and NOT InstanceName like 'VMware%' and NOT InstanceName like 'VirtualBox Host-Only%'"
        $ConnectedAdapters = Get-WmiObject -Class win32_NetworkAdapter -Filter 'NetConnectionStatus = 2'
        $VPNAdapters = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "Description like '%pangp%' or Description like '%cisco%' or Description like '%juniper%' or Description like '%vpn%'" 
    }


    Foreach($Adapter in $ConnectedAdapters) {
        If($WirelessAdapters.InstanceName -contains $Adapter.Name)
        {
            $WirelessConnected = $true
        }
    }

    Foreach($Adapter in $ConnectedAdapters) {
        If($WiredAdapters.InstanceName -contains $Adapter.Name)
        {
            $WiredConnected = $true
        }
    }

    Foreach($Adapter in $ConnectedAdapters) {
        If($VPNAdapters.Index -contains $Adapter.DeviceID)
        {
            $VPNConnected = $true
        }
    }

    If(($WirelessConnected -ne $true) -and ($WiredConnected -eq $true)){ $ConnectionType="WIRED"}
    If(($WirelessConnected -eq $true) -and ($WiredConnected -eq $true)){$ConnectionType="WIRED AND WIRELESS"}
    If(($WirelessConnected -eq $true) -and ($WiredConnected -ne $true)){$ConnectionType="WIRELESS"}
    If($VPNConnected -eq $true){$ConnectionType="VPN"}

    #RAM
    $RAM = ((Get-WMIObject win32_physicalmemory | Measure-Object -Property Capacity -Sum).sum) / 1GB

    #CPUs
    $CPUS = (Get-WMIObject win32_processor | Measure-Object -Property numberoflogicalprocessors -Sum).sum

    # Microsoft Connect Cache (MCC)
    $MCCEnabled = Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\SMS\DP -Name DOINCEnabled -ErrorAction SilentlyContinue
    If ($MCCEnabled){
        If ($MCCEnabled.DOINCEnabled -eq 1){
            $MCCEnabledDP = "True"

            $MCCServer = "localhost"
            $MCC = Invoke-RestMethod http://$($MCCServer):53000/summary
            Start-sleep -Seconds 5
            $MCC = Invoke-RestMethod http://$($MCCServer):53000/summary
        
            # Measure Active connections three times
            $MCC_AC1 = [Math]::Round($MCC.LastCacheNodeHealthPingRequest.TCPv4ConnectionsActive)
            Start-sleep -Seconds 10
            $MCC = Invoke-RestMethod http://$($MCCServer):53000/summary
            $MCC_AC2 = [Math]::Round($MCC.LastCacheNodeHealthPingRequest.TCPv4ConnectionsActive)
            Start-sleep -Seconds 10
            $MCC = Invoke-RestMethod http://$($MCCServer):53000/summary
            $MCC_AC3 = [Math]::Round($MCC.LastCacheNodeHealthPingRequest.TCPv4ConnectionsActive)

            $MCC_ActiveConnections = [math]::Round(($MCC_AC1+$MCC_AC2+$MCC_AC3)/3)

            $MCC_HitGB = [Math]::Round($MCC.LastCacheNodeHealthPingRequest.DoincCacheTotalHitBytes /1GB,2)
            $MCC_MissGB = [Math]::Round($MCC.LastCacheNodeHealthPingRequest.DoincCacheTotalMissBytes /1GB,2)
            If ($MCC_HitGB -eq 0){
                # Do nothing, can't divide by zero
                $MCC_CachePercent = 0
            }
            Else{
                $MCC_CachePercent = "{0:P2}" -f ($MCC_HitGB / ($MCC_MissGB + $MCC_HitGB))
            }
        
        }
        Else{
            $MCCEnabledDP = "False"
        }
    }

    # Validate the results
    If (!($MCC_ActiveConnections)){ $MCC_ActiveConnections = "NA"}
    If (!($MCC_HitGB)){ $MCC_HitGB = "NA"}
    If (!($MCC_MissGB)){ $MCC_MissGB = "NA"}
    If (!($MCC_CachePercent)){ $MCC_CachePercent = "NA"}
    If (!($MCCEnabledDP)){ $MCCEnabledDP = "False"}

# Use DP Computer Name as filename for the export
$ExportFilePath = "$($ExportPath)\$($env:computerName).CSV"


# Using New-Object since $HASH = [ordered]@ is not supported on older PowerShell versions
$HASH = New-Object System.Collections.Specialized.OrderedDictionary
$Hash.Add("COMPUTERNAME",$ComputerName)
$Hash.Add("DateForLastSecurityUpdate",$DateForLastSecurityUpdate)
$Hash.Add("LastSecurityUpdateKB",$LastSecurityUpdateKB)
$Hash.Add("DateForLastUpdate",$DateForLastUpdate)
$Hash.Add("LastUpdateKB",$LastUpdateKB)
$Hash.Add("LEDBATEnabledDP",$LEDBATEnabledDP)
$Hash.Add("LEDBATHostHeaderEnabled",$LEDBATHostHeaderEnabled)
$Hash.Add("BC_BranchCacheServiceStatus",$BC_BranchCacheServiceStatus)
$Hash.Add("BC_BranchCacheServiceStartType",$BC_BranchCacheServiceStartType)
$Hash.Add("BC_ContentServerIsEnabled",$BC_ContentServerIsEnabled)
$Hash.Add("BC_MaxPublicationCacheSizeAsPercentageOfDiskVolume",$BC_MaxCacheSizeAsPercentageOfDiskVolume)
$Hash.Add("BC_MaxPublicationCacheSize_GB", $BC_MaxCacheSizeAsNumberOfBytes)
$Hash.Add("BC_CurrentActiveCacheSize_GB",$BC_CurrentActiveCacheSize)
$Hash.Add("BC_PublicationCacheFileDirectoryPath",$BC_PublicationCacheFileDirectoryPath)
$Hash.Add("BC_PublicationCachePDSFileSizeInMB",$BC_PublicationCachePDSFileSizeInMB)
$Hash.Add("BC_PublicationCachePDSFileCreationDate",$BC_PublicationCachePDSFileCreationDate)
$Hash.Add("BC_PublicationCacheTempFileCount",$BC_PublicationCacheTempFileCount)
$Hash.Add("ServerSecret",$ServerSecret)
$Hash.Add("BCError13CountLastWeek",$BCError13CountLastWeek)
$Hash.Add("BCError13CountLast2Days",$BCError13CountLast2Days)
$Hash.Add("DefaultWebSiteLogPath",$DefaultWebSiteLogPath)
$Hash.Add("DefaultWebSiteLogFilesSizeInMB",$DefaultWebSiteLogFilesSizeInMB)
$Hash.Add("DefaultWebSiteLogFilesCount",$DefaultWebSiteLogFilesCount)
$Hash.Add("CacheNodeServiceLogPath",$CacheNodeServiceLogPath)
$Hash.Add("CacheNodeServiceLogFilesSize",$CacheNodeServiceLogFilesSize)
$Hash.Add("CacheNodeServiceLogFilesCount",$CacheNodeServiceLogFilesCount)
$Hash.Add("DefaultGty",$DefaultGty[0])
$Hash.Add("IPAddress",$IPAddress[0])
$Hash.Add("CONNECTIONTYPE",$CONNECTIONTYPE)
$Hash.Add("RAM_GB",$RAM)
$Hash.Add("OSVersion",$OS)
$Hash.Add("Number_Of_CPUS",$CPUS)
$Hash.Add("SystemDisk_Free_GB",$SystemDisk_Free)
$Hash.Add("SystemDisk_Total_GB",$SystemDisk_Total)
$Hash.Add("ContentLibraryDisk_Free_GB",$ContentLibraryDisk_Free)
$Hash.Add("ContentLibraryDisk_Total_GB",$ContentLibraryDisk_Total)
$Hash.Add("MCCEnabledDP",$MCCEnabledDP)
$Hash.Add("MCC_ActiveConnections",$MCC_ActiveConnections)
$Hash.Add("MCC_HitGB",$MCC_HitGB)
$Hash.Add("MCC_MissGB",$MCC_MissGB)
$Hash.Add("MCC_CachePercent",$MCC_CachePercent)

    $CSVObject = New-Object -TypeName psobject -Property $HASH
    $CSVObject | Export-Csv -Path $ExportFilePath -NoTypeInformation
}



