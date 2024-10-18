Attribute VB_Name = "AFDRS_spinifex"
'constants
Private Const HEAT_CONTENT As Integer = 16700 'KJ/kg Malcolm Possell pers comm.
Private Const KGSQM_TO_TPH As Integer = 10
Private Const SECONDS_PER_HOUR As Integer = 3600 's
Private Const MAX_COVER As Integer = 75 '%

Public Function fuel_cover_spinifex(time_since_fire, subtype) As Double
    ''' return estimated spinifex fuel cover
    ''' Based on: Holmes AW, Krix D, Burrows ND, Kristina A, Jenkins M (2023)
    ''' Adapting fire behaviour models in spinifex grasslands of arid australia to incorporate AWRA-Lv7 root zone soil moisture.
    '''
    ''' args
    '''   time_since_fire: (y)
    '''   subtype: "open"  or "woodland"

    fuel_cover_spinifex = -2.55991763 - 0.03838217 * time_since_fire + 1.10476581 * Log(time_since_fire)
    If subtype = "woodland" Then fuel_cover_spinifex = (fuel_cover_spinifex - 0.13992188 + 0.12047025 * Log(time_since_fire))
    fuel_cover_spinifex = (1 / (1 + exp(-fuel_cover_spinifex))) * 100
    
End Function


Public Function FMC_spinifex(AWAP_uf, time_since_fire, relative_humidity, air_temperature, subtype) As Double
    ''' return the fuel moisture content (%)
    ''' Based on: Holmes AW, Krix D, Burrows ND, Kristina A, Jenkins M (2023)
    ''' Adapting fire behaviour models in spinifex grasslands of arid australia to incorporate AWRA-Lv7 root zone soil moisture.
    '''
    ''' args
    '''   AWAP_uf: monthly top level soil moisture (unitless 0-1)from http://www.sciro.au/awap
    '''   time_since_fire: (y)
    '''   relative_humidity: (%)
    '''   air _temperature: (°C)
    '''   subtype: "open"  or "woodland"
    
    time_since_fire = WorksheetFunction.Min(25, time_since_fire) 'AFDRS limits TSF to 25 years
    
    fuel_cover = fuel_cover_spinifex(time_since_fire, subtype)

    Dim vpd As Double
    vpd = vp_deficit(air_temperature, relative_humidity)
    
    Dim dead, live, pct_dead As Single
    
    pct_dead = -4.0936696 + 0.8619864 * time_since_fire - 1.613603 * Log(time_since_fire) - 0.1739302 * time_since_fire * Log(time_since_fire)
    pct_dead = (1 / (1 + exp(-pct_dead))) * 100 'TODO: check why this is not * 100, but the others are not - I have ammended
    
    live = (0.419130229421894 + 0.158980195 * Sqr(AWAP_uf) - 0.271357085 * Sqr(fuel_cover) - 0.007380343 * vpd)
    live = (1 / (1 + exp(-live))) * 100
    
    dead = -9.34004475 - 0.37649308 * relative_humidity + 3.17594774 * Log(relative_humidity) + 0.06805771 * relative_humidity * Log(relative_humidity)
    dead = (1 / (1 + exp(-dead))) * 100
    
    'FMC_spinifex = dead
    FMC_spinifex = ((live * (fuel_cover - pct_dead)) + (dead * pct_dead)) / fuel_cover
End Function

Public Function fuel_load_spinifex(time_since_fire, subtype) As Single
    ''' return estimated fuel load (t/ha) [Range: 0-20 t/ha]
    ''' Based on: Holmes AW, Krix D, Burrows ND, Kristina A, Jenkins M (2023)
    ''' Adapting fire behaviour models in spinifex grasslands of arid australia to incorporate AWRA-Lv7 root zone soil moisture.
    '''
    ''' args
    '''   time_since_fire: (y)
    '''   subtype: "open"  or "woodland"
    
    time_since_fire = WorksheetFunction.Min(25, time_since_fire) 'AFDRS limits TSF to 25 years
    
    fuel_load_spinifex = -0.6892583 - 0.0360736 * time_since_fire + 1.1552554 * Log(time_since_fire)
    
    If subtype = "woodland" Then fuel_load_spinifex = (fuel_load_spinifex + 0.4253039 - 0.1723223 * Log(time_since_fire))
    
    fuel_load_spinifex = exp(fuel_load_spinnifex)

End Function

