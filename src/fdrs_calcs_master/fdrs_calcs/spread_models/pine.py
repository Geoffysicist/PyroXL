"""Fire behaviour calculations for dry forests
"""
import numpy as np
import pandas as pd

from . import grass
from . import fire_behaviour_index
from . import fire_danger_rating

START_PEAK_MONTH = 10 #October
END_PEAK_MONTH = 3 #March
START_AFTERNOON = 12
END_AFTERNOON = 17
SUNRISE = 6
SUNSET = 19
HEAT_CONTENT = 18600 #KJ/kg
KGSQM_TO_TPH = 10.0
SECONDS_PER_HOUR = 3600 #s
KGM2_PER_LBFT2 = 4.88243 # kg/m2 per lb/ft2
KJKG_PER_BTULB = 2.326 # kg/kJ per Btu/lb
MSEC_PER_FTMIN  = 0.00508 #m/s per ft/min

def fuel_availability(drought_factor,drought_index,WRF):
    """Use drought factor to estimate amount of fuel available to burn
       From Cruz et al. (2022) Vesta Mk 2 model
    """
    C1 = 0.1*((0.0046*np.power(WRF,2)-0.0079*WRF-0.0175)*drought_index+(-0.9167*np.power(WRF,2)+1.5833*WRF+13.5))
    C1 = np.clip(C1,0,1)

    return 1.008/(1+104.9*np.exp(-0.9306*C1*drought_factor))

def fuel_moisture_model(air_temperature, relative_humidity):
    """Calculate dead fuel moisture (%)
    Based on Matthews, S., Gould, J., & McCaw, L. (2010). Simple models for
    predicting dead fuel moisture in eucalyptus forests. International Journal
    of Wildland Fire, 19(4), 459-467.

    Modified Rothermel model (Cruz pers comm 2021)
    """
    fuel_moisture = 4.3426+0.1188*relative_humidity-0.0211*air_temperature

    return fuel_moisture

