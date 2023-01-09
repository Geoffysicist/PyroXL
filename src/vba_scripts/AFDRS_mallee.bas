Attribute VB_Name = "AFDRS_mallee"
Public Function FMC_mallee( _
    air_temperature, relative_humidity, date_ As Date, time As Date, precipitation, time_since_rain _
    ) As Double
    ''' return fuel moisture content (%). Based on:
    '''   Cruz, M., et al. (2010). Fire dynamics in mallee-heath: fuel, weather
    '''   and fire behaviour prediction in south Australian semi-arid shrublands.
    '''   Bushfire CRC Program A Rep 1(01).
    '''
    ''' In addition, a fuel moisture modifier based on recent rainfall was used. Marsden-Smedley, J. B.,
    ''' et al. (1999). Buttongrass moorland fire-behaviour prediction
    ''' and management. Tasforests 11: 87-107.
    ''' Precipitation in mm. Time_since_rain in hours.
    ''' args
    '''   air_temperature: air temperature (C)
    '''   relative_humidity: relative humidity (%)
    '''   date_: (underscore due to VBA Date objects)
    '''   time: 24 hour time format
    '''   precipitation: precipitation in the last 48 hours (mm)
    '''   time_since_rain: time since rain or dewfall stopped (h)
    
    Dim start_peak_month, end_peak_month As Integer
    Dim start_afternoon, end_afternoon As Integer
    Dim sunrise, sunset As Integer
    
    start_peak_month = 10 'October
    end_peak_month = 3 'March
    start_afternoon = 12
    end_afternoon = 17
    'HEAT_CONTENT = 18600 'kJ/kg 'TODO how did this stuff end up in here?
    'KGSQM_TO_TPH = 10#
    'SECONDS_PER_HOUR = 3600 's
    'FLAME_HEIGHT_CROWN_FRACTION = 0.66 'm
    months = Month(date_)
    hours = Hour(time)
    
    If ((months >= start_peak_month) Or (months <= end_peak_month)) And _
        (hours >= start_afternoon) And (hours <= end_afternoon) Then
        FMC_mallee = (4.79 + 0.173 * relative_humidity - 0.1 * _
            (air_temperature - 25) - 0.027 * relative_humidity)
    Else
        FMC_mallee = 4.79 + 0.173 * relative_humidity - 0.1 * (air_temperature - 25)
    End If
        
    FMC_mallee = FMC_mallee + 67.128 * (1 - exp(-3.132 * precipitation)) * exp(-0.0858 * time_since_rain)
End Function

Public Function spread_prob_mallee(wind_speed, fuel_moisture, overstorey_cover) As Double
    ''' return the likelihood of spread sustainability (go/no-go) [value between 0 and 1].
    ''' Based on: Cruz, M. G., et al. (2013). "Fire behaviour modelling in semi-arid
    ''' mallee-heath shrublands of southern Australia." Environmental Modelling & Software 40: 21-34.
    '''
    ''' args
    '''   wind_speed: 10 m wind speed(km/h)
    '''   fuel_moisture: dead fuel moisture content (%)
    '''   overstorey_cover: (%)
   
    spread_prob_mallee = (1 / (1 + exp(-(14.624 + 0.2066 * wind_speed - 1.8719 * fuel_moisture - 0.030442 * overstorey_cover))))
End Function

Public Function crown_prob_mallee(wind_speed, fuel_moisture) As Double
    ''' type of fire, i.e. surface fire, crown fire, or an ensemble of the two, based on
    ''' crown probability [value between 0 and 1].
    ''' Based on: Cruz, M. G., et al. (2013). "Fire behaviour modelling in semi-arid
    ''' mallee-heath shrublands of southern Australia." Environmental Modelling & Software 40: 21-34.
    '''
    ''' args
    '''   wind_speed: 10 m wind speed(km/h)
    '''   fuel_moisture: dead fuel moisture content (%)
    
    crown_prob_mallee = 1 / (1 + exp(-(-11.138 + 1.4054 * wind_speed - 3.4217 * fuel_moisture)))
End Function


