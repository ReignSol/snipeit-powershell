$CSVFolder = '\\NETWORKSHARE\INV$\*.csv';
$OutputFile = '\\NETWORKSHARE\Merged CSV\IMPORT.csv';

$CSV= @();

Get-ChildItem -Path $CSVFolder -Filter *.csv | ForEach-Object { 
    $CSV += @(Import-Csv -Path $_)
}

$CSV | Export-Csv -Path $OutputFile -NoTypeInformation -Force;
get-childitem -Path "\\NETWORKSHARE\*.csv" | where-object {$_.LastWriteTime -lt (get-date).AddDays(-1)} | move-item -destination "\\NETWORKSHARE\Archive\" -force