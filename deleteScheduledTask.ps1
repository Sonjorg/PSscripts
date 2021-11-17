#to disable it only:
Get-ScheduledTask | where {$_.taskname -eq "name"} | disable-scheduledtask
#to delete it:
Get-ScheduledTask | where {$_.taskname -eq "newrestorepointdaily"} | Unregister-ScheduledTask