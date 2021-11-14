#Creates a new restorepoint daily at 7PM
Enable-ComputerRestore -Drive C:\
$tasktrigger = new-scheduledtasktrigger -Daily -At 7:00PM
$name = [System.IO.Path]::GetRandomFileName()
$taskaction = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument '-NoProfile -WindowStyle Hidden -command "&{Checkpoint-Computer -Description "RestorePoint1" -RestorePointType "MODIFY_SETTINGS"}"'
Register-Scheduledtask `
    -TaskName $name `
    -Action $taskaction `
    -Trigger $tasktrigger