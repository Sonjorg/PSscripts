#$cred = get-credential #åpner et innloggingsvindu for tilkobling
Connect-MsolService
Connect-SPOService -url https://sondremann-admin.sharepoint.com/ 
Connect-MicrosoftTeams

#Setter generelle sikkerhetsfunksjoner
Set-MsolPasswordPolicy -DomainName sondremann.onmicrosoft.com -NotificationDays 30 -ValidityPeriod 90
Set-CsTeamsCallingPolicy -Identity Global -AllowPrivateCalling $true -AllowCallForwardingToUser $true -AllowCloudRecordingForCalls $true
Set-CsTeamsMeetingPolicy -Identity Global -AllowMeetNow $true -AllowAnonymousUsersToJoinMeeting $false -AllowCloudRecording $true -AllowPowerPointSharing $true
-AllowChannelMeetingScheduling $true -AllowRecordingStorageOutsideRegion $false
Function nyavdelingteamskanal {
     #Finner msonline avdelinger for å enkelt legge dem til teams og sharepoint
     get-msolgroup
     $search = Read-Host -Prompt 'Skriv inn avdeling'
     get-msoluser -department $search | export-csv -FilePath "\Users\$env:UserName\users$search.csv"
     $csv = new-object PSObject
     $csv | add-member NoteProperty Teamnavn $search
     $csv | add-member NoteProperty Eksisterende-gruppe-ID ""
     $csv | add-member NoteProperty Synlighet "Privat"
     $csv | add-member NoteProperty Gruppemal-ID "com.microsoft.teams.template.$search"
     $csv | export-csv -path "\Users\$env:UserName\teams.csv"
     $nykanal = New-CsBatchTeamsDeployment -TeamsFilePath "\Users\$env:UserName\teams.csv" -UsersFilePath "\Users\$env:UserName\users.csv" -DisplayName $search
     $userpolicy = New-CsTeamsChannelsPolicy -AllowSharedChannelCreation $false -AllowUserToParticipateInExternalSharedChannel $true -AllowChannelSharingToExternalUser $false
     $nykanal | Set-CsTeamsChannelsPolicy $userpolicy
     rm "\Users\$env:UserName\users$search.csv"
}

Function nyfellesteamskanal {
     #Finner msonline avdelinger for å enkelt legge dem til teams og sharepoint
     $navn = Read-Host -Prompt 'Skriv inn navn'
     get-msoluser | export-csv -FilePath "\Users\$env:UserName\users$navn.csv"
     #lager et objekt med riktig format til å skrives til csv-fil til kanalopprettelse
     $csv = new-object PSObject
     $csv | add-member NoteProperty Teamnavn $navn
     $csv | add-member NoteProperty Eksisterende-gruppe-ID ""
     $csv | add-member NoteProperty Synlighet "Privat"
     $csv | add-member NoteProperty Gruppemal-ID "com.microsoft.teams.template.$navn"
     $csv | export-csv -path "\Users\$env:UserName\teams.csv"
     $nykanal = New-CsBatchTeamsDeployment -TeamsFilePath "\Users\$env:UserName\teams.csv" -UsersFilePath "\Users\$env:UserName\users.csv" -DisplayName $search
     $userpolicy = New-CsTeamsChannelsPolicy -AllowSharedChannelCreation $true -AllowUserToParticipateInExternalSharedChannel $true -AllowChannelSharingToExternalUser $false
     $nykanal | Set-CsTeamsChannelsPolicy $userpolicy
     rm "\Users\$env:UserName\users$navn.csv"
}
Function nyadminkanal {
     #lager en admins kanal med admins for avdelingers kanaler som har lov å 
     #opprette avdelinger men ikke lov å dele innhold ut fra disse
     Get-MsolUser
     get-msoluser -Title "avdelingsleder" | export-csv -FilePath "\Users\$env:UserName\avdelingsledere.csv"
     #lager et objekt med riktig format til å skrives til csv-fil til kanalopprettelse
     $csv = new-object PSObject
     $csv | add-member NoteProperty Teamnavn "avdelingsledere"
     $csv | add-member NoteProperty Eksisterende-gruppe-ID ""
     $csv | add-member NoteProperty Synlighet "Privat"
     $csv | add-member NoteProperty Gruppemal-ID "com.microsoft.teams.template.avdelingsledere"
     $csv | export-csv -path "\Users\$env:UserName\teams.csv"
     $administratorkanal = New-CsBatchTeamsDeployment -TeamsFilePath $teams -UsersFilePath $brukere -DisplayName $search
     $adminkanalpolicy = New-CsTeamsChannelsPolicy -AllowPrivateChannelCreation $true -AllowSharedChannelCreation $false
     -AllowUserToParticipateInExternalSharedChannel $true -AllowChannelSharingToExternalUser $false
     $administratorkanal | Set-CsTeamsChannelsPolicy -identity $adminkanalpolicy
     rm "\Users\$env:UserName\avdelingsledere.csv"
}

function nysharepointgruppe {
     $search = Read-Host -Prompt 'Skriv inn avdeling'
     get-msoluser -department $search | export-csv -FilePath "\Users\$env:UserName\users$search-2.csv"
     New-SPOSiteGroup -Group $search -Site https://sondremann-admin.sharepoint.com/ -permissionlevels contribute
     [string]$brukere = Read-Host -Prompt 'sti til brukerfil'
     $brukere2 = Get-Content -Path $Path | select-object -LoginName
     for (bruker in $brukere2) {
          Add-SPOUser -LoginName $bruker -Group $gruppenavn -site https://sondremann-admin.sharepoint.com/
     }
     rm "\Users\$env:UserName\users$search-2.csv"
}
function konfidensielledataer {
     get-msoluser -title "avdelingsleder" | export-csv -FilePath "\Users\$env:UserName\avdelingsledere.csv"
     New-SPOSiteGroup -Group sikredata -Site https://sondremann-admin.sharepoint.com/ -permissionlevels Read
     $brukere = Get-Content -Path "\Users\$env:UserName\avdelingsledere.csv" | select-object -LoginName
     for (bruker in $brukere) {
          Add-SPOUser -LoginName $bruker -Group sikredata -site https://sondremann-admin.sharepoint.com/
     }
     rm "\Users\$env:UserName\avdelingsledere.csv"
}
#Fjerner rettigheter til en oppsagt ansatt
Function nyoppsagtbruker {
     Get-MsolUser
     [string]$sparket = Read-Host -Prompt 'Sparket bruker (objectid)'
     Remove-MsolUser -ObjectId $sparket2
}
Function Read-Options {
     "Trykk A for å opprette teamskanal for en avdeling"
     "Trykk F for å opprette teams kanal til alle brukere"
     "S for å opprette sharepointgruppe til en avdeling"
     "S for å opprette sharepointgruppe med konfidensielle dataer"
     "O for å si opp en bruker"
     "NB: Husk å logge med U når du er ferdig"
 }
 Read-Options
 #Valg for hvordan brukeren skal legges til
 $kommando = (Read-host -prompt 'Kommando').toupper()
 Switch ($kommando)
 {
     A {nyavdelingteamskanal}
     F {nyfellesteamskanal}
     N {nyadminkanal}
     S {nysharepointgruppe}
     K {konfidensielledataer}
     O {nyoppsagtbruker}
     U {disconnect-MsolService
          disconnect-SPOService
          disconnect-MicrosoftTeams}
     default {Read-Options}
 }

