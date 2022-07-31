#"/E" makes sure subfolders gets copied and "/XO" exludes older files"
#source robocopy: https://superuser.com/questions/671244/robocopy-to-copy-only-new-folders-and-files
#If you want to run a scriptfile instead, replace "-Argument..." with
# -Argument '-File C:\users\yourfile.ps1'

$tasktrigger = new-scheduledtasktrigger -AtStartup
$taskaction = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument '-NoProfile -WindowStyle Hidden `
    -command &{Robocopy "full path of source" "full path of destination" /E /XO}'
Register-Scheduledtask `
    -TaskName 'backup' `
    -Action $taskaction `
    -Trigger $tasktrigger

Read-Host -Prompt "Press Enter to exit"