"""Fire behaviour calculations for native grasslands
"""
import numpy as np

from . import fire_behaviour_index
from . import fire_danger_rating

from .csiro_grassland import calc_fuel_moisture
from .csiro_grassland import calc_fuel_moisture_factor
from .csiro_grassland import calc_rate_of_spread
from .csiro_grassland import calc_intensity
from .csiro_grassland import calc_flame_height
from .csiro_grassland import calc_spotting_distance

HEAT_CONTENT = 18600 #KJ/kg
KGSQM_TO_TPH = 10.0
M_PER_KM = 1000
SECONDS_PER_HOUR = 3600 #s

def calculate(dataset, fuel_parameters):
    """
    Takes an xarray dataset and a pandas data row.

    Returns: rate_of_spread, flame_height, intensity, spotting_distance, rating, index
    """

    dead_fuel_moisture = calc_fuel_moisture(dataset['T_SFC'], dataset['RH_SFC'])

    rate_of_spread = calc_rate_of_spread(dead_fuel_moisture,
                                         dataset['WindMagKmh_SFC'],
                                         dataset['Curing_SFC'],
                                         dataset['grass_condition'])

    flame_height = calc_flame_height(rate_of_spread, dataset['GrassFuelLoad_SFC'])

    intensity = calc_intensity(rate_of_spread, dataset['GrassFuelLoad_SFC'])

    spotting_distance = calc_spotting_distance(dataset['T_SFC'])

    index_1 = fire_behaviour_index.grass(intensity)
    rating_1 = fire_danger_rating.fire_danger_rating(index_1)

    return {'dead_fuel_moisture':dead_fuel_moisture,
            'rate_of_spread': rate_of_spread,
            'flame_height': flame_height,
            'intensity': intensity,
            'spotting_distance': spotting_distance,
            'rating_1': rating_1,
            'index_1': index_1}

