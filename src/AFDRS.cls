VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "AFDRS"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
'Recalculate after entry values have changed
Private Sub Worksheet_Change(ByVal Target As Range)
    Dim KeyCells As Range

    ' The variable KeyCells contains the cells that will
    ' cause an alert when they are changed.
    
    
    'if grass state has changed need to recalculate grass fuel load
    Set KeyCells = Range("state_grass")
    If Not Application.Intersect(KeyCells, Range(Target.Address)) Is Nothing Then
        Select Case Range("state_grass").Value
            Case "natural"
                Range("fl_grass").Value = 6
            Case "grazed"
                Range("fl_grass").Value = 4.5
            Case "eaten-out"
                Range("fl_grass").Value = 1.5
        End Select
        'MsgBox "Cell " & Target.Address & " has changed."
    End If
    
    'if grass fuel load has changed need to recalculate grass state
    'Set KeyCells = Range("fl_grass")
    'If Not Application.Intersect(KeyCells, Range(Target.Address)) Is Nothing Then
    '    Select Case Range("fl_grass").Value
    '        Case Is >= 6
    '            Range("state_grass").Value = "natural"
    '        Case Is < 3
    '            Range("state_grass").Value = "eaten_out"
    '        Case Else
    '            Range("state_grass").Value = "grazed"
    '    End Select
    '    'MsgBox "Cell " & Target.Address & " has changed."
    'End If
    
    'if any of the input cells have changed need to recalculate all outputs
    'Set KeyCells = Range("weather,fhs_s,H2,H4:H7,H9:H10")
    Set KeyCells = Range("weather")
    If Not Application.Intersect(KeyCells, Range(Target.Address)) Is Nothing Then

        'recalculate whole sheet
        'MsgBox "Cell " & Target.Address & " has changed."
        PyroXL_helpers.Copy_formulae
        'ActiveSheet.Calculate
    End If
End Sub

