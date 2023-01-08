## AFDRS_grass

### Public Function FMC_grass(temp, rh As Single) As Single
     returns the grass fuel moisture content (%) based on McArthur (1966)
     args:
       temp: air temperature (C)
       rh: relative humidity (%)

### Public Function curing_coeff_grass(curing As Single) As Single
     returns the curing coefficient based on Cruz et al. (2015)
     args
       curing: degree of grass curing (%)

### Public Function moist_coeff_grass(U_10, mc As Single) As Single
     returns the grass moisture coefficient
     args
       U_10: 10 m wind speed (km/h)
       mc: fuel moisture content (%)

### Public Function ROS_grass(U_10, mc As Single, curing As Single, state As String) As Single
     returns the forward ROS (m/h) ignoring slope
     args
       U_10: 10 m wind speed (km/h)
       mc: fuel moisture content (%)
       curing: degree of grass curing (%)
       state: grass state (natural, grazed, eaten-out)

### Public Function Flame_height_grass(ROS As Single, state As String) As Single
     returns the flame height (m) based on M. Plucinski, pers. comm.
     args
       ROS: forward rate of spread (m/h)
       state: grass state (natural, grazed, eaten-out)

### Public Function Intensity_grass(ByVal ROS As Double, ByVal fuel_load As Single) As Double
     returns the fireline intensity (kW/m) based on Byram 1959
     for grass fuel loads are limited to range 1 to 6 t/ha
     args
       ROS: forward rate of spread (km/h)
       fuel_load: fine fuel load (t/ha)

### Public Function state_to_load_grass(state As String) As Single
     returns the grass fuel load (t/ha)
     args
       state: the grass fuel state - eaten-out, grazed or natural

### Public Function load_to_state_grass(load As Single) As String
     returns the grass fuel state - eaten-out, grazed or natural
     args
       load: the grass fuel load (t/ha)

### Public Function enumerate_state_grass(state As String) As Integer
     returns an enumerated value of the grass fuel state
     args
       state: the grass fuel state - eaten-out, grazed or natural

### Public Function categorise_state_grass(state As Integer) As String
     returns an categorical value of the grass fuel state
     args
       state: the grass fuel state - 1=eaten-out, 2=grazed or 3=natural
