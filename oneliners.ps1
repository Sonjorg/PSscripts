#find file:
Get-Childitem –Path C:\ -Include *filename* -Recurse
#find folder:
Get-ChildItem -path C:\ -recurse | Where-Object {$_.PSIsContainer -eq $true -and $_.Name -match "keyword"}
#find newly accessed file, (edit last number for number of hours or use adddays()):
Get-ChildItem -path C:\ -Include *filename* -recurse | Where-Object {$_.lastaccesstime -gt (get-date).addhours(-8)}
#Sort items by size:
get-childitem * | select name, length | sort { $_.length } -descending
#Clean disks
cleanmgr /sagerun:1 | out-Null
#scheduled tasks:
#get list of all scheduled tasks
Get-ScheduledTask
#to disable it only:
Get-ScheduledTask | where {$_.taskname -eq "name"} | disable-scheduledtask
#to delete it:
Get-ScheduledTask | where {$_.taskname -eq "name"} | Unregister-ScheduledTask

#tip: use get-help before a cmdlet to see arguments or "| get-member" after to get objects and methods