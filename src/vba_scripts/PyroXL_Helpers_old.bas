Attribute VB_Name = "PyroXL_Helpers"
Sub ImportWeather()
    'ATM only set up to work with standard gridded data
    Dim filePath As String, line As String
    Dim ws_weather As Worksheet: Set ws_weather = ActiveWorkbook.Sheets("Weather")
    Dim row As Integer: row = 3
    Dim arr() As String
    Dim weatherRange As Range
    Dim numFields As Integer: numFields = 0
    Dim filter() As Variant
    
    filter = Array("Weather Data", "*.csv")
    filePath = GetFilePath(filter)
    If Len(filePath) = 0 Then
        Exit Sub
    End If
    
    ws_weather.Cells.Clear
    ws_weather.Cells(1, 1) = "Source:"
    ws_weather.Cells(1, 2) = filePath
    Open filePath For Input As #1
    Do Until EOF(1)
        Line Input #1, line
        arr = Split(line, ",")
        'put in a blamk line whenver the number of fields changes
        If UBound(arr) <> numFields Then
            row = row + 1
            numFields = UBound(arr)
        End If
        
        For i = LBound(arr) To UBound(arr)
            ws_weather.Cells(row, i + 1) = arr(i)
        Next i
        row = row + 1
    Loop
    Close #1
    
    'name the columns
    Set weatherRange = ws_weather.Cells(row - 1, i).CurrentRegion
    weatherRange.CreateNames Top:=True, Left:=False
    'more convenient if we save RH for later
    ws_weather.Range("RH").Name = "rel_hum"
    With ThisWorkbook
        .Names("RH").Delete
    End With
    'MsgBox ActiveWorkbook.Names.Count
    
End Sub
Sub ResetWeather()
    Dim ws_overview As Worksheet: Set ws_overview = ActiveWorkbook.Sheets("Overview")
    Dim row As Integer
    Dim rows As Integer
    Dim weatherHead As Range
    Dim weather As Range
    Dim headerRow As Integer: headerRow = 15
    Dim dateTimeCol As Integer: dateTimeCol = 1
    Dim tempCol As Integer: tempCol = 2 'temperature deg C
    Dim rhCol As Integer: rhCol = 3 'relative humidity %
    Dim wsCol As Integer: wsCol = 4 '10 m wind speed km/h
    Dim wdCol As Integer: wdCol = 5 'wind direction degrees
    Dim dfCol As Integer: dfCol = 6 'drought factor
    Dim dateTime As Date
    
    'clear existing data
    ws_overview.Cells(headerRow, dateTimeCol).CurrentRegion.Clear
    
    'set the headings
    ws_overview.Cells(headerRow, dateTimeCol) = "DateTime"
    ws_overview.Cells(headerRow, tempCol) = "Temp C"
    ws_overview.Cells(headerRow, rhCol) = "RH %"
    ws_overview.Cells(headerRow, wsCol) = "Wind Spd km/h"
    ws_overview.Cells(headerRow, wdCol) = "Wind Dir deg"
    ws_overview.Cells(headerRow, dfCol) = "DF"
    Set weatherHead = ws_overview.Cells(headerRow, dateTimeCol).CurrentRegion
    weatherHead.Font.Bold = True
    weatherHead.Font.ColorIndex = 49
    
    rows = Range("Local_Date").rows.Count
    
    For i = 1 To rows:
        row = headerRow + i
        dateTime = Range("Local_Date")(i, 1) + Range("Local_Time")(i, 1)
        ws_overview.Cells(row, dateTimeCol) = dateTime
        ws_overview.Cells(row, tempCol) = Range("Temp__C")(i, 1)
        ws_overview.Cells(row, dateTimeCol).NumberFormat = "yyyy-mm-dd hh:ss"
        ws_overview.Cells(row, rhCol) = Range("rel_hum")(i, 1)
        ws_overview.Cells(row, wsCol) = Range("Wind_Speed__km_h")(i, 1)
        ws_overview.Cells(row, wdCol) = Range("Wind_Dir")(i, 1)
        ws_overview.Cells(row, dfCol) = Range("Drought_Factor")(i, 1)
        
    Next i
    
    Set weather = Range(ws_overview.Cells(headerRow, 1), ws_overview.Cells(row, dfCol)) 'careful if you change this to make sure the val of row is correct
    MsgBox weather.address
    weather.CreateNames Top:=True, Left:=False
    weather.Font.ColorIndex = 49
        
