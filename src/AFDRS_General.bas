Attribute VB_Name = "AFDRS_General"
Public Function FBI(ByVal intensity As Long, Optional fuel As String = "forest") As Single

    ' returns FBI.
    'args
    '  intensity: file line intensity (kW/m)
    '  fuel: the fuel type

    
    Dim intensity_b() As Variant 'bounds for intensity classes
    Dim fbi_b() As Variant 'bounds for fba classes
    Dim intensity_ha As Long 'arbitrary high anchor for intensity
    Dim fbi_ha As Integer 'arbitrary high anchor for fbi
    Dim intensity_la, intensity_ua, fbi_la, fbi_ua As Integer 'upper and lower anchors for intensity and fbi
  
    'use same fbi bounds, fbi high anchor and intensity high anchor for all classes
    fbi_b = Array(0, 6, 12, 24, 50, 100)
    fbi_ha = 200
    intensity_ha = 90000
    
    'make case insensitive
    fuel = LCase(fuel)
  
    'set the intensity bounds according to fuel type
    Select Case fuel
        Case "forest"
            intensity_b = Array(0, 100, 750, 4000, 10000, 30000) 'intensity_b and fbi_b must have same dimensions
        Case "grass"
            intensity_b = Array(0, 100, 3000, 9000, 17500, 25000) 'intensity_b and fbi_b must have same dimensions
        Case "heath"
            intensity_b = Array(0, 50, 500, 4000, 20000, 40000) 'intensity_b and fbi_b must have same dimensions
        Case "savannah"
            intensity_b = Array(0, 100, 3000, 9000, 17500, 25000) 'intensity_b and fbi_b must have same dimensions
        Case "pine"
            intensity_b = Array(0, 100, 750, 4000, 10000, 30000) 'intensity_b and fbi_b must have same dimensions
        Case Else
            MsgBox "invalid fuel type"
            Exit Function
    End Select
    
    'determine FBI
    Select Case intensity
        Case Is < intensity_b(0)
            FBI = -9999
            Exit Function
        Case Is >= intensity_b(UBound(intensity_b))
            intensity_ua = intensity_ha
            fbi_ua = fbi_ha
            intensity_la = intensity_b(UBound(intensity_b))
            fbi_la = fbi_b(UBound(fbi_b))
        Case Else
            For i = 1 To UBound(intensity_b)
                If intensity < intensity_b(i) Then
                    fbi_la = fbi_b(i - 1)
                    fbi_ua = fbi_b(i)
                    intensity_la = intensity_b(i - 1)
                    intensity_ua = intensity_b(i)
                    Exit For
                End If
            Next i
    End Select
    
    FBI = fbi_la + (fbi_ua - fbi_la) * (intensity - intensity_la) / (intensity_ua - intensity_la)
    FBI = Int(FBI) 'FBI needs to be truncated for National consistency

End Function

Public Function intensity(ByVal ROS As Double, ByVal fuel_load As Single) As Double
    'calculates the fireline intensity (kW/m) based on Byram 1959
    'args:
    '  ROS: forward rate of spread (km/h)
    '  fuel_load: fine fuel load (t/ha)
    
    'convert units
    ROS = ROS / 3600 'm/s
    fuel_load = fuel_load / 10 'kg/m^2
    
    intensity = 18600 * ROS * fuel_load
End Function

Public Function fuel_load(fl_max, tsf, k) As Single
    'returns the fuel load (t/ha) based on time since fire and fuel accumulation curve parameter
    'args
    '  fl_max: the steady state fuel load (t/ha)
    '  tsf: time since fire (y)
    '  k: fuel accumulation curve parameter
    
    fuel_load = fl_max * (1 - Exp(-1 * tsf * k))
End Function
