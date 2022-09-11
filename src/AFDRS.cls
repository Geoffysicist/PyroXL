VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "AFDRS"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
'Recalculate after input values have changed
Private Sub Worksheet_Change(ByVal Target As Range)
    Dim KeyCells As Range

    'if weather changed resize output range
    Set KeyCells = Range("A:B")
    If Not Application.Intersect(KeyCells, Range(Target.Address)) Is Nothing Then
        'use date field to determine number of rows
        Worksheets("AFDRS").Unprotect
        Call trim_output(Range("A15"), Range("G15:Q15"))
        Worksheets("AFDRS").Protect
    End If
    
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
    
    'if any of the input cells have changed need to recalculate all outputs
    'Set KeyCells = Range("weather,fhs_s,H2,H4:H7,H9:H10")
End Sub

