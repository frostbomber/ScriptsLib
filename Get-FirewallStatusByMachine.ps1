$ins = $args[0]
$outs = $args[1] + (get-date).tostring('yyyyMMddHHmmss') + ".txt"

foreach ($computer in $ins)
{ 
    try{
        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine",$computer) 2>> $outs

	    $firewallEnabled = $reg.OpenSubKey("System\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile").GetValue("EnableFirewall") 2>> $outs

	    "$computer : Firewall Enabled = $([bool]$firewallEnabled)" >> $outs
    }
    catch{
        "$computer : An error occurred. This probably means the firewall is enabled." >> $outs
    }
}