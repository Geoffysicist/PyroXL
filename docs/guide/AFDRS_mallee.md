## AFDRS_mallee

### Public Function FMC_mallee( _
     return fuel moisture content (%). Based on:
       Cruz, M., et al. (2010). Fire dynamics in mallee-heath: fuel, weather
       and fire behaviour prediction in south Australian semi-arid shrublands.
       Bushfire CRC Program A Rep 1(01).
     In addition, a fuel moisture modifier based on recent rainfall was used. Marsden-Smedley, J. B.,
     et al. (1999). Buttongrass moorland fire-behaviour prediction
     and management. Tasforests 11: 87-107.
     Precipitation in mm. Time_since_rain in hours.
     args
       air_temperature: air temperature (C)
       relative_humidity: relative humidity (%)
       date_: (underscore due to VBA Date objects)
       time: 24 hour time format
       precipitation: precipitation in the last 48 hours (mm)
       time_since_rain: time since rain or dewfall stopped (h)

### Public Function spread_prob_mallee(wind_speed, fuel_moisture, overstorey_cover) As Double
     return the likelihood of spread sustainability (go/no-go) [value between 0 and 1].
     Based on: Cruz, M. G., et al. (2013). "Fire behaviour modelling in semi-arid
     mallee-heath shrublands of southern Australia." Environmental Modelling & Software 40: 21-34.
     args
       wind_speed: 10 m wind speed(km/h)
       fuel_moisture: dead fuel moisture content (%)
       overstorey_cover: (%)

### Public Function crown_prob_mallee(wind_speed, fuel_moisture) As Double
     type of fire, i.e. surface fire, crown fire, or an ensemble of the two, based on
     crown probability [value between 0 and 1].
     Based on: Cruz, M. G., et al. (2013). "Fire behaviour modelling in semi-arid
     mallee-heath shrublands of southern Australia." Environmental Modelling & Software 40: 21-34.
     args
       wind_speed: 10 m wind speed(km/h)
       fuel_moisture: dead fuel moisture content (%)

### Public Function ROS_mallee(wind_speed, fuel_moisture, overstorey_cover, overstorey_height) As Double
     return rate of spread (m/h) [Range = 0 - 8000].
     Based on: Cruz, M. G., et al. (2013). "Fire behaviour modelling in semi-arid
     mallee-heath shrublands of southern Australia." Environmental Modelling & Software 40: 21-34.
     args
       wind_speed: 10 m wind speed(km/h)
       fuel_moisture: dead fuel moisture content (%)
       overstorey_cover: (%)
       overstorey_height: (m)

### Public Function fuel_load_mallee( _
     return fuel load based on crown probability.
     if fuel loads are know don't pass the k values as arguments
     if k values passed then use exponetial decay model to adjust fuel for age (fuel build-up).
     Based on Olson, J. S. (1963). Energy storage and the balance of producers
     and decomposers in ecological systems. Ecology, 44(2), 322-331.
     Include canopy fuel based on crown_probability (Cruz pers. comm.).
     args
       wind_speed: 10 m wind speed(km/h)
       fuel_moisture: dead fuel moisture content (%)
       fuel_load_surface: maximum surface fuel load (t/ha)
       fuel_load_canopy: maximum canopy fuel load (t/ha)
       k_surface: surface fuel accumulation constant
       k_canopy: canopy fuel accumulation constant

### Public Function flame_height_mallee(Intensity) As Double

### Public Function FBI_mallee(wind_speed, fuel_moisture, overstorey_cover, Intensity) As Integer
     returns the AFDRS FBI for mallee
     args
       wind_speed: 10 m wind speed(km/h)
       fuel_moisture: dead fuel moisture content (%)
       overstorey_cover: (%)
       intensity: fire line intensity (kW/m)