End Sub
Sub Sandbox()
    Dim dateTime As Date
    'dateTime = CDate(Range("Local_Date")(1, 1)) + CDate(Range("Local_Time")(1, 1))
    dateTime = Range("Local_Date")(1, 1) + Range("Local_Time")(1, 1)
    MsgBox Format(dateTime, "yyyy-mm-ddThh:mm")

End Sub


Function GetFilePath(ByRef filter() As Variant) As String
    ' Open the file dialog - use msoFileDialogFilePicker?
    With Application.FileDialog(msoFileDialogOpen)
        .AllowMultiSelect = False
        .Filters.Clear
        '.Filters.Add "Weather Data", "*.csv", 1
        .Filters.Add filter(0), filter(1)
        .FilterIndex = 1
        .Title = "Choose the weather data"
        
        ' avoid error if user enters Cancel
        If .Show = -1 Then
            GetFilePath = .SelectedItems(1)

        Else
            MsgBox "No file selected"
        End If
    End With
End Function

Public Sub RunModels()
    Dim rows As Integer
    Dim weather As Range: Set weather = Range("Weather")
    Dim ws_params As Worksheet
    
    If sheetExists("Parameters") = True Then
        MsgBox "The sheet exists"
        Set ws_params = ActiveWorkbook.Sheets("Parameters")
    Else
        MsgBox "Create the Sheet"
        ActiveWorkbook.Sheets.Add.Name = "Parameters"
        Set ws_params = ActiveWorkbook.Sheets("Parameters")
    End If
    
    rows = weather.rows.Count
    MsgBox rows
    
    ws_params.Range("D1:D" & rows) = Index(Range("FFDI"))

End Sub
Sub dural()
    Dim second As Range
    Dim first As Range
    Dim third As Range

    Set first = Range("A1:A3")
    Set second = Range("B1:B3")
    Set third = Range("C1:C3")

    For i = 1 To 3
        third(i, 1) = first(i, 1) * second(i, 1)
    Next i

End Sub

Public Sub RunModels_old()
    Dim rowNum As Integer
    Dim weather As Range: Set weather = Range("Weather")
    Dim ws_params As Worksheet
    
    If sheetExists("Parameters") = True Then
        MsgBox "The sheet exists"
        Set ws_params = ActiveWorkbook.Sheets("Parameters")
    Else
        MsgBox "Create the Sheet"
        ActiveWorkbook.Sheets.Add.Name = "Parameters"
        Set ws_params = ActiveWorkbook.Sheets("Parameters")
    End If
    
    For Each row In weather
        rowNum = row.row
        ws_params.Cells(rowNum, 1) = rowNum
        'ws_params.Cells(rowNum, 2) = row.col
        temp = "Weather!" & weather.Cells(rowNum, 3).address
        rh = "Weather!" & weather.Cells(rowNum, 4).address
        
        ws_params.Cells(rowNum, 2).Formula = "=" & temp
        ws_params.Cells(rowNum, 3).Formula = "=" & rh
        ws_params.Cells(rowNum, 4).Formula = "=MC(" & temp & "," & rh & ")"
    Next row

End Sub


Function sheetExists(sheetToFind As String, Optional wb As Workbook) As Boolean
    If wb Is Nothing Then Set wb = ThisWorkbook

    Dim Sheet As Object
    sheetExists = False
    
    For Each Sheet In wb.Sheets
        If sheetToFind = Sheet.Name Then
            sheetExists = True
        End If
    Next Sheet
End Function
