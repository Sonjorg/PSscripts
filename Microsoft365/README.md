# Dette var en av mine besvarelser i faget "Skytjenester som arbeidsflate"
# ved NTNU, og tilhører filen oppgave2.ps1
## Sikker oppretting av MS-grupper for bedrift
### Problem:
Hvordan bør en IT-avdelingen i en bedrift gå fram for å opprette teamskanaler og
sharepointsitegrupper til de ansatte i ulike avdelinger både på en sikker og effektiv måte? Hvordan
sørge for ved bruk av powershell at disse ressursene er sikre men allikevel ikke så strenge at det går
ut over produktivitet?
### Løsning
Min løsning er et skript med noe brukerinput hvor brukeren kan velge mellom en rekke funksjoner
som hovedsakelig går på å opprette grupper i teams og sharepoint, på en måte som er både sikkert
og effektivt. Skriptet starter med connect-msolservice hvor administratoren må logge seg inn med
passord og tofaktor autentisering (hvis enabla) før han kan bruke noen av funksjonene til skriptet.
Skriptet avsluttes med utlogging som er viktig slik at ingen skal kunne benytte sesjonen om en
trussel aktør er inne i pc-en eller bygget. Først vil jeg gå gjennom hver av funksjonene og legge frem
hvordan de fungerer, og hvilke sikkerhetsfunksjoner jeg har valgt her. Deretter vil jeg gå gjennom
generelle sikkerhetstiltak som er nødvendig både i bedriften og for IT-avdelingen.
Skriptet starter med å gi alle brukere tilgang til for eksempel å opprette møter:
` Set-CsTeamsMeetingPolicy -Identity Global -AllowMeetNow $true `
#### Function nyavdelingteamskanal
Først skriver brukeren inn avdelingen han vil lage en teamskanal på. Deretter finner skriptet ut alle
brukere som tilhører denne avdelingen og skriver dem til en csv fil som er nødvendig for å opprette
en teamskanal. Deretter lager jeg et objekt med riktig format til å skrives til csv-fil for
kanalopprettelse. Etter at teamsrommet er opprettet, sletter jeg bruker-csv fila så ikke denne
kommer på avveie og brukes til å sende phishing til eposter eller hacking av kontoer. Sikkerhet til
teamskanal:
- **AllowSharedChannelCreation** er satt til **$false** slik at brukere ikke skal kunne lage delte
kanaler med både ansatte og personer fra utsiden.
- **AllowUserToParticipateInExternalSharedChannel** er satt til $true slik at brukere kan bli med i
andre åpne grupper.
- **AllowChannelSharingToExternalUser** er satt til $false slik at brukere ikke skal kunne legge til
andre brukere selv.
Function nyfelleskanal er omtrent det samme som over bare at AllowSharedChannelCreation er satt
til true slik at brukere kan opprette mer spesifiserte kanaler.
#### Function nyadminkanal
Denne oppretter en teamskanal til avdelingsledere og har større sikkerhet enn de andre for
eksempel skal andre ansatte vite hva som diskuteres her.
function nysharepointgruppe
Denne oppretter en sharepointgruppe til valgt avdeling med permissionlevel contribute. Det vil si at
alle har lov å laste opp, lese og slette dataer.
#### Function konfidensielledataer
Her opprettes det en sharepointgruppe med konfidensielle dataer som bare avdelingsledere har lov
å lese fra, men ikke slette. Denne løsningen er jeg litt i tvil om med tanke på hvilke dataer som bør
legges her. Her bør det lages en policy blant lederne om hva som skal lastes opp. For eksempel bør
kanskje ikke alle typer hemmelige dataer som brukersensitive opplysninger eller forretnings
sensitive dataer legges her, men heller ha et eget vault i azure ad for sensitive opplysninger.
#### Function nyoppsagtbruker
Denne funksjonen bør brukes helst før en ansatt har fått vite at han blir sagt opp fra bedriften. Her
mister den ansatte all tilgang til Microsoft miljøet slik at han ikke kan gjøre skade om han skulle bli
sint og lei seg.
I tillegg kan man taste kommandoen U som logger ut administratoren fra sesjonen.
## Sikkerhetstiltak
Det bør utføres regelmessig backup av alle dataer enten i on-prem eller i azure ad. Dette gis det
informasjon om her: [backup-disks](https://learn.microsoft.com/en-us/azure/backup/backup-managed-disks).
### Passord- og hemmelighetshåndtering
Passord bør aldri deles over epost da dette er svært usikkert i hvert fall om den ikke er kryptert.
Passord bør byttes etter en viss tid for eksempel 3 måneder. Dette er gjort i powershell. De ansatte
bør informeres om bruk av en passordmanager som for eksempel google passord eller lastpass.
### Kryptert epost
Jeg ville valgt å benytte planen Microsoft 365 E3/E5 som tilbyr kryptert epost og virus beskyttelse.
Dette er viktig da trussel aktører kan sende ansatte skadelige virus eller phishing eposter.
### Håndtering av data
Bedriften bør sette opp en backup og recovery løsning i tilfelle et ransomware.
### Tofaktor autentisering
Tofaktor autentisering er svært viktig i dag ettersom de kraftigste datamaskinene kan gjette hvilket
som helst passord på en time. Personlig har jeg erfart med en verdifull konto på Steam at den blir
forsøkt hacket i snitt 5-10 ganger uka. Det eneste som stopper dette er at jeg bruker tofaktor
autentisering. Tofaktor for microsft 365 kan gjøres ifølge denne linken hvor bruk av powershell står
nederst: https://learn.microsoft.com/en-us/azure/active-directory/authentication/howto-mfauserstates
Sikkerhetsseminarer med de ansatte og regelmessig firedrill
Nye ansatte bør får opplæring av bedriftens sikkerhetstiltak og på tilfeldige tidspunkter for eksempel
en gang i måneden bør det utføres en firedrill hvor noen forsøker å hacke bedriften på ulike måter.
For eksempel kan man lage phishing eposter og sende dem til halvparten av bedriften og se hvor
mange som går i fella, med seminar om hva som ble gjort feil i henhold til dette. I tillegg bør
seminarene informere om hvilke sikkerhetstiltak som gjelder, hva som er nytt og hva som skal gjøres
under ulike scenarioer.
## Forbedring og refleksjon av min besvarelse
Jeg kunne unngått å ha sitenavnet i klartekst, men heller hentet det inn fra et innloggingsobjekt på
noen måte. Jeg vil si at skriptet mitt er mer tilpasset en større bedrift da den er mer formet til
gjenbruk og har lesing til og fra fil for større brukergrupper. Derfor er skriptet i noen grad overflødig
men hensiktsmessig for større bedrifter og organisasjoner. Jeg føler jeg har fått fram mange av de
viktigste sikkerhetsfunksjonene (cmdlets og parametere) men jeg så at det fantes mange fler man
kunne bruke som er hensiktsmessig å lese mer om i den virkelige verden.
Jeg brukte mye tid på testing men alt er ikke testet 100% så hvis skriptet skulle bli brukt i et reelt
scenario måtte jeg gjort et grundigere arbeid. Mange av funksjonen er løst på ved å hente inn
brukere fra microsoft online miljøet, skrive dem til fil og så hente dem inn igjen for å opprette teams
kanaler. Dette var nødvendig for å opprette teamskanaler med alle brukere fra for eksempel en
avdeling. Etter dette er gjort sletter skriptet denne filen i tilfelle en hacker ved en senere anledning
finner disse dataene og sprer dem eller bruker dem på en ondsinnet måte. I verste fall kan det hende
at denne ikke blir slettet hvis noe går galt under utførelse eller hvis filen ligger i et område uten at
administratoren har rettigheter til å slette. Derfor er det viktig at skriptet blir kjørt med
administrator rettigheter for å utelukke dette scenarioet. Det er også svært viktig at spesielt alle
administratoren har tofaktor autentisering til microsoft tenanten, hvis ikke er det lett for en erfaren
passord knekker å komme seg inn på både microsoft miljøet og alle powershell cmdletser.
Kilder:
- Microsoft's dokumentasjon til M365 og powershell cmdlets
- https://www.sharepointdiary.com/2013/04/sharepoint-2010-permission-levels.html
- get-command og get-help kommandoene