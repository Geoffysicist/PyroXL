Attribute VB_Name = "Leaflet_80"
Public Function FMC_Leaflet80(temp, rh As Single, time As Date) As Single
    ''' returns the fuel moisture content (%) as per Billy Tan 20 May 2024 (internal RFS)
    '''
    ''' args:
    '''   temp: air temperature (C)
    '''   rh: relative humidity (%)
    '''   time:
    
    start_desorption = 6
    end_desorption = 12
    
    If (Hour(time) < end_desorption) Then
        FMC_Leaflet80 = 12.519 + 0.122 * rh - 0.282 * temp
    Else
        FMC_Leaflet80 = 6.783 + 0.133 * rh - 0.17 * temp
        End If
    
End Function
Public Function U1_5_leaflet80(U10) As Single
    ''' returns the 1.5m wind speed km/h as per Billy Tan 20 May 2024 (internal RFS)
    '''
    ''' U10: 10m wind speed km/h
    U1_5_leaflet80 = 1.674 + 0.179 * U10
    
End Function

Public Function ROS_Leaflet80(U1_5, fmc, load) As Single
    '''  returns McArthur Leaflet 80 Rate of Spread as per Billy Tan 20 May 2024 (internal RFS).
    '''
    '''   U1_5: 1.5m wid speed km/h
    ''' fmc: fine fuel moisture content %
    '''   load: surface fine fuel load (t/ha)

    ROS_Leaflet80 = 60 * 0.22 * load * exp(0.158 * U1_5 - 0.227 * fmc)

End Function

Public Function Flame_height_leaflet80(load, ROS)
    ''' returns the flame height m
    '''
    ''' load: available fine fuel load t/ha
    ''' ROS: forward rate of spread m/h
    
    Flame_height_leaflet80 = 0.163 * Power(load, 0.862) * Power(ROS / 60, 0.89)
End Function

Public Function Scorch_height_leaflet80(flame_height)
    ''' returns the scorch height in m
    '''
    ''' flame_height: m
    
    Scorch_height_leaflet80 = 5.232 * Power(flame_height, 0.756)
End Function


