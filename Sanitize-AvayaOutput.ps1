$file = Get-Content $args[0]
$lines = "Extension,Port,Registered`r`n"

foreach ($line in $file)
{
    $linePre1 = ([System.Text.RegularExpressions.Regex]::Replace($line,"$([char]0x001b)",""))
    $linePre2 = ([System.Text.RegularExpressions.Regex]::Replace($linePre1,"$([char]0x0007)",""))
    $linePre3 = ([System.Text.RegularExpressions.Regex]::Replace($linePre2,'\[[0-9]*\;*[0-9]*[H|K|B|m]*',""))
    $linePre4 = ([System.Text.RegularExpressions.Regex]::Replace($linePre3,'7                                                                               		press CANCEL to quit --  press NEXT PAGE to continue87ESC-x=Cancel Esc-e=Submit Esc-p=Prev Pg Esc-n=Next Pg Esc-h=Help Esc-r=Refresh8.*',""))
    $linePre5 = ([System.Text.RegularExpressions.Regex]::Replace($linePre4,'IP STATION',""))
    $linePre6 = ([System.Text.RegularExpressions.Regex]::Replace($linePre5,'Ext             Port     Registered\?',""))
    $linePre7 = ([System.Text.RegularExpressions.Regex]::Replace($linePre6,'Command: list multimedia ip-unregistered7list multimedia ip-unregistered 8                                                                               7       Page   18UNREGISTERED IP TELEPHONES',""))
    $linePre7 = $linePre7.Trim()
    if (!([string]::IsNullOrEmpty($linePre7)))
    {
        $linePre8 = ([System.Text.RegularExpressions.Regex]::Replace($linePre7,'[ ]{1,}',","))
        if (!($linePre8 -match '.*\,S.*'))
        {
            $index = $linePre8.IndexOf('S')
            $linePre8 = $linePre8.Insert($index,',')
        }
        $lines += $linePre8
        $lines += "`r`n"
    }
}

$lines | Out-File $args[1]