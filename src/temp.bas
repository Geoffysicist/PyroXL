Private Sub Worksheet_Activate()
' Copy the formulae down the required number of rows
' For optional fields where there may be existing constants these are to be maintained.
' To use this on other sheets you need to :-
'  Define the Formula_Range as sets of contiguous columns where ONLY formulae are required.
'  Define the FirstDataRow - this holds the first set of formulae that will be used for filling down
'  Define a set of Individual columns ( opt_Column_range ) that will be used for OPTIONAL values
'  Define a set of formula ( opt_formula ) that will be used where the cells are blank in the OPTIONAL columns.

Set Formula_Range = Range("A:H,K:K,M:AG")
FirstDataRow = 9
opt_column_range = Array("I:I", "J:J", "L:L")
opt_formula = Array("=R5C[-6]", "=R4C[0]", "=R4C[-9]")

Application.Calculation = xlCalculationManual
ActiveSheet.Unprotect Password:="fred"
Numbrows = Sheets("Weather_Site").Range("B65536").End(xlUp).row - 11
Dim y_rng As Range
'MsgBox "rows=" & numbrows
If Numbrows >= 2 Then
 ' Deal with formula columns
 Set Fillrange = Intersect(Formula_Range, Cells(FirstDataRow, 1).EntireRow)
 For Each iarea In Fillrange.Areas
  x = iarea.Address
  ' clear the formulae
  iarea.Offset(1, 0).Resize(65536 - iarea.row, iarea.Columns.Count).ClearContents
  ' paste in the new formulae
  iarea.AutoFill Destination:=iarea.Resize(Numbrows, iarea.Columns.Count), Type:=xlFillValues
 Next iarea
 
 ' Deal with OPTIONAL Value/formula columns
 
 iacount = 0
 For Each icol In opt_column_range
  'MsgBox icol
  Set iarea = Intersect(Range(icol), Cells(FirstDataRow, 1).EntireRow).Resize(Numbrows, 1)
  ' clear the formulae from area BEYOND current data
  iarea.Offset(Numbrows, 0).Resize(65536 - iarea.row - Numbrows, 1).ClearContents
  ' paste in the new formulae if the cell is blank
  For Each icell In iarea
   icell_address = icell.Address
   yval = icell.Value
   If icell.Value = "" Then
    icell.Formula = opt_formula(iacount)
   End If
  Next icell
  iacount = iacount + 1
 Next icol

End If

Application.Calculation = xlCalculationAutomatic
ActiveSheet.Protect Password:="fred"

End Sub