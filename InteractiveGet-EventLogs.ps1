$this = [char](Read-Host "Do you want to view logs for this computer? Y\N")
if ((($this -eq 'Y') -or ($this -eq 'y'))){
    $target = Get-Content env:computername
}
else{
    $target = Read-Host "Enter the name of the computer you want to get logs for."
}
$logname = Read-Host "Provide the Logname to lessen your results"
$reference = [DateTime]$(Read-Host "Provide the base DateTime you want to find Event Logs for.") 
$delta = 0 + $(Read-Host "Plus-and-minus how many minutes?")
$uwannalog = [char](Read-Host "Write to log file? Y/N")


if (($uwannalog -eq 'Y') -or ($uwannalog -eq 'y')){
    $dt = Get-Date
    echo "`n Log will be located in [current directory]\.-(DayYearHourMinute).txt"
    $path = ".\" + $dt.Day + $dt.Year + $dt.Hour + $dt.Minute + ".txt"
    $trimpath = $path.Replace(':' , '_')
    $trimpath = $trimpath.Replace('\' , '-')
    Get-WinEvent -ComputerName $target -FilterHashtable @{Logname = $logname; StartTime = $($reference.AddMinutes(-1 * $delta)); EndTime  = $($reference.AddMinutes($delta))} | Out-File $trimpath
}
else{
    Get-WinEvent -ComputerName $target -FilterHashtable @{Logname = $logname; StartTime = $($reference.AddMinutes(-1 * $delta)); EndTime  = $($reference.AddMinutes($delta))}
}