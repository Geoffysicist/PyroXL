Attribute VB_Name = "PyroXL_helpers"
Public Sub Copy_formulae()
    'Copies the output formulae down to match input data rows
    '
    '
    ActiveSheet.Unprotect
    Application.Calculation = xlCalculationManual

    Dim _weather As Range
    Dim _outputs As Range
    Set _weather = ActiveSheet.Range("weather", ActiveSheet.Range("weather").End(xlDown))
    Set _outputs = ActiveSheet.Range("outputs", ActiveSheet.Range("outputs").End(xlDown))
    
    Dim weather_rows As Integer: weather_rows = _weather.Rows.Count
    Dim output_rows As Integer: output_rows = _outputs.Rows.Count
    If Not weather_rows = output_rows Then
        _outputs.Offset(1,).ClearContents
        _outputs.Resize(weather_rows, ).FillDown
        '_outputs.Offset(1,).Select
        'Selection.ClearContents
        '_outputs.Resize(weather_rows, ).Select
        'Selection.FillDown
    End If
    Application.Calculation = xlCalculationAutomatic
    ActiveSheet.Protect
End Sub

Public Sub trim_output(input, output As Range)
    'Trims or extends the output rows to match input rows
    
    ActiveSheet.Unprotect
    Application.Calculation = xlCalculationManual
    
    Dim input_rows As Integer: input_rows = input.Rows.Count
    Dim output_rows As Integer: output_rows = output.Rows.Count
    If Not input_rows = output_rows Then
        output.Offset(1,).ClearContents
        output.Resize(input_rows, ).FillDown
    End If
    Application.Calculation = xlCalculationAutomatic
    ActiveSheet.Protect
End Sub

