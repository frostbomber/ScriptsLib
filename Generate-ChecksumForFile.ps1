$someFilePath = "$($Args[0])"
$hasher = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider 
$hash = [System.BitConverter]::ToString($hasher.ComputeHash([System.IO.File]::ReadAllBytes($someFilePath))).Replace("-", "") 
$hash > "$($Args[1])" 