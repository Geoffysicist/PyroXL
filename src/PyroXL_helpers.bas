Attribute VB_Name = "PyroXL_helpers"
Public Sub Copy_formulae()
Attribute Copy_formulae.VB_ProcData.VB_Invoke_Func = " \n14"
    'Copies the formulae down to match weather data
    'ActiveSheet.Unprotect
    Application.Calculation = xlCalculationManual
    Dim weather_range As Range
    Dim formulae As Range
    Set weather_range = ActiveSheet.Range("start_date", ActiveSheet.Range("start_date").End(xlDown))
    Set formulae = Range("Outputs")
    'weather_range.Select
    Dim num_rows As Integer: num_rows = weather_range.Rows.Count
    If num_rows > 1 Then
        formulae.Select
        Selection.Resize(num_rows, 11).Select
        Selection.FillDown
        'MsgBox num_rows
    End If
    Application.Calculation = xlCalculationAutomatic
    'ActiveSheet.Protect
End Sub
