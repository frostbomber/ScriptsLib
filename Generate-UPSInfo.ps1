# for use with APC UPS'
$UPSs = $args[0] #this should be an array of hostnames
$cmds = "1.3.6.1.4.1.318.1.1.1.1.1.1.0", "1.3.6.1.4.1.318.1.1.1.2.2.1.0", "1.3.6.1.4.1.318.1.1.1.2.2.2.0", "1.3.6.1.4.1.318.1.1.1.2.2.3.0", "1.3.6.1.4.1.318.1.1.1.2.2.4.0", "1.3.6.1.4.1.318.1.1.1.3.2.1.0", "1.3.6.1.4.1.318.1.1.1.3.2.4.0", "1.3.6.1.4.1.318.1.1.1.3.2.5.0", "1.3.6.1.4.1.318.1.1.1.4.2.1.0", "1.3.6.1.4.1.318.1.1.1.4.2.2.0", "1.3.6.1.4.1.318.1.1.1.4.2.3.0", "1.3.6.1.4.1.318.1.1.1.4.2.4.0", "1.3.6.1.4.1.318.1.1.1.7.2.3.0", "1.3.6.1.4.1.318.1.1.1.7.2.4.0"  
$file = $args[1] #this should be a file directory
$results = @()

Write-Output "Name,Type,Capacity,Temperature(Celcius),RuntimeRemaining(ticks)[dd:hh:mm],BatteryStatus,InputVolts(V),InputFreq(Hz),LastEvent,OutputVolts(V),OutputFreq(Hz),OutputLoad(%),OutputCurrent(A),LastSelfTestResult,LastSelfTestDate"| Out-File "$file.txt" 
foreach($u in $UPSs){
        foreach($c in $cmds)
        {
            $Runtime = "c:\usr\bin\snmpwalk.exe -v 1 -c ASCISNMP $u $c"
  
            $results += Invoke-Expression $Runtime
        }

        $results[4] = $results[4].Substring(52)
        $results[4] = $results[4].TrimStart()
        if($results[4] -eq "1"){$results[4] = "OK"}
        elseif($results[4] -like "2"){$results[4] = "Needs Replacement"}
        else{$results[4] = "Error Reading Status"}

        $results[7] = $results[7].Substring(52)
        $results[7] = $results[7].TrimStart()
        switch ($results[7])
        {
         "1" {$results[7] = "None"}
         "2" {$results[7] = "High Line Voltage"}
         "3" {$results[7] = "Brownout"}
         "4" {$results[7] = "Loss of Main Power"}
         "5" {$results[7] = "Small Temporary Power Drop"}
         "6" {$results[7] = "Large Temporary Power Drop"}
         "7" {$results[7] = "Small Spike"}
         "8" {$results[7] = "Large Spike"}
         "9" {$results[7] = "UPS Self Test"}
         "10" {$results[7] = "Excessive Input Voltage"}
         default {$results[7] = "Error Reading Event"}
        }


        Write-Output "$u,$($results[0].Substring(52)),$($results[1].Substring(53)),$($results[2].Substring(52)),$($results[3].Substring(54)),$($results[4]),$($results[5].Substring(52)),$($results[6].Substring(52)),$($results[7]),$($results[8].Substring(52)),$($results[9].substring(52)),$($results[10].Substring(52)),$($results[11].Substring(52)),$($results[12].Substring(52)),$($results[13].Substring(51))" | Out-File "$file.txt" -Append
        $results.Clear() #clear
        $results = @() #need to declare a new array after clear
} 

$excel = New-Object -com "Excel.Application"
$excel.Visible = $false

#opens text file in excel using comma as a delimiter
$excel.Workbooks.__OpenText("$file.txt",437,1,1,1,$True,$False,$False,$True,$False,$False)

#saves this workbook
$excel.ActiveSheet.SaveAs("$file.xlsx", 51)

#closes the workbook
$excel.Workbooks.Close()

#quits excel
$excel.Quit()

#really greasy way of handling excel, may need to change this later
Stop-Process -processname EXCEL -Force
