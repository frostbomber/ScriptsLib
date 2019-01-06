#############################################################################################################################################################################
#  Get-LargeFiles 
# 
#  Description: Generates a report of all files over a specified size threshold on every workstation on the domain
#
#  Usage: .\get-largefiles.ps1 threshold
#
#  Dependencies: $args[1] must exist
#+               Running User must have read AND write permissions to ^^^^
#+               $args[2] must exist
#+               Running User must have permissions to access Active Directory info
#+               Running User must have permission to RPC all workstations on the domain (domain admins)
#
#  @ Joseph A. Pietrzak, Jr. and Fabian Labat 08/2014
#############################################################################################################################################################################

$drivez = @()
$hosts = Get-Content $args[2]
$outs = $args[1]
$threshold = $args[0]

Write-Output "Hostname,Drive,FullPath,Length"  > $outs

foreach ($member in $hosts)
{
    $drivez = GET-WMIOBJECT –query “SELECT * from win32_logicaldisk” –computername “$member” | ?{$_.DriveType -ne 5} | %{$_.DeviceID}
    if ($?) #if the above query fails then do nothing, else, do below.
    {
        foreach ($drive in $drivez)
        {
            $drive = $drive.Substring(0,1)
            Get-ChildItem \\$member\$drive$ -recurse -ErrorAction SilentlyContinue | ?{$_.Length -gt $threshold} | %{"$member,$drive,$($_.DirectoryName)\$($_.Name), $($_.Length)"} >> $outs
        }
        $drivez = @() #effectively clear drivez.
    }
}