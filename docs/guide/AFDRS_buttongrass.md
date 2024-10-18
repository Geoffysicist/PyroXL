## AFDRS_buttongrass

### Public Function FMC_buttongrass(temp, rh, dew_pt, tsr, rain) As Single
     returns the grass fuel moisture content (%) based on McArthur (1966)
     args:
       temp: air temperature (C)
       rh: relative humidity (%)
       tsr: time since rain (h)
       rain: rainfall (mm)
       dew_pt: dewpoint temperature (c)

### Public Function fuel_load_buttongrass(tsf, productivity) As Single
     returns the curing coefficient based on Cruz et al. (2015)
     args
       tsf: time since fire (y)
       productivity:

### Public Function spread_prob_buttongrass(U_10, mc, productivity) As Single
     returns the grass moisture coefficient
     args
       U_10: 10 m wind speed (km/h)
       mc: fuel moisture content (%)
       productivity:

### Public Function ROS_buttongrass(U_10, mc, tsf, productivity) As Single
     returns the forward ROS (m/h) ignoring slope
     args
       U_10: 10 m wind speed (km/h)
       mc: fuel moisture content (%)
       tsf: time since fire (y))

### Public Function Flame_height_buttongrass(intensity) As Single
     returns the flame height (m) based on M. Plucinski, pers. comm.
     args
       intensity: fireline intensity (kW/m)

### Public Function Intensity_buttongrass(ByVal ROS As Double, ByVal fuel_load As Single) As Double
     returns the fireline intensity (kW/m) based on Byram 1959
     args
       ROS: forward rate of spread (km/h)
       fuel_load: fine fuel load (t/ha)

### Public Sub update_from_LUT_Buttongrass()
