Enable-ComputerRestore -Drive C:\
$tasktrigger = new-scheduledtasktrigger -daily -At 8:00PM
$name = "newRestorePointDaily"
$taskaction = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -argument "-file C:\users\$env:UserName\newrestorepointdaily\createRestorePoint.ps1"
Register-Scheduledtask `
    -TaskName $name `
    -Action $taskaction `
    -Trigger $tasktrigger