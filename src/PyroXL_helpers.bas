Attribute VB_Name = "PyroXL_helpers"
Private Sub Save_Distro()
    ThisWorkbook.Save

    fn = Split(ThisWorkbook.FullName, ".")(0) + "_" + Format(Date, "YYYYMMDD")
    
    ThisWorkbook.SaveAs (fn)
     
    'delete the tests and hide the tables
    Application.DisplayAlerts = False
    For Each ws In ThisWorkbook.Worksheets
        If InStr(ws.Name, "tests_") > 0 Then
            ws.Delete
        ElseIf InStr(ws.Name, "tables") > 0 Then
            ws.Protect UserInterfaceOnly:=True
            ws.Visible = False
        Else
            ws.EnableCalculation = True
            ws.Protect UserInterfaceOnly:=True
        End If
    Next ws
    
    ThisWorkbook.Save
End Sub

Private Sub stop_calculation()
    For Each ws In ThisWorkbook.Worksheets
        If InStr(ws.Name, "tests_") > 0 Then
            ws.EnableCalculation = False
        Else
            ws.EnableCalculation = True
        End If
    Next ws
End Sub

Public Sub trim_output(input_row1, output_row1 As Range)
    'Trims or extends the output rows to match input rows
    'args:
    '  input_row1: the first row of the input data
    '  output_row1: the first row of the output
    Dim input_range, output_range As Range
    Set input_range = Range(input_row1, input_row1.End(xlDown))
    Set output_range = Range(output_row1, output_row1.End(xlDown))
    'Dim output_rows As Integer: output_rows = output.Rows.Count
    If Not input_range.Rows.Count = output_range.Rows.Count Then
        'MsgBox "unequal"
        output_range.Resize(output_range.Rows.Count - 1).Offset(1, 0).ClearContents
        'avoid filling all the way to the bottom if only one row of input
        If WorksheetFunction.CountA(input_range) > 1 Then
            output_range.Resize(input_range.Rows.Count).FillDown
        End If
    End If

End Sub
Public Function Power(coefficient, exponent) As Double
    'returns the coefficient raised to the power of the exponent
    'to make life easier translating python :)

    Power = coefficient ^ exponent
End Function


Public Sub test(arg1 As Integer, ParamArray p_array() As Variant)
    Dim this_array, that_array, big_array As Variant
    
    If UBound(p_array) < LBound(p_array) Then
        MsgBox "empty"
        p_array = Array(1, 2, 3, 4)
    Else
        MsgBox p_array(1)
    End If
    
    If UBound(p_array) < LBound(p_array) Then
        MsgBox "empty"
    Else
        MsgBox p_array(1)
    End If
    this_array = Array(1, 2, 3, 4)
    that_array = Array(5, 6, 7, 8)
    big_array = Array(this_array, that_array)

End Sub

Public Sub test2()
    this_array = Array(5, 6, 7, 8)
    Call test(99, this_array(0), this_array(1))
End Sub
