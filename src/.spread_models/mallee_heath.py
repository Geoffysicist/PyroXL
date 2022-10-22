"""Fire behaviour calculations for mallee-heath
"""
import numpy as np
import pandas as pd

from . import fire_behaviour_index
from . import fire_danger_rating

START_PEAK_MONTH = 10 #October
END_PEAK_MONTH = 3 #March
START_AFTERNOON = 12
END_AFTERNOON = 17
HEAT_CONTENT = 18600 #KJ/kg
KGSQM_TO_TPH = 10.0
SECONDS_PER_HOUR = 3600 #s
FLAME_HEIGHT_CROWN_FRACTION = 0.66 #m


def calc_fuel_moisture (relative_humidity, air_temperature, time, precipitation, time_since_rain):
    """Calculate fuel moisture content(%)
    Based on Cruz, M. G., et al. (2015). A Guide to Rate of Fire Spread Models for
    Australian Vegetation.
    Fuel_moisture_1 assumes sunny days. Maybe we could include cloud cover at some point...
    In addition, a fuel moisture modifier based on recent rainfall was used. Marsden-Smedley, J. B.,
    et al. (1999). Buttongrass moorland fire-behaviour prediction
    and management. Tasforests 11: 87-107.
    Precipitation in mm. Time_since_rain in hours.
    """
    months, hours = time
    fuel_moisture = np.empty(relative_humidity.shape)
    fuel_moisture_1 = (4.79 + 0.173 * relative_humidity - 0.1 * (air_temperature - 25)
                       - 0.027 * relative_humidity)
    fuel_moisture_2 = 4.79 + 0.173 * relative_humidity - 0.1 * (air_temperature - 25)
    selector_1 = (((months >= START_PEAK_MONTH) | (months <= END_PEAK_MONTH)) &
                  (hours >= START_AFTERNOON) & (hours <= END_AFTERNOON))
    selector_2 = np.logical_not(selector_1)
    fuel_moisture[selector_1] = fuel_moisture_1[selector_1]
    fuel_moisture[selector_2] = fuel_moisture_2[selector_2]
    fuel_moisture += 67.128 * (1-np.exp(-3.132 * precipitation)) * np.exp(-0.0858 * time_since_rain)
    return fuel_moisture


def calc_spread_probability (wind_speed, fuel_moisture, overstorey_cover):
    """Calculate the likelihood of spread sustainability (go/no-go) [value between 0 and 1].
    Based on: Cruz, M. G., et al. (2013). "Fire behaviour modelling in semi-arid
    mallee-heath shrublands of southern Australia." Environmental Modelling & Software 40: 21-34.
    """
    spread_probability = (1 / (1 + np.exp(-(14.624 + 0.2066 * wind_speed - 1.8719 * fuel_moisture - 0.030442 * overstorey_cover))))

    return spread_probability


def calc_crown_probability (wind_speed, fuel_moisture):
    """Predict type of fire, i.e. surface fire, crown fire, or an ensemble of the two, based on
    crown probability [value between 0 and 1].
    Based on: Cruz, M. G., et al. (2013). "Fire behaviour modelling in semi-arid
    mallee-heath shrublands of southern Australia." Environmental Modelling & Software 40: 21-34.
    """
    crown_probability = np.empty(np.shape(wind_speed))
    crown_probability = 1 / (1 + np.exp(-(-11.138 + 1.4054 * wind_speed - 3.4217 * fuel_moisture)))

    return crown_probability

def calc_rate_of_spread (wind_speed, fuel_moisture, overstorey_cover,overstorey_height):
    """ Calculate rate of spread in m/h. [Range = 0 - 8000].
    Based on: Cruz, M. G., et al. (2013). "Fire behaviour modelling in semi-arid
    mallee-heath shrublands of southern Australia." Environmental Modelling & Software 40: 21-34.
    Overstorey cover in %, overstorey height in m.
    """
    spread_probability = calc_spread_probability (wind_speed, fuel_moisture,overstorey_cover)
    crown_probability = calc_crown_probability (wind_speed, fuel_moisture)

    rate_of_spread = np.empty(np.shape(wind_speed))

    fire_spread_surface = (3.337 * wind_speed * np.exp(-0.1284 * fuel_moisture)*
                           np.power(overstorey_height, -0.7073) * 60)
    fire_spread_crown = (9.5751 * wind_speed * np.exp(-0.1795 * fuel_moisture) *
                         np.power((overstorey_cover/100), 0.3589)*60)
    fire_spread_ensemble = ((1 - crown_probability) * fire_spread_surface + crown_probability
                            * fire_spread_crown)

    rate_of_spread [spread_probability < 0.5] = 0
    rate_of_spread [spread_probability >= 0.5] = rate_of_spread[spread_probability >= 0.5]
    rate_of_spread[crown_probability <= 0.01] = fire_spread_surface[crown_probability <= 0.01]
    rate_of_spread[crown_probability > 0.99] = fire_spread_crown[crown_probability > 0.99]
    rate_of_spread[(crown_probability > 0.01) & (crown_probability <= 0.99)] = fire_spread_ensemble[(crown_probability > 0.01) & (crown_probability <= 0.99)]

    return rate_of_spread


