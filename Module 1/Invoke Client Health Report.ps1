# Where to store the collected data points
$HealthCheckPath = "\\cm01.corp.viamonstra.com\HealthCheck$"
$ts = $(get-date -f MMddyyyy)+$(get-date -f HHmmss)
$ReportFileName = "ConfigMgrClientHealthSummary_$ts.csv"

# Get the CSV files
$CSVFiles = Get-ChildItem -Path "$HealthCheckPath\Clients" -Filter "*.CSV"
Write-Output "Importing $($CSVFiles.count) CSV files. Sit tight, may take a while..."
Write-Output ""

# Export to a report
foreach ($CSVFile in $CSVFiles){
    (Import-CSV -Path $CSVFile.FullName) | Export-CSV -Path "$HealthCheckPath\Results\$ReportFileName" -NoTypeInformation -Append 
}