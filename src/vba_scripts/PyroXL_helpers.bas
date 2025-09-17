Attribute VB_Name = "PyroXL_helpers"
Private Sub calculate_activesheet()
    ActiveSheet.EnableCalculation = True
    ActiveSheet.Calculate
    ActiveSheet.EnableCalculation = False
End Sub

Private Sub calculate_selected()
    Selection.Calculate
End Sub

Private Sub Save_Distro()
    ThisWorkbook.Save
    
    Call set_defaults
    
    fn = Split(ThisWorkbook.FullName, ".")(0) + "_" + Format(Date, "YYYYMMDD")
    
    ThisWorkbook.SaveAs (fn)
     
    'delete the tests and hide the tables
    Application.DisplayAlerts = False
    For Each ws In ThisWorkbook.Worksheets
        If InStr(ws.Name, "tests_") > 0 Then
            ws.Delete
        ElseIf InStr(ws.Name, "models") > 0 Then
            ws.Protect UserInterfaceOnly:=True
            ws.Visible = False
        Else
            ws.Unprotect
            ws.EnableCalculation = True
            ws.Protect UserInterfaceOnly:=True
        End If
    Next ws
    
    ThisWorkbook.Save
End Sub

Public Sub export_modules()
    Dim path, fn As String
    
    path = ThisWorkbook.path & "\src\vba_scripts\"
    
    For Each cmp In ThisWorkbook.VBProject.VBComponents
        Select Case cmp.Type
            Case Is = 1 'module
                cmp.Export path & cmp.Name & ".bas"
            Case Is = 3 'form
                cmp.Export path & cmp.Name & ".frm"
            Case Else
        End Select
    Next cmp
End Sub

Private Sub run_all_tests()
    For Each ws In ThisWorkbook.Worksheets
        If InStr(ws.Name, "tests_") > 0 Then
            ws.EnableCalculation = True
            ws.Calculate
            ws.EnableCalculation = False
        End If
    Next ws
End Sub

Public Sub disable_test_calculation()
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

Public Sub list_names()
    Dim sht As Worksheet
    Dim nm As Name
    
    Set Sheet = ActiveSheet
    this_row = 2
    col_name = "F"
    col_address = "G"
    For Each nm In Names
        Worksheets("tables").Range(col_name & this_row).Value = nm.Name
        Worksheets("tables").Range(col_address & this_row).Value = Range(nm.Name).Address
        this_row = this_row + 1
    Next nm
End Sub

Public Function Power(coefficient, exponent) As Double
    'returns the coefficient raised to the power of the exponent
    'to make life easier translating python :)

    Power = coefficient ^ exponent
End Function

Public Function cardinal_to_degrees(ByVal cardinal As String) As Single
    ''' returns a compass direction in degrees
    '''
    ''' args
    '''   cardinal: a cardinal direction (N, NNE, NE, ENE, E, ESE, SE, SSE,
    '''                                   S, SSW, SW, WSW, W, WNW, NW, NNW)
    
    'cardinal = UCase(cardinal)
    Dim cardinal_array As Variant
    Dim i As Variant
    Dim pos As Variant
    
    cardinal_array = Array( _
        "N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", _
        "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW" _
        )
    Dim degree_array() As Single
    Step = 360 / (UBound(cardinal_array) + 1) 'zero indexed array
    d = 0
    
    For i = 0 To UBound(cardinal_array)
        ReDim Preserve degree_array(i)
        degree_array(i) = d
        d = d + Step
    Next i
    
    i = Application.Match(cardinal, cardinal_array, False) 'zero indexed array
    
    If IsError(i) Then
        cardinal_to_degrees = -9999
    Else
        cardinal_to_degrees = degree_array(i - 1)
    End If
End Function

Function degrees_to_cardinal(degrees As Single) As String
    Dim cardinal_array As Variant
    
    cardinal_array = Array("N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", _
                           "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW")
    
    Dim index As Integer
    index = Int((degrees / 22.5) + 0.5) Mod 16
    
    degrees_to_cardinal = cardinal_array(index)
End Function

Public Function backbearing(ByVal bearing As Variant) As Single
    If Not IsNumeric(bearing) Then
        bearing = cardinal_to_degrees(bearing)
    End If
    
    If bearing < 180 Then
        backbearing = bearing + 180
    Else
        backbearing = bearing - 180
    End If
End Function

Public Function breach_probability(ByVal intensity As Double, ByVal width As Single, Optional trees As Boolean = True) As Single
    ''' returns the probability that a firebreak will be breached
    ''' based on:
    ''' Wilson, A. A. G. (2011). Width of firebreak that is necessary to stop grass fires: Some field experiments.
    ''' Canadian Journal of Forest Research. https://doi.org/10.1139/x88-104
    '''
    ''' using logistic function described in:
    ''' Frost, S. M., Alexander, M. E., & Jenkins, M. J. (2022). The Application of Fire Behavior Modeling
    ''' to Fuel Treatment Assessments at Army Garrison Camp Williams, Utah.
    '''
    ''' args
    '''   intensity: fireline intensity (kW/m)
    '''   width: firebreak width (m)
    '''   trees: presence or absence of trees
    
    Dim width_coeff As Single
    If trees Then
        width_coefficient = 0.38
    Else
        width_coefficient = 0.99
    End If
    
    breach_probability = exp(1.36 + 0.00036 * intensity - width_coefficient * width)
    breach_probability = 100 * breach_probability / (1 + breach_probability)
End Function

Function LookupValueInTable(lookupValue As Variant, lookupColumnName As String, returnColumnName As String, sheetName As String, tableName As String) As Variant
    Dim ws As Worksheet
    Dim tbl As ListObject
    Dim result As Variant
    Dim i As Long

    ' Set the worksheet and table
    Set ws = ThisWorkbook.Sheets(sheetName)
    Set tbl = ws.ListObjects(tableName)

    ' Initialize result as not found
    result = "Not found"

    ' Loop through each row in the table
    For i = 1 To tbl.ListRows.Count
        ' Check if the value in the lookup column matches the lookup value
        If tbl.DataBodyRange.Cells(i, tbl.ListColumns(lookupColumnName).index).Value = lookupValue Then
            ' Get the corresponding value from the return column
            result = tbl.DataBodyRange.Cells(i, tbl.ListColumns(returnColumnName).index).Value
            Exit For
        End If
    Next i

    ' Return the result
    LookupValueInTable = result
End Function

