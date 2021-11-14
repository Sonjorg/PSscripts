#Skrur av pc-en om x timer
[float]$hours = read-host -prompt 'Avslutte pc om hvor mange timer?'
$name = read-host -prompt 'Gi oppgaven et navn'
$date = (get-date).addhours($hours)
$tasktrigger = new-scheduledtasktrigger -Once -At $date
$taskaction = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument '-NoProfile -WindowStyle Hidden -command "&{stop-computer}"'
Register-Scheduledtask `
    -TaskName $name `
    -Action $taskaction `
    -Trigger $tasktrigger
$tid = (get-date)
$log = "En task schedule opprettet klokken $tid satt til å avslutte pcen klokken $date ! =)"
add-content -path "\users\$env:UserName\avsluttpclog.log" -value $log
start-process -path "\users\$env:UserName\avsluttpclog.log"
