## Leaflet_80

### Public Function FMC_Leaflet80(temp, rh As Single, time As Date) As Single
     returns the fuel moisture content (%) as per Billy Tan 20 May 2024 (internal RFS)
     args:
       temp: air temperature (C)
       rh: relative humidity (%)
       time:

### Public Function U1_5_leaflet80(U10) As Single
     returns the 1.5m wind speed km/h as per Billy Tan 20 May 2024 (internal RFS)
     U10: 10m wind speed km/h

### Public Function ROS_Leaflet80(U1_5, fmc, load) As Single
      returns McArthur Leaflet 80 Rate of Spread as per Billy Tan 20 May 2024 (internal RFS).
       U1_5: 1.5m wid speed km/h
     fmc: fine fuel moisture content %
       load: surface fine fuel load (t/ha)

### Public Function Flame_height_leaflet80(load, ROS)
     returns the flame height m
     load: available fine fuel load t/ha
     ROS: forward rate of spread m/h

### Public Function Scorch_height_leaflet80(flame_height)
     returns the scorch height in m
     flame_height: m
