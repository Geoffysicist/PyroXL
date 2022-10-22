#CSIRO grassland model for use  in grass-like modules

import numpy as np

HEAT_CONTENT = 18600 #KJ/kg
KGSQM_TO_TPH = 10.0
M_PER_KM = 1000
SECONDS_PER_HOUR = 3600 #s

GRASS_CONDITION_NATURAL = 3
GRASS_CONDITION_GRAZED = 2
GRASS_CONDITION_EATENOUT = 1

def calc_fuel_moisture(air_temperature, relative_humidity):
    fuel_moisture = -0.205*air_temperature+0.138*relative_humidity+9.58
    fuel_moisture[fuel_moisture<5] = 5
    return fuel_moisture
    
def calc_fuel_moisture_factor(dead_fuel_moisture, wind_speed):
    fuel_moisture_factor = np.empty(np.shape(dead_fuel_moisture))
    fuel_moisture_factor_1 = np.exp(-0.108*dead_fuel_moisture)
    fuel_moisture_factor_2 = np.clip(0.684-0.0342*dead_fuel_moisture, 0.001, 1)
    fuel_moisture_factor_3 = np.clip(0.547-0.0228*dead_fuel_moisture, 0.001, 1)
    fuel_moisture_factor[dead_fuel_moisture < 12] = fuel_moisture_factor_1[dead_fuel_moisture < 12]
    fuel_moisture_factor[(dead_fuel_moisture >= 12)&(wind_speed <= 10)] = (
        fuel_moisture_factor_2[(dead_fuel_moisture >= 12) & (wind_speed <= 10)])
    fuel_moisture_factor[(dead_fuel_moisture >= 12)&(wind_speed > 10)] = (
        fuel_moisture_factor_3[(dead_fuel_moisture >= 12) & (wind_speed > 10)])

    return fuel_moisture_factor

def calc_intensity(rate_of_spread, fuel_load):
    """Calculate fire line intensity (kW/m)
    """
    fuel_load_clip = np.clip(fuel_load,1,6)
    intensity = (HEAT_CONTENT * (fuel_load_clip / KGSQM_TO_TPH) *
                 (rate_of_spread / SECONDS_PER_HOUR))
    return intensity

def calc_flame_height(rate_of_spread, fuel_load):
    """Calculate flame height (m)
    Matt Plucinski pers. comm. 31/07/2017 (email)
    """
    flame_height = np.empty(np.shape(rate_of_spread))
    flame_height_natural = 2.66 * np.power(((rate_of_spread/M_PER_KM)/3.6), 0.295)
    flame_height_grazed = 1.12 * np.power(((rate_of_spread/M_PER_KM)/3.6), 0.295)
    flame_height_eatenout = 1.12 * np.power(((rate_of_spread/M_PER_KM)/3.6), 0.295)
    flame_height [fuel_load>=6] = flame_height_natural [fuel_load>=6]
    flame_height [(fuel_load>=3)&(fuel_load<6)] = flame_height_grazed [(fuel_load>=3)&(fuel_load<6)]
    flame_height [fuel_load<3] = flame_height_eatenout [fuel_load<3]

    return flame_height

def calc_spotting_distance(air_temperature):
    """Return an empty array because grass fuels don't spot
    """
    spotting_distance = np.empty(np.shape(air_temperature))
    spotting_distance.fill(np.nan)
    return spotting_distance
    
def calc_rate_of_spread(dead_fuel_moisture, wind_speed, curing, grass_condition):
    """Calculate rate of spread (m/h)
    Based on:
    Cheney, N. P., Gould, J. S., & Catchpole, W. R. (1998). Prediction of fire
    spread in grasslands. International Journal of Wildland Fire, 8(1), 1-13.

    Cruz, M. G., Gould, J. S., Kidnie, S., Bessell, R., Nichols, D., &
    Slijepcevic, A. (2015). Effects of curing on grassfires: II. Effect of grass
    senescence on the rate of fire spread. International Journal of Wildland
    Fire, 24(6), 838-848.
    """
    #Fuel moisture factor
    fuel_moisture_factor = calc_fuel_moisture_factor(dead_fuel_moisture, wind_speed)

    #Curing factor (Cruz et al. 2015)
    curing_factor = 1.036/(1+103.989*np.exp(-0.0996*(curing-20)))

    #Rate of spread (by fuel load)

    #set up parameters for CSIRO models
    a_a = 0.054

    a_b = np.full(np.shape(wind_speed),np.nan)
    a_b[grass_condition==GRASS_CONDITION_NATURAL] = 0.269
    a_b[grass_condition==GRASS_CONDITION_GRAZED] = 0.209
    a_b[grass_condition==GRASS_CONDITION_EATENOUT] = 0.209

    a_c = np.full(np.shape(wind_speed),np.nan)
    a_c[grass_condition==GRASS_CONDITION_NATURAL] = 1.4
    a_c[grass_condition==GRASS_CONDITION_GRAZED] = 1.1
    a_c[grass_condition==GRASS_CONDITION_EATENOUT] = 0.55

    a_d = np.full(np.shape(wind_speed),np.nan)
    a_d[grass_condition==GRASS_CONDITION_NATURAL] = 0.838
    a_d[grass_condition==GRASS_CONDITION_GRAZED] = 0.715
    a_d[grass_condition==GRASS_CONDITION_EATENOUT] = 0.357

    rate_of_spread = np.empty(np.shape(wind_speed))
    rate_of_spread_1 = (a_a+a_b*wind_speed)*fuel_moisture_factor*curing_factor*M_PER_KM
    rate_of_spread_2 = ((a_c+a_d*np.power(wind_speed-5, 0.844))*
                        fuel_moisture_factor*curing_factor*M_PER_KM)
    rate_of_spread[wind_speed < 5] = rate_of_spread_1[wind_speed < 5]
    rate_of_spread[wind_speed >= 5] = rate_of_spread_2[wind_speed >= 5]

    return rate_of_spread
    