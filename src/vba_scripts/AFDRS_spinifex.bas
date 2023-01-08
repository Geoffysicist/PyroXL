Attribute VB_Name = "AFDRS_spinifex"
'constants
Private Const HEAT_CONTENT As Integer = 16700 'KJ/kg Malcolm Possell pers comm.
Private Const KGSQM_TO_TPH As Integer = 10
Private Const SECONDS_PER_HOUR As Integer = 3600 's
Private Const MAX_COVER As Integer = 75 '%

Public Function fuel_cover_spinifex(time_since_fire, productivity) As Double
    ''' return estimated spinifex fuel cover (live + dead) based on the midpoints of the ranges
    ''' as reported in Burrows, N. D., Liddelow G.L. and Ward, B. (2015). A guide to estimating fire
    ''' rate of spread in spinifex grasslands of Western Australia (Mk2v3).
    ''' [Range for total fuel cover: 15 - 75]
    '''
    ''' args
    '''   time_since_fire: (y)
    '''   productivity: based on the Carbon Farming Initiative mapping (CFI 2013), 1 arid fuels, 2 low rainfall, 3 high rainfall

    Select Case productivity
        Case 1
            fuel_cover_spinifex = 26.2 * Power(time_since_fire, 0.227)
        Case Else
            fuel_cover_spinifex = 1.5 * 26.2 * Power(time_since_fire, 0.227)
    End Select

    fuel_cover_spinifex = WorksheetFunction.Min(fuel_cover_spinifex, MAX_COVER)
End Function


Public Function FMC_spinifex(AWAP_uf, time_since_fire, relative_humidity, air_temperature, productivity) As Double
    ''' return the fuel moisture content (%)
    '''
    ''' args
    '''   AWAP_uf: monthly top level soil moisture (unitless 0-1)from http://www.sciro.au/awap
    '''   time_since_fire: (y)
    '''   relative_humidity: (%)
    '''   air _temperature: (°C)
    '''   productivity: based on the Carbon Farming Initiative mapping (CFI 2013), 1 arid fuels, 2 low rainfall, 3 high rainfall

    Select Case time_since_fire
        Case Is <= 3 And productivity <= 1
            FMC_spinifex = 200
        Case Is <= 11
            FMC_spinifex = (40 * AWAP_uf + 13)
        Case Is <= 16
            FMC_spinifex = (40 * AWAP_uf + 13) - (1 / (0.03 * relative_humidity)) * 1.5
            FMC_spinifex = WorksheetFunction.Max(FMC_spinifex, 14)
        Case Is <= 20
            FMC_spinifex = (40 * AWAP_uf + 13) - (1 / (0.03 * relative_humidity)) * 2.5
            FMC_spinifex = WorksheetFunction.Max(FMC_spinifex, 14)
        Case Else
            FMC_spinifex = (40 * AWAP_uf + 13) - (1 / (0.03 * relative_humidity)) * 3.5
            FMC_spinifex = WorksheetFunction.Max(FMC_spinifex, 14)
    End Select
    
    simard_moisture = 2.2279 + 0.160107 * relative_humidity - 0.014784 * air_temperature + 7#
    FMC_spinifex = WorksheetFunction.Max(FMC_spinifex, simard_moisture)
End Function

Public Function fuel_load_spinifex(time_since_fire, productivity, subtype) As Single
    ''' return estimated fuel load (t/ha) [Range: 0-20 t/ha]
    ''' Based on: pers. comm. Neil Burrows 16/10/2017.
    '''
    ''' args
    '''   time_since_fire: (y)
    '''   productivity: based on the Carbon Farming Initiative mapping (CFI 2013), 1 arid fuels, 2 low rainfall, 3 high rainfall
    '''   subtype: "open"  or "woodland"
    
    'Apply look up table values from BK analysis of CFI data
    Select Case productivity
        Case 2
            Select Case subtype
                Case "open"
                    Select Case time_since_fire
                        Case Is <= 1
                            fuel_load_spinifex = 1.28
                        Case Is <= 2
                            fuel_load_spinifex = 2.39
                        Case Is <= 3
                            fuel_load_spinifex = 3.36
                        Case Is <= 4
                            fuel_load_spinifex = 4.21
                        Case Is <= 5
                            fuel_load_spinifex = 4.96
                        Case Else
                            fuel_load_spinifex = 5.6
                    End Select
                Case "woodland"
                    Select Case time_since_fire
                        Case Is <= 1
                            fuel_load_spinifex = 2.01
                        Case Is <= 2
                            fuel_load_spinifex = 3.4
                        Case Is <= 3
                            fuel_load_spinifex = 4.38
                        Case Is <= 4
                            fuel_load_spinifex = 5.06
                        Case Is <= 5
                            fuel_load_spinifex = 5.53
                        Case Else
                            fuel_load_spinifex = 5.86
                    End Select
            End Select
        Case 3
            Select Case subtype
                Case "open"
                    Select Case time_since_fire
                        Case Is <= 1
                            fuel_load_spinifex = 3.58
                        Case Is <= 2
                            fuel_load_spinifex = 5.25
                        Case Is <= 3
                            fuel_load_spinifex = 6.73
                        Case Is <= 4
                            fuel_load_spinifex = 8.05
                        Case Is <= 5
                            fuel_load_spinifex = 9.21
                        Case Else
                            fuel_load_spinifex = 13.34
                    End Select
                Case "woodland"
                    Select Case time_since_fire
                        Case Is <= 1
                            fuel_load_spinifex = 3.78
                        Case Is <= 2
                            fuel_load_spinifex = 5.11
                        Case Is <= 3
                            fuel_load_spinifex = 5.95
                        Case Is <= 4
                            fuel_load_spinifex = 6.49
                        Case Is <= 5
                            fuel_load_spinifex = 6.84
                        Case Else
                            fuel_load_spinifex = 7.38
                    End Select
            End Select
        Case Else 'Default equation for productivity==1
            fuel_load_spinifex = 2.046 * Power(time_since_fire, 0.42)
    End Select

End Function

Public Function spread_index_spinifex(wind_speed, time_since_fire, dead_fuel_moisture, productivity) As Single
    ''' returns the spread index (go/no-go).
    ''' Very unlikely fire will spread at SI < 0. If SI > 0 fire is likely to spread.
    ''' Based on:
    ''' Burrows, N., Gill, M., and Sharples, J. (2018). Development and validation of a model for
    ''' predicting fire behaviour in spinifex grasslands of arid Australia [IJWF].
    '''
    ''' args
    '''   wind_speed: mean 10 m wind speed (km/h)
    '''   time_since_fire: (y)
    '''   dead_fuel_moisture: (%)
    '''   productivity: based on the Carbon Farming Initiative mapping (CFI 2013), 1 arid fuels, 2 low rainfall, 3 high rainfall
      
    wind_speed_2m = wind_speed / 1.35
    fuel_cover = fuel_cover_spinifex(time_since_fire, productivity)
    spread_index_spinifex = 0.412 * wind_speed_2m + 0.311 * fuel_cover - 0.676 * dead_fuel_moisture - 4.073
    'spread_index [np.isnan(spread_index)] = 0
