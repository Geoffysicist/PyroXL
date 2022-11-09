"""Fire behaviour calculations for heathland
"""
import numpy as np
import pandas as pd

from . import fire_behaviour_index
from . import fire_danger_rating

HEAT_CONTENT = 18600 #kJ/kg
KGSQM_TO_TPH = 10.0
SECONDS_PER_HOUR = 3600 #s

def calc_fuel_moisture (relative_humidity, air_temperature, precipitation, time_since_rain):
    """Calculate fuel moisture content (%). Based on:
    Cruz, M., et al. (2010). Fire dynamics in mallee-heath: fuel, weather
    and fire behaviour prediction in south Australian semi-arid shrublands.
    Bushfire CRC Program A Rep 1(01).

    In addition, a fuel moisture modifier based on recent rainfall was used. Marsden-Smedley, J. B.,
    et al. (1999). Buttongrass moorland fire-behaviour prediction
    and management. Tasforests 11: 87-107.
    Precipitation in mm. Time_since_rain in hours.
    """

    fuel_moisture = np.empty(relative_humidity.shape)
    fuel_moisture_1 = (4.37 + 0.161 * relative_humidity - 0.1 * (air_temperature - 25)
                       - 0.027 * relative_humidity)
    fuel_moisture_2 = 4.37 + 0.161 * relative_humidity - 0.1 * (air_temperature - 25)
    fuel_moisture[relative_humidity <= 60] = fuel_moisture_1[relative_humidity <= 60]
    fuel_moisture[relative_humidity > 60] = fuel_moisture_2[relative_humidity > 60]
    fuel_moisture += 67.128 * (1-np.exp(-3.132 * precipitation)) * np.exp(-0.0858 * time_since_rain)
    return fuel_moisture


def calc_fuel_load (fuel_load_total_max, time_since_fire, k):
    """For intensity-calculations. Comes directly from Bel's look-up table?
    """
    fuel_load = fuel_load_total_max * (1-np.exp(-time_since_fire * k))
    return fuel_load


def calc_rate_of_spread (wind_reduction_factor, wind_speed, elevated_height, fuel_moisture):
    """ Calculate forward rate of spread in m/h [range: 0-6000 m/h]
    Anderson, W. R., et al. (2015). "A generic, empirical-based model for predicting rate of fire
    spread in shrublands." International Journal of Wildland Fire 24(4): 443-460.
    Elevated height in m.
    """

    fuel_moisture_factor = np.exp(-0.0762 * fuel_moisture)
    fuel_moisture_factor[fuel_moisture<4] = np.exp(-0.0762 * 4)
    fuel_moisture_factor[fuel_moisture>20] = 0.05

    rate_of_spread = (5.6715 * np.power((wind_reduction_factor * wind_speed), 0.912) *
                      np.power((elevated_height), 0.227) * fuel_moisture_factor * 60)

    #Apply go-nogo model
    rate_of_spread *= 1.0/(1+np.exp(-0.4*(wind_reduction_factor *wind_speed-20)))                 
    rate_of_spread *= 1.0/(1+np.exp(-0.4*(12-fuel_moisture)))                 
                      
    return rate_of_spread

def calc_intensity(rate_of_spread, fuel_load_total_max, time_since_fire, k):
    """Calculate fire line intensity (kW/m)
    Based on definition in Byram, G. M. (1959). Combustion of forest fuels.
    In Forest fire: control and use.(Ed. KP Davis) pp. 61 89.
    """
    fuel_load = calc_fuel_load(fuel_load_total_max, time_since_fire, k)
    intensity = (HEAT_CONTENT * (fuel_load / KGSQM_TO_TPH) *
                 (rate_of_spread / SECONDS_PER_HOUR))

    return intensity

def calc_flame_height(intensity):
    """No equation for flame height was given in the Anderson et al. paper (2015).
    Here we use the flame height calculation for mallee-heath shrublands (Cruz, M. G., et al. (2013).
    "Fire behaviour modelling in semi-arid mallee-heath shrublands of southern Australia.
    Environmental Modelling & Software 40: 21-34).
    """

    flame_height = np.exp(-4.142) * np.power(intensity, 0.633)

    return flame_height

def calc_spotting_distance(air_temperature):
    """Short distance spotting possible, long distance spotting unlikely.
    Return an empty array because we don't have a better solution for now.
    """
    spotting_distance = np.empty(np.shape(air_temperature))
    spotting_distance.fill(np.nan)

    return spotting_distance

def calculate(dataset, fuel_parameters):
    """
    Takes an xarray dataset and a pandas data row.

    Returns: rate_of_spread, flame_height, intensity, spotting_distance, rating, index
    """

    dead_fuel_moisture = calc_fuel_moisture(dataset['RH_SFC'], 
                                            dataset['T_SFC'], 
                                            dataset['precipitation'], 
                                            dataset['time_since_rain'])

    rate_of_spread = calc_rate_of_spread(fuel_parameters.WF_Heath,
                                         dataset['WindMagKmh_SFC'],
                                         fuel_parameters.H_el,
                                         dead_fuel_moisture)

    intensity = calc_intensity(rate_of_spread,
                               fuel_parameters.FL_total,
                               dataset['time_since_fire'],
                               fuel_parameters.Fk_total)

    flame_height = calc_flame_height(intensity)

    spotting_distance = calc_spotting_distance(dataset['T_SFC'])
    index_1 = fire_behaviour_index.heathland(intensity)
    rating_1 = fire_danger_rating.fire_danger_rating(index_1)

    return {'dead_fuel_moisture': dead_fuel_moisture,
            'rate_of_spread': rate_of_spread,
            'flame_height': flame_height,
            'intensity': intensity,
            'spotting_distance': spotting_distance,
            'rating_1': rating_1,
            'index_1': index_1}
