$LogPath = "C:\Windows\Temp\demo.log"

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