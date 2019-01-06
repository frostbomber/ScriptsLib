#$y should be $x.length
#$x should be an array of hostnames
$y = $args[0].length
for($z = 0; $z -lt $y; $z++){

    try{
        [System.Net.Dns]::GetHostAddresses($args[0][$z])|Foreach {$_.IPAddressToString} | Out-File -append $args[1]
        }
    catch 
    {
        echo "error!!!!"
    }
}