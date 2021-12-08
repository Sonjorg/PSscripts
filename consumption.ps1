#This will filter your expenditure, export/download your expenditure .csv file from your bank
#It is recommended to run this in powershell and not in the vscode terminal in case of error and readability
#How to use: run the script in powershell as described in README.MD, 
#or you can replace the filepath, and add to the phrases in $stringarray to search for all expenditures on the phrases' corresponding posts,
#(can also include only one entry)
#replace "filepath.csv" with the path of the file you downloaded

$filepath = Read-host -prompt 'Please paste the full .csv filepath'
$filepath = $filepath -replace '"',''
Do {
    $item = Read-host -prompt 'Please type in a phrase you would like to search for'
    "`n"
    $another = (Read-host -Prompt "Another phrase? 'y' for yes / any other key for no").toupper()
    [array]$stringArray += $item;
} While ($another -eq 'Y')
# Alternatively use one of the string arrays underneath:
# $stringarray = ".*mcdonalds*.", ".*tacobell*.", ".*pizzahut*.", ".*starbucks*.", ".*walmart*."
# $stringarray = ".*extra*.", ".*rema*.", ".*obs*.", ".*matkroken*.", ".*meny*.", ".*spar*.", ".*kiwi*.", ".*mcd*."
$stringarray
import-csv $filepath | select-string $stringarray | export-csv C:\Users\$env:UserName\Desktop\spending.csv
$array = select-string -path C:\Users\$env:userName\Desktop\spending.csv -pattern '-[0-9]*' -allmatches
[array]$array1 = Import-Csv -path C:\Users\$env:userName\Desktop\spending.csv | select-string -pattern '-[0-9]*' -allmatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }
#source: https://stackoverflow.com/questions/12609760/i-would-like-to-color-highlight-sections-of-a-pipeline-string-according-to-a-reg
$array1 = $array1 -replace '"',''
$array1 = $array1 -replace ' ',''
[double]$array1
#[System.Int32[]]$array1 
#[convert]::ToInt32($array1, 10)
$sum = 0
$array1 | ForEach-Object { $sum += $_}
remove-item -path "C:\Users\$env:userName\Desktop\spending.csv"
$array
"`n"
Write-Host "Above you can see all the purchases made to the businesses with the chosen phrases, and underneath are the total costs: " -ForegroundColor magenta
Write-host "Total costs are: $sum" -ForegroundColor green
"`n"