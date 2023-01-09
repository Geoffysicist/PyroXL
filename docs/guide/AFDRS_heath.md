## AFDRS_heath

### Public Function FMC_heath(temp, rh, rain, hours As Double) As Double
     returns fuel moisture content (%). Based on:
       Cruz, M., et al. (2010). Fire dynamics in mallee-heath: fuel, weather
       and fire behaviour prediction in south Australian semi-arid shrublands.
       Bushfire CRC Program A Rep 1(01).
     In addition, a fuel moisture modifier based on recent rainfall was used. Marsden-Smedley, J. B.,
     et al. (1999). Buttongrass moorland fire-behaviour prediction
     and management. Tasforests 11: 87-107.
     args
       temp: air temperature (C)
       rh: relative humidity (%)
       rain: precipitation in the last 48 hours (mm)
       hours: time since rain or dewfall stopped (h)

### Public Function Mf_heath(mc As Double) As Double
     returns the heathland moisture function
     args
       mc: fuel moisture content (%)

### Public Function ROS_heath(U_10, h_el, mc As Double, overstorey As Boolean) As Double
     returns forward rate of spread (m/h) [range: 0-6000 m/h]
     Anderson, W. R., et al. (2015). "A generic, empirical-based model for predicting rate of fire
     spread in shrublands." International Journal of Wildland Fire 24(4): 443-460.
     args
       U_10: 10 m wind speed (km/h)
       h_el: elevated fuel height (m)
       mc: fuel moisture content (%)
       overstorey: presence or absence of woodland overstorey (true/false)

### Public Function intensity_heath(ROS, fl_max, tsf, k) As Double
     returns the fire line intensity (kW/m)
     args
       ROS: forward rate of spread (m/h)
       fl_max: maximum fuel load (t/ha)
       tsf: time since fire (y)
       k: fuel accumulation curve constant

### Public Function Flame_height_heath(Intensity As Double) As Double
     returns flame height (m)
     No equation for flame height was given in the Anderson et al. paper (2015).
     Here we use the flame height calculation for mallee-heath shrublands (Cruz, M. G., et al. (2013).
     "Fire behaviour modelling in semi-arid mallee-heath shrublands of southern Australia.
     Environmental Modelling & Software 40: 21-34).
     args
       intensity: fire line intensity (kW/m)
