$HealthCheckPath = "\\cm01.corp.viamonstra.com\HealthCheck$"
$EventLogsPath = "C:\Windows\System32\winevt\Logs"
$TempEventLogsPath = "C:\Windows\Temp\EventLogs"
$EventLogsArchivePath = "C:\Windows\Temp"

# US DPs 
$DPs = @(
    "DP01"
    "DP02"
)

foreach ($DP in $DPs){
    $EventLogsArchive = "$EventLogsArchivePath\$($DP)_EventLogs.zip"
    Invoke-Command { param ($TempEventLogsPath);If (!(test-path $TempEventLogsPath)){New-Item -Path $TempEventLogsPath -ItemType Directory -Force } }  -ComputerName $DP -ArgumentList $TempEventLogsPath
    Invoke-Command { param ($TempEventLogsPath,$EventLogsPath);If (test-path $TempEventLogsPath){Copy-Item -path "$EventLogsPath\*" -Destination $TempEventLogsPath -Force } } -ComputerName $DP -ArgumentList $TempEventLogsPath,$EventLogsPath    
    Invoke-Command { param ($TempEventLogsPath,$EventLogsArchive);If (test-path $TempEventLogsPath){ Compress-Archive -Path $TempEventLogsPath -DestinationPath $EventLogsArchive -Force } } -ComputerName $DP -ArgumentList $TempEventLogsPath,$EventLogsArchive
    $EventLogsArchiveUNCPath = "\\$DP\$($EventLogsArchive.Replace("C:","C`$"))"
    Copy-Item -Path $EventLogsArchiveUNCPath -Destination "$HealthCheckPath\DPLogs"
}

