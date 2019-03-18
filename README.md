# snipeit-powershell
Snipe IT Asset automation with PowerShell Scripts


This will be to help people get started with Snipe IT and PowerShell.
From a domain controller as a GPO, Asset-Create.ps1 can be assigned to run on any number of domain pc's.


                        
                        
                        
                        
                        
                        
                        
                        
                        Merge all csv files into single csv

        Use mergeCSV.ps1 with look for csv's that are older than 1 day and archive them, into a folder named "archive" to merge all csv files into single csv to import. 

$CSVFolder = THE FOLDER WHERE THE INDIVIDUAL ASSET CSV'S ARE. 
$OutputFile = LOCATION OF MERGED CSV FILE

MergeCSV.ps1 with look for csv's that are older than 1 day and archive them, into a folder named "archive"