Public Function spread_index_spinifex(wind_speed_10m, fuel_moisture, fuel_cover, wrf) As Single
    ''' returns the spread index (go/no-go).
    ''' Very unlikely fire will spread at SI < 0. If SI > 0 fire is likely to spread.
    ''' Based on: Holmes AW, Krix D, Burrows ND, Kristina A, Jenkins M (2023)
    ''' Adapting fire behaviour models in spinifex grasslands of arid australia to incorporate AWRA-Lv7 root zone soil moisture.
    '''
    ''' args
    '''   wind_speed_10m: mean 10 m wind speed (km/h)
    '''   fuel_moisture: combined dead & live fuel moisture(%)
    '''   fuel_cover: total fuel cover (%)
    '''   wrf:
      
    Dim intercept_value, wind_speed_coefficient, fuel_moisture_coefficient, fuel_cover_coefficient As Double
    intercept_value = -5.85681251780825
    wind_speed_coefficient = 0.336940088553979
    fuel_moisture_coefficient = -0.496404135425536
    fuel_cover_coefficient = 0.272475260353266

    wind_speed_2m = wind_speed_10m * wrf

    'calculate the linear predictions
    lin_preds = (intercept_value + (wind_speed_coefficient * wind_speed_2m) + (fuel_moisture_coefficient * fuel_moisture) + (fuel_cover_coefficient * fuel_cover))

    'convert to spread index
    spread_index_spinifex = exp(lin_preds) / (1 + exp(lin_preds))
    spread_index_spinifex = WorksheetFunction.Round(spread_index_spinifex, 0)
End Function

Public Function ROS_spinifex(wind_speed_10m, time_since_fire, fuel_moisture, wrf, subtype) As Double
    ''' return the steady-state forward rate of spread (m/h)
    ''' Based on:
    ''' Burrows, N., Gill, M., and Sharples, J. (2018). Development and validation of a model for
    ''' predicting fire behaviour in spinifex grasslands of arid Australia [IJWF].
    '''
    ''' args
    '''   wind_speed_10m: mean 10 m wind speed (km/h)
    '''   fuel_moisture: combined dead & live fuel moisture(%)
    '''   fuel_cover: total fuel cover (%)
    '''   wrf:
       
    wind_speed_2m = wind_speed_10m * wrf
    fuel_cover = fuel_cover_spinifex(time_since_fire, subtype)
    spread_index = spread_index_spinifex(wind_speed_10m, fuel_moisture, fuel_cover, wrf)
    
    ROS_spinifex = 40.982 * ((Power(wind_speed_2m, 1.399) * Power(fuel_cover, 1.201)) / (Power(fuel_moisture, 1.699)))
    
    If (spread_index <= 0) Or (ROS_spinifex < 0) Then
        ROS_spinifex = 0
    End If

End Function
   
Public Function intensity_spinifex(rate_of_spread, time_since_fire, subtype) As Double
    ''' returns fire line intensity (kW/m)
    ''' Based on definition in Byram, G. M. (1959). Combustion of forest fuels in Forest fire: control and use.(Ed. KP Davis) pp. 61 89.
    '''
    ''' args
    '''   rate_of_spread: steady-state forward rate of spread (m/h)
    '''   time_since_fire: (y)
    '''   subtype: "open" or "woodland"
    
    fuel_load = fuel_load_spinifex(time_since_fire, subtype) '/ KGSQM_TO_TPH this conversion happens in intensity calc
    intensity_spinifex = intensity(rate_of_spread, fuel_load)
End Function

Public Function flame_height_spinifex(rate_of_spread, time_since_fire, subtype) As Single
    ''' returns flame height (m) [range: 0 - 6 m]
    ''' Based on:
    ''' Burrows, N., Gill, M., and Sharples, J. (2018). Development and validation of a model for
    ''' predicting fire behaviour in spinifex grasslands of arid Australia [IJWF].
    '''
    ''' args
    '''   rate_of_spread: steady-state forward rate of spread (m/h)
    '''   time_since_fire: (y)
    '''   subtype: "open" or "woodland"

    fuel_load = fuel_load_spinifex(time_since_fire, subtype)
    flame_height_spinifex = 0.097 * Power(rate_of_spread, 0.424) + 0.102 * fuel_load
End Function

Public Sub update_from_LUT_Spinifex()
    Dim FTno As Single
    FTno = Application.WorksheetFunction.VLookup(Range("ClassSpinifex").Value, Range("SpinifexLUT"), 2, False)
    
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
        Case "Spinifex_woodland"
            Range("subtype_spinifex").Value = "woodland"
        Case Else
            Range("subtype_spinifex").Value = "open"
    End Select
    

    Range("waf_spinifex").Value = LookupValueInTable(FTno, "FTno_State", "WF_Sav", lut, table)
End Sub


    

