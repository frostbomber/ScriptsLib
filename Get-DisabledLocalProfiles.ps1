#############################################################################################################################################################################
#  Get-DisabledLocalProfiles 
# 
#  Description: Reads in a list of workstations, and for each, finds existing user profiles that correspond to a disabled user in Active Directory
#
#  Usage: .\get-disabledlocalprofiles.ps1
#
#  Dependencies: $args[0] must exist
#+               Running User must have permissions to access the appropriate path to the arguments supplied to the script ^^^^
#+               $args[1] must exist
#+               Running User must have permissions to access ^^^
#+               Running Host must have Active Directory snap-in for PowerShell
#+               Running User must have permissions to access Active Directory info
#+               Running User must have permission to RPC all workstations on the domain (domain admins)
#
#  @ Joseph A. Pietrzak, Jr. and Fabian Labat 08/2014
#############################################################################################################################################################################

$cnames = @()
$disabledaccts = @()
#optional "check-all"
if ($args[2] -eq $true)
{
    Get-ADComputer -Filter 'OperatingSystem -like "Windows*"' | %{$cnames += $_.Name}
}
$source = $args[0]

$dest = $args[1]

#-------------------------------------------------------------------------------------------

"Computer,Account" > $dest

Get-Content $source | %{$cnames += $_}
foreach ($name in $cnames)
{
    Write-Output "Now checking $name..." #debug

    Get-WmiObject win32_userprofile -computer $name | ?{!($_.Special)} |
    %{
        Write-Output "Non-Special Local Account found" #debug
        $profname = $_.LocalPath.Substring(9)
        try{
                Get-ADUser $profname -EA SilentlyContinue | ?{!($_.Enabled)} | %{$disabledaccts += $profname}
           }
        catch{}
     } #find all profiles on computer that are not special
    
    foreach ($acct in $disabledaccts)
    {
        Write-Output "Disabled Account Detected!!" #debug
        Write-Output "$name,$acct" >> $dest
    } #output them in an orderly fashion

    if($disabledaccts)
    {
        $disabledaccts.Clear() #make sure array is emptied out
        $disabledaccts = @() #declare a new one
    }
}