#Shuts down your PC after x hours
[float]$hours = read-host -prompt 'When to shut down PC(hours from now)?'
$name = [System.IO.Path]::GetRandomFileName()
$date = (get-date).addhours($hours)
$tasktrigger = new-scheduledtasktrigger -Once -At $date
$Settings = New-ScheduledTaskSettingsSet -WakeToRun
$taskaction = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument '-NoProfile -WindowStyle Hidden -command "&{stop-computer}"'
Register-Scheduledtask `
    -settings $Settings `
    -TaskName $name `
    -Action $taskaction `
    -Trigger $tasktrigger
$tid = (get-date)
$log = "Task schedule created at $tid to shut down the PC at $date ! =)"
add-content -path "\users\$env:UserName\shutdownpclog.log" -value $log
start-process -path "\users\$env:UserName\shutdownpclog.log"
