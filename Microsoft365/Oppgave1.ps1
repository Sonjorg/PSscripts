#Kilder: docs.microsoft.com, Tor melling's 02-intro-powershell-m365.ps1, powershell kommandoene "get-help", "get-command" og "get-member"

Find-Module -Name AzureAD | Install-Module
Import-Module AzureAD
Connect-AzureAD
Find-Module -Name MSOnline | Install-Module
Import-Module MSOnline
Connect-MsolService


# Sjekk hvilke kommandoner en har tilgjengelig samt list ut brukere (demobrukere)
#Get-Command -Module MSOnline
#Get-Command -Module AzureAD
#Get-MsolUser
#Get-Help New-MsolUser -Examples

Function NewUser {
    $Givenname = Read-host -prompt 'Fornavn';
    $Surname = Read-host -prompt 'Etternavn';
    $DisplayName = Read-host -prompt 'Brukernavn';
    $UserPrincipalName = Read-host -prompt 'UserPrincipalName';
    $MailNickName = Read-host -prompt 'MailNickName (For eksempel Ola.Normann)';
    $Email = Read-host -prompt 'Epost-adresse';

    #Her en test om passordet er sterkt nok
    Do {
        [bool]$test;
        [string]$Password=Read-Host -Prompt 'Passord (Skriv ett komplisert passord, minst 15 karakterer og kan ikke inneholde brukerens navn)'
        $array = '~', '!', '@', '#', '$', '%', '^', '&', '(', ')', '-', '.+', '=', '}', '{', '\', '/', '|', ';', ',', ':', '<', '>', '?', '"', '*'
        #Kilde for test om inneholder spesial karakterer:
        #https://social.technet.microsoft.com/Forums/en-US/ea541503-1211-4caf-83b9-d290aa5a6cad/special-character-validation-in-a-string-using-powershell?forum=winserverpowershell
        #Her brukte jeg svært lang tid på testing og forsøkte med -contains og -match ved hjelp av forløkke og forEach uten hell, mens kilden over ga riktig resultat
        $array |
	    foreach-Object {
		    if ($Password.IndexOf($_) -ge 0) {
			    return $test = $false;
		    }
	    }
        #Kilde test for match på uppercase: https://itworldjd.wordpress.com/2014/07/23/powershell-how-to-test-if-a-string-contains-uppercase-or-lowercase/
        If ($Password.Length -lt 15 -or $Password.Contains($Givenname) -or $Password.Contains($Surname) -or -not ($Password -cmatch "[A-Z]") -or -not ($Password -cmatch "[a-z]")) {
            $test = $true;
        }
        If($test -eq $true) {
            Write-Warning "Passordet inneholder ikke spesialkarakterer, både store og små bokstaver, er ikke langt nok eller inneholder brukerens navn."
        }

    } While ($test -eq $true)

    $PasswordProfile=New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $PasswordProfile.Password=$Password
        #$PasswordProfile=New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
        #$PasswordProfile.Password=$user.Password
        New-AzureADUser `
            -GivenName $Givenname `
            -SurName $Surname `
            -DisplayName $DisplayName `
            -UserPrincipalName $UserPrincipalName `
            -MailNickName $MailNickName `
            -OtherMails $Email `
            -PasswordProfile $PasswordProfile `
            -AccountEnabled $true
}
Function NewMsOlGroup {
    Get-AzureADTenantDetail
    $ManagedBy = Read-host -prompt 'Admin';
    $TenantID = Read-host -prompt 'TenantID';
    $DisplayName = Read-host -prompt 'DisplayName';
    $Description = Read-host -prompt 'Beskrivelse';

    New-MsolGroup `
    -Description $Description `
    -Displayname $DisplayName `
    -ManagedBy $ManagedBy `
    -TenantId $TenantID `
}

Function AddGroupMember {
    $kommandoJa = (Read-host -prompt 'Trykk "J" For å se liste over grupper og brukere').toupper()
    If($kommandoJa -eq "J") {
        Write-output "Grupper"
        get-azureadgroup -all $true
        Write-output "Brukere"
        Get-AzureADUser -all $true
    }
    $MedlemsID = Read-host -prompt 'Medlems-ID';
    $GruppeID = Read-host -prompt 'Gruppe-ID';
    Add-MsolGroupMember -GroupMemberObjectId $MedlemsID -GroupObjectId $GruppeID
}
Function Read-Options {
    "Trykk U for å opprette ny bruker"#
    "Trykk G for å oprette ny gruppe"
    "Trykk A for å legge til en bruker i en gruppe"
}
Read-Options
#Valg for hvordan brukeren skal legges til
$kommando = (Read-host -prompt 'Kommando').toupper()
Switch ($kommando)
{
    U {NewUser}
    G {NewMsOlGroup}
    A {AddGroupMember}
    default {Read-Options}
}