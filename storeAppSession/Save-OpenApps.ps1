$basePath = "$PSScriptRoot\data"
New-Item -ItemType Directory -Force -Path $basePath | Out-Null

$apps = Get-Process | Where-Object {
    $_.MainWindowHandle -ne 0 -and $_.Path
} | Select-Object Name, Path

$apps | ConvertTo-Json -Depth 2 | Set-Content "$basePath\open_apps.json"

Write-Host "Åpne apper lagret."
