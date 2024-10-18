## AFDRS_General

### Public Sub set_defaults()

### Public Sub set_defaults_Forest()

### Public Sub set_defaults_Grass()

### Public Sub set_defaults_Woodland()

### Public Sub set_defaults_Buttongrass()

### Public Sub set_defaults_Heath()

### Public Sub set_defaults_Mallee()

### Public Sub set_defaults_Spinifex()

### Public Sub set_defaults_Pine()

### Public Sub set_defaults_Other()

### Public Sub set_defaults_from_LUT(param_dict As Object)

### Public Function FBI(ByVal intensity As Double, Optional fuel As String = "forest") As Single
      returns FBI.
     args
       intensity: file line intensity (kW/m)
       fuel: the fuel type

### Public Function intensity(ByVal ROS As Double, ByVal fuel_load As Single) As Double
     returns the fireline intensity (kW/m) based on Byram 1959
     args
       ROS: forward rate of spread (km/h)
       fuel_load: fine fuel load (t/ha)

### Public Function fuel_amount(fuel_param_max, tsf, k) As Double
     returns the adjusted fuel parameter based on time since fire and fuel accumulation curve parameter
     args
       fuel_param_max: the steady state value for the fuel parameter
       tsf: time since fire (y)
       k: fuel accumulation curve parameter

### Public Function fl_to_fhs(layer As String, fuel_load As Single)
     converts a fuel load to a VESTA fuel hazard score
     args
       layer: fuel layer (surface, near surface, elevated, bark)
       fuel_load: (t/ha)

### Public Function dewpoint(temp, rh) As Single
     returns the dew point temperature based on the Magnus formula with the the Arden Buck modification
     args
       temp: air temperature (C)
       rh: relative humidity (%)

### Public Function vp_deficit(air_temperature, relative_humidity) As Single
     returns the vapour pressure deficit in hPa, calculated using Tetens (1930)
     args
       temp: air temperature (C)
       rh: relative humidity (%)

### Public Sub ListAFDRSClasses(lower As Single, upper As Single)
     create list of AFDRS classes based on FTno range

### Public Sub ListNSWClasses(Optional lower = 0, Optional upper = 76)
     create list of AFDRS classes based on FTno range

### Public Sub test()
