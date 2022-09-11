Attribute VB_Name = "PyroXL_helpers"
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

Public Sub test()
    Call trim_output(Range("A2:B2"), Range("C2:D2"))
End Sub
