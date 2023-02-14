# Configuration Item Script that checks for FipsMode setting

$FipsModeCompliantValue = "true"

$Logfile = "C:\Windows\Temp\CiscoAnyConnectProfile_Discovery.log"

# Delete any existing logfile if it exists
If (Test-Path $Logfile){Remove-Item $Logfile -Force -ErrorAction SilentlyContinue -Confirm:$false}

Function Write-Log{
	param (
    [Parameter(Mandatory = $true)]
    [string]$Message
   )

   $TimeGenerated = $(Get-Date -UFormat "%D %T")
   $Line = "$TimeGenerated : $Message"
   Add-Content -Value $Line -Path $LogFile -Encoding Ascii
}

# Check if Cisco AnyConnect Policy is available 
$AnyConnectLocalPolicyFile = "$Env:AllUsersProfile\Cisco\Cisco AnyConnect Secure Mobility Client\AnyConnectLocalPolicy.xml"

If (Test-Path $AnyConnectLocalPolicyFile){
    Write-Log "Cisco AnyConnect Policy found, continuing"

    # Read the value from the profile
    $xml = [Xml](Get-Content -Path $AnyConnectLocalPolicyFile)
    $FipsModeCurrentValue = $xml.AnyConnectLocalPolicy.FipsMode

    If ($FipsModeCurrentValue -eq $FipsModeCompliantValue){
        Write-Log "Fipsmode value is compliant, currently set to: $FipsModeCurrentValue"
        Return $True
    }
    Else{
        Write-Log "Fipsmode value is Not compliant, currently set to: $FipsModeCurrentValue"
        Return $False
    }

}
Else{
    Write-Log "Cisco AnyConnect Policy found Not found, do Nothing"    
    Return $True # Returning compliant anyway, no point in triggering a remediation for something that does not exist
}
