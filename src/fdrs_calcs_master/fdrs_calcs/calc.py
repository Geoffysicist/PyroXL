'''
Copyright Bureau Of Meteorology and NSW Rural Fire Service.

This software is provided under license 'as is', without warranty of any
kind including, but not limited to, fitness for a particular purpose. The
user assumes the entire risk as to the use and performance of the software.
In no event shall the copyright holder be held liable for any claim, damages
or other liability arising from the use of the software.
'''

import numpy as np
import pandas as pd

from .spread_models import (
grass, savannah, dry_forest, wet_forest, spinifex, pine, buttongrass,
low_wetland, heathland, wet_heathland, mallee_heath, chenopod, pasture,
woody_horticulture, rural, acacia_woodland, unburnable, gamba)

SECONDSINHOUR = 3600
SECONDSINYEAR = 3600*24*365.25
GRASS_CONDITION_NATURAL = 3 
GRASS_CONDITION_GRAZED = 2
GRASS_CONDITION_EATENOUT = 1

SPREAD_MODEL_LOOKUP = {
    'Wet_forest': wet_forest,
    'Forest': dry_forest,
    'Heath': heathland,
    'Wet_heath': wet_heathland,
    'Low_wetland': low_wetland,
    'Woodland': savannah,
    'Acacia_woodland': acacia_woodland,
    'Mallee': mallee_heath,
    'Spinifex_woodland': spinifex,
    'Spinifex': spinifex,
    'Chenopod_shrubland': chenopod,
    'Buttongrass': buttongrass,
    'Non_combustible': unburnable,
    'Grass': grass,
    'Gamba': gamba,
    'Pasture': pasture,
    'Woody_horticulture': woody_horticulture,
    'Horticulture': unburnable,
    'Rural': rural,
    'Crop': grass,
    'Pine': pine,
    'Built_up': unburnable,
    'Urban': woody_horticulture,
}

def calculate_indicies(
    temp,
    windmag,
    rh,
    td,
    df,
    curing,
    grass_fuel_load,
    precip,
    time_since_rain,
    time_since_fire,
    ground_moisture,
    fuel_type,
    fuel_table,
    hours,
    months
    ):
    contract = ['dead_fuel_moisture',
                'rate_of_spread',
                'crown_probability',
                'spread_probability',
                'spread_index',
                'flame_height',
                'intensity',
                'spotting_distance',
                'rating_1',
                'index_1']

    dataset = dict(
        AWAP_uf=ground_moisture,
        Curing_SFC=curing,
        DF_SFC=df,
        GrassFuelLoad_SFC=grass_fuel_load,
        RH_SFC=rh,
        T_SFC=temp,
        Td_SFC=td,
        WindMagKmh_SFC=windmag,
        hours=hours,
        months=months,
        precipitation=precip,
        time_since_fire=time_since_fire,
        time_since_rain=time_since_rain
    )

    if 'grass_condition' not in dataset:
        dataset['grass_condition'] = np.full(dataset['GrassFuelLoad_SFC'].shape,np.nan) 
        dataset['grass_condition'][dataset['GrassFuelLoad_SFC']>=6] = GRASS_CONDITION_NATURAL
        dataset['grass_condition'][(dataset['GrassFuelLoad_SFC']>=3)&(dataset['GrassFuelLoad_SFC']<6)] = GRASS_CONDITION_GRAZED
        dataset['grass_condition'][dataset['GrassFuelLoad_SFC']<3] = GRASS_CONDITION_EATENOUT
    

    outputs = {x: np.full_like(temp, np.nan) for x in contract}

    for index, fuel_parameters in fuel_table.iterrows():
        mask = np.broadcast_to(fuel_type.astype(int) == int(fuel_parameters.FTno_State), temp.shape)
        if mask.any():
            reduced_dataset = {x: y[mask] for x, y in dataset.items()}

            fire_model = fuel_parameters['Fuel_FDR']
            reduced_output = SPREAD_MODEL_LOOKUP[fire_model].calculate(reduced_dataset, fuel_parameters)

            for param in contract:
                if param in reduced_output:
                    outputs[param][mask] = reduced_output[param]

    return outputs


def build_local_time_grids(utc_forecast_times, tz_grid):
    '''Build a country wide grid for local hours.'''

    final_shape = utc_forecast_times.shape + tz_grid.shape
    hours = np.broadcast_to(utc_forecast_times.hour, np.flip(final_shape, 0)).T
    hours = (np.broadcast_to(tz_grid, final_shape) + hours) % 24

    months = np.broadcast_to(utc_forecast_times.month.values, np.flip(final_shape, axis=0)).T
    months = np.where(np.isnan(tz_grid), np.nan, months)

    return months, hours


def update_time_since_fire(tsf_grid, tsf_grid_time, calculation_time):
    '''Adjust the time since fire grids to reflect the current time of calculation.'''

    time_since_production = (pd.to_datetime(calculation_time) - pd.to_datetime(tsf_grid_time)).total_seconds()
    tsf = tsf_grid + time_since_production // SECONDSINYEAR
    return tsf
