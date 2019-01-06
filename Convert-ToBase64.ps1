function Out-FileForce {
PARAM($path)
PROCESS
{
    if(Test-Path $path)
    {
        Out-File -inputObject $_ -append -filepath $path
    }
    else
    {
        new-item -force -path $path -value $_ -type file | Out-Null
    }
}
}
$args1 = $args[1]
Get-ChildItem "$($args[0])" -Filter *.png | % { [convert]::ToBase64String((get-content $_.FullName -encoding byte)) | Out-FileForce "$args1\$($_.Name).base64" }

