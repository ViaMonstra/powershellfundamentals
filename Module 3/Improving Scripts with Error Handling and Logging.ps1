$LogPath = "C:\Windows\Temp\Demo.log"

# Delete any existing logfile if it exists
If (Test-Path $LogPath){Remove-Item $LogPath -Force -ErrorAction SilentlyContinue -Confirm:$false}

Function Write-Log{
	param (
    [Parameter(Mandatory = $true)]
    [string]$Message
    )

    $TimeGenerated = $(Get-Date -UFormat "%D %T")
    $Line = "$TimeGenerated : $Message"
    Add-Content -Value $Line -Path $LogPath -Encoding Ascii
}


# Create c:\temp\filelist.txt file with some data

$File = "C:\temp\demo.txt"

try {
        Get-Content $File -ErrorAction STOP
}
catch {
    Write-Warning "An Error Occured" 
}
finally {
    $Error.Clear()
}