def calc_fire_spread_single(dead_fuel_moisture, wind_speed,
                        drought_factor, drought_index, time_since_fire,
                        canopy_fuel_load = 1.1, canopy_base_height = 5,
                        canopy_bulk_density = 0.1, surface_load = 1.05, wrf=5,
                        proportion = None):
    """Calculate rate of spread in m/h and intensity in kW/m
    Based on simplifcation of Cruz model
    """

    #Fuel moisture model
    moisture_fraction = dead_fuel_moisture/100.0

    #Model parameters
    moisture_fraction_extinction = 0.30 # Moisture content of extinction, mass water / mass ovendry wood
    mineral_content_silica_free = 0.010 # fuel particle effective mineral content, mass silica-free minerals / mass ovendry wood
    mineral_content_total = 0.0555 # fuel particle total mineral content, mass minerals / mass ovendry wood
    surface_volume_ratio = 1700 # surface area to volume ratio, 1/ft
    particle_density = 32 # ovendry particle density, lb/ft^3
    heat_of_combustion_IMP = 8000 # Btu/lb
    heat_of_combustion_SI = heat_of_combustion_IMP*KJKG_PER_BTULB # kJ/kg
    critical_mass_flow_rate = 3.0 # Critical mass flow rate for solid crown flame, estimated as 3 kg/m^2/min
    fuel_depth = 1.148 # ft

    fuel_load_SI = surface_load*fuel_availability(drought_factor, drought_index,wrf) 
    fuel_load_IMP = fuel_load_SI/KGM2_PER_LBFT2 # ovendry fuel loading, lb/ft^2

    foliar_moisture_content = 150 - 5*drought_factor # %
    stand_height = 15 # m

    #Calculate below canopy winds (Cruz et al. 2006)
    #Eqn 11
    wind_stand_height = wind_speed*(np.log((stand_height-0.64*stand_height)/(0.13*stand_height))/np.log(((10+stand_height)-0.64*stand_height)/(0.13*stand_height)))

    #Eqn 10
    wind_mid_flame = wind_stand_height * np.exp(1.2*(0.6-1))

    bulk_density = fuel_load_IMP / fuel_depth # lb/ft^3
    packing_ratio = bulk_density / particle_density
    heat_of_preignition = 250 + 1116 * moisture_fraction # Btu/lb
    effective_heating_number = np.exp(-138 / surface_volume_ratio)

    net_fuel_load_IMP = fuel_load_IMP / (1 + mineral_content_total) # lb/ft^2

    E = 0.715 * np.exp(-0.000359 * surface_volume_ratio)
    B = 0.02562 * np.power(surface_volume_ratio, 0.54)
    C = 7.47 * np.exp(-0.133 * np.power(surface_volume_ratio, 0.55))
    packing_ratio_op = 3.348 * np.power(surface_volume_ratio, -0.8189) # Optimum packing ratio
    wind_coefficient = C * np.power(wind_mid_flame * 54.68, B) * np.power(packing_ratio / packing_ratio_op, -E)

    xi = np.power(192 + 0.2595*surface_volume_ratio, -1) * np.exp((0.792 * 0.681 * np.power(surface_volume_ratio, 0.5)) * (packing_ratio + 0.1)) # Propagating flux ratio

    eta_S = 0.174 * np.power(mineral_content_silica_free, -0.19) # Mineral damping coefficient
    eta_M = 1 - 2.59 * moisture_fraction/moisture_fraction_extinction + 5.11 * np.power(moisture_fraction/moisture_fraction_extinction, 2) - 3.52 * np.power(moisture_fraction/moisture_fraction_extinction, 3) # Moisture damping coefficient

    A = 1 / (4.77 * np.power(surface_volume_ratio, 0.1) - 7.27)
    gamma_max = np.power(surface_volume_ratio, 1.5) / (495 + 0.0594 * np.power(surface_volume_ratio, 1.5)) # Maximum reaction velocity
    gamma = gamma_max * np.power((packing_ratio / packing_ratio_op), A) * np.exp(A*(1 - packing_ratio / packing_ratio_op)) # Optimum reaction velocity

    reaction_intensity = gamma * net_fuel_load_IMP * heat_of_combustion_IMP * eta_M * eta_S # Btu/ft^2 min

    speed_surface = reaction_intensity * xi * (1 + wind_coefficient ) / (bulk_density * effective_heating_number * heat_of_preignition) # Surface rate of spread, ft/min
    speed_surface = speed_surface * MSEC_PER_FTMIN # Convert to m/s

    # Using Byram (1959) to calculate surface fire intensity
    intensity = heat_of_combustion_SI * fuel_load_SI * speed_surface # Fire intensity, kW/m

    # Using Van Wagner (1977) for the crowning criteria threshold
    # Crowning threshold intensity
    heat_of_ignition = 460 + 26 * foliar_moisture_content # Heat of ignition, kJ/kg
    crowning_intensity = np.power(0.01 * canopy_base_height * heat_of_ignition, 1.5) # Crowning threshold intensity, kW/m
    crowning_ratio = intensity / crowning_intensity # If this is greater than 1 then crowning is predicted and vice versa
    speed_active_MMIN = 11.021 * np.power(wind_speed, 0.8966) * np.power(canopy_bulk_density, 0.1901) * np.exp(-0.1714 * moisture_fraction*100.0) # Active crown fire spread rate, m/min.
    speed_active_MS = speed_active_MMIN / 60 # Converting to m/s

    # Calculate criteria for active crowning from Cruz (2008)
    CAC = speed_active_MMIN / (critical_mass_flow_rate / canopy_bulk_density) # Criteria for active crowning.
    speed_passive = speed_active_MS * np.exp(-1 * CAC) #Passive ROS
    passive = ((crowning_ratio>1)&(CAC < 1))
    active = ((crowning_ratio>1)&(CAC >= 1))
    surface = (crowning_ratio<=1)

    rate_of_spread = np.empty(speed_surface.shape)
    rate_of_spread[surface] = speed_surface[surface]
    rate_of_spread[passive] = np.maximum(speed_passive[passive], speed_surface[passive])
    rate_of_spread[active] = np.maximum(speed_active_MS[active], speed_surface[active])

    fuel_load = fuel_load_SI
    fuel_load[passive] += canopy_fuel_load
    fuel_load[active] += canopy_fuel_load
    intensity_total = heat_of_combustion_SI * fuel_load * rate_of_spread #kW/m

    flame_length = 0.07755* np.power(intensity_total,0.46)
    # FIXME convert flame_length = flame height
    flame_height = flame_length
    flame_height[active] += stand_height

    rate_of_spread = rate_of_spread*3600 # Convert to m/h

    return rate_of_spread, intensity_total, flame_length

