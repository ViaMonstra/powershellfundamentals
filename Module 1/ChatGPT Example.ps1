$searchTerm = "example text"
$root = "C:\example\directory"

Get-ChildItem -Path $root -Include *.* -Recurse | Select-String -Pattern $searchTerm -AllMatches |
    ForEach-Object {
        Write-Output "File: $($_.Path)`nLine: $($_.Line)`nMatch: $($_.Matches.Value)"
    }
