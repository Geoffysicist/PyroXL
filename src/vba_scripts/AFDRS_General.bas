Attribute VB_Name = "AFDRS_General"
Public Sub set_defaults()
    Range("A15").Value = Date 'date (formatted)
    Range("B15").Value = time 'time (formatted)
    Range("C15").Value = 25 'temp
    Range("D15").Value = 30 'RH
    Range("E15").Value = "N" 'wind direction
    Range("F15").Value = 20 'wind speed
    Range("G13").Value = 100 'KBDI
    Range("G15").Value = 8 'DF
    Range("J2").Value = 3 'WAF
    Range("J10").Value = 20 'forest h_ns
    Range("J11").Value = 2 'forest h_el
    Range("J12").Value = 20 'forest h_o
    Range("K4").Value = 10 'forest fl_s
    Range("K5").Value = 3.5 'forest fl_ns
    Range("K6").Value = 2 'forest fl_e
    Range("K7").Value = 2 'forest fl_b
    Range("K8").Value = 4.5 'forest fl_o
    Range("M10").Value = "dry" 'forest submodel
    Range("P3").Value = "grazed" 'grass state
    Range("P4").Value = 80 'grass curing
    Range("X2").Value = 0 'heath precipation last 48 hours
    Range("X3").Value = 48 'heath time since rain
    Range("X4").Value = False 'heath presence of overstorey
    Range("X5").Value = 2 'heath h_el
    Range("X6").Value = 25 'heath  time since fire
    Range("AH2").Value = 3 'mallee fl_s
    Range("AH3").Value = 1 'mallee fl_o
    Range("AH4").Value = 18 'mallee Cov_o
    Range("AH5").Value = 4.5 'mallee H_o
    Range("AH6").Value = 20 'mallee time since fire
    Range("AH7").Value = 0 'mallee precipation last 48 hours
    Range("AH8").Value = 48 'mallee time since rain
End Sub

Public Function FBI(ByVal intensity As Double, Optional fuel As String = "forest") As Single
    '''  returns FBI.
    '''
    ''' args
    '''   intensity: file line intensity (kW/m)
    '''   fuel: the fuel type

    
    Dim intensity_b() As Variant 'bounds for intensity classes
    Dim fbi_b() As Variant 'bounds for fba classes
    Dim intensity_ha As Double 'arbitrary high anchor for intensity
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
    ''' returns the fireline intensity (kW/m) based on Byram 1959
    '''
    ''' args
    '''   ROS: forward rate of spread (km/h)
    '''   fuel_load: fine fuel load (t/ha)
    
    'convert units
    ROS = ROS / 3600 'm/s
    fuel_load = fuel_load / 10 'kg/m^2
    
    intensity = 18600 * ROS * fuel_load
End Function

Public Function fuel_amount(fuel_param_max, tsf, k) As Double
    ''' returns the adjusted fuel parameter based on time since fire and fuel accumulation curve parameter
    '''
    ''' args
    '''   fuel_param_max: the steady state value for the fuel parameter
    '''   tsf: time since fire (y)
    '''   k: fuel accumulation curve parameter
    
    fuel_amount = fuel_param_max * (1 - Exp(-1 * tsf * k))
End Function

Public Function fl_to_fhs(layer As String, fuel_load As Single)
    ''' converts a fuel load to a VESTA fuel hazard score
    '''
    ''' args
    '''   layer: fuel layer (surface, near surface, elevated, bark)
    '''   fuel_load: (t/ha)
    
    Dim fhs_dict 'fuel hazard score
    Set fhs_dict = CreateObject("Scripting.Dictionary")
    fhs_dict.Add "surface", Array(1, 2, 3, 3.5, 4)
    fhs_dict.Add "near surface", Array(1, 2, 3, 3.5, 4)
    fhs_dict.Add "elevated", Array(1, 2, 3, 3.5, 4)
    fhs_dict.Add "bark", Array(0, 1, 2, 3, 4)
    
    Dim fl_dict 'fuel load class boundaries t/ha
    Set fl_dict = CreateObject("Scripting.Dictionary")
    fl_dict.Add "surface", Array(4, 9, 13, 18)
    fl_dict.Add "near surface", Array(2, 3, 4, 6)
    fl_dict.Add "elevated", Array(1, 2, 3, 5)
    fl_dict.Add "bark", Array(0, 1, 2, 5)
    
    fl_to_fhs = fhs_dict(layer)(UBound(fhs_dict(layer)))
    
    For i = UBound(fl_dict(layer)) To 0 Step -1
        If fuel_load <= fl_dict(layer)(i) Then
            fl_to_fhs = fhs_dict(layer)(i)
        End If
    Next i
End Function
