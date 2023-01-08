## AFDRS_spinifex

### Public Function fuel_cover_spinifex(time_since_fire, productivity) As Double
     return estimated spinifex fuel cover (live + dead) based on the midpoints of the ranges
     as reported in Burrows, N. D., Liddelow G.L. and Ward, B. (2015). A guide to estimating fire
     rate of spread in spinifex grasslands of Western Australia (Mk2v3).
     [Range for total fuel cover: 15 - 75]
     args
       time_since_fire: (y)
       productivity: based on the Carbon Farming Initiative mapping (CFI 2013), 1 arid fuels, 2 low rainfall, 3 high rainfall

### Public Function FMC_spinifex(AWAP_uf, time_since_fire, relative_humidity, air_temperature, productivity) As Double
     return the fuel moisture content (%)
     args
       AWAP_uf: monthly top level soil moisture (unitless 0-1)from http://www.sciro.au/awap
       time_since_fire: (y)
       relative_humidity: (%)
       air _temperature: (°C)
       productivity: based on the Carbon Farming Initiative mapping (CFI 2013), 1 arid fuels, 2 low rainfall, 3 high rainfall

### Public Function fuel_load_spinifex(time_since_fire, productivity, subtype) As Single
     return estimated fuel load (t/ha) [Range: 0-20 t/ha]
     Based on: pers. comm. Neil Burrows 16/10/2017.
     args
       time_since_fire: (y)
       productivity: based on the Carbon Farming Initiative mapping (CFI 2013), 1 arid fuels, 2 low rainfall, 3 high rainfall
       subtype: "open"  or "woodland"

### Public Function spread_index_spinifex(wind_speed, time_since_fire, dead_fuel_moisture, productivity) As Single
     returns the spread index (go/no-go).
     Very unlikely fire will spread at SI < 0. If SI > 0 fire is likely to spread.
     Based on:
     Burrows, N., Gill, M., and Sharples, J. (2018). Development and validation of a model for
     predicting fire behaviour in spinifex grasslands of arid Australia [IJWF].
     args
       wind_speed: mean 10 m wind speed (km/h)
       time_since_fire: (y)
       dead_fuel_moisture: (%)
       productivity: based on the Carbon Farming Initiative mapping (CFI 2013), 1 arid fuels, 2 low rainfall, 3 high rainfall

### Public Function ROS_spinifex(wind_speed, time_since_fire, dead_fuel_moisture, wind_reduction_savannah, productivity) As Double
     return the steady-state forward rate of spread (m/h)
     Based on:
     Burrows, N., Gill, M., and Sharples, J. (2018). Development and validation of a model for
     predicting fire behaviour in spinifex grasslands of arid Australia [IJWF].
     args
       wind_speed: mean 10 m wind speed (km/h)
       time_since_fire: (y)
       dead_fuel_moisture: (%)
       wind_reduction_savannah: unitless in range 0.3 to 1
       productivity: based on the Carbon Farming Initiative mapping (CFI 2013), 1 arid fuels, 2 low rainfall, 3 high rainfall

### Public Function intensity_spinifex(rate_of_spread, time_since_fire, productivity, subtype) As Double
     returns fire line intensity (kW/m)
     Based on definition in Byram, G. M. (1959). Combustion of forest fuels in Forest fire: control and use.(Ed. KP Davis) pp. 61 89.
     args
       rate_of_spread: steady-state forward rate of spread (m/h)
       time_since_fire: (y)
       productivity: based on the Carbon Farming Initiative mapping (CFI 2013), 1 arid fuels, 2 low rainfall, 3 high rainfall
       subtype: "open" or "woodland"

### Public Function flame_height_spinifex(rate_of_spread, time_since_fire, productivity, subtype) As Single
     returns flame height (m) [range: 0 - 6 m]
     Based on:
     Burrows, N., Gill, M., and Sharples, J. (2018). Development and validation of a model for
     predicting fire behaviour in spinifex grasslands of arid Australia [IJWF].
     args
       rate_of_spread: steady-state forward rate of spread (m/h)
       time_since_fire: (y)
       productivity: based on the Carbon Farming Initiative mapping (CFI 2013), 1 arid fuels, 2 low rainfall, 3 high rainfall
       subtype: "open" or "woodland"
