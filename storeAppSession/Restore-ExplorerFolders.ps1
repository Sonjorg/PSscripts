$basePath = "$PSScriptRoot\data"
$folderFile = "$basePath\open_folders.txt"

if (-Not (Test-Path $folderFile)) {
    Write-Host "Fant ingen lagrede mapper."
    exit
}

Get-Content $folderFile | ForEach-Object {
    Start-Process explorer.exe $_
}

Write-Host "Explorer-mapper åpnet."
