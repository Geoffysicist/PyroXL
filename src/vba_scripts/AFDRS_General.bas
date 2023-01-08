Attribute VB_Name = "AFDRS_General"
Public Sub set_defaults()
    Range("current_date").Value = Date 'date (formatted)
    Range("current_time").Value = time 'time (formatted)
    Range("date_row1").Value = Date 'date (formatted)
    Range("time_row1").Value = time 'time (formatted)
    Range("temp_row1").Value = 25 'temp
    Range("rh_row1").Value = 30 'RH
    Range("wind_dir_row1").Value = "N" 'wind direction
    Range("wind_mag_row1").Value = 20 'wind speed
    Range("kbdi").Value = 100 'KBDI
    Range("tsf").Value = 20 'Time since fire
    Range("df_row1").Value = 8 'DF
    Range("waf_forest").Value = 3 'WAF Forest
    Range("h_ns_forest").Value = 20 'forest h_ns
    Range("h_e_forest").Value = 2 'forest h_el
    Range("h_o_forest").Value = 20 'forest h_o
    Range("fl_s_forest").Value = 10 'forest surface fuel load
    Range("fl_ns_forest").Value = 3.5 'forest fl_ns
    Range("fl_e_forest").Value = 2 'forest fl_e
    Range("fl_b_forest").Value = 2 'forest fl_b
    Range("fl_o_forest").Value = 4.5 'forest fl_o
    Range("submodel_forest").Value = "dry" 'submodel_forest
    Range("state_grass").Value = "grazed" 'grass state
    Range("curing_grass").Value = 80 'grass curing
    Range("subtype_woodland").Value = "woodland" 'woodland subtype
    Range("fl_woodland").Value = 4.5 'woodland grass fuel load
    Range("curing_woodland").Value = 80 'grass curing
    Range("waf_woodland").Value = 0.5 'woodland wind adjustment factor
    Range("rain_heath").Value = 0 'heath precipation last 48 hours
    Range("tsr_heath").Value = 48 'heath time since rain
    Range("overstorey_heath").Value = False 'heath presence of overstorey
    Range("h_el_heath").Value = 2 'elevated fuel height
    Range("tsf_heath").Value = 25 'heath  time since fire
    Range("fl_s_mallee").Value = 3 'mallee fl_s
    Range("fl_o_mallee").Value = 1 'mallee fl_o
    Range("cov_o_mallee").Value = 18 'mallee Cov_o
    Range("h_o_mallee").Value = 4.5 'mallee H_o
    Range("tsf_mallee").Value = 20 'mallee time since fire
    Range("rain_mallee").Value = 0 'mallee precipation last 48 hours
    Range("tsr_mallee").Value = 48 'mallee time since rain
    Range("AWAP_uf").Value = 0 'soil moisture factor
    Range("tsf_spinifex").Value = 25 'spinifex time since fire
    Range("rain_spinifex").Value = 0 'spinifex precipation last 48 hours
    Range("tsr_spinifex").Value = 48 'spinifex time since rain
    Range("productivity_spinifex").Value = 1 'arid = 1, low rainfall = 2, high rainfall = 3
    Range("subtype_spinifex").Value = "open" 'spinifex subtype
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
        Case "savannah", "woodland"
            intensity_b = Array(0, 100, 3000, 9000, 17500, 25000) 'intensity_b and fbi_b must have same dimensions
        Case "pine"
            intensity_b = Array(0, 100, 750, 4000, 10000, 30000) 'intensity_b and fbi_b must have same dimensions
        Case "spinifex"
            'actually uses ROS (m/h) but uses the same process so for simplicity label it here as intensity
            intensity_b = Array(0, 0.1, 50, 1300, 7500, 10750)
            intensity_ha = 20000
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
