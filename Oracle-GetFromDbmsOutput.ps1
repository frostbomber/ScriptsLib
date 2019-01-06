if ($ora_loaded -eq $null)
{
    $ora_loaded = [System.Reflection.Assembly]::LoadWithPartialName("Oracle.ManagedDataAccess") 
}

$ConnectionString = "Data Source=$($args[0]);User ID=$($args[1]);Password=$($args[2])"


function Execute-NonQuery_WITH_DBMS_OUTUT
{
    param (
        [string] $sql, [string]$sql2
    )

        $conn = new-object Oracle.ManagedDataAccess.Client.OracleConnection 
        $conn.ConnectionString = $ConnectionString 
        $conn.open() | out-NULL
		
		$preCmd = new-object Oracle.ManagedDataAccess.Client.OracleCommand($sql,$conn)
		$preCmd.ExecuteNonQuery() | out-NULL

        $cmd = new-object Oracle.ManagedDataAccess.Client.OracleCommand($sql2,$conn)
        $p_1 = new-object Oracle.ManagedDataAccess.Client.OracleParameter("1", [Oracle.ManagedDataAccess.Client.OracleDbType]::Varchar2, 32000, "", [System.Data.ParameterDirection]::Output)
        $p_2 = new-object Oracle.ManagedDataAccess.Client.OracleParameter("2", [Oracle.ManagedDataAccess.Client.OracleDbType]::Decimal, [System.Data.ParameterDirection]::Output);
        $cmd.Parameters.Add($p_1) | out-NULL
        $cmd.Parameters.Add($p_2) | out-NULL

		$finished = $false
		$output = ""
		
		while ( -not $finished )
		{
			$cmd.ExecuteNonQuery() | out-NULL
			if ( $p_2.Value.ToString() -ne "1" )
			{
				$output += "$($p_1.Value.ToString())`r`n"
			}
			else
			{
				$finished = $true
			}
		}
       
        $conn.close()
		return $output
}

$writeOutput = "begin " +
"  dbms_output.enable; " +
"  begin " +
"  PLSQL_Html_Report('Hello SRI Team');" +
"  end;" +
" end;"

$readOutput = "begin" +
"  dbms_output.get_line(:1, :2); " +
"end;"

return $(Execute-NonQuery_WITH_DBMS_OUTUT $writeOutput $readOutput)