End Function

Public Function ROS_spinifex(wind_speed, time_since_fire, dead_fuel_moisture, wind_reduction_savannah, productivity) As Double
    ''' return the steady-state forward rate of spread (m/h)
    ''' Based on:
    ''' Burrows, N., Gill, M., and Sharples, J. (2018). Development and validation of a model for
    ''' predicting fire behaviour in spinifex grasslands of arid Australia [IJWF].
    '''
    ''' args
    '''   wind_speed: mean 10 m wind speed (km/h)
    '''   time_since_fire: (y)
    '''   dead_fuel_moisture: (%)
    '''   wind_reduction_savannah: unitless in range 0.3 to 1
    '''   productivity: based on the Carbon Farming Initiative mapping (CFI 2013), 1 arid fuels, 2 low rainfall, 3 high rainfall
      
    wind_speed_2m = wind_speed / 1.35
    fuel_cover = fuel_cover_spinifex(time_since_fire, productivity)
    spread_index = spread_index_spinifex(wind_speed, time_since_fire, dead_fuel_moisture, productivity)
    
    ROS_spinifex = 40.982 * ((Power(wind_speed_2m, 1.399) * Power(fuel_cover, 1.201)) / (Power(dead_fuel_moisture, 1.699)))
    'ROS_spinifex [np.isnan(rate_of_spread)] = 0
    If (spread_index <= 0) Or (ROS_spinifex < 0) Then
        ROS_spinifex = 0
    End If
    
    'Modify rate_of_spread using wind_reduction_savannah [wind reduction values range between 0.3 and 1.0]
    ROS_spinifex = ROS_spinifex * wind_reduction_savannah
End Function
   
Public Function intensity_spinifex(rate_of_spread, time_since_fire, productivity, subtype) As Double
    ''' returns fire line intensity (kW/m)
    ''' Based on definition in Byram, G. M. (1959). Combustion of forest fuels in Forest fire: control and use.(Ed. KP Davis) pp. 61 89.
    '''
    ''' args
    '''   rate_of_spread: steady-state forward rate of spread (m/h)
    '''   time_since_fire: (y)
    '''   productivity: based on the Carbon Farming Initiative mapping (CFI 2013), 1 arid fuels, 2 low rainfall, 3 high rainfall
    '''   subtype: "open" or "woodland"
    
    fuel_load = fuel_load_spinifex(time_since_fire, productivity, subtype) '/ KGSQM_TO_TPH this conversion happens in intensity calc
    intensity_spinifex = intensity(rate_of_spread, fuel_load)
End Function

Public Function flame_height_spinifex(rate_of_spread, time_since_fire, productivity, subtype) As Single
    ''' returns flame height (m) [range: 0 - 6 m]
    ''' Based on:
    ''' Burrows, N., Gill, M., and Sharples, J. (2018). Development and validation of a model for
    ''' predicting fire behaviour in spinifex grasslands of arid Australia [IJWF].
    '''
    ''' args
    '''   rate_of_spread: steady-state forward rate of spread (m/h)
    '''   time_since_fire: (y)
    '''   productivity: based on the Carbon Farming Initiative mapping (CFI 2013), 1 arid fuels, 2 low rainfall, 3 high rainfall
    '''   subtype: "open" or "woodland"

    fuel_load = fuel_load_spinifex(time_since_fire, productivity, subtype)
    flame_height_spinifex = 0.097 * Power(rate_of_spread, 0.424) + 0.102 * fuel_load
End Function

    

    

