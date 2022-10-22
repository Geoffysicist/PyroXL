"""Fire behaviour calculations for gamba (invasive gamba grass with wind reduction factor)
"""
import numpy as np

from . import fire_behaviour_index
from . import fire_danger_rating

from .csiro_grassland import calc_fuel_moisture
from .csiro_grassland import calc_fuel_moisture_factor
from .csiro_grassland import calc_flame_height
from .csiro_grassland import calc_spotting_distance

HEAT_CONTENT = 18600 #KJ/kg
KGSQM_TO_TPH = 10.0
M_PER_KM = 1000
SECONDS_PER_HOUR = 3600 #s

def calc_rate_of_spread(dead_fuel_moisture, wind_speed, curing, wind_reduction_savannah):
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

    #set up parameters for CSIRO models
    #Always use natural for gamba grass
    #This assumes that Gamba ROS is not even higher in spite of high fuel height
    a_a = 0.054
    a_b = 0.269
    a_c = 1.4
    a_d = 0.838

    rate_of_spread = np.empty(np.shape(wind_speed))
    rate_of_spread_1 = (a_a+a_b*wind_speed)*fuel_moisture_factor*curing_factor*M_PER_KM
    rate_of_spread_2 = ((a_c+a_d*np.power(wind_speed-5, 0.844))*
                        fuel_moisture_factor*curing_factor*M_PER_KM)
    rate_of_spread[wind_speed < 5] = rate_of_spread_1[wind_speed < 5]
    rate_of_spread[wind_speed >= 5] = rate_of_spread_2[wind_speed >= 5]

    #Modify rate_of_spread using wind_reduction_savannah [wind reduction values range from 0.3 to 1.0]
    rate_of_spread = rate_of_spread*wind_reduction_savannah

    return rate_of_spread

def calc_intensity(rate_of_spread, fuel_load):
    """Calculate fire line intensity (kW/m)
    """
    intensity = (HEAT_CONTENT * (fuel_load / KGSQM_TO_TPH) *
                 (rate_of_spread / SECONDS_PER_HOUR))
    return intensity

def calculate(dataset, fuel_parameters):
    """
    Takes an xarray dataset and a pandas data row.

    Returns: rate_of_spread, flame_height, intensity, spotting_distance, rating, index
    """

    months = dataset['months']
    hours = dataset['hours']

    dead_fuel_moisture = calc_fuel_moisture(dataset['T_SFC'], dataset['RH_SFC'])

    rate_of_spread = calc_rate_of_spread(dead_fuel_moisture,
                                         dataset['WindMagKmh_SFC'],
                                         dataset['Curing_SFC'],
                                         fuel_parameters.WF_Sav)

    flame_height = calc_flame_height(rate_of_spread, fuel_parameters.FL_total)

    intensity = calc_intensity(rate_of_spread, fuel_parameters.FL_total)

    spotting_distance = calc_spotting_distance(dataset['T_SFC'])

    index_1 = fire_behaviour_index.grass(intensity)
    rating_1 = fire_danger_rating.fire_danger_rating(index_1)

    return {'dead_fuel_moisture':dead_fuel_moisture,
            'rate_of_spread': rate_of_spread,
            'flame_height': flame_height,
            'intensity': intensity,
            'spotting_distance': spotting_distance,
            'dead_fuel_moisture': dead_fuel_moisture,
            'rating_1': rating_1,
            'index_1': index_1}

