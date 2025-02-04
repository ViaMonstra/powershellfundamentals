
$Logfile = "C:\Temp\LoggingDemo.log"

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

Write-Log "Demo for class"

Write-Log "Write more"



$SetupFile = "msiexec.exe"
$Arguments = "/i MyMSI.msi /v"

# Install my MSI
$Result = Start-Process -FilePath $SetupFile -ArgumentList $Arguments -NoNewWindow -Wait -Passthru

# error handling
if ($Result.ExitCode -eq 0) {
	Write-Log -Message  "MSI Installed successful"
} else {
	return Write-Log "An unknown error occurred."
}
