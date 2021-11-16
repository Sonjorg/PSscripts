$tasktrigger = new-scheduledtasktrigger -Daily -At 11AM
$taskaction = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument '-NoProfile -WindowStyle Hidden `
    -command &{Robocopy "full path of source" "full path of destination" /E /XO}'
    #"/E" makes sure subfolders gets copied and "/XO" exludes older files"
#source robocopy: https://superuser.com/questions/671244/robocopy-to-copy-only-new-folders-and-files

Register-Scheduledtask `
    -TaskName 'backup' `
    -Action $taskaction `
    -Trigger $tasktrigger
