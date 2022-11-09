import numpy as np

from . import fire_danger_rating

def calc_rate_of_spread(any_grid):
    rate_of_spread = np.full(any_grid.shape,np.nan)
    return rate_of_spread

def calc_intensity(any_grid):
    intensity = np.full(any_grid.shape,np.nan)
    return intensity

def calc_flame_height(any_grid):
    flame_height = np.full(any_grid.shape,np.nan)
    return flame_height

def calc_spotting_distance(any_grid):
    spotting_distance = np.full(any_grid.shape,np.nan)
    return spotting_distance

def calc_rating_1(any_grid):
    rating = np.full(any_grid.shape,np.nan)
    return rating

def calc_index_1(any_grid):
    index_1 = np.full(any_grid.shape,np.nan)
    return index_1

def calculate(dataset, fuel_parameters):
    """
    Takes an xarray dataset and a pandas data row.

    Returns: rate_of_spread, flame_height, intensity, spotting_distance, rating, index
    """

    rate_of_spread = calc_rate_of_spread(list(dataset.values())[0])
    flame_height = calc_flame_height(rate_of_spread)
    intensity = calc_intensity(rate_of_spread)
    spotting_distance = calc_spotting_distance(list(dataset.values())[0])
    index_1 = calc_index_1(intensity)
    rating_1 = fire_danger_rating.fire_danger_rating(index_1)

    return {'rate_of_spread': rate_of_spread,
            'flame_height': flame_height,
            'intensity': intensity,
            'spotting_distance': spotting_distance,
            'rating_1': rating_1,
            'index_1': index_1}
