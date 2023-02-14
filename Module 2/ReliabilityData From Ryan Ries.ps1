# Looking at Windows software installations and uninstallations and other reliability data
# Ryan Ries, Jan 5 2012
#
# Usage: .\ReliabilityData.ps1 <argument>
# Valid arguments are "ShowAll", "ShowSystemCrashes", "ShowWhateverYourImaginationIsTheLimit", ...
# Arguments are not case sensitive.
 
param([parameter(Mandatory=$true)]
      [string]$Argument)
 
Function WMIDateStringToDateTime([String] $strWmiDate) 
{ 
    $strWmiDate.Trim() > $null
    $iYear   = [Int32]::Parse($strWmiDate.SubString( 0, 4)) 
    $iMonth  = [Int32]::Parse($strWmiDate.SubString( 4, 2)) 
    $iDay    = [Int32]::Parse($strWmiDate.SubString( 6, 2)) 
    $iHour   = [Int32]::Parse($strWmiDate.SubString( 8, 2)) 
    $iMinute = [Int32]::Parse($strWmiDate.SubString(10, 2)) 
    $iSecond = [Int32]::Parse($strWmiDate.SubString(12, 2)) 
    $iMicroseconds = [Int32]::Parse($strWmiDate.Substring(15, 6)) 
    $iMilliseconds = $iMicroseconds / 1000 
    $iUtcOffsetMinutes = [Int32]::Parse($strWmiDate.Substring(21, 4)) 
    if ( $iUtcOffsetMinutes -ne 0 ) 
    { 
        $dtkind = [DateTimeKind]::Local 
    } 
    else
    { 
        $dtkind = [DateTimeKind]::Utc 
    } 
    return New-Object -TypeName DateTime -ArgumentList $iYear, $iMonth, $iDay, $iHour, $iMinute, $iSecond, $iMilliseconds, $dtkind
} 
 
If($Argument -eq "ShowAll")
{
       $reliabilityData = Get-WmiObject Win32_ReliabilityRecords
       ForEach ($entry in $reliabilityData)
       {
              Write-Host "Computer Name: " $entry.ComputerName
              Write-Host "Event ID:      " $entry.EventIdentifier
              Write-Host "Record Number: " $entry.RecordNumber
              Write-Host "Date and Time: " $(WMIDateStringToDateTime($entry.TimeGenerated))
              Write-Host "Source:        " $entry.SourceName
              Write-Host "Product Name:  " $entry.ProductName
              Write-Host "User:          " $entry.User
              Write-Host "Message:       " $entry.Message
              Write-Host " "
       }
}
 
If($Argument -eq "ShowSystemCrashes")
{
       $reliabilityData = Get-WmiObject Win32_ReliabilityRecords
       ForEach ($entry in $reliabilityData)
       {
              If($entry.Message.StartsWith("The previous system shutdown") -And $entry.Message.EndsWith("was unexpected."))
              {
                     Write-Host "Computer Name: " $entry.ComputerName
                     Write-Host "Event ID:      " $entry.EventIdentifier
                     Write-Host "Record Number: " $entry.RecordNumber
                     Write-Host "Date and Time: " $(WMIDateStringToDateTime($entry.TimeGenerated))
                     Write-Host "Source:        " $entry.SourceName
                     Write-Host "Product Name:  " $entry.ProductName
                     Write-Host "User:          " $entry.User
                     Write-Host "Message:       " $entry.Message
                     Write-Host " "            
              }
       }
}
 
If($Argument -eq "ShowApplicationInstalls")
{
       $reliabilityData = Get-WmiObject Win32_ReliabilityRecords
       ForEach ($entry in $reliabilityData)
       {
              If($entry.Message.StartsWith("Windows Installer installed the product."))
              {
                     Write-Host "Computer Name: " $entry.ComputerName
                     Write-Host "Event ID:      " $entry.EventIdentifier
                     Write-Host "Record Number: " $entry.RecordNumber
                     Write-Host "Date and Time: " $(WMIDateStringToDateTime($entry.TimeGenerated))
                     Write-Host "Source:        " $entry.SourceName
                     Write-Host "Product Name:  " $entry.ProductName
                     Write-Host "User:          " $entry.User
                     Write-Host "Message:       " $entry.Message
                     Write-Host " "            
              }
       }
}
