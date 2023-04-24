#find file:
Get-Childitem –path C:\ -Include *filename* -Recurse

#find folder:
Get-ChildItem -path C:\ -recurse | Where-Object {$_.PSIsContainer -eq $true -and $_.Name -match "keyword"}

#find newly accessed file, (edit last number for number of hours or use adddays()):
Get-ChildItem -path C:\ -Include *filename* -recurse | Where-Object {$_.lastaccesstime -gt (get-date).addhours(-8)}

#Sort items by size:
get-childitem * | select name, length | sort { $_.length } -descending

#Find log in attempts on your computer:
Get-WinEvent -LogName Security | where {$_.message -like "*account*"}

#Remove annoying digits and special characters from subtitle files
$(foreach($line in Get-Content .\subtitlefile.srt) {$line|foreach {$_ `
    -replace ':', '' `
    -replace '-->','' `
    -replace '\d','' `
    -replace ',',''}}) | out-file subtitlefile2.srt

#Remove everything after first word for each entry in a list, for example after pasting from wikipedia
$(foreach($line in Get-Content .\messylist.txt) {$line|foreach {$_ -replace '\s+.*', '' }}) | out-file cleanlist.txt

#Clean disks
cleanmgr /sagerun:1 | out-Null

#scheduled tasks:
#get list of all scheduled tasks
Get-ScheduledTask

#to disable it only:
Get-ScheduledTask | where {$_.taskname -eq "name"} | disable-scheduledtask

#to delete it:
Get-ScheduledTask | where {$_.taskname -eq "name"} | Unregister-ScheduledTask
