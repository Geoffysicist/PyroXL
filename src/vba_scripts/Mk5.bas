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

Public Function FMC_grass_Mk5(temp, rh As Single) As Single
    ''' returns the grass fuel moisture content (%) based on McArthur (1966)
    '''
    ''' args:
    '''   temp: air temperature (C)
    '''   rh: relative humidity (%)
    '''   curing: degree of grass curing (%)
    
    FMC_grass_Mk5 = (97.7 + 4.06 * rh) / (temp + 6) - 0.00854 * rh + 3000 / c - 30
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

