$basePath = "$PSScriptRoot\data"
New-Item -ItemType Directory -Force -Path $basePath | Out-Null

$shell = New-Object -ComObject Shell.Application

$folders = $shell.Windows() | Where-Object {
    $_.FullName -like "*explorer.exe"
} | ForEach-Object {
    $_.Document.Folder.Self.Path
}

$folders | Set-Content "$basePath\open_folders.txt"

Write-Host "Explorer-mapper lagret."
