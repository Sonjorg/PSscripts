#This script most likely needs to be started in powershell as admin
Enable-ComputerRestore -Drive C:\
$tasktrigger = new-scheduledtasktrigger -Daily -At 8:00PM
$name = "newRestorePointDaily"

$taskaction = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -argument "-file C:\users\$env:UserName\newrestorepointdaily\createRestorePoint.ps1"
Register-Scheduledtask `
    -TaskName $name `
    -Action $taskaction `
    -Trigger $tasktrigger

$Settings = New-ScheduledTaskSettingsSet -WakeToRun
set-scheduledtask `
    -taskname $name `
    -settings $Settings