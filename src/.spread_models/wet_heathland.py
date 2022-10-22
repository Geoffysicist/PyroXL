"""Fire behaviour calculations for heathland
"""
import numpy as np
import pandas as pd

from . import fire_behaviour_index
from . import fire_danger_rating

from .heathland import calc_fuel_moisture
from .heathland import calc_fuel_load
from .heathland import calc_rate_of_spread
from .heathland import calc_intensity
from .heathland import calc_flame_height
from .heathland import calc_spotting_distance

HEAT_CONTENT = 18600 #kJ/kg
KGSQM_TO_TPH = 10.0
SECONDS_PER_HOUR = 3600 #s


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
