#get list of all scheduled tasks
Get-ScheduledTask
#to disable it only:
Get-ScheduledTask | where {$_.taskname -eq "name"} | disable-scheduledtask
#to delete it:
Get-ScheduledTask | where {$_.taskname -eq "newrestorepointdaily2"} | Unregister-ScheduledTask