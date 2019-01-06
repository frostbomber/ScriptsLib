$plainStr = [string]$args[0]
$strarr = $plainStr.Split("`n")

foreach ($str in $strarr)
{
    Write-Host "$($args[1])$($str.Replace('\','\\'))$($args[2])"
}