
# Call netsh to carry out a match against the status
$ShowStatusAllCommand = { netsh branchcache show status all }
$ShowStatusAll = Invoke-Command -ScriptBlock $ShowStatusAllCommand
$ShowStatusAllMsg = $ShowStatusAll | Out-String

if(@($ShowStatusAll | Select-String -SimpleMatch -Pattern "Error Executing Action Display Firewall Rule Group Status:")[0].ToString() -match "Could not query Windows Firewall configuration"){

    $Compliance = "Firewall Non-Compliant"
    Write-Log "Firewall not setup correctly " 
    Write-Log "Firewall Check Returned - $Compliance"
    Return $Compliance
}
else{
    $Compliance = "Compliant"
}


$BCPort = 1337
$ShowHttpUrl = netsh http show url
$Result = $ShowHttpUrl | Select-String -SimpleMatch -Pattern "http://+:$BCPort/116B50EB-ECE2-41ac-8429-9F9E963361B7/"