def calc_fire_spread(dead_fuel_moisture, wind_speed,
                    drought_factor, drought_index, time_since_fire):
    """Calculate rate of spread in m/h and intensity in kW/m
    Based on simplifcation of Cruz model
    """
    fuel_models = [
        {'proportion': 0.151,
         'canopy_fuel_load': 1.15,
         'canopy_base_height': 0.7,
         'canopy_bulk_density': 0.17,
         'surface_load': 0.4,
        },
        {'proportion': 0.151,
         'canopy_fuel_load': 1.2,
         'canopy_base_height': 1.5,
         'canopy_bulk_density': 0.18,
         'surface_load': 0.5,
        },
        {'proportion': 0.121,
         'canopy_fuel_load': 1.2,
         'canopy_base_height': 2.5,
         'canopy_bulk_density': 0.18,
         'surface_load': 0.85,
        },
        {'proportion': 0.091,
         'canopy_fuel_load': 0.8,
         'canopy_base_height': 6,
         'canopy_bulk_density': 0.12,
         'surface_load': 1.,
        },
        {'proportion': 0.394,
         'canopy_fuel_load': 1.,
         'canopy_base_height': 14,
         'canopy_bulk_density': 0.15,
         'surface_load': 0.7,
        },
    ]
    
    rate_of_spread, intensity_total, flame_length= (0,0,0)
    
    #Grass for newly harvested
    grass_stage_proportion = 0.091
    curing = np.full(wind_speed.shape,100)
    grass_load = np.full(wind_speed.shape,1.5)
    grass_condition = np.full(wind_speed.shape,1)
    r = grass.calc_rate_of_spread(
        dead_fuel_moisture, wind_speed, curing, grass_condition)
    i = grass.calc_intensity(r, grass_load)
    f = grass.calc_flame_height(r, grass_load)
    rate_of_spread += grass_stage_proportion*r
    intensity_total += grass_stage_proportion*i
    flame_length += grass_stage_proportion*f
    
    for parameters in fuel_models:
        r, i, f = calc_fire_spread_single(dead_fuel_moisture, wind_speed, 
                                drought_factor, drought_index, time_since_fire, **parameters)    
                                
        rate_of_spread += parameters['proportion']*r
        intensity_total += parameters['proportion']*i
        flame_length += parameters['proportion']*f
        
    return rate_of_spread, intensity_total, flame_length

def calc_spotting_distance(air_temperature):
    """No spotting
    """
    spotting_distance = np.empty(np.shape(air_temperature))
    spotting_distance.fill(np.nan)
    return spotting_distance

def calculate(dataset, fuel_parameters):
    """
    Takes an xarray dataset and a pandas data row.

    Returns: rate_of_spread, flame_height, intensity, spotting_distance, rating, index
    """

    #Use SDI for Tasmania, KBDI elsewhere
    if fuel_parameters.FTno_State>=7000:
        drought_index = dataset['SDI_SFC']
    else:
        drought_index = dataset['KBDI_SFC']

    dead_fuel_moisture = fuel_moisture_model(dataset['T_SFC'], dataset['RH_SFC'])
    
    rate_of_spread,intensity,flame_height = calc_fire_spread(dead_fuel_moisture,
                                                dataset['WindMagKmh_SFC'],
                                                dataset['DF_SFC'],
                                                drought_index,
                                                dataset['time_since_fire'])

    spotting_distance = calc_spotting_distance(dataset['T_SFC'])

    index_1 = fire_behaviour_index.pine(intensity)
    rating_1 = fire_danger_rating.fire_danger_rating(index_1)

    return {'dead_fuel_moisture':dead_fuel_moisture,
            'rate_of_spread': rate_of_spread,
            'flame_height': flame_height,
            'intensity': intensity,
            'spotting_distance': spotting_distance,
            'rating_1': rating_1,
            'index_1': index_1}

