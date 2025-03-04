# Set AOVPN Template name  
$VPNtemplateName = 'CHANGE ME'
$VPNMachineType = "LT"
$EnrollmentTestsForSuccess = 5
$TimeInBetweenTests = 60 # Seconds
$NumberOfTests = 30 # total test time: 60x30 = 1800 seconds
$EnrollmentSuccessful = $false # assume false

# Get Task Sequence variables
$TSEnv = New-Object -ComObject Microsoft.SMS.TSEnvironment
$MachineType = $TSEnv.Value("MachineType")
$SMSTSLogPath = $tsenv.value("_SMSTSLogPath")

# Set Log file
$Logfile = "$SMSTSLogPath\Wait-ForIntuneEnrollment.log"

# Remove log file if exist
If (Test-Path $Logfile) {Remove-Item -Path $Logfile -Force }

function Write-Log {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false)]
        $Message,
        [Parameter(Mandatory=$false)]
        $ErrorMessage,
        [Parameter(Mandatory=$false)]
        $Component = "Script",
        [Parameter(Mandatory=$false)]
        [int]$Type
    )
    <#
    Type: 1 = Normal, 2 = Warning (yellow), 3 = Error (red)
    #>
   $Time = Get-Date -Format "HH:mm:ss.ffffff"
   $Date = Get-Date -Format "MM-dd-yyyy"
   if ($ErrorMessage -ne $null) {$Type = 3}
   if ($Component -eq $null) {$Component = " "}
   if ($Type -eq $null) {$Type = 1}
   $LogMessage = "<![LOG[$Message $ErrorMessage" + "]LOG]!><time=`"$Time`" date=`"$Date`" component=`"$Component`" context=`"`" type=`"$Type`" thread=`"`" file=`"`">"
   $LogMessage.Replace("`0","") | Out-File -Append -Encoding UTF8 -FilePath $LogFile
}

# Starting the logging
Write-Log "Starting the enrollment tests"
Write-Log "Number of tests to pass to indicate a successful enrollment: $EnrollmentTestsForSuccess"
Write-Log "The tests will be evaulated for up to $NumberOfTests time with a delay of $TimeInBetweenTests seconds in between each test"
Write-Log "VPNtemplateName set to $VPNtemplateName"

# Take machine out of provisioning mode to speed up enrollment
Write-Log "Taking machine out of provisioning mode to speed up Intune enrollment via Co-Management"
Invoke-WmiMethod -Namespace root\CCM -Class SMS_Client -Name SetClientProvisioningMode -ArgumentList $false

# Check if MachineType task sequence variable is set
Write-Log "Checking if MachineType task sequence variable is set to: $VPNMachineType"

If ($MachineType -eq $VPNMachineType){

    Write-Log "MachineType task sequence variable set to: $VPNMachineType"
    Write-Log "Adding one more test to be successful"
    
    # Add one more test to be successful
    $EnrollmentTestsForSuccess++    
    Write-Log "Number of indivudual tests for each test round to pass to indicate a successful enrollment is now: $EnrollmentTestsForSuccess"
}
Else {
    Write-Log "This devices will not have a VPN certifcate, number of tests stays at $EnrollmentTestsForSuccess"
}

