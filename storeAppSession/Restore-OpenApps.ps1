$basePath = "$PSScriptRoot\data"
$appFile = "$basePath\open_apps.json"

if (-Not (Test-Path $appFile)) {
    Write-Host "Fant ingen lagrede apper."
    exit
}

$apps = Get-Content $appFile | ConvertFrom-Json

foreach ($app in $apps) {
    try {
        Start-Process $app.Path
    } catch {
        Write-Host "Kunne ikke starte $($app.Name)"
    }
}

Write-Host "Apper startet."
