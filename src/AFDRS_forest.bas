Attribute VB_Name = "AFDRS_forest"
Public Function Intensity_forest(ROS, DF, flame_h As Double, fl_s, fl_ns, fl_e, fl_o, h_o As Single) As Long
    'return the intensity based on fuel load and ROS
    'note AFDRS caps surface fuel load at 10 t/ha (1 kg/m)
    'args
    '  ROS: forward rate of spread (km/h)
    '  DF: drought (fuel availability) factor (1-10)
    '  flame_h: flame height (m)
    '  fl_s: surface fuel load (t/ha)
    '  fl_ns: near surface fuel load (t/ha)
    '  fl_e: elevated fuel load (t/ha)
    '  fl_o: overstorey (canopy) fuel load (t/ha)
    '  h_o: overstorey (canopy) height (m)
       
    Dim fuel_avail As Single
    Dim fuel_load As Single
    Dim flame_h_elev As Single: flame_h_elev = 1 'm
    Dim flame_h_crown_frac As Single: flame_h_crown_frac = 0.66 'dimensionless
    fuel_avail = DF * 0.1
    
    'cap surface fuel load
    fl_s = WorksheetFunction.Min(10, fl_s)
    
    'accumulate fuel load based on flame height
    fuel_load = fl_s + fl_ns
    If flame_h > flame_h_elev Then
        fuel_load = fuel_load + fl_e
    End If
    If flame_h > (h_o * flame_h_crown_frac) Then
        fuel_load = fuel_load + 0.5 * fl_o
    End If
    fuel_load = fuel_load * fuel_avail
        
    Intensity_forest = Intensity(ROS, fuel_load)
End Function

Public Function Flame_height_forest(ROS As Double, fh_e As Single) As Single
    'return the flame height
    'args
    '  ROS - forward rate of spread (m/h)
    '  fh_e - elevated fuel height (m)
    
    Flame_height_forest = 0.0193 * ROS ^ 0.723 * Exp(fh_e * 0.64) * 1.07
End Function

Public Function ROS_forest(U_10, fhs_s, fhs_ns, h_ns, fmc, DF, WAF As Single) As Integer
    'return the forward ROS (m/h) ignoring slope
    'args
    '  U_10: 10 m wind speed (km/h)
    '  fhs_s: surface fuel hazard score
    '  fhs_ns: near surface fuel hazard score
    '  h_ns: near surface fuel height (cm)
    '  fmc: fuel moisture content (%)
    '  DF: drought factor (0-10)
    '  WAF: wind adjustment factor
    
    Dim wind_threshold As Single: wind_threshold = 5
    Dim fuel_avail As Single: fuel_avail = DF * 0.1
    
    Dim Mf As Single 'moisture function
    Mf = Mf_forest((fmc))
    
    'modify fuel parameters with fuel availability
    fhs_s = fhs_s * fuel_avail
    fhs_ns = fhs_ns * fuel_avail
    
    'apply wind reduction factor
    wind_speed = U_10 * 3# / WAF
    
    'calculate ROS for 7% moisture
    If wind_speed > wind_threshold Then
        ROS_forest = 30 + 1.5308 * (wind_speed - wind_threshold) ^ 0.8576 * fhs_s ^ 0.9301 * (fhs_ns * h_ns) ^ 0.6366 * 1.03
    Else
        ROS_forest = 30
    End If
    
    'apply moisture factor
    ROS_forest = ROS_forest * Mf
End Function

Public Function FMC_forest(temp, rh As Single, date_, time As Date) As Single
    'return the fine fuel moisture content (%)
    'args
    '  temp: air temperature (C)
    '  rh: relative humidity (%)
    '  date_: (underscore due to VBA Date objects)
    '  time:
    
    Dim start_peak_month, end_peak_month As Integer
    Dim start_afternoon, end_afternoon As Integer
    Dim sunrise, sunset As Integer
    
    start_peak_month = 10 'October
    end_peak_month = 3 'March
    start_afternoon = 12
    end_afternoon = 17
    sunrise = 6
    sunset = 19
    
    If (Month(date_) >= start_peak_month Or Month(date_) <= end_peak_month) And _
        (Hour(time) >= start_afternoon And Hour(time) <= end_afternoon) Then
        FMC_forest = 2.76 + 0.124 * rh - 0.0187 * temp
    ElseIf Hour(time) <= sunrise Or Hour(time) >= sunset Then
        FMC_forest = 3.08 + 0.198 * rh - 0.0483 * temp
    Else
        FMC_forest = 3.6 + 0.169 * rh - 0.045 * temp
    End If
End Function


Public Function Mf_forest(fmc As Single) As Single
    'returns the forest fuel moisture factor
    'args
    '  fmc: fine fule moisture content (%)
    
    If fmc <= 4 Then
        Mf_forest = 2.31
    ElseIf fmc > 20 Then
        Mf_forest = 0
    Else
        Mf_forest = 18.35 * fmc ^ -1.495
    End If
End Function

Public Function Spotting_forest(ROS, U_10, fhs_s As Single) As Integer
    'calculates the spotting distance in m
    'args
    '  ROS: forward rate of spread (m/h)
    '  U_10: 10m wind speed (km/h)
    '  fhs_s: fuel hazard score surface
    
    If ROS < 150 Then
        Spotting_forest = 50
    Else
        Spotting_forest = Abs( _
            176.969 * Atn(fhs_s) * (ROS / (U_10 ^ 0.25)) ^ 0.5 + _
            1568800 * fhs_s ^ -1 * (ROS / (U_10 ^ 0.25)) ^ -1.5 - 3015.09 _
        )
    End If
End Function

Public Function test() As Single
    test = Mf_AFDRS()
End Function

