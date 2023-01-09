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

Public Function ROS_heath(U_10, h_el, mc As Double, overstorey As Boolean) As Double
    ''' returns forward rate of spread (m/h) [range: 0-6000 m/h]
    ''' Anderson, W. R., et al. (2015). "A generic, empirical-based model for predicting rate of fire
    ''' spread in shrublands." International Journal of Wildland Fire 24(4): 443-460.
    '''
    ''' args
    '''   U_10: 10 m wind speed (km/h)
    '''   h_el: elevated fuel height (m)
    '''   mc: fuel moisture content (%)
    '''   overstorey: presence or absence of woodland overstorey (true/false)
    
    Dim mf As Double 'fuel moisture factor
    mf = Mf_heath(mc)
    
    'wrf depends on presence or absence of woodland overstorey
    Dim wrf As Double: wrf = 0.667
     
    If overstorey = True Then
        wrf = 0.35
    End If
    
    
    ROS_heath = 5.6715 * (wrf * U_10) ^ 0.912 * h_el ^ 0.227 * mf * 60
    
    'apply go-nogo correction
    ROS_heath = ROS_heath / (1 + exp(-0.4 * (wrf * U_10 - 20)))
    ROS_heath = ROS_heath / (1 + exp(-0.4 * (12 - mc)))
    
End Function
Public Function intensity_heath(ROS, fl_max, tsf, k) As Double
    ''' returns the fire line intensity (kW/m)
    '''
    ''' args
    '''   ROS: forward rate of spread (m/h)
    '''   fl_max: maximum fuel load (t/ha)
    '''   tsf: time since fire (y)
    '''   k: fuel accumulation curve constant
    
    Dim fuel_load_ As Double
    fuel_load_ = fl_max * (1 - exp(-1 * tsf * k)) 'fuel_load(fl_max, tsf, k)
    
    'intensity_heath = intensity(ROS, fuel_load_)
    intensity_heath = 18600 * (fuel_load_ / 10) * (ROS / 3600)
End Function

Public Function Flame_height_heath(Intensity As Double) As Double
    ''' returns flame height (m)
    ''' No equation for flame height was given in the Anderson et al. paper (2015).
    ''' Here we use the flame height calculation for mallee-heath shrublands (Cruz, M. G., et al. (2013).
    ''' "Fire behaviour modelling in semi-arid mallee-heath shrublands of southern Australia.
    ''' Environmental Modelling & Software 40: 21-34).
    '''
    ''' args
    '''   intensity: fire line intensity (kW/m)
    
    Flame_height_heath = exp(-4.142) * Intensity ^ 0.633
End Function
