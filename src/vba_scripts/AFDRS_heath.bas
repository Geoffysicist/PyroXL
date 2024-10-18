Attribute VB_Name = "AFDRS_heath"
Public Function FMC_heath(temp, rh, rain, hours As Double) As Double
    ''' returns fuel moisture content (%). Based on:
    '''   Cruz, M., et al. (2010). Fire dynamics in mallee-heath: fuel, weather
    '''   and fire behaviour prediction in south Australian semi-arid shrublands.
    '''   Bushfire CRC Program A Rep 1(01).
    '''
    ''' In addition, a fuel moisture modifier based on recent rainfall was used. Marsden-Smedley, J. B.,
    ''' et al. (1999). Buttongrass moorland fire-behaviour prediction
    ''' and management. Tasforests 11: 87-107.
    '''
    ''' args
    '''   temp: air temperature (C)
    '''   rh: relative humidity (%)
    '''   rain: precipitation in the last 48 hours (mm)
    '''   hours: time since rain or dewfall stopped (h)
    
    Dim mc_1 As Double
    Dim mc_2 As Double
    
    mc_1 = 4.37 + 0.161 * rh - 0.1 * (temp - 25)
    If rh <= 60 Then
        mc_1 = mc_1 - 0.027 * rh
    End If
    mc_2 = 67.128 * (1 - exp(-3.132 * rain)) * exp(-0.0858 * hours)

    FMC_heath = mc_1 + mc_2
End Function

Public Function Mf_heath(mc As Double) As Double
    ''' returns the heathland moisture function
    '''
    ''' args
    '''   mc: fuel moisture content (%)
    
    Select Case mc
        Case Is < 4
            Mf_heath = exp(-0.0762 * 4)
        Case Is > 20
            Mf_heath = 0.05
        Case Else
            Mf_heath = exp(-0.0762 * mc)
    End Select
End Function

Public Function SI_heath(U_10, h_el, mc, waf) As Double
    ''' returns Spread Index.
    '''
    ''' args
    '''   U_10: 10 m wind speed (km/h)
    '''   h_el: elevated fuel height (m)
    '''   mc: fuel moisture content (%)
    '''   waf: wind adjustment factor
    
    Dim U_2 As Double: U_2 = U_10 * waf
    SI_heath = 2.57902560498943 + 0.175608738551563 * U_2 + 0.752448659028343 * h_el + 0.14916661946054 * h_el * U_2 - 0.430727111563859 * mc
    SI_heath = exp(SI_heath) / (1 + exp(SI_heath))
    
End Function
Public Function ROS_heath(U_10, h_el, mc As Double, SI, waf) As Double
    ''' returns forward rate of spread (m/h) [range: 0-6000 m/h]
    ''' Anderson, W. R., et al. (2015). "A generic, empirical-based model for predicting rate of fire
    ''' spread in shrublands." International Journal of Wildland Fire 24(4): 443-460.
    '''
    ''' args
    '''   U_10: 10 m wind speed (km/h)
    '''   h_el: elevated fuel height (m)
    '''   mc: fuel moisture content (%)
    '''   overstorey: presence or absence of woodland overstorey (true/false)
    '''   waf: wind adjustment factor
    
    Dim U_2 As Double: U_2 = U_10 * waf
    Dim sqrt_U_2 As Double: sqrt_U_2 = Sqr(U_2)
    'Dim SI As Double: SI = SI_heath(U2, h_el, mc)
    
    mc = mc / 100 'change to proportion
    Dim fmc As Double: fmc = Log(mc / (1 - mc))
    
    ROS_heath = 3.34696092119763 + 0.588661598397372 * sqrt_U_2 - 0.788551298241711 * fmc + 0.414992984575498 * Log(h_el)
    
    ROS_heath = SI * exp(ROS_heath)
    
End Function

Public Function intensity_heath(ROS, fuel_load) As Double
    ''' returns the fire line intensity (kW/m)
    '''
    ''' args
    '''   ROS: forward rate of spread (m/h)
    '''   fl_max: maximum fuel load (t/ha)
    '''   tsf: time since fire (y)
    '''   k: fuel accumulation curve constant
    
    'intensity_heath = intensity(ROS, fuel_load_)
    intensity_heath = 18600 * (fuel_load / 10) * (ROS / 3600)
End Function

Public Function Flame_height_heath(intensity As Double) As Double
    ''' returns flame height (m)
    ''' No equation for flame height was given in the Anderson et al. paper (2015).
    ''' Here we use the flame height calculation for mallee-heath shrublands (Cruz, M. G., et al. (2013).
    ''' "Fire behaviour modelling in semi-arid mallee-heath shrublands of southern Australia.
    ''' Environmental Modelling & Software 40: 21-34).
    '''
    ''' args
    '''   intensity: fire line intensity (kW/m)
    
    Flame_height_heath = exp(-4.142) * intensity ^ 0.633
End Function

Public Sub update_from_LUT_Heath()
    Dim FTno As Single
    FTno = Application.WorksheetFunction.VLookup(Range("ClassHeath").Value, Range("HeathLUT"), 2, False)
    
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
        Case "Heath", "Wet_heath" ' no diff in the models at this stage
            Range("fl_heath").Value = fuel_amount(LookupValueInTable(FTno, "FTno_State", "FL_total", lut, table), Range("tsf").Value, LookupValueInTable(FTno, "FTno_State", "Fk_total", lut, table))
    End Select
    
    Range("waf_heath").Value = LookupValueInTable(FTno, "FTno_State", "WF_Heath", lut, table)
    Range("h_el_heath").Value = LookupValueInTable(FTno, "FTno_State", "H_el", lut, table)
    
            
End Sub
