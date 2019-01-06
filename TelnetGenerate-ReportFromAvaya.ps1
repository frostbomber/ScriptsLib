function DoConnect()
{
	param([String] $username, [String] $password, [String] $termtype, [String] $hostIP, [String] $port)

	$Socket = New-Object System.Net.Sockets.TcpClient($hostIP, $port)
	If ($Socket)
    {   
    $Stream = $Socket.GetStream()
    $Writer = New-Object System.IO.StreamWriter($Stream)
    $Buffer = New-Object System.Byte[] 1024 
    $Encoding = New-Object System.Text.UTF8Encoding #UTF-8 should work better than ASCII

    #Issue username, password, terminal type
    
        $Writer.WriteLine("")
        $Writer.Flush()
        Start-Sleep -Milliseconds $WaitTime
        $Writer.WriteLine("")
        $Writer.Flush()
        Start-Sleep -Milliseconds $WaitTime
        $Writer.WriteLine("")
        $Writer.Flush()
        Start-Sleep -Milliseconds $WaitTime
        $Writer.WriteLine("")
        $Writer.Flush()
        Start-Sleep -Milliseconds $WaitTime
        #through experimentation we found we need to send some empty commands first

        #now enter the real stuff
        $Writer.WriteLine("$username")
        $Writer.Flush()
        Start-Sleep -Milliseconds $WaitTime
        $Writer.WriteLine("$password")
        $Writer.Flush()
        Start-Sleep -Milliseconds $WaitTime
        $Writer.WriteLine("$termtype")
        $Writer.Flush()
        Start-Sleep -Milliseconds $WaitTime

        #capture this data and just discard it.
        While($Stream.DataAvailable) 
        {   
		$Reader = $Stream.Read($Buffer, 0, 1024) 
        }

        return $stream
    }
}

function SendCommand()
{
    param ([String] $command, [int] $waitTime, [System.Net.Sockets.NetworkStream] $stream)

    $Writer = New-Object System.IO.StreamWriter($Stream)
    $Buffer = New-Object System.Byte[] 1024 
    $Encoding = New-Object System.Text.UTF8Encoding #UTF-8 should work better than ASCII

    #now, issue the command that will actually get the data
    $Writer.WriteLine("$command")
    $Writer.Flush()
    Start-Sleep -Milliseconds ($waitTime)

       #read output of these commands
    While($Stream.DataAvailable) 
    {   
	    $Reader = $Stream.Read($Buffer, 0, 1024) 
	    $Result += ($Encoding.GetString($Buffer, 0, $Reader))
    }

    return $Result
}

function SendKeyCombo()
{
    param ([char] $c1, [char] $c2, [int]$waitTime, [System.Net.Sockets.NetworkStream]$stream)
    
    $Writer = New-Object System.IO.StreamWriter($Stream)
    $Buffer = New-Object System.Byte[] 1024 
    $Encoding = New-Object System.Text.UTF8Encoding #UTF-8 should work better than ASCII

    $Writer.WriteLine("$c1$c2")
    $Writer.Flush()
    Start-Sleep -Milliseconds ($waitTime)

     #read output of these commands
    While($Stream.DataAvailable) 
    {   
	    $Reader = $Stream.Read($Buffer, 0, 1024) 
	    $Result += ($Encoding.GetString($Buffer, 0, $Reader))
    }

    return $Result
}
 

[int]$WaitTime = 1000
[string]$OutputPath = $args[0]

#create the connection to the system and log in and select terminal type
#returns a NetworkStream that can be passed to SendCommand/SendKeyCombo to run commands/send keys
[System.Net.Sockets.NetworkStream] $strm = DoConnect -username $args[1] -password $args[2] -termtype "w2ktt" -hostIP $args[3] -port $args[4] ?? "5023"

#issue command and then wait and get output
[string]$Result = SendCommand -command "list multimedia ip-un" -waittime $WaitTime -stream $strm


#output the final result
$Result | Out-File $OutputPath 
