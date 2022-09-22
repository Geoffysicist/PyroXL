## AFDRS_pine

### Public Function FMC_pine(temp, rh As Single) As Single
     returns the grass fuel moisture content (%) based on McArthur (1966)
     args
       temp: air temperature (C)
       rh: relative humidity (%)

### Public Function FA_pine(DF, DI, WAF As Single) As Single
     returns fuel availability estimates using drought factor
     From Cruz et al. (2022) Vesta Mk 2 model
     args
       DF: drought factor
       DI: Drought IndexKeetch Byram drought index KBDI
       WAF: wind adjustment factor restricted to range 3 to 5

### Public Function U_flame_height(U_10, h_o As Single) As Single
     returns wind speed at flame height (km/h) based on Cruz et al. 2006
     args
       U_10: 10 m wind speed (km/h)
       h_o: stand (overstorey) height m

### Public Function fire_behaviour_pine(U_10, mc, DF, KBDI, _
     returns array of the the forward rate of spread m/h, intensity kW/m and flame height m for pine based on Cruz model
     args
       U_10: 10 m wind speed (km/h)
       mc: dead fuel moisture content %
       DF: drought factor
       KBDI: Keetch Byram drought index KBDI
       fuel_models array comprising
         wrf: wind adjustment factor restricted to range 3 to 5
         fl_s: surface fuel load (t/ha)
         fl_o: overstorey (canopy) fuel load (t/ha)
         bh_o: overstorey (canopy) base height m
         bd_o: overstorey (canopy) bulk density

### Public Function ROS_pine(U_10, mc, DF, KBDI) As Single

### Public Function Intensity_pine(U_10, mc, DF, KBDI) As Single

### Public Function FH_pine(U_10, mc, DF, KBDI) As Single

### Public Function fb_pine_ensemble(U_10, mc, DF, KBDI) As Variant()
     returns array of the the forward rate of spread (m/h), intensity (kW/m) and flame height (m) for pine using an mixed stand ensemble
     args
       U_10: 10 m wind speed (km/h)
       mc: dead fuel moisture content %
       DF: drought factor
       KBDI: Keetch Byram drought index KBDI
