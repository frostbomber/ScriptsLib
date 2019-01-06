#obviously incomplete, but a good start at least...

$originalScript = [IO.File]::ReadAllText($args[0])
#VBS syntax
$newScript = [System.Text.RegularExpressions.Regex]::Replace($originalScript,"[Cc]all ","")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($originalScript,"[Ss]leep ","Start-Sleep -milliseconds ")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"[Cc]onst ","$")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"[Ss]et ","$")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"VbCrLf",'"')
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"[Ee]nd [Ii]f","}")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"[Ee]nd [Ff]unction","}")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"[Dd]im .*","")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"[Nn]ext","}")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"[Ee]lse","}`r`nelse{")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"[Tt]hen","{")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"byval ","$")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"<>","-ne")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,">","-gt")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"<","-lt")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"'","#")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,'([Ii]f ) ','if (')
#special case for = as ==
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,'([Ii]f [\(]*)(.* )=( .*[\)]*) ','$1$2-eq$3')
#the rest of them
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,'([Ii]f )(.* )(-[a-z]{2})( .*) ','$1($2$3$4)')
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"(?<![\(\,]),",'$null,')
$newScript = $newScript -cReplace "[Ff]or [Ee]ach (.*) in (.*)",'foreach($$$1 in $$$2){'
$newScript = $newScript -creplace '(?<![\$A-Za-z])([osn][A-Z]{1}[a-z]*[0-9]*)', '$$$1'
$newScript = $newScript -creplace "([Ff]unction .*[\(]*.*[\)]*)", '$1{'
$newScript = $newScript -creplace '(".*"?)[ & ', '$1{'
$newScript = $newScript -cReplace '(& \$[a-zA-Z]+[0-9]*[\.]*[a-zA-Z]+[0-9]*)','$1"'
$newScript = $newScript -cReplace '["]* & ["]*',' '
$newScript = $newScript -creplace '([\(|\s])n ', '$1$n '
$newScript = $newScript -creplace '\((\$PATH) (.*)\)', '("$1/$2)'

#abat functions
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"\.RefreshData",".RefreshData()")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"\.Restart",".Restart()")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"\.Synchronize",".Synchronize()")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"\.Trigger3",".Trigger3()")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"\.TriggerEx",".TriggerEx()")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"\.Abort$",".Abort()")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"\.AbortBatch",".AbortBatch()")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"\.FlushInstances",".FlushInstances()")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"\.GetInstances",".GetInstances()")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"\.Delete",".Delete()")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"\.Update",".Update()")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"\.ResetAverage",".ResetAverage()")

#abat module functions/variables
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,'(abatIS[DF]*_.*)','$$$1')
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,'(Log "|ExitFailure ")(.*)(?!")$','$1$2"')
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,'\$\{QA_WSF_BEGIN\}',"")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,'\$\{QA_WSF_END\}',"")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,"oJss","oCOMJss")
$newScript = [System.Text.RegularExpressions.Regex]::Replace($newScript,'(?<![\$\@])PATH','$PATH')
$newScript = $newScript -creplace '(Log ")(.* )#( .* )#(.*)',"`$1`$2'`$3'`$4"
$newScript = $newScript -creplace '(Log ")(.* )(\$[a-zA-Z]+[0-9]*\.[a-zA-Z]+[0-9]*)','$1$2$($3)'

echo $newScript