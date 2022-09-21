## AFDRS_dry_forest

### Public Function Intensity_dry_forest(ROS, DF, flame_h, fl_s, fl_ns, fl_e, fl_o, h_o) As Double
     returns the fire line intensity (kW/m) based on fuel load and ROS
     note AFDRS caps surface fuel load at 10 t/ha (1 kg/m)
     args
       ROS: forward rate of spread (km/h)
       DF: drought (fuel availability) factor (1-10)
       flame_h: flame height (m)
       fl_s: surface fuel load (t/ha)
       fl_ns: near surface fuel load (t/ha)
       fl_e: elevated fuel load (t/ha)
       fl_o: overstorey (canopy) fuel load (t/ha)
       h_o: overstorey (canopy) height (m)

### Public Function Flame_height_dry_forest(ROS As Double, h_el As Single) As Single
     returns the flame height (m)
     
     args
      ROS - forward rate of spread (m/h)
      h_el - elevated fuel height (m)

### Public Function ROS_forest(U_10, fhs_s, fhs_ns, h_ns, fmc, DF, WAF) As Double
     return the forward ROS (m/h) ignoring slope
     
     args
       U_10: 10 m wind speed (km/h)
       fhs_s: surface fuel hazard score
       fhs_ns: near surface fuel hazard score
       h_ns: near surface fuel height (cm)
       fmc: fuel moisture content (%)
       DF: drought factor (0-10)
       WAF: wind adjustment factor

### Public Function FMC_forest(temp, rh As Single, date_, time As Date) As Double
     return the fine fuel moisture content (%)
     
     args
       temp: air temperature (C)
       rh: relative humidity (%)
       date_: (underscore due to VBA Date objects)
       time:

### Public Function Mf_forest(fmc As Single) As Single
     returns the forest fuel moisture factor
     
     args
       fmc: fine fule moisture content (%)

### Public Function Spotting_forest(ROS, U_10, fhs_s As Single) As Integer
     returns the spotting distance (m)
     
     args
       ROS: forward rate of spread (m/h)
       U_10: 10m wind speed (km/h)
       fhs_s: fuel hazard score surface
