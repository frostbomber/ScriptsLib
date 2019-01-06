#create the file and import from the text file
$file = $args[0]   #VVV
$path = $args[1] #must be full path or this won't work

$excel = New-Object -com "Excel.Application"
$excel.Visible = $true

#opens text file in excel using comma as a delimiter
$workbooks = $excel.Workbooks.__OpenText("$path\$file.txt",437,1,1,1,$True,$False,$False,$True,$False,$False)

#Auto-filters to get only email triggerz
$excel.ActiveSheet.Cells.AutoFilter(3, "Triggers.Abat.Email")

#Finds the number of entries after filtering
$cell = $excel.Range("H1")
$cell.Activate()
$excel.ActiveCell.FormulaR1C1 = "=SUBTOTAL(3,C[-7])-1"
$entries = $excel.ActiveCell.Value2

#We have the value, so clear the cell now
$excel.ActiveCell.Clear()



#saves this workbook
$excel.ActiveSheet.SaveAs("$path\$file.xlsx", 51)

#closes the workbook
$excel.Workbooks.Close()

#quits excel
$excel.Quit()

Stop-Process -processname EXCEL -Force

Write-Output "$entries Entries were found in the text file!"
