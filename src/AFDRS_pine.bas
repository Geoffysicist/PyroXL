Attribute VB_Name = "AFDRS_pine"
Private Const HEAT_CONTENT = 18600 'KJ/kg
Private Const KGSQM_TO_TPH = 10 ' kg/m2 to t/ha
Private Const SECONDS_PER_HOUR = 3600 's
Private Const KGM2_PER_LBFT2 = 4.88243 'kg/m2 per lb/ft2
Private Const KJKG_PER_BTULB = 2.326 'kg/kJ per Btu/lb
Private Const MSEC_PER_FTMIN = 0.00508 'm/s per ft/min

Public Function FMC_pine(temp, rh As Single) As Single
    'calculate the grass fuel moisture content as % based on McArthur (1966)
    'args
    '  temp: air temperature (C)
    '  rh: relative humidity (%)

    FMC_pine = 4.3426 + 0.1188 * rh - 0.0211 * temp
End Function

Public Function FA_pine(DF, KBDI, WAF As Single) As Single
    'Use drought factor to estimate amount of fuel available to burn
    'From Cruz et al. (2022) Vesta Mk 2 model
    'args
    '  DF: drought factor
    '  KBDI: Keetch Byram drought index KBDI
    '  WAF: wind adjustment factor restricted to range 3 to 5
    
    C1 = 0.1 * ((0.0046 * WAF ^ 2 - 0.0079 * WAF - 0.0175) * KBDI + (-0.9167 * WAF ^ 2) + 1.5833 * WAF + 13.5)
    
    DF = DF * WorksheetFunction.Max(C1, 0)
    
    FA_pine = 1.008 / (1 + 104.9 * Exp(-0.9306 * DF))
    
End Function
Public Function U_flame_height(U_10, h_o As Single) As Single
    'return wind speed at flame height (km/r) based on Cruz et al. 2006
    'args
    '  U_10: 10 m wind speed (km/h)
    '  h_o: stand (overstorey) height m
    
    Dim U_stand_height As Single 'wind speed at stand height
    U_stand_height = U_10 * Log((0.36 * h_o) / (0.13 * h_o)) / Log((10 + 0.36 * h_o) / (0.13 * h_o))
    
    U_flame_height = U_stand_height * Exp(-0.48)

