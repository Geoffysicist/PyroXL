## Mk5

### Public Function GFDI(U10, load, fmc) As Single
      returns McArthur Mk5 Grass Fire Danger Index from Noble et al. 1980.
       U_10: 10 m wind speed (km/h)
       load: grass fuel load (t/ha)
       fmc: fuel moisture content (%)

### Public Function FMC_grass_Mk5(temp, rh As Single, curing) As Single
     returns the grass fuel moisture content (%) based on McArthur (1966)
     args:
       temp: air temperature (C)
       rh: relative humidity (%)
       curing: degree of grass curing (%)

### Public Function FMC_Mk5(temp, rh As Single) As Single
     returns the fuel moisture content (%) based on McArthur FFDM (1967. 1973a)
     args:
       temp: air temperature (C)
       rh: relative humidity (%)

### Public Function Flame_height_forest_Mk5(ROS As Double, h_el As Single) As Single
     returns the flame height (m)
     args
       ROS - forward rate of spread (m/h)
       load: fine fuel load (t/ha)

### Public Function ffdi(temp, rh, DF, U10, Optional wrf = 3) As Single
      returns McArthur Mk5 Forest Fire Danger Index from Noble et al. 1980.
       temp: air temperature (C)
       rh: relative humidity (%)
       DF: drought factor
       U_10: 10 m wind speed (km/h)

### Public Function ROS_Mk5(ffdi, load) As Single
      returns McArthur Mk5 Rate of Spread from Noble et al. 1980.
       ffdi: FFDi
       load: fine fuel load (t/ha)
