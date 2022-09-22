Attribute VB_Name = "Sandbox"
Private Sub sandbox()
    temp = backbearing("n")
    MsgBox temp
End Sub


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
    Dim a As Variant
    a = Array(1, 2, 3, 4, 1, 2, 3, 4, 5)
    Dim index As Integer
    MsgBox Application.Match(4, a, 0)
End Sub

