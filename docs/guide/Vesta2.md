## Vesta2

### Public Function FMC_Vesta2(temp, rh As Single, date_ As Date, time As Date, Optional submodel = "dry") As Double
     return the fine fuel moisture content (%)
     args
       temp: air temperature (C)
       rh: relative humidity (%)
       date_: (underscore due to VBA Date objects)
       time:

### Public Function Mf_Vesta2(fmc As Single) As Single
     returns the forest fuel moisture factor
     args
       fmc: fine fule moisture content (%)

### Public Function fuel_availability_Vesta2(DF, Optional DI = 100, Optional waf = 3, Optional submodel = "dry") As Double
     returns the fuel availability - proportion of fuel available to be burnt
     TODO: implement slope/aspect effect
     args
       DF: Drought factor
       DI: drought index - KBDI except SDI in Tas
       WAF: wind adjustment factor between 3 and 5
       submodel: dry or wet

### Public Function fme_Vesta2(mf, fa) As Single
     returns the fuel moisture effect function
     Cruz 2021 Eq 8
     args
       mf: fine dead fuel moisture content factor
       fa: fuel availability

### Public Function prob_phase2(U_10, waf, fls, fmc, fa) As Single
     returns the probability of transition to phase 2
     Cruz 2021 Eqn 9 and 10
     args
       U_10: 10m wind speed (km/h)
       waf: wind adjustment factor between 3 and 5
       fls: surface fuel load (t/ha)
       fmc: fine fule moisture content (%)
       fa: fuel availability

### Public Function prob_phase3(U_10, ros2, fmc, fa) As Single
     returns the probability of transition to phase 2
     Cruz 2021 Eqn 9 and 10
     args
       U_10: 10m wind speed (km/h)
       ros2: phase 2 rate of spread km/h
       fmc: fine fule moisture content (%)
       fa: fuel availability

### Public Function sf_Vesta2(slope) As Single
     returns the slope function
     based on on A.G. McArthur slope effect rule of thumb for upslope fires and the
     Kataburn down slope effect refinement from Sullivan et al. (2014)
     Cruz 2021 eqn 13

### Public Function ros1_Vesta2(U_10, waf, fls, fmc, fa, Optional sf = 1) As Single
     returns the phase 1 forwards rate of spread (km/h)
     Cruz 2021 eqn 14a and b
     args
       U_10: 10m wind speed (km/h)
       waf: wind adjustment factor between 3 and 5
       fls: surface fuel load (t/ha)
       fmc: fine fule moisture content (%)
       fa: fuel availability
       slope factor

### Public Function ros2_Vesta2(U_10, waf, fls, h_u, fmc, fa, Optional sf = 1) As Single
     returns the phase 2 forwards rate of spread (km/h)
     Cruz 2021 eqn 15
     args
       U_10: 10m wind speed (km/h)
       waf: wind adjustment factor between 3 and 5
       fls: surface fuel load (t/ha)
       h_u: average understorey height (m)
       fmc: fine fule moisture content (%)
       fa: fuel availability
       slope factor

### Public Function ros3_Vesta2(U_10, fmc, fa, Optional sf = 1) As Single
     returns the phase 2 forwards rate of spread (km/h)
     Cruz 2021 eqn 16
     args
       U_10: 10m wind speed (km/h)
       fmc: fine fule moisture content (%)
       fa: fuel availability
       slope factor

### Public Function ros_Vesta2(ros1, ros2, ros3, p2, p3) As Single
     returns the ovral forward rate of spread (km/h)
     Cruz 2021 eqn 17
     args
       ros1: the phase 1 forward rate of spread (km/h)
       ros2: the phase 2 forward rate of spread (km/h)
       ros3: the phase 3 forward rate of spread (km/h)
       p2: probability of transitioning to phase 2
       p3: probability of transitioning to phase 3
