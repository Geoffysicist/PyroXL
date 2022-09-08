Attribute VB_Name = "PyroXL_AFDRS"
Public Function FBI(ByVal intensity As Double, Optional fuel As String = "forest") As Integer

    ' Calculates FBI as a function of intensity.
    ' fuel is the fuel type: valid values are forest, grass, heath, savannah
    ' TODO add non forest model types
    
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
        Case Else
            FBI = -999 'error flag
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

End Function

Public Function Intensity_forest_AFDRS(ByVal ROS As Double, ByVal DF As Single, ByVal flame_h As Single) As Long
    'calculate the intensity based on fuel load and ROS
    'note AFDRS caps surface fuel load at 10 t/ha (1 kg/m)
    'Args:
    '  ROS: forward rate of spread (km/h)
    '  DF: drought (fuel availability) factor (1-10)
    '  flame_h: flame height (m)
       
    Dim fuel_avail As Single
    Dim fl_s, fl_ns, fl_e, fl_b As Integer 'fuel loads: s surface, ns near surface, e elevated, b bark
    Dim fuel_load As Single
    Dim flame_h_elev As Single: flame_h_elev = 1 'm
    Dim flame_h_crown_frac As Single: flame_h_crown_frac = 0.66 'dimensionless
    fuel_avail = DF * 0.1
    
    fl_s = Range("fl_s").Value
    fl_ns = Range("fl_ns").Value
    fl_e = Range("fl_e").Value
    fl_b = Range("fl_b").Value
    
    'cap surface fuel load
    fl_s = WorksheetFunction.Min(10, fl_s)
    
    'accumulate fuel load based on flame height
    fuel_load = fl_s + fl_ns
    If flame_h > flame_h_elev Then
        fuel_load = fuel_load + fl_e
    End If
    fuel_load = fuel_load * fuel_avail
        
    'Intensity_forest_AFDRS = fuel_load
    Intensity_forest_AFDRS = Intensity_AFDRS(ROS, fuel_load)
End Function
Public Function Intensity_AFDRS(ByVal ROS As Double, ByVal fuel_load As Single) As Long
    'calculates the fireline intensity (kW/m) based on Byram 1959
    'args:
    '  ROS: forward rate of spread (km/h)
    '  fuel_load: dine fuel load (t/ha)
    
    'convert units
    ROS = ROS / 3600 'm/s
    fuel_load = fuel_load / 10 'kg/m^2
    
    Intensity_AFDRS = 18600 * ROS * fuel_load
End Function
Public Function Flame_Height_AFDRS(ByVal ROS As Double) As Single
    'calculate the flame height
    'Args:
    '  ROS - forward rate of spread m/h
    
    Dim fh_e As Single 'flame height elevated fuel m
    fh_e = Range("fh_e").Value
    
    Flame_Height_AFDRS = 0.0193 * ROS ^ 0.723 * Exp(fh_e * 0.64) * 1.07
    
End Function

Public Function ROS_Forest_AFDRS( _
    ByVal wind_speed As Single, ByVal fmc As Single, Optional ByVal WAF As Single = 3 _
    ) As Integer
    'calculate the forward ROS (m/h) ignoring slope
    'Args:
    '  wind_speed - 10 m wind speed (km/h)
    '  fmc - fuel moisture content (%)
    '  WAF - wind adjustment factor default = 3
    
    Dim wind_threshold As Integer: wind_threshold = 5

    Dim fhs_s As Single 'fuel hazard score surface
    Dim fhs_ns As Single 'fuel hazard score near surface
    Dim fh_ns As Single 'fuel height near surface (m)
    Dim Mf As Single 'moisture function
    fhs_s = Range("fhs_s").Value
    fhs_ns = Range("fhs_ns").Value
    fh_ns = Range("fh_ns").Value
    Mf = Mf_AFDRS(fmc)
    
    'apply wind reduction factor
    wind_speed = wind_speed * 3 / WAF
    
    'calculate ROS for 7% moisture
    If wind_speed > wind_threshold Then
        ROS_Forest_AFDRS = 30 + 1.5308 * (wind_speed - 5) ^ 0.8576 * fhs_s ^ 0.9301 * (fhs_ns * fh_ns) ^ 0.6366 * 1.03
    Else
        ROS_Forest_AFDRS = 30
    End If
    
    'apply moisture factor
    ROS_Forest_AFDRS = ROS_Forest_AFDRS * Mf
    