End Function
Public Function fire_behaviour_pine(U_10, mc, DF, KBDI, _
    Optional wrf = 5, Optional fl_s = 10.5, Optional fl_o = 11, Optional bh_o = 5, Optional bd_o = 0.1 _
    ) As Single()
    'return the forward rate of spread m/h for pine based on Cruz model
    'args
    '  U_10: 10 m wind speed (km/h)
    '  mc: dead fuel moisture content %
    '  DF: drought factor
    '  KBDI: Keetch Byram drought index KBDI
    '  WAF: wind adjustment factor restricted to range 3 to 5
    '  fl_s: surface fuel load (t/ha)
    '  fl_o: overstorey (canopy) fuel load (t/ha)
    '  bh_o: overstorey (canopy) base height m
    '  bd_o: overstorey (canopy) bulk density
    
    'Model parameters
    moisture_fraction_extinction = 0.3  'Moisture content of extinction, mass water / mass ovendry wood
    mineral_content_silica_free = 0.01  'fuel particle effective mineral content, mass silica-free minerals / mass ovendry wood
    mineral_content_total = 0.0555 'fuel particle total mineral content, mass minerals / mass ovendry wood
    surface_volume_ratio = 1700 'surface area to volume ratio, 1/ft
    particle_density = 32 'ovendry particle density, lb/ft^3
    heat_of_combustion_IMP = 8000 'Btu/lb
    heat_of_combustion_SI = heat_of_combustion_IMP * KJKG_PER_BTULB 'kJ/kg
    critical_mass_flow_rate = 3 ' 'Critical mass flow rate for solid crown flame, estimated as 3 kg/m^2/min
    fuel_depth = 1.148 'ft
    stand_height = 15  'm
    
    'change mc to fraction
    moisture_fraction = mc / 100
    
    'adjust units
    fuel_load_SI = (fl_s / KGSQM_TO_TPH) * FA_pine(DF, KBDI, (wrf))
    fuel_load_IMP = fuel_load_SI / KGM2_PER_LBFT2 ' convert to imperial kg/m2 per lb/ft2
    
    'foliar moisture content
    foliar_moisture_content = 150 - 5 * DF
    
    wind_mid_flame = U_flame_height(U_10, (stand_height))
    
    bulk_density = fuel_load_IMP / fuel_depth
    packing_ratio = bulk_density / particle_density
    heat_of_preignition = 250 + 1116 * moisture_fraction 'Btu/lb
    effective_heating_number = Exp(-138 / surface_volume_ratio)

    net_fuel_load_IMP = fuel_load_IMP / (1 + mineral_content_total)
    
    E = 0.715 * Exp(-0.000359 * surface_volume_ratio)
    B = 0.02562 * Power(surface_volume_ratio, 0.54)
    C = 7.47 * Exp(-0.133 * Power(surface_volume_ratio, 0.55))
    packing_ratio_op = 3.348 * Power(surface_volume_ratio, -0.8189) 'Optimum packing ratio
    wind_coefficient = C * Power(wind_mid_flame * 54.68, B) * Power(packing_ratio / packing_ratio_op, -E)

    xi = Power(192 + 0.2595 * surface_volume_ratio, -1) * Exp((0.792 * 0.681 * Power(surface_volume_ratio, 0.5)) * (packing_ratio + 0.1)) 'Propagating flux ratio

    eta_S = 0.174 * Power(mineral_content_silica_free, -0.19) 'Mineral damping coefficient
    eta_M = 1 - 2.59 * moisture_fraction / moisture_fraction_extinction + 5.11 * Power(moisture_fraction / moisture_fraction_extinction, 2) - 3.52 * Power(moisture_fraction / moisture_fraction_extinction, 3) 'Moisture damping coefficient

    A = 1 / (4.77 * Power(surface_volume_ratio, 0.1) - 7.27)
    gamma_max = Power(surface_volume_ratio, 1.5) / (495 + 0.0594 * Power(surface_volume_ratio, 1.5)) 'Maximum reaction velocity
    Gamma = gamma_max * Power((packing_ratio / packing_ratio_op), A) * Exp(A * (1 - packing_ratio / packing_ratio_op)) 'Optimum reaction velocity

    reaction_intensity = Gamma * net_fuel_load_IMP * heat_of_combustion_IMP * eta_M * eta_S 'Btu/ft^2 min

    speed_surface = reaction_intensity * xi * (1 + wind_coefficient) / (bulk_density * effective_heating_number * heat_of_preignition)  'Surface rate of spread, ft/min
    speed_surface = speed_surface * MSEC_PER_FTMIN 'Convert to m/s

    'Using Byram (1959) to calculate surface fire intensity
    intensity_ = intensity(speed_surface, fuel_load_SI)

    'Using Van Wagner (1977) for the crowning criteria threshold
    heat_of_ignition = 460 + 26 * foliar_moisture_content 'Heat of ignition, kJ/kg
    crowning_intensity = Power(0.01 * bh_o * heat_of_ignition, 1.5) 'Crowning threshold intensity, kW/m
    crowning_ratio = intensity_ / crowning_intensity 'If this is greater than 1 then crowning is predicted and vice versa
    speed_active_MMIN = 11.021 * Power(U_10, 0.8966) * Power(bd_o, 0.1901) * Exp(-0.1714 * moisture_fraction * 100) 'Active crown fire spread rate, m/min.
    speed_active_MS = speed_active_MMIN / 60 'Converting to m/s

    'Calculate criteria for active crowning from Cruz (2008)
    CAC = speed_active_MMIN / (critical_mass_flow_rate / bd_o) 'Criteria for active crowning.
    speed_passive = speed_active_MS * Exp(-1 * CAC) 'Passive ROS
    'passive = ((crowning_ratio > 1) & (CAC < 1))
    Dim passive, acitve, surface As Boolean
    passive = crowning_ratio > 1 And CAC < 1
    'Active = crowning_ratio > 1 And CAC >= 1
    surface = (crowning_ratio <= 1)
    
    If surface Then
        ROS = speed_surface
    ElseIf passive Then
        ROS = WorksheetFunction.Max(speed_passive, speed_surface)
    Else
        ROS = speed_active_MS
    End If
    
    If Active Or passive Then
        fuel_load_SI = fuel_load_SI + fl_o
    End If
    
    'convert to m/h
    ROS = ROS * 3600
    intensity_total = intensity(ROS, fuel_load_SI)
    flame_height = 0.07755 * Power(intensity_total, 0.46)
    
    If Active Then
        flame_height = flame_height + stand_height
    End If
    
    Dim fire_behaviour_array(0 To 2) As Single
    fire_behaviour_array(0) = ROS
    fire_behaviour_array(1) = intensity_total
    fire_behaviour_array(2) = flame_height
    fire_behaviour_pine = fire_behaviour_array
    
End Function

Public Function ROS_pine(U_10, mc, DF, KBDI) As Single
    
End Function


