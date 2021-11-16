#This will filter your expenditure, download your expenditure .csv file from your bank
#How to use: replace, remove or add to the phrases underneath to search for all expenditure on the phrases' corresponding posts,
#(can also include only one entry)
#replace "filepath.csv" with the path of the file you downloaded

$stringarray = ".*mcdonalds*.", ".*tacobell*.", ".*pizzahut*.", ".*starbucks*.", ".*walmart*."
$filepath = "filepath.csv"
#$stringarray = ".*extra*.", ".*rema*.", ".*obs*.", ".*matkroken*.", ".*meny*."
import-csv "filepath.csv" | select-string $stringarray | export-csv C:\Users\$env:UserName\Desktop\spending.csv
$array = select-string -path C:\Users\$env:userName\Desktop\spending.csv -pattern '"-[0-9]*' -allmatches
[array]$array1 = select-string -path C:\Users\$env:userName\Desktop\spending.csv -pattern '"-[0-9]*' -allmatches | % { $_.Matches } | % { $_.Value }
#https://stackoverflow.com/questions/12609760/i-would-like-to-color-highlight-sections-of-a-pipeline-string-according-to-a-reg
$array1 = $array1 -replace '"',''
$array1 = $array1 -replace ' ',''
[int]$array1 = [convert]::ToInt32($array1, 10)
$sum = 0
$array1 | Foreach { $sum += $_}
remove-item -path "C:\Users\$env:userName\Desktop\spending.csv"
$array
Write-Host "Above you can see all the purchases made to the businesses with the chosen phrases, and underneath are the total costs: " -ForegroundColor magenta
$sum | write-output
