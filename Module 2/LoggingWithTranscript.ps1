
$Logfile = "C:\Temp\LoggingDemoTranscript.log"

# Start logging
Start-transcript -path $LogFile

#Output base info
Write-Output ""
Write-Output "Line 1"
Write-Output "Line 2"
Write-Output "ComputerName is PC42"

# Stop logging
Start-transcript 