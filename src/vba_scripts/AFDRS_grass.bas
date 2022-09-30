Attribute VB_Name = "AFDRS_grass"
Public Function FMC_grass(temp, rh As Single) As Single
    ''' returns the grass fuel moisture content (%) based on McArthur (1966)
    '''
    ''' args:
    '''   temp: air temperature (C)
    '''   rh: relative humidity (%)
    
    FMC_grass = 9.58 - 0.205 * temp + 0.138 * rh
    FMC_grass = WorksheetFunction.Max(FMC_grass, 5)
End Function
Public Function curing_coeff_grass(curing As Single) As Single
    ''' returns the curing coefficient based on Cruz et al. (2015)
    '''
    ''' args
    '''   curing: degree of grass curing (%)
    
    curing_coeff_grass = 1.036 / (1 + 103.989 * Exp(-0.0996 * (curing - 20)))
End Function

Public Function moist_coeff_grass(U_10, mc As Single) As Single
    ''' returns the grass moisture coefficient
    '''
    ''' args
    '''   U_10: 10 m wind speed (km/h)
    '''   mc: fuel moisture content (%)
    
    If mc < 12 Then
        moist_coeff_grass = Exp(-0.108 * mc)
    Else
        If U_10 <= 10 Then
            moist_coeff_grass = 0.684 - 0.0342 * mc
        Else
            moist_coeff_grass = 0.547 - 0.0228 * mc
        End If
    End If
    
    moist_coeff_grass = WorksheetFunction.Max(moist_coeff_grass, 0.001)
    
End Function

Public Function ROS_grass(U_10, mc As Single, curing As Single, state As String) As Single
    ''' returns the forward ROS (m/h) ignoring slope
    '''
    ''' args
    '''   U_10: 10 m wind speed (km/h)
    '''   mc: fuel moisture content (%)
    '''   curing: degree of grass curing (%)
    '''   state: grass state (natural, grazed, eaten-out)
    
    Dim moist_coeff, curing_coeff As Single
    
    curing_coeff = curing_coeff_grass(curing)
    moist_coeff = moist_coeff_grass(U_10, (mc))
    
    Select Case state
        Case "natural"
            If U_10 < 5 Then
                ROS_grass = 0.054 + 0.269 * U_10
            Else
                ROS_grass = 1.4 + 0.838 * (U_10 - 5) ^ 0.844
            End If
        Case "grazed"
            If U_10 < 5 Then
                ROS_grass = 0.054 + 0.209 * U_10
            Else
                ROS_grass = 1.1 + 0.715 * (U_10 - 5) ^ 0.844
            End If
        Case "eaten-out"
            If U_10 < 5 Then
                ROS_grass = 0.054 + 0.209 * U_10
            Else
                ROS_grass = 0.55 + 0.357 * (U_10 - 5) ^ 0.844
            End If
    End Select
    
    ROS_grass = ROS_grass * 1000 * moist_coeff * curing_coeff
End Function

Public Function Flame_height_grass(ROS As Single, state As String) As Single
    ''' returns the flame height (m) based on M. Plucinski, pers. comm.
    '''
    ''' args
    '''   ROS: forward rate of spread (m/h)
    '''   state: grass state (natural, grazed, eaten-out)
    
    'adjust units to km/h
    ROS = ROS / 3600
    
    Select Case state
        Case "natural"
            Flame_height_grass = 2.66 * ROS ^ 0.295
        Case "grazed"
            Flame_height_grass = 1.12 * ROS ^ 0.295
        Case "eaten-out"
            Flame_height_grass = 1.12 * ROS ^ 0.295
    End Select
End Function

Public Function Intensity_grass(ByVal ROS As Double, ByVal fuel_load As Single) As Double
    ''' returns the fireline intensity (kW/m) based on Byram 1959
    ''' for grass fuel loads are limited to range 1 to 6 t/ha
    '''
    ''' args
    '''   ROS: forward rate of spread (km/h)
    '''   fuel_load: fine fuel load (t/ha)
    
    'limit fuel load to range 1 - 6
    fuel_load = WorksheetFunction.Max(1, fuel_load)
    fuel_load = WorksheetFunction.Min(6, fuel_load)
    Intensity_grass = intensity(ROS, fuel_load)
End Function

Public Function state_to_load_grass(state As String) As Single
    ''' returns the grass fuel load (t/ha)
    '''
    ''' args
    '''   state: the grass fuel state - eaten-out, grazed or natural
    
    Select Case state
        Case "natural"
            state_to_load_grass = 6
        Case "grazed"
            state_to_load_grass = 4.5
        Case "eaten-out"
            state_to_load_grass = 1.5
    End Select
End Function

Public Function load_to_state_grass(load As Single) As String
    ''' returns the grass fuel state - eaten-out, grazed or natural
    '''
    ''' args
    '''   load: the grass fuel load (t/ha)
    
    Select Case load
        Case Is >= 6
            load_to_state_grass = "natural"
        Case Is < 3
            load_to_state_grass = "eaten-out"
        Case Else
            load_to_state_grass = "grazed"
    End Select
End Function

Public Function enumerate_state_grass(state As String) As Integer
    ''' returns an enumerated value of the grass fuel state
    '''
    ''' args
    '''   state: the grass fuel state - eaten-out, grazed or natural
    
    Select Case state
        Case "natural"
            enumerate_state_grass = 3
        Case "grazed"
            enumerate_state_grass = 2
        Case "eaten-out"
            enumerate_state_grass = 1
    End Select
End Function

Public Function categorise_state_grass(state As Integer) As String
    ''' returns an categorical value of the grass fuel state
    '''
    ''' args
    '''   state: the grass fuel state - 1=eaten-out, 2=grazed or 3=natural
    
    Select Case state
        Case 3
            categorise_state_grass = "natural"
        Case 2
            categorise_state_grass = "grazed"
        Case 1
            categorise_state_grass = "eaten-out"
    End Select
End Function
