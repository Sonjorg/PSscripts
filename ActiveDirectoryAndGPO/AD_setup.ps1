#Dette skriptet setter opp active directory og shares
#Fra domenecontroller
New-ADOrganizationalUnit -Name "Regnskap" -Path "DC=onpremit,DC=sec"
New-ADOrganizationalUnit -Name "ITdrift" -Path "DC=onpremit,DC=sec"
New-ADOrganizationalUnit -Name "Developers" -Path "DC=onpremit,DC=sec"
New-ADOrganizationalUnit -Name "HR" -Path "DC=onpremit,DC=sec"
New-ADOrganizationalUnit -Name "Renhold" -Path "DC=onpremit,DC=sec"
New-ADOrganizationalUnit -Name "Workstations" -Description "Computers in fixed locations" -Path "DC=onpremit,DC=sec"
New-ADOrganizationalUnit -Name "Printere" -Path "DC=onpremit,DC=sec"
New-ADOrganizationalUnit -Name "Doerer" -Path "DC=onpremit,DC=sec"

#Lager shared mapper på en server foreløpig og dfsn namespace
Install-WindowsFeature -Name FS-DFS-Namespace,FS-DFS-Replication,RSAT-DFS-Mgmt-Con -IncludeManagementTools
Import-Module dfsn
$folders = ('C:\Installerfiles','C:\dfsroots\files','C:\shares\regnskap','C:\shares\itdrift','C:\shares\developers','C:\shares\HR','C:\shares\itdrift\ISOfiler','C:\shares\printere','C:\shares\doerer')
mkdir -path $folders
$folders | ForEach-Object {$sharename = (Get-Item $_).name; New-SMBShare -Name $shareName -Path $_ -FullAccess Everyone}

New-DfsnRoot -TargetPath \\tim-srv1\files -Path \\onpremit.sec\files -Type DomainV2
$folders | Where-Object {$_ -like "*shares*"} | ForEach-Object {$name = (Get-Item $_).name;
$DfsPath = (‘\\onpremit.sec\’ + $name); $targetPath = (‘\\srv1\’ + $name); New-DfsnFolderTarget -Path $dfsPath -TargetPath $targetPath
#Brukt all kode over fra mellings dokument: https://gitlab.com/undervisning/dcst1005-demo/-/blob/master/configure-dfs-namespace.ps1

#Finner alle shares som tilhører en avdeling
$OU = Get-ADOrganizationalUnit -filter * # Å gjøre kommando til array, brukt 1/2: https://stackoverflow.com/questions/41591529/how-to-get-the-output-of-a-powershell-command-into-an-array
$Shares = For ($i=0; $i -le $OU.count; $i++) {  # forløkke: https://www.business.com/articles/powershell-for-loop/
            Get-smbshare | where-object {$_.name -like $OU[$i].name} } # Kommando til array 2/2
            }
#Lager en mappe som heter "ansatte" inni alle avdelings-shares
For ($i=0; $i -le $Shares.count; $i++) {
    mkdir -path \\onpremit.sec\$Shares[$i].name\ansatte
    New-smbshare -name $mappe -path \\onpremit.sec\$Shares[$i].name\ansatte
}
#Installerer IIS på srv1
#Kilde: https://adamtheautomator.com/powershell-iis/
Install-Module -Name 'IISAdministration'
New-Item -ItemType Directory -Name 'onpremitnettside' -Path 'C:\'
New-Item -ItemType File -Name 'onpremiumit.html' -Path 'C:\onpremitnettside\'
New-IISSite -Name 'onpremitnettside' -PhysicalPath 'C:\\' -BindingInformation "*:8088:"

#Linker min egen GPO til alle avdelings OU-er
Get-GPO -Name "Sondres GP instillinger" |
 New-GPLink -Target "OU=Workstations,DC=onpremit,DC=sec"

 Get-GPO -Name "Sondres GP instillinger" |
New-GPLink -Target "OU=Regnskap,DC=sec,DC=core"

 Get-GPO -Name "Sondres GP instillinger" |
New-GPLink -Target "OU=HR,DC=sec,DC=core"

 Get-GPO -Name "Sondres GP instillinger" |
New-GPLink -Target "OU=Developers,DC=sec,DC=core"

Get-GPO -Name "Sondres GP instillinger" |
 New-GPLink -Target "OU=ITdrift,DC=sec,DC=core"

 Get-GPO -Name "Sondres GP instillinger" |
 New-GPLink -Target "OU=Renhold,DC=sec,DC=core"

#NB: All kode nedenfor er bare kopiert ifra https://gitlab.com/erikhje/dcsg1005/-/blob/master/group-policy/notes.md
choco install -y 7zip wget
wget https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/Windows%2010%20Version%2020H2%20and%20Windows%20Server%20Version%2020H2%20Security%20Baseline.zip
7z x '.\Windows 10 Version 20H2 and Windows Server Version 20H2 Security Baseline.zip'
cd '.\Windows-10-Windows Server-v20H2-Security-Baseline-FINAL\'
Get-ChildItem
cd Scripts
.\Baseline-ADImport.ps1
Get-GPO -All | Format-Table -Property displayname

# We need to OU distinguished name several times
$OU = "OU=Workstations,DC=onpremit,DC=sec"

# Get all currently linked to OU Workstations
Get-ADOrganizationalUnit $OU |
 Select-Object -ExpandProperty LinkedGroupPolicyObjects
# if you want to see the names of the GPOs
# from https://community.spiceworks.com/topic/2197327-powershell-script-to-get-gpo-linked-to-ou-and-its-child-ou
$LinkedGPOs = Get-ADOrganizationalUnit $OU |
 Select-object -ExpandProperty LinkedGroupPolicyObjects
$LinkedGPOGUIDs = $LinkedGPOs | ForEach-object{$_.Substring(4,36)}
$LinkedGPOGUIDs |
 ForEach-object {Get-GPO -Guid $_ | Select-object Displayname }

# link two new ones to OU Workstations
Get-GPO -Name "MSFT Windows 10 20H2 - Computer" |
 New-GPLink -Target $OU
Get-GPO -Name "MSFT Windows 10 20H2 - User" |
 New-GPLink -Target $OU

Read-Host -Prompt "Press Enter to exit"