# Start the test rounds
$i = 1
do {
    
    Write-Log "Starting test round $i / $NumberOfTests"
    Write-Log "Each test round checks for this number of tests to pass to indicate a successful enrollment: $EnrollmentTestsForSuccess"

    # Set start number for successful tests
    $SucessfulEnrollmentTests = 0
    Write-Log "Setting start number for successful tests to: $SucessfulEnrollmentTests"

    If ($MachineType -eq $VPNMachineType){
    
        # Check to see if the machine has the VPN Device certificate installed.
        Write-Log "Checking to see if the machine has the VPN Device certificate installed"
        $VPNCert = Get-ChildItem 'Cert:\LocalMachine\My' | Where-Object{ $_.Extensions | Where-Object{ ($_.Oid.FriendlyName -eq 'Certificate Template Information') -and ($_.Format(0) -match $VPNtemplateName) }}

        If ($VPNCert){
            $SucessfulEnrollmentTests++
            Write-Log "VPN certificate found, number of successful tests are now: $SucessfulEnrollmentTests / $EnrollmentTestsForSuccess"
        }
        Else {
            Write-Log "VPN certificate Not found" -Type 2
        }
    }

    # Check for MDM certificate
    $Today = Get-Date
    $MDMCert = Get-ChildItem 'Cert:\LocalMachine\My\' | Where-object { $_.Issuer -EQ "CN=Microsoft Intune MDM Device CA" -and $_.Notafter -gt $today}
    If ($MDMCert){
        $SucessfulEnrollmentTests++
        Write-Log "MDM certificate found, number of successful tests are now: $SucessfulEnrollmentTests / $EnrollmentTestsForSuccess"
    }
    Else {
        Write-Log "MDM certificate Not found" -Type 2
    }

    # Get status from dsregcmd
    $DSRegOutput = [PSObject]::New()
    & dsregcmd.exe /status | Where-Object { $_ -match ' : ' } | ForEach-Object {
        $Item = $_.Trim() -split '\s:\s'
        $DSRegOutput | Add-Member -MemberType NoteProperty -Name $($Item[0] -replace '[:\s]', '') -Value $Item[1] -ErrorAction SilentlyContinue
    }

    # Test Entra ID join
    Write-Log "Starting Entra ID joined test"
    if ($DSRegOutput.AzureADJoined -eq 'YES') {
        # Device is Entra ID joined"
        $SucessfulEnrollmentTests++
        Write-Log "Device is Entra ID joined, number of successful tests are now: $SucessfulEnrollmentTests / $EnrollmentTestsForSuccess"
    } 
    else {
        Write-Log "Device is Not Entra ID joined" -Type 2
    }

    # Test MDM URL
    Write-Log "Testing MDM URL"
    if ($DSRegOutput.MDMUrl -like '*.microsoft.com*') {
        $SucessfulEnrollmentTests++
        Write-Log "Device has a Microsoft MDM URL, number of successful tests are now: $SucessfulEnrollmentTests / $EnrollmentTestsForSuccess"
    } 
    else {
        Write-Log "Device does not have a Microsoft MDM URL" -Type 2
    }

    # Test TenantId
    Write-Log "Testing TenantId"
    if ($DSRegOutput.TenantId) {
        $SucessfulEnrollmentTests++
        Write-Log "Device has a bound tenant id, number of successful tests are now: $SucessfulEnrollmentTests / $EnrollmentTestsForSuccess"
    } 
    else {
        Write-Log "Device does Not have a bound tenant id" -Type 2
    }

    # Test scheduled tasks
    $MDMScheduledTask = Get-ScheduledTask | Where-Object { $_.TaskPath -like '*Microsoft*Windows*EnterpriseMgmt\*' -and $_.TaskName -eq 'PushLaunch' }
    $EnrollmentGUID = $MDMScheduledTask | Select-Object -ExpandProperty TaskPath -Unique | Where-Object { $_ -like '*-*-*' } | Split-Path -Leaf
    if ($EnrollmentGUID) {
        $SucessfulEnrollmentTests++
        Write-Log "Device has an enrollment GUID, number of successful tests are now: $SucessfulEnrollmentTests / $EnrollmentTestsForSuccess"
    } 
    else {
        Write-Log "Device does not have an enrollment GUID or Intune scheduled sync task is missing" -Type 2
    }


    # Verify if all tests where successful
    If ($SucessfulEnrollmentTests -eq $EnrollmentTestsForSuccess){
        Write-Log "All tests are successful at test round $i / $NumberOfTests"
        $EnrollmentSuccessful = $true
        # Set successful message

        Break
    }
    Else {
        Write-Log "Test round round $i / $NumberOfTests was no successful, sleeping for $TimeInBetweenTests seconds"
        $EnrollmentSuccessful = $false
    }
    
    # Sleep in between tests
    Start-Sleep -Seconds $TimeInBetweenTests
$i++
}
while ($i -le $NumberOfTests)


If ($EnrollmentSuccessful -eq $true) {
    write-log "Test Successful, the EnrollmentSuccessful variable is $EnrollmentSuccessful"
    $TSEnv.Value("EnrollmentStatus") = "Success"
    $TSEnv.Value("EnrollmentInfo") = "Add in whatever details you want"
}
Else {
    write-log "Test Not Successful, the EnrollmentSuccessful variable is $EnrollmentSuccessful"
    $TSEnv.Value("EnrollmentStatus") = "Failure"
    $TSEnv.Value("EnrollmentInfo") = "Add in whatever details you want"
}