def calc_fuel_load (wind_speed, time_since_fire, fuel_moisture,
                    fuel_load_surface, fuel_load_canopy, k_surface, k_canopy):
    """Use exponetial decay model to adjust fuel for age (fuel build-up).
    Based on Olson, J. S. (1963). Energy storage and the balance of producers
    and decomposers in ecological systems. Ecology, 44(2), 322-331.
    Include canopy fuel based on crown_probability (Cruz pers. comm.).
    """

    crown_probability = calc_crown_probability (wind_speed, fuel_moisture)

    fuel_load = np.empty(np.shape(wind_speed))

    fuel_load_surface_grid = fuel_load_surface * (1-np.exp(-time_since_fire * k_surface))
    fuel_load_crown_grid = fuel_load_canopy * (1-np.exp(-time_since_fire * k_canopy))
    fuel_load_ensemble_grid = fuel_load_surface_grid + crown_probability * fuel_load_crown_grid

    fuel_load [crown_probability <= 0.01] = fuel_load_surface_grid[crown_probability <= 0.01]
    fuel_load [crown_probability > 0.99] = fuel_load_surface_grid[crown_probability > 0.99] + fuel_load_crown_grid[crown_probability > 0.99]
    fuel_load [(crown_probability > 0.01) & (crown_probability <= 0.99)] = fuel_load_ensemble_grid[(crown_probability > 0.01) & (crown_probability <= 0.99)]

    return fuel_load

def calc_intensity(rate_of_spread,fuel_load):
    """Calculate fire line intensity (kW/m)
    Based on definition in Byram, G. M. (1959). Combustion of forest fuels.
    In Forest fire: control and use.(Ed. KP Davis) pp. 61 89.
    """
    intensity = (HEAT_CONTENT * (fuel_load / KGSQM_TO_TPH) *
                 (rate_of_spread / SECONDS_PER_HOUR))

    return intensity

def calc_flame_height(intensity):
    """Calculate flame height in m [range: 0 - 10 m]
    Based on: Cruz, M. G., et al. (2013). "Fire behaviour modelling in semi-arid
    mallee-heath shrublands of southern Australia." Environmental Modelling & Software 40: 21-34.
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

    # Numpy functions take dataset and fuel parameters and return numpy
    # objects

    months = dataset['months']
    hours = dataset['hours']

    fuel_moisture = calc_fuel_moisture (dataset['RH_SFC'],
                                        dataset['T_SFC'],
                                        (months, hours),
                                        dataset['precipitation'],
                                        dataset['time_since_rain'])

    fuel_load = calc_fuel_load(dataset['WindMagKmh_SFC'],
                               dataset['time_since_fire'],
                               fuel_moisture,
                               fuel_parameters.FL_s,
                               fuel_parameters.FL_o,
                               fuel_parameters.Fk_s,
                               fuel_parameters.Fk_o)


    spread_probability = calc_spread_probability (dataset ['WindMagKmh_SFC'],
                                                  fuel_moisture,
                                                  fuel_parameters.Cov_o)
    crown_probability = calc_crown_probability (dataset['WindMagKmh_SFC'],
                                                fuel_moisture)

    rate_of_spread = calc_rate_of_spread(dataset['WindMagKmh_SFC'],
                                         fuel_moisture,
                                         fuel_parameters.Cov_o,
                                         fuel_parameters.H_o)

    intensity = calc_intensity(rate_of_spread,fuel_load)

    flame_height = calc_flame_height(intensity)

    spotting_distance = calc_spotting_distance(dataset['T_SFC'])
    index_1 = fire_behaviour_index.mallee_heath(spread_probability, crown_probability, intensity)
    rating_1 = fire_danger_rating.fire_danger_rating(index_1)

    return {'dead_fuel_moisture':fuel_moisture,
            'rate_of_spread': rate_of_spread,
            'crown_probability': crown_probability,
            'spread_probability': spread_probability,
            'flame_height': flame_height,
            'intensity': intensity,
            'spotting_distance': spotting_distance,
            'rating_1': rating_1,
            'index_1': index_1}