Public Function ROS_mallee(wind_speed, fuel_moisture, overstorey_cover, overstorey_height) As Double
    ''' return rate of spread (m/h) [Range = 0 - 8000].
    ''' Based on: Cruz, M. G., et al. (2013). "Fire behaviour modelling in semi-arid
    ''' mallee-heath shrublands of southern Australia." Environmental Modelling & Software 40: 21-34.
    '''
    ''' args
    '''   wind_speed: 10 m wind speed(km/h)
    '''   fuel_moisture: dead fuel moisture content (%)
    '''   overstorey_cover: (%)
    '''   overstorey_height: (m)
    
    spread_probability = spread_prob_mallee(wind_speed, fuel_moisture, overstorey_cover)
    crown_probability = crown_prob_mallee(wind_speed, fuel_moisture)
    
    ros_surface = 3.337 * wind_speed * exp(-0.1284 * fuel_moisture) * Power(overstorey_height, -0.7073) * 60
    ros_crown = 9.5751 * wind_speed * exp(-0.1795 * fuel_moisture) * Power((overstorey_cover / 100), 0.3589) * 60
    
    If spread_probability < 0.5 Then
        ROS_mallee = 0
    ElseIf crown_probability <= 0.01 Then
        ROS_mallee = ros_surface
    ElseIf crown_probability > 0.99 Then
        ROS_mallee = ros_crown
    Else
        ROS_mallee = ros_surface * (1 - crown_probability) + ros_crown * crown_probability
    End If
End Function

Public Function fuel_load_mallee( _
    wind_speed, time_since_fire, fuel_moisture, fuel_load_surface, fuel_load_canopy, Optional k_surface, Optional k_canopy _
    ) As Double
    ''' return fuel load based on crown probability.
    ''' if fuel loads are know don't pass the k values as arguments
    ''' if k values passed then use exponetial decay model to adjust fuel for age (fuel build-up).
    ''' Based on Olson, J. S. (1963). Energy storage and the balance of producers
    ''' and decomposers in ecological systems. Ecology, 44(2), 322-331.
    ''' Include canopy fuel based on crown_probability (Cruz pers. comm.).
    '''
    ''' args
    '''   wind_speed: 10 m wind speed(km/h)
    '''   fuel_moisture: dead fuel moisture content (%)
    '''   fuel_load_surface: maximum surface fuel load (t/ha)
    '''   fuel_load_canopy: maximum canopy fuel load (t/ha)
    '''   k_surface: surface fuel accumulation constant
    '''   k_canopy: canopy fuel accumulation constant
    
    crown_probability = crown_prob_mallee(wind_speed, fuel_moisture)
    If Not IsMissing(k_surface) Then
        fuel_load_surface = fuel_amount(fuel_load_surface, time_since_fire, k_surface)
    End If
    
    If Not IsMissing(k_canopy) Then
        fuel_load_canopy = fuel_amount(fuel_load_canopy, time_since_fire, k_canopy)
    End If
    
    Select Case crown_probability
        Case Is <= 0.01
            fuel_load_mallee = fuel_load_surface
        Case Is > 0.99
            fuel_load_mallee = fuel_load_surface + fuel_load_canopy
        Case Else
            fuel_load_mallee = fuel_load_surface + crown_probability * fuel_load_canopy
    End Select
End Function

Public Function flame_height_mallee(Intensity) As Double
    flame_height_mallee = exp(-4.142) * Power(Intensity, 0.633)
End Function

Public Function FBI_mallee(wind_speed, fuel_moisture, overstorey_cover, Intensity) As Integer
    ''' returns the AFDRS FBI for mallee
    '''
    ''' args
    '''   wind_speed: 10 m wind speed(km/h)
    '''   fuel_moisture: dead fuel moisture content (%)
    '''   overstorey_cover: (%)
    '''   intensity: fire line intensity (kW/m)
    
    Dim intensity_ha As Double 'arbitrary high anchor for intensity
    Dim fbi_ha As Integer 'arbitrary high anchor for fbi
    Dim param_la, param_ua, fbi_la, fbi_ua As Integer 'upper and lower anchors for parameter and fbi
    
    'use same fbi bounds, fbi high anchor and intensity high anchor for all classes
    fbi_b = Array(0, 6, 12, 24, 50, 100)
    fbi_ha = 200
    param_ha = 90000
    
    spread_probability = spread_prob_mallee(wind_speed, fuel_moisture, overstorey_cover)
    crown_probability = crown_prob_mallee(wind_speed, fuel_moisture)

    Select Case spread_probability
        Case Is < 0.5 'category 1
            param = spread_probability
            param_ua = 0.5
            param_la = 0
            fbi_ua = fbi_b(1)
            fbi_la = fbi_b(0)
        Case Else
            Select Case crown_probability
                Case Is < 0.33 'category 2
                    param = crown_probability
                    param_ua = 0.33
                    param_la = 0
                    fbi_ua = fbi_b(2)
                    fbi_la = fbi_b(1)
                Case Is >= 0.66
                    param = Intensity
                    Select Case Intensity
                        Case Is < 20000 'category 4
                            param_ua = 20000
                            param_la = 0
                            fbi_ua = fbi_b(4)
                            fbi_la = fbi_b(3)
                        Case Is >= 40000 'category 6
                            param_ua = param_ha
                            param_la = 40000
                            fbi_ua = fbi_ha
                            fbi_la = fbi_b(5)
                        Case Else 'category 5
                            param_ua = 40000
                            param_la = 20000
                            fbi_ua = fbi_b(5)
                            fbi_la = fbi_b(4)
                    End Select
                Case Else 'category 3
                    param = crown_probability
                    param_ua = 0.66
                    param_la = 0.66
                    fbi_ua = fbi_b(3)
                    fbi_la = fbi_b(2)
            End Select
    End Select
   
    FBI_mallee = fbi_la + (fbi_ua - fbi_la) * (param - param_la) / (param_ua - param_la)
    FBI_mallee = Int(FBI_mallee) 'FBI needs to be truncated for National consistency
End Function
