## AFDRS_grass

### Public Function FMC_grass(temp, rh As Single) As Single
     returns the grass fuel moisture content as (%) based on McArthur (1966)
     
     args
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

### Public Function enumerate_state_grass(state As String) As Integer
     returns an enumerated value for grass state
     eaten-out = 1, grazed = 2, natural = 3
     
     args
       the grass state

### Public Function categorise_state_grass(state As Integer) As String
     returns an category string for grass state
     1 = eaten-out, 2 = grazed, 3 = natural
     
     args
       the grass state
