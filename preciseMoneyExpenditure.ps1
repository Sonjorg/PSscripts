#edit the string array to what you want to search for (can also include only one entry)
#This will filter your expenditure, download your expenditure .csv file from your bank
#How to use: replace, remove or add to the phrases underneath to see all expenditure on the posts you want to know how much you spent on,

$stringarray = ".*mcdonalds*.", ".*tacobell*.", ".*pizzahut*.", ".*starbucks*.", ".*walmart*."
#$stringarray = ".*extra*.", ".*rema*.", ".*obs*.", ".*matkroken*.", ".*meny*."
import-csv C:\Users\sonde\Desktop\OversiktKonti-01.09.2021-16.11.2021.csv | select-string $stringarray | export-csv C:\Users\$env:UserName\Desktop\spending.csv
$array = select-string -path C:\Users\$env:userName\Desktop\spending2.csv -pattern '"-[0-9]*' -allmatches
[array]$array1 = select-string -path C:\Users\$env:userName\Desktop\spending.csv -pattern '"-[0-9]*' -allmatches | % { $_.Matches } | % { $_.Value }
#https://stackoverflow.com/questions/12609760/i-would-like-to-color-highlight-sections-of-a-pipeline-string-according-to-a-reg
$array1 = $array1 -replace '"',''
$array1 = $array1 -replace ' ',''
[int]$array1 = [convert]::ToInt32($array1, 10)
$sum = 0
$array1 | Foreach { $sum += $_}
remove-item -path "C:\Users\$env:userName\Desktop\spending.csv"
$array
Write-Host "Above you can see all purchases made to the outposts with the chosen phrases, and underneath is the total costs: " -ForegroundColor magenta
$sum | write-output