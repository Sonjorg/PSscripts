# Powershell scripts
## **Scripts that may be useful.**
**I recommend using my scripts in native powershell or PS7 and not in the vs code extenstion in case of bugs, and extra processing time.**
**Please contact me at sondrjor@stud.ntnu.no to report bugs or to ask questions.**
### **newRestorePointDaily.ps1**
Creates a new restorepoint daily.
##### How to use
- Add the folder in you home directory and run newRestorePointDaily.ps1 as administrator once.
- Can easily be changed to run at another time or weekly instead of daily
##### Good to know
- The user needs to be be able to run the script as administrator for it to work, otherwise it might work if you use
"powershell -noprofile -executionpolicy bypass -file "FilePath"" for all 3 files
- You might want to delete the restorepoints about twice a year as each point is 300MB(or more, you can change size in the settings);
"vssadmin delete shadows /For=C: /oldest" or /all in cmd as admin.
- To see all restorepoints you have, use "get-computerrestorepoint" in powershell as admin or "vssadmin list shadows" in cmd as admin.
- To remove the task go to powershell and type Unregister-ScheduledTask -taskname newRestorePointDaily

### **shutDownPcLater.ps1**
If you're in the middle of a long upload or other type of job, and then have to leave, this script shuts down your PC after a desired time. Creates a nice log file of when it will shut down.

### **Consumption.ps1**
This will filter your expenditures and show the sum of money spent on it. It is also very useful for finding specific transactions. Export/download your balance sheet (.csv) file from your bank and search for phrases associated with a business. It shows all entries with the selected phrase and the sum of money spent on it.
##### How to use
Run the script in powershell and a dialog will tell you what to do, or you can replace, and add to the phrases in $stringarray to search for all expenditures on the phrases' corresponding posts.
WARNING: Make sure the phrases are correct; use the script to search the correct names used in the file, i.e McDonalds is called 'MCD' in some places.

### **oneliners.ps1**
Find files you cant find, delete scheduled tasks, among other things.

### **Active Directory and group policy**
Scripts that are a good start for setting up and maintaining active directory, adding new users to it and enabling some group policy settings for security in the business. (Everything is written in norwegian).
