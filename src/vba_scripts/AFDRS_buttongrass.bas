Attribute VB_Name = "AFDRS_buttongrass"
Public Function FMC_buttongrass(temp, rh As Single) As Single
    ''' returns the grass fuel moisture content (%) based on McArthur (1966)
    '''
    ''' args:
    '''   temp: air temperature (C)
    '''   rh: relative humidity (%)
    '''   tsr: time since rain (h)
    '''   rain: rainfall (mm)
    '''   dew_pt: dewpoint temperature (c)
    
    FMC_buttongrass = (67.128 * (1-exp(-3.132 * rain)) * exp(-0.0858 * tsr)) +
                     (exp(1.660 + 0.0214 * rh - 0.0292 * dew_pt))
End Function

Public Function fuel_load_buttongrass(tsf, productivity) As Single
    ''' returns the curing coefficient based on Cruz et al. (2015)
    '''
    ''' args
    '''   tsf: time since fire (y)
    '''   productivity:
    
    Select Case productivity
        Case 1
            fuel_load_buttongrass = 11.73 * (1-exp(-0.106 * tsf))
        Case 2
            fuel_load_buttongrass = 44.61 * (1-exp(-0.041 * tsf))
    End Select
End Function

Public Function spread_prob_buttongrass(U_10, mc, productivity) As Single
    ''' returns the grass moisture coefficient
    '''
    ''' args
    '''   U_10: 10 m wind speed (km/h)
    '''   mc: fuel moisture content (%)
    '''   productivity:

    U_2 = U_10/1.2
    spread_prob_buttongrass = 1/(1+exp(-(-1 + 0.68 * U_2 - 0.07 * mc -
                          0.0037 * U_2 * mc + 2.1 * productivity)))
End Function

Public Function ROS_buttongrass(U_10, mc, spread_prob, tsf) As Single
    ''' returns the forward ROS (m/h) ignoring slope
    '''
    ''' args
    '''   U_10: 10 m wind speed (km/h)
    '''   mc: fuel moisture content (%)
    '''   tsf: time since fire (y))
    '''   spread_prob: Probability of spread
    
    U_2 = U_10 / 1.2

    ROS_buttongrass = 0.678 * power(U_2, 1.312) * exp(-0.0243*mc)*(1-exp(-0.116 * tsf)) * 60
    if spread_prob <= 0.5] then ROS_buttongrass = 0
End Function

Public Function Flame_height_buttongrass(Intensity_grass) As Single
    ''' returns the flame height (m) based on M. Plucinski, pers. comm.
    '''
    ''' args
    '''   intensity: fireline intensity (kW/m)
    
    Flame_height_buttongrass = 0.148 * power(intensity, 0.403)
End Function

