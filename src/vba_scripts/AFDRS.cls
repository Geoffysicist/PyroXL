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
        Call trim_output(Range("A15"), Range("G15:AA15"))
    End If
    
    'if grass state has changed need to recalculate grass fuel load
    Set KeyCells = Range("N3")
    If Not Application.Intersect(KeyCells, Range(Target.Address)) Is Nothing Then
        Dim fl_grass As Single
        Select Case Range("N3").Value
            Case "natural"
                fl_grass = 6
            Case "grazed"
                fl_grass = 4.5
            Case "eaten-out"
                fl_grass = 1.5
        End Select
        Range("O3").Value = fl_grass
    End If
    
    'if forest strata fuel loads have changed adjust hazard scores
    If Target.Address = "$I$4" Then 'surface load
        Select Case Target.Value
            Case Is <= 4
                haz_score = 1
            Case Is <= 9
                haz_score = 2
            Case Is <= 13
                haz_score = 3
            Case Is <= 18
                haz_score = 3.5
            Case Else
                haz_score = 4
        End Select
        Range("H4").Value = haz_score
     End If
    
    If Target.Address = "$I$5" Then 'near surface load
        Select Case Target.Value
            Case Is <= 2
                haz_score = 1
            Case Is <= 3
                haz_score = 2
            Case Is <= 4
                haz_score = 3
            Case Is <= 6
                haz_score = 3.5
            Case Else
                haz_score = 4
        End Select
        Range("H5").Value = haz_score
     End If
    
    If Target.Address = "$I$6" Then 'elevated load
        Select Case Target.Value
            Case Is <= 1
                haz_score = 1
            Case Is <= 2
                haz_score = 2
            Case Is <= 3
                haz_score = 3
            Case Is <= 5
                haz_score = 3.5
            Case Else
                haz_score = 4
        End Select
        Range("H6").Value = haz_score
     End If
    
    If Target.Address = "$I$7" Then 'bark load
        Select Case Target.Value
            Case Is < 1
                haz_score = 0
            Case Is < 2
                haz_score = 1
            Case Is < 5
                haz_score = 2
            Case Is < 7
                haz_score = 3
            Case Else
                haz_score = 4
        End Select
        Range("H7").Value = haz_score
     End If
    
    'MsgBox Target.Address
End Sub

