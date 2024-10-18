Attribute VB_Name = "AFDRS_woodland"
Public Function ROS_woodland(U_10, mc As Single, curing As Single, state As String, waf As Single) As Single
    ''' returns the forward ROS (m/h) ignoring slope
    ''' Based on:
    ''' Cheney, N. P., Gould, J. S., & Catchpole, W. R. (1998). Prediction of fire
    ''' spread in grasslands. International Journal of Wildland Fire, 8(1), 1-13.
    '''
    ''' Cruz, M. G., Gould, J. S., Kidnie, S., Bessell, R., Nichols, D., &
    ''' Slijepcevic, A. (2015). Effects of curing on grassfires: II. Effect of grass
    ''' senescence on the rate of fire spread. International Journal of Wildland
    ''' Fire, 24(6), 838-848.
    '''
    ''' args
    '''   U_10: 10 m wind speed (km/h)
    '''   mc: fuel moisture content (%)
    '''   curing: degree of grass curing (%)
    '''   subtype: woodland, acacia_woodland, woody_forticulture, rural, urban
    '''   state: grass state (natural, eaten out, grazed)
    '''   WAF: wind adjustment factor
    

    ROS_woodland = ROS_grass(U_10, mc, curing, state) * waf
End Function

Public Function FMC_woodland(temp, rh As Single) As Single
    ''' returns the woodland fuel moisture content (%)
    ''' uses grass fuel moisture content based on McArthur (1966)
    '''
    ''' args:
    '''   temp: air temperature (C)
    '''   rh: relative humidity (%)
    
    FMC_woodland = FMC_grass(temp, rh)
End Function

Public Function Flame_height_woodland(ROS As Single, state As String) As Single
    ''' returns the flame height (m) based on M. Plucinski, pers. comm.
    ''' uses the grass model
    '''
    ''' args
    '''   ROS: forward rate of spread (m/h)
    '''   state: grass state (natural, eaten out, grazed)
    

    Flame_height_woodland = Flame_height_grass(ROS, state)
End Function

Public Function Intensity_woodland(ByVal ROS As Double, ByVal fuel_load As Single) As Double
    ''' returns the fireline intensity (kW/m) based on Byram 1959
    '''
    ''' args
    '''   ROS: forward rate of spread (km/h)
    '''   fuel_load: fine fuel load (t/ha)
    
    Intensity_woodland = Intensity_grass(ROS, fuel_load)
End Function

Public Sub update_from_LUT_Woodland()
    Dim FTno As Single
    FTno = Application.WorksheetFunction.VLookup(Range("ClassWoodland").Value, Range("WoodlandLUT"), 2, False)
    
    Dim lut As String
    lut = "AFDRS Fuel LUT"
    Dim table As String
    table = "AFDRS_LUT"
    Dim fuel_sub_type As String
    fuel_sub_type = "Fuel_FDR"
    
    If Range("State").Value = "NSWv402" Then
        lut = "NSW_Fuel_v402_LUT"
        table = "NSW_fuel_LUT"
        fuel_sub_type = "AFDRS fuel type"
    End If
    
    
    Select Case LookupValueInTable(FTno, "FTno_State", fuel_sub_type, lut, table)
        Case "Acacia_woodland"
            Range("state_woodland").Value = "eaten-out"
        Case "Rural"
            Range("state_woodland").Value = "grazed"
        Case "Gamba"
            Range("state_woodland").Value = "natural"
    End Select
    
    Range("waf_woodland").Value = LookupValueInTable(FTno, "FTno_State", "WF_Sav", lut, table)
            
End Sub
