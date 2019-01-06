$computerName = $args[0]
$productName = $args[1]

$reg = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$computerName)
$parentkey = $reg.OpenSubKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products')
$subkeys = $parentkey.GetSubKeyNames()

foreach ($subkey in $subkeys)
{
	$installkey = $parentKey.OpenSubKey("$subkey\\InstallProperties")
	$displayName = $installkey.GetValue("DisplayName")

	if (($displayName -ne $null) -and ($displayName -eq $productName))
	{
		$uninstallCommand = $installkey.GetValue("UninstallString")
	}
}

Write-Host $uninstallCommand
#return $uninstallCommand

$returnval = ([WMICLASS]"\\$computerName\ROOT\CIMV2:win32_process").Create("$uninstallCommand")