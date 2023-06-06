$lines = [System.Io.File]::ReadLines('/path/to/file.txt')

$lines | Select-Object -Unique   # 6-12 minutes

$lines | Sort-Object -Unique    # 2-3 seconds