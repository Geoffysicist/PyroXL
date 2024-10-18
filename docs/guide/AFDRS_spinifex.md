## AFDRS_spinifex

### Public Function fuel_cover_spinifex(time_since_fire, subtype) As Double
     return estimated spinifex fuel cover
     Based on: Holmes AW, Krix D, Burrows ND, Kristina A, Jenkins M (2023)
     Adapting fire behaviour models in spinifex grasslands of arid australia to incorporate AWRA-Lv7 root zone soil moisture.
     args
       time_since_fire: (y)
       subtype: "open"  or "woodland"

### Public Function FMC_spinifex(AWAP_uf, time_since_fire, relative_humidity, air_temperature, subtype) As Double
     return the fuel moisture content (%)
     Based on: Holmes AW, Krix D, Burrows ND, Kristina A, Jenkins M (2023)
     Adapting fire behaviour models in spinifex grasslands of arid australia to incorporate AWRA-Lv7 root zone soil moisture.
     args
       AWAP_uf: monthly top level soil moisture (unitless 0-1)from http://www.sciro.au/awap
       time_since_fire: (y)
       relative_humidity: (%)
       air _temperature: (°C)
       subtype: "open"  or "woodland"

### Public Function fuel_load_spinifex(time_since_fire, subtype) As Single
     return estimated fuel load (t/ha) [Range: 0-20 t/ha]
     Based on: Holmes AW, Krix D, Burrows ND, Kristina A, Jenkins M (2023)
     Adapting fire behaviour models in spinifex grasslands of arid australia to incorporate AWRA-Lv7 root zone soil moisture.
     args
       time_since_fire: (y)
       subtype: "open"  or "woodland"

### Public Function spread_index_spinifex(wind_speed_10m, fuel_moisture, fuel_cover, wrf) As Single
     returns the spread index (go/no-go).
     Very unlikely fire will spread at SI < 0. If SI > 0 fire is likely to spread.
     Based on: Holmes AW, Krix D, Burrows ND, Kristina A, Jenkins M (2023)
     Adapting fire behaviour models in spinifex grasslands of arid australia to incorporate AWRA-Lv7 root zone soil moisture.
     args
       wind_speed_10m: mean 10 m wind speed (km/h)
       fuel_moisture: combined dead & live fuel moisture(%)
       fuel_cover: total fuel cover (%)
       wrf:

### Public Function ROS_spinifex(wind_speed_10m, time_since_fire, fuel_moisture, wrf, subtype) As Double
     return the steady-state forward rate of spread (m/h)
     Based on:
     Burrows, N., Gill, M., and Sharples, J. (2018). Development and validation of a model for
     predicting fire behaviour in spinifex grasslands of arid Australia [IJWF].
     args
       wind_speed_10m: mean 10 m wind speed (km/h)
       fuel_moisture: combined dead & live fuel moisture(%)
       fuel_cover: total fuel cover (%)
       wrf:

### Public Function intensity_spinifex(rate_of_spread, time_since_fire, subtype) As Double
     returns fire line intensity (kW/m)
     Based on definition in Byram, G. M. (1959). Combustion of forest fuels in Forest fire: control and use.(Ed. KP Davis) pp. 61 89.
     args
       rate_of_spread: steady-state forward rate of spread (m/h)
       time_since_fire: (y)
       subtype: "open" or "woodland"

### Public Function flame_height_spinifex(rate_of_spread, time_since_fire, subtype) As Single
     returns flame height (m) [range: 0 - 6 m]
     Based on:
     Burrows, N., Gill, M., and Sharples, J. (2018). Development and validation of a model for
     predicting fire behaviour in spinifex grasslands of arid Australia [IJWF].
     args
       rate_of_spread: steady-state forward rate of spread (m/h)
       time_since_fire: (y)
       subtype: "open" or "woodland"

### Public Sub update_from_LUT_Spinifex()
