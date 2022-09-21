VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "test"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Private Sub Worksheet_Change(ByVal Target As Range)
    Dim KeyCells As Range
    
    Set KeyCells = Range("A:B")
    If Not Application.Intersect(KeyCells, Range(Target.Address)) Is Nothing Then
    'resize outputs to inputs
    
        Call trim_output(Range("A2:B2"), Range("C2:D2"))
    End If
End Sub
