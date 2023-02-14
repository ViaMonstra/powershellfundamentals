# Run data collection script on all DPs
$HealthCheckPath  = "E:\HealthCheck"
$ExportPath = "C:\Windows\Temp"
$CollectScript = "Get-DPInfo.ps1"
$SiteServer = "cm01.corp.viamonstra.com"
$SiteCode = "PS1"

# Get all DPs that are not in maintenance mode
$Namespace = "root\SMS\Site_" + $SiteCode
$DPSearch = "select * from SMS_DistributionPointInfo where ResourceType = 'Windows NT Server' and MaintenanceMode = '0'" 
$DPs = (Get-WMIObject -ComputerName $SiteServer -Namespace $Namespace -Query $DPSearch | Sort-Object Name).Name

Set-Location "C:\"

# Remove existing CSV files
If (Test-Path "$HealthCheckPath\DPs"){Get-ChildItem -Path "$HealthCheckPath\DPs" -Filter *.csv | Remove-Item -Force}

# Copy the script to each DP
write-host "Starting to copy script to each DP..."
write-host ""
foreach ($DP in $DPs){
    write-host "Copying $CollectScript script to C:\Windows\Temp on $DP"
    Copy-Item "$HealthCheckPath\Scripts\$CollectScript" "\\$DP\C`$\Windows\Temp" -Force
}

# Run the script on each DP and save output locally
write-host "Running script on each DP, and save output locally..."
write-host ""
$LocalScriptPath = "C:\Windows\Temp\$CollectScript"
Invoke-Command -ScriptBlock {write-host $ENV:ComputerName;& $using:LocalScriptPath -ExportPath $using:ExportPath } -ComputerName $DPs 

# Make sure all scripts finished writing to the log
write-host "Waiting 10 seconds..."
write-host ""
Start-Sleep -Seconds 10

# Copy the result back to the Health Check folder
write-host "Copy the result back to the Health Check folder..."
write-host ""
foreach ($DP in $DPs){
    $DPShortName = $($DP.Split(".")[0])
    write-host "Copying the result from $DP"
    Copy-Item "\\$DP\C`$\Windows\Temp\$DPShortName.CSV" "$HealthCheckPath\DPs" -Force
}

# Combine the result in a summary report
write-host "Combining the result in a summary report..."

$ts = $(get-date -f MMddyyyy_hhmmss)
$SummaryReport = "$HealthCheckPath\results\DPHealthSummary_$ts.csv"
$CSVFiles = Get-ChildItem -Path "$HealthCheckPath\DPs" -Filter "*.CSV" 
$CSVFiles | Select-Object -ExpandProperty FullName | Import-Csv | Export-Csv "$SummaryReport" -NoTypeInformation
$NumberOfCSVFiles = ($CSVFiles | Measure-Object).Count

Write-Host "Summarized $NumberOfCSVFiles CSV files into $SummaryReport"