End Function
Public Function FMC_Forest(ByVal temp As Single, ByVal rh As Single, ByVal this_date As Date, ByVal time As Date) As Single
    'Calculate the fine fuel moisture content
    'Args:
    '  temp: air temperature (C)
    '  rh: relative humidity (%)
    '  this_date: the date
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
    
    If (Month(this_date) >= start_peak_month Or Month(this_date) <= end_peak_month) And _
        (Hour(time) >= start_afternoon And Hour(time) <= end_afternoon) Then
        FMC_Forest = 2.76 + 0.124 * rh - 0.0187 * temp
    ElseIf Hour(time) <= sunrise Or Hour(time) >= sunset Then
        FMC_Forest = 3.08 + 0.198 * rh - 0.0483 * temp
    Else
        FMC_Forest = 3.6 + 0.169 * rh - 0.045 * temp
    End If
    
    'Mf_AFDRS = Month(this_date)
    
End Function

Public Function Mf_AFDRS(ByVal fmc As Single) As Single
    If fmc <= 4 Then
        Mf_AFDRS = 2.31
    ElseIf fmc > 20 Then
        Mf_AFDRS = 0
    Else
        Mf_AFDRS = 18.35 * fmc ^ -1.495
    End If
End Function
Public Function Spotting_Dist(ByVal ROS As Single, ByVal wind_speed As Single) As Integer
    'calculates the spotting distance in m
    'args:
    '  ROS: forward rate of spread (m/h)
    '  wind_speed: 10m wind speed (km/h)
    
    Dim fhs_s As Single 'fuel hazard score surface
    fhs_s = Range("fhs_s").Value
    
    Spotting_Dist = Abs(176.969 * Atn(fha_s) * (ROS / (wind_speed ^ 0.25)) ^ 0.5 + 1568800 * fhs_s ^ -1 * (ROS / (wind_speed ^ 0.25)) ^ -1.5 - 3015.09)
    
End Function
Public Function FMC_Grass(ByVal temp As Single, ByVal rh As Single) As Single
    'calculate the grass fuel moisture content as % based on McArthur (1966)
    'args:
    '  temp: air temperature (C)
    '  rh: relative humidity (%)
    
    FMC_Grass = 9.58 - 0.205 * temp + 0.138 * rh
End Function
Public Function ROS_Grass_AFDRS( _
    ByVal wind_speed As Single, ByVal fmc As Single, ByVal curing As Single, ByVal state As String _
    ) As Integer
    'calculate the forward ROS (m/h) ignoring slope
    'Args:
    '  wind_speed - 10 m wind speed (km/h)
    '  fmc - fuel moisture content (%)
    '  curing - degree of grass curing (%)
    '  state - grass state
    
    Dim moist_coeff, curing_coeff As Single
    
    curing_coeff = curing_coeff_grass(curing)
    moist_coeff = moist_coeff_grass(fmc)
    
    Select Case state
        Case "natural"
            If wind_speed < 5 Then
                ROS_Grass_AFDRS = 0.054 + 0.269 * wind_speed
            Else
                ROS_Grass_AFDRS = 1.4 + 0.838 * (wind_speed - 5) ^ 0.844
            End If
        Case "grazed"
            If wind_speed < 5 Then
                ROS_Grass_AFDRS = 0.054 + 0.209 * wind_speed
            Else
                ROS_Grass_AFDRS = 1.1 + 0.715 * (wind_speed - 5) ^ 0.844
            End If
        Case "eaten-out"
            If wind_speed < 5 Then
                ROS_Grass_AFDRS = 0.054 + 0.209 * wind_speed
            Else
                ROS_Grass_AFDRS = 0.55 + 0.357 * (wind_speed - 5) ^ 0.844
            End If
    End Select
    
    ROS_Grass_AFDRS = ROS_Grass_AFDRS * 1000 * moist_coeff * curing_coeff
    
End Function
Public Function curing_coeff_grass(ByVal curing As Single) As Single
    'calculate the curing coefficient based on Cruz et al. (2015)
    'args:
    '  curing - degree of grass curing (%)
    
    curing_coeff_grass = 1.036 / (1 + 103.989 * Exp(-0.0996 * (curing - 20)))
End Function
Public Function moist_coeff_grass(ByVal fmc As Single) As Single
    'calculate the grass moisture coefficient
    'args:
    '  fmc - fuel moisture content (%)
    If fmc < 12 Then
        moist_coeff_grass = Exp(-0.108 * fmc)
    Else
        If windspeed <= 10 Then
            moist_coeff_grass = 0.684 - 0.0342 * fmc
        Else
            moist_coeff_grass = 0.547 - 0.228 * fmc
        End If
    End If
End Function
Public Function test() As Single
    test = Mf_AFDRS()
End Function

