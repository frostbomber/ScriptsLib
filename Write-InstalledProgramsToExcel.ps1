    $gd = "$($args[0])" + "progs" + (get-date).tostring('yyyyMMddHHmmss')
    $path = $args[0] #must be full path or this won't work 

    Write-Output "Name,Version,Publisher,InstallDate" | Out-File "$path\$gd.txt" 

    $aray = @()
    
    $reg = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine', "$($args[0])")
    $regkey = $reg.OpenSubKey("Software\Microsoft\Windows\CurrentVersion\Uninstall")
    $aray = $regkey.GetSubKeyNames()
    
     foreach ($a in $aray)
    {
        $akey = $regkey.OpenSubKey($a)
        if ($akey.GetValue("DisplayName"))
        {
            if ($akey.GetValue("Publisher") -and $akey.GetValue("Publisher").Contains(','))
            {
                $adjustedpub = $akey.GetValue("Publisher").Replace(',',"")
                "$($akey.GetValue("DisplayName")),$($akey.GetValue("DisplayVersion")),$adjustedpub,$($akey.GetValue("InstallDate"))" | Out-File "$path\$gd.txt" -Append
            }
            else
            {
                "$($akey.GetValue("DisplayName")),$($akey.GetValue("DisplayVersion")),$($akey.GetValue("Publisher")),$($akey.GetValue("InstallDate"))" | Out-File "$path\$gd.txt" -Append
            }
        }
        else
        {
            "$a,$($akey.GetValue("DisplayVersion")),$($akey.GetValue("Publisher")),$($akey.GetValue("InstallDate"))" | Out-File "$path\$gd.txt" -Append
        }
    }

    

    $excel = New-Object -com "Excel.Application"
    $excel.Visible = $false

    #opens text file in excel using comma as a delimiter
    $excel.Workbooks.__OpenText("$path\$gd.txt",437,1,1,1,$True,$False,$False,$True,$False,$False)

    #saves this workbook
    $excel.ActiveSheet.SaveAs("$path\$gd.xlsx", 51)

    #closes the workbook
    $excel.Workbooks.Close()

    #quits excel
    $excel.Quit()

    #really greasy way of handling excel, may need to change this later
    Stop-Process -processname EXCEL -Force
 