#Shuts down your PC after x hours
[float]$hours = read-host -prompt 'When to shut down PC(hours from now)?'
$name = [System.IO.Path]::GetRandomFileName()
$time2 = (get-date).addhours($hours)
$tasktrigger = new-scheduledtasktrigger -Once -At $time2
$taskaction = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument '-NoProfile -WindowStyle Hidden -command "&{stop-computer}"'
Register-Scheduledtask `
    -TaskName $name `
    -Action $taskaction `
    -Trigger $tasktrigger

$Settings = New-ScheduledTaskSettingsSet -WakeToRun
set-scheduledtask `
    -taskname $name `
    -settings $Settings

$time = (get-date)
$log = "Task schedule created at $time to shut down the PC at $time2 ! =)"
add-content -path "\users\$env:UserName\shutdownpclog.log" -value $log
start-process -path "\users\$env:UserName\shutdownpclog.log"

Read-Host -Prompt "Press Enter to exit"