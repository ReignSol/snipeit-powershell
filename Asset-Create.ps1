<#
.SYNOPSIS
Collect stats from a windows PC and generate a csv file, then export the csv to a newtwork share.
.DESCRIPTION
This script will get the memory usage statistics OS configuration of any Server or Computer, generate a CSV file and export the csv to a network share.
.NOTES  
The script will execute the commands on machines sequentially using non-concurrent sessions.
The info will be exported to a csv format.
#>
#
$computers = $Env:Computername
#
$infoColl = @()
Foreach ($s in $computers)
{
	$CPUInfo = (gwmi win32_ComputerSystem).name #Get CPU Information
    $OSInfo = Get-WmiObject Win32_OperatingSystem -ComputerName $s #Get OS Information
	#Get Memory Information. The data will be shown in a table as MB, rounded to the nearest second decimal.
	$OSTotalVirtualMemory = [math]::round($OSInfo.TotalVirtualMemorySize / 1MB, 2)
	$OSTotalVisibleMemory = [math]::round(($OSInfo.TotalVisibleMemorySize / 1MB), 2)
	$PhysicalMemory = Get-WmiObject CIM_PhysicalMemory -ComputerName $s | Measure-Object -Property capacity -Sum | % { [Math]::Round(($_.sum / 1GB), 2) }
	$SN = (gwmi win32_bios).serialnumber 
	$AT = (gwmi win32_bios).serialnumber
	$ID = Get-CimInstance Win32_OperatingSystem | Select-Object  InstallDate | ForEach{ $_.InstallDate }
    $MN = (Get-WmiObject -Class:Win32_ComputerSystem).Model
    $status = "Ready to Deploy"
    $CG = "Windows Computers"
    $FN = (Get-WmiObject -Class:Win32_ComputerSystem).Model
    $user = whoami
    $MF = (gwmi win32_bios).manufacturer
    $FNSN = (gwmi win32_bios).serialnumber # FileName Serial Number
    $IP = (Test-Connection $CPUInfo -count 1).IPv4Address.IPAddressToString
    $DISKTOTAL = Get-CimInstance win32_logicaldisk | where caption -eq "C:" | foreach-object {write " $('{0:N2}' -f ($_.Size/1gb)) GB "}
    $DISKFREE = Get-CimInstance win32_logicaldisk | where caption -eq "C:" | foreach-object {write " $('{0:N2}' -f ($_.FreeSpace/1gb)) GB "}
    $MAC = (Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.ipenabled -EQ $true}).Macaddress | select-object -first 1
    $strName = $env:username
    $strFilter = "(&(objectCategory=User)(samAccountName=$strName))"
    $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
    $objSearcher.Filter = $strFilter
    $objPath = $objSearcher.FindOne()
    $objUser = $objPath.GetDirectoryEntry()
    $lastuser = ($objUser).cn | Select-Object


    Foreach ($CPU in $CPUInfo)
	{
		$infoObject = New-Object PSObject
		#The following add data to the infoObjects.	
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "Item Name" -value $CPUInfo
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "OS" -value $OSInfo.Caption
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "Total Physical Memory" -value $PhysicalMemory
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "Total Virtual Memory" -value $OSTotalVirtualMemory
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "Total Visable Memory" -value $OSTotalVisibleMemory
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "Serial Number" -value $SN
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "Asset Tag" -value $AT
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "OS Install Date" -value $ID
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "Model Number" -value $MN
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "Model Name" -value $MN
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "Category" -value $CG
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "Status" -value $status
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "Manufacturer" -value $MF
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "IP Address" -value $IP
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "Total Disk Space" -value $DISKTOTAL
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "Free Disk Space" -value $DISKFREE
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "MAC Address" -value $MAC
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "Last User" -value $lastuser
        


        $infoObject #Output to the screen for a visual feedback.
		$infoColl += $infoObject
	}
}
$infoColl | Export-Csv -path \\NETWORKSHARE\$FNSN.csv  -NoTypeInformation -Encoding UTF8 #Export the results in csv file.