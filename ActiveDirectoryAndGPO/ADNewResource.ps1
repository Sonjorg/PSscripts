#Dette er et skript som utfører en rekke AD funksjoner for brukeren med to stykk switch setninger og funksjoner til disse.

#Dette er hoved-alternativer til brukeren
Function Read-Options {
    "Trykk O for å opprette ny bruker"#
    "Trykk S for å sette en bruker som lokal administrator"#Dette er fordelaktig for 'developers' med mye kompetanse ønsker å administrere egen maskin
    "Trykk C for å legge til en ny maskin"
    "Trykk M for å lage en mappe inni flere mapper"
}
#Funksjon som lager en ny active directory bruker
Function New-User {
    $Navn = Read-host -prompt 'Navn'; $Navn = $Navn.Replace('ø','o'); $Navn = $Navn.Replace('å','aa') #Kilde: Uke_9-Active_Directory-TIPSnTRICK-Mappe2.ps1
    $Fornavn = Read-host -prompt 'Fornavn'; $Fornavn = $Fornavn.Replace('ø','o'); $Fornavn = $Fornavn.Replace('å','aa')
    $Etternavn = Read-host -prompt 'Etternavn'; $Etternavn = $Etternavn.Replace('ø','o'); $Etternavn = $Etternavn.Replace('å','aa')
    $Brukernavn = Read-host -prompt 'Brukernavn (F.eks på formen "fornavn.etternavn")'
        #En test for å finne ut om en person allerede er registrert med samme brukernavn
        [bool] $Brukt = $false
        get-aduser -filter * | foreach-object { If ($_.SamAccountName -eq $Brukernavn)
            { $Brukt -eq $true } }
               While ($Brukt -eq $true) {
                       write-warning "Denne brukeren eksisterer fra før, vennligst oppgi et annet brukernavn."
                       $Brukernavn = Read-host -prompt "Brukernavn (F.eks på formen "fornavn.etternavn")"
                       $Brukt = $false
                       get-aduser -filter * | foreach-object { if ($_.SamAccountName -eq $Brukernavn) {$Brukt -eq $true}}
                }
    $Epost = Read-host -prompt 'Epost-adresse'
    $OU = Read-host -prompt 'Hvilken avdeling tilhører brukeren?'
    Do {  $Password = Read-Host -Prompt 'Passord (20 karakterer)' -AsSecureString
            If ($Password.Length -lt 20) { #Sjekker om passordet er langt nok
                Write-warning "Passordet er ikke langt nok, vennligst skriv et lengre."
            }
    } While ($Password.Length -lt 20)

        New-ADUser -Name "$Navn" `
        -GivenName "$Fornavn" `
        -Surname "$Etternavn" `
        -SamAccountName  "$Brukernavn" `
        -UserPrincipalName  "$Epost" `
        -Path "OU=$OU,DC=onpremit,DC=sec" `
        -AccountPassword "$Password" -Enabled $true
        #Kilde "New-ADUser": Uke_7-Active_Directory.ps1
    #lager brukerens delte mappe inn deres avdeling's share
    $OUmappe = Get-smbshare | where-object {$_.name -contains $OU.name}
        mkdir -path "\\onpremit.sec\$OUmappe\Ansatte\$Brukernavn"
        new-smbshare -name $Brukernavn -path "\\onpremit.sec\$OUmappe\Ansatte\$Brukernavn" -FullAccess $Brukernavn
    #Oppretter en mappe lokalt til brukeren (se ansattbackupscript)
    mkdir "\Users\$env:UserName\Desktop\$env:UserName" #Root-directory, vanligvis C:\
    #Lager en backup mappe til brukeren
        mkdir -path "\\onpremit.sec\$OUmappe\Ansatte\$Brukernavn\backup"
        new-smbshare -name $Brukernavn-backup -path "\\onpremit.sec\$OUmappe\Ansatte\$Brukernavn\backup" -FullAccess $Brukernavn
    #Gir denne brukeren leserettigheter til andre ansattes mapper innenfor deres avdeling
    $Ansattshares = Get-childitem -path \\onpremit.sec\$OUmappe\ | where-object {$_ -ne $Brukernavn}
    For ($i=0; $i -le $Ansattshares.count; $i++) {
        Grant-SmbShareAccess -Name $Ansattshares[$i].name -AccountName $Brukernavn -AccessRight Read
    }
    #Gir alle brukere innenfor denne avdeling leserettigheter til denne nylig opprettede bruker sin mappe
    $Brukere = Get-ADUser -Filter * -SearchBase “ou=$OU,dc=onpremit,dc=sec" | where-object {$_.SamAccountName -ne $Brukernavn}
    #Linjen over (Finne alle brukere i en OU): https://devblogs.microsoft.com/scripting/powertip-use-a-single-line-powershell-command-to-list-all-users-in-an-ou/
    $Brukere | For-eachobject | Grant-SmbShareAccess -Name $Brukernavn -AccountName $_ -AccessRight Read
    #Linjen over (Grant-SmbShareAccess): https://4sysops.com/archives/managing-windows-file-shares-with-powershell/
}
#Denne funksjonen finner alle shares med navn likt OU, dvs. alle shares som tilhører en avdeling
Function Get-avdshare {
$OU = Get-ADOrganizationalUnit -filter * # Å gjøre kommando til array, brukt 1/2: https://stackoverflow.com/questions/41591529/how-to-get-the-output-of-a-powershell-command-into-an-array
        $Shares = For ($i=0; $i -le $OU.count; $i++) {  # forløkke: https://www.business.com/articles/powershell-for-loop/
            Get-smbshare | where-object {$_.name -contains $OU[$i].name} } # Kommando til array 2/2
}
Function New-Folders {
    "Trykk (1) for å lage en delt mappe inni alle avdelinger"
    "Trykk (2) for å lage en delt mappe inni alle ansattes mapper"
    "Trykk (3) for å lage en delt mappe inni ansattes mapper for en bestemt avdeling"
    "Trykk (4) for å finne alle brukere til en bestemt avdeling"
    $Kommando2 = Read-host -Prompt 'Kommando'
    switch ($Kommando2)
    {
        1 { $mappe = Read-host -prompt 'Navnet på mappen du ønsker å lage'
                Get-avdshare
                    For ($i=0; $i -le $Shares.count; $i++) {
                        mkdir -path \\onpremit.sec\$Shares[$i].name\$mappe
                        New-smbshare -name $mappe -path \\onpremit.sec\$Shares[$i].name\$mappe
                    }
        }
        2 { $mappe = Read-host -prompt 'Navnet på mappen du ønsker å lage'
                Get-avdshare
                    For ($i=0; $i -le $OU.count; $i++) {
                        $Bruker = (Get-ADUser -Filter * -SearchBase “ou=$OU[$i].name,dc=onpremit,dc=sec")
                            $Brukermapper = Get-smbshare -filter * | Where-object {$_.name -eq $Bruker.SamAccountName}
                                New-smbshare -Name $mappe -path "\\onpremit.sec\$Shares[$i].name\$Brukermappe.name\$mappe"
                    } #Kilde alle brukere i en OU: https://devblogs.microsoft.com/scripting/powertip-use-a-single-line-powershell-command-to-list-all-users-in-an-ou/

            }
        3 { $mappe = Read-host -prompt 'Navnet på mappen du ønsker å lage'
            Do{
                $OU = Read-host -Prompt 'Hvilken avdelingsmappe ønsker du å legge inn mappe for deres ansatte?'
                #Tester om mappen finnes
                [bool] $finnes = $true
                get-smbshare | If ($_.name -ne $OU) {$finnes -eq $false
                    Write-warning "Mappen finnes ikke, vennligst velg en annen eller stav bedre."
                }
            } while ($OU -eq $false)
            $Brukere = Get-ADUser -Filter * -SearchBase “ou=$OU.name,dc=onpremit,dc=sec" # Alle brukere i en OU: https://devblogs.microsoft.com/scripting/powertip-use-a-single-line-powershell-command-to-list-all-users-in-an-ou/
            $Brukermappe = Get-smbshare | where-object {$_.name -contains $Brukere.SamAccountName}
            $OUmappe = Get-smbshare | where-object {$_.name -contains $OU.name}
            For ($i=0; $i -le $Brukere.count; $i++) {
                mkdir -path "\\onpremit.sec\$OUmappe.name\$Brukermappe.name\$mappe"
                New-smbshare -name $mappe -path "\\onpremit.sec\$Brukermappe.name\$mappe"
            }
        }
        4 {$avdeling = Read-host -Prompt 'Hva heter anvdelingen? F.eks "sales"'
        Get-ADOrganizationalUnit -filter * | where-object {$_.name -eq $avdeling} | foreach-object {get-aduser} # <-fungerer
        }
    }


}

#Denne switch setningen utfører hovedalternativene til brukeren
Read-Options
$kommando = (Read-host -prompt 'Kommando').toupper()
Switch ($kommando)
{
    O {New-User} #Ny AD bruker
    S {$Bruker = Read-host -Prompt 'Bruker som skal settes som lokal Administrator'
        Add-LocalGroupMember -group "Administrators" -member $Bruker}
    C {$PCnavn = Read-host -Prompt "PC-ens navn" #Legger til en ny maskin
        New-ADComputer -Name "$PCnavn" -SamAccountName "$PCnavn" -Path "OU=Workstations,DC=onpremit,DC=sec"
        } #Kilde:https://docs.microsoft.com/en-us/powershell/module/addsadministration/new-adcomputer?view=windowsserver2019-ps
    M {New-folders} #Ny mappe innenfor andre mapper
    default {Read-Options}
}

Read-Host -Prompt "Press Enter to exit"