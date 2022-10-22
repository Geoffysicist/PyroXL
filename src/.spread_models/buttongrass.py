"""Fire behaviour calculations for buttongrass
"""
import numpy as np
import pandas as pd

from . import fire_behaviour_index
from . import fire_danger_rating

HEAT_CONTENT = 19900
"""KJ/kg, based on Marsden-Smedley, J. B. and W. R. Catchpole (1995).
Fire modelling in Tasmanian buttongrass moorlands I. Fuel characteristics. International Journal
of Wildland Fire 5(4): 203-214.
"""
KGSQM_TO_TPH = 10.0
SECONDS_PER_HOUR = 3600 #s


def calc_fuel_moisture (precipitation, time_since_rain, relative_humidity, dew_point_temp):
    """For fuel moisture content we use the equations as presented in
    Marsden-Smedley, J. B., et al. (1999). Buttongrass moorland fire-behaviour prediction
    and management. Tasforests 11: 87-107. [range: 0-100, if > 100 fire spread unlikely]
    Precipitation in mm. Time_since_rain in hours.
    """

    fuel_moisture = np.empty(np.shape(time_since_rain))
    fuel_moisture = ((67.128 * (1-np.exp(-3.132 * precipitation)) * np.exp(-0.0858 * time_since_rain)) +
                     (np.exp(1.660 + 0.0214 * relative_humidity - 0.0292 * dew_point_temp)))

    return fuel_moisture


def calc_fuel_load (time_since_fire, productivity):
    """Estimate fuel load (ton/ha) based on time since fire (years). Please note it is unclear
    if 'total fuel' will burn, or just a fraction of it (e.g. 'dead fuel load'). For now
    we are using total fuel load which will very likely lead to overestimation because
    it is very unlikely that all of this fuel will burn during a fire.[Range for fuel load: 0-45 ton/ha]
    Based on: Marsden-Smedley, J. B., et al. (1999). Buttongrass moorland fire-behaviour prediction
    and management. Tasforests 11: 87-107.
    """
    fuel_load = np.empty(np.shape(time_since_fire))
    fuel_load_low = 11.73 * (1-np.exp(-0.106 * time_since_fire))
    fuel_load_med = 44.61 * (1-np.exp(-0.041 * time_since_fire))
    if productivity == 1:
        fuel_load = fuel_load_low
    elif productivity == 2:
        fuel_load = fuel_load_med

    return fuel_load


def calc_spread_probability (wind_speed, fuel_moisture,
                             time_since_fire, productivity):
    """Probability of sustained fire spread ('go/no-go', value between 0 and 1). From Marsden-Smedley,
    J. B., et al. (1999). Buttongrass moorland fire-behaviour prediction and management.
    Tasforests 11: 87-107.
    Careful! This equation is actually not described in the text.
    It seems that there was a typo as well (minus at the beginning of the equation, corrected here.)
    """
    wind_speed_2m = wind_speed / 1.2
    spread_probability = (1/(1+np.exp(-(-1 + 0.68 * wind_speed_2m - 0.07 * fuel_moisture -
                          0.0037 * wind_speed_2m * fuel_moisture + 2.1 * productivity))))

    return spread_probability

def calc_rate_of_spread (wind_speed, fuel_moisture, spread_probability,
                         time_since_fire, productivity):
    """ Calcualte forward rate of spread in m/h [range: 0-3500 m/h]
    Marsden-Smedley, J. B. and W. R. Catchpole (1995).
    Fire modelling in Tasmanian buttongrass moorlands I. Fuel characteristics. International Journal
    of Wildland Fire 5(4): 203-214.
    """
    wind_speed_2m = wind_speed / 1.2

    rate_of_spread = (0.678 * np.power(wind_speed_2m, 1.312) * np.exp(-0.0243*fuel_moisture)*
                      (1-np.exp(-0.116 * time_since_fire)) * 60)
    rate_of_spread[spread_probability <= 0.5] = 0

    return rate_of_spread

def calc_intensity(rate_of_spread, time_since_fire, productivity):
    """Calculate fire line intensity (kW/m)
    Based on definition in Byram, G. M. (1959). Combustion of forest fuels.
    In Forest fire: control and use.(Ed. KP Davis) pp. 61 89.
    """
    fuel_load = calc_fuel_load(time_since_fire, productivity)
    intensity = (HEAT_CONTENT * (fuel_load / KGSQM_TO_TPH) *
                 (rate_of_spread / SECONDS_PER_HOUR))
    return intensity

def calc_flame_height(intensity):
    """ Calculate flame height in m [range: 0-6 m].
    Marsden-Smedley, J. B. and W. R. Catchpole (1995).
    Fire modelling in Tasmanian buttongrass moorlands I. Fuel characteristics. International Journal
    of Wildland Fire 5(4): 203-214.
    """
    flame_height = 0.148 * np.power(intensity, 0.403)

    return flame_height

def calc_spotting_distance(air_temperature):
    """Return an empty array because buttongrass fuels don't spot
    """
    spotting_distance = np.empty(np.shape(air_temperature))
    spotting_distance.fill(np.nan)
    return spotting_distance

def calculate(dataset, fuel_parameters):
    """
    Takes an xarray dataset and a pandas data row.

    Returns: rate_of_spread, flame_height, intensity, spotting_distance, rating, index
    """

    dead_fuel_moisture = calc_fuel_moisture(dataset['precipitation'], 
                                            dataset['time_since_rain'],
                                            dataset['RH_SFC'],
                                            dataset['Td_SFC'])

    spread_probability = calc_spread_probability (dataset['WindMagKmh_SFC'], 
                                                  dead_fuel_moisture,
                                                  dataset['time_since_fire'], 
                                                  int(fuel_parameters.Prod_BG))


    rate_of_spread = calc_rate_of_spread(dataset['WindMagKmh_SFC'],
                                         dead_fuel_moisture,
                                         spread_probability,
                                         dataset['time_since_fire'],
                                         int(fuel_parameters.Prod_BG))

    intensity = calc_intensity(rate_of_spread,
                               dataset['time_since_fire'],
                               int(fuel_parameters.Prod_BG))

    flame_height = calc_flame_height(intensity)

    spotting_distance = calc_spotting_distance(dataset['T_SFC'])
    index_1 = fire_behaviour_index.buttongrass(rate_of_spread)
    rating_1 = fire_danger_rating.fire_danger_rating(index_1)

    return {'dead_fuel_moisture': dead_fuel_moisture,
            'rate_of_spread': rate_of_spread,
            'flame_height': flame_height,
            'intensity': intensity,
            'spotting_distance': spotting_distance,
            'rating_1': rating_1,
            'index_1': index_1}

