Attribute VB_Name = "Mk5"
Public Function GFDI(U10, load, fmc) As Single
    '''  returns McArthur Mk5 Grass Fire Danger Index from Noble et al. 1980.
    '''
    '''   U_10: 10 m wind speed (km/h)
    '''   load: grass fuel load (t/ha)
    '''   fmc: fuel moisture content (%)

    If fmc < 18.8 Then
        GFDI = 3.35 * load * exp(-0.0897 * fmc + 0.0403 * U10)
    ElseIf fmc >= 30 Then
        GFDI = 0
    Else
        GFDI = 0.299 * load * exp(-1.686 * fmc + 0.0403 * U10) * (30 - fmc)
    End If
End Function

Public Function FMC_grass_Mk5(temp, rh As Single, curing) As Single
    ''' returns the grass fuel moisture content (%) based on McArthur (1966)
    '''
    ''' args:
    '''   temp: air temperature (C)
    '''   rh: relative humidity (%)
    '''   curing: degree of grass curing (%)
    
    FMC_grass_Mk5 = (97.7 + 4.06 * rh) / (temp + 6) - 0.00854 * rh + 3000 / curing - 30
End Function

Public Function FMC_Mk5(temp, rh As Single) As Single
    ''' returns the fuel moisture content (%) based on McArthur FFDM (1967. 1973a)
    '''
    ''' args:
    '''   temp: air temperature (C)
    '''   rh: relative humidity (%)
    
    FMC_Mk5 = 5.658 + 0.04651 * rh + 0.0003151 * rh ^ 3 * temp ^ (-1) - 0.184 *  temp ^ 0.77
End Function

Public Function Flame_height_forest_Mk5(ROS As Double, h_el As Single) As Single
    ''' returns the flame height (m)
    '''
    ''' args
    '''   ROS - forward rate of spread (m/h)
    '''   load: fine fuel load (t/ha)
    
    'KT version with slope
    'Flame_height_forest_Mk5 = 13 * ROS / Exp(0.069 * slope) / 1000 + 0.24 * load - 2
    
    ' version from noble et al. 1980
    Flame_height_forest = 13 * ROS + 0.24 * load - 2
End Function

Public Function ffdi(temp, rh, DF, U10, Optional wrf = 3) As Single
    '''  returns McArthur Mk5 Forest Fire Danger Index from Noble et al. 1980.
    '''
    '''   temp: air temperature (C)
    '''   rh: relative humidity (%)
    '''   DF: drought factor
    '''   U_10: 10 m wind speed (km/h)
    
    U10 = U10 * 3 / wrf
    
    ffdi = 2 * exp(-0.45 + 0.987 * Log(DF) - 0.0345 * rh + 0.0338 * temp + 0.0234 * U10)

End Function

Public Function ROS_Mk5(ffdi, load) As Single
    '''  returns McArthur Mk5 Rate of Spread from Noble et al. 1980.
    '''
    '''   ffdi: FFDi
    '''   load: fine fuel load (t/ha)

    ROS_Mk5 = 1.2 * ffdi * load

End Function
