"""Fire behaviour calculations for spinifex
"""
import numpy as np
import pandas as pd

from . import fire_behaviour_index
from . import fire_danger_rating

HEAT_CONTENT = 16700 #KJ/kg Malcolm Possell pers comm.
KGSQM_TO_TPH = 10.0
SECONDS_PER_HOUR = 3600 #s
MAX_COVER = 75 #%

#Productivity (Prod_BG) is an enum:
#   1   Arid
#   2   Low rainfall
#   3   High rainfall

def calc_fuel_cover (time_since_fire, productivity):
    """Estimate spinifex fuel cover (live + dead) based on the midpoints of the ranges
    as reported in Burrows, N. D., Liddelow G.L. and Ward, B. (2015). A guide to estimating fire
    rate of spread in spinifex grasslands of Western Australia (Mk2v3). [Range for total fuel cover: 15 - 75]
    """
    fuel_cover = np.empty(time_since_fire.shape)
    
    fuel_cover_1 = 26.20 * np.power(time_since_fire, 0.227)
    fuel_cover_23 = 1.5*26.20 * np.power(time_since_fire, 0.227)
    fuel_cover[productivity == 1] = fuel_cover_1[productivity == 1]
    fuel_cover[productivity > 1] = fuel_cover_23[productivity > 1]
    fuel_cover[fuel_cover > MAX_COVER] = MAX_COVER

    return fuel_cover

def calc_age_class (time_since_fire):
    """ Based on:
    Burrows, N. D., Liddelow G.L. and Ward, B. (2015). A guide to estimating fire
    rate of spread in spinifex grasslands of Western Australia (Mk2v3).
    Minimum age class for class two changed to 3 years based on data from NAFI for NT
    """
    age_class = np.empty(time_since_fire.shape)
    age_class[time_since_fire > 20] = 5
    age_class[time_since_fire <= 20] = 4
    age_class[time_since_fire <= 16] = 3
    age_class[time_since_fire <= 11] = 2
    age_class[time_since_fire < 3] = 1

    return age_class

def calc_fuel_moisture (AWAP_uf, time_since_fire, relative_humidity, air_temperature, productivity):
    """AWAP monthly top level soil moisture (unitless 0-1)
    from http://www.sciro.au/awap
    """
    age_class = calc_age_class(time_since_fire)
    fuel_moisture = np.empty(np.shape(time_since_fire))
    fuel_moisture_class_1 = np.full(np.shape(AWAP_uf), 200)
    fuel_moisture_class_2 = 40 * AWAP_uf + 13
    fuel_moisture_class_3 = fuel_moisture_class_2 - (1/(0.03 * relative_humidity)) * 1.5
    fuel_moisture_class_4 = fuel_moisture_class_2 - (1/(0.03 * relative_humidity)) * 2.5
    fuel_moisture_class_5 = fuel_moisture_class_2 - (1/(0.03 * relative_humidity)) * 3.5
    fuel_moisture_class_3[fuel_moisture_class_3 <= 14] = 14
    fuel_moisture_class_4[fuel_moisture_class_4 <= 13] = 13
    fuel_moisture_class_5[fuel_moisture_class_5 <= 12] = 12
    fuel_moisture[age_class==1]=fuel_moisture_class_1[age_class==1]
    fuel_moisture[age_class==2]=fuel_moisture_class_2[age_class==2]
    fuel_moisture[age_class==3]=fuel_moisture_class_3[age_class==3]
    fuel_moisture[age_class==4]=fuel_moisture_class_4[age_class==4]
    fuel_moisture[age_class==5]=fuel_moisture_class_5[age_class==5]

    fuel_moisture[(age_class==1)&(productivity>1)]=fuel_moisture_class_2[(age_class==1)&(productivity>1)]

    simard_moisture = 2.2279 + 0.160107*relative_humidity - 0.014784*air_temperature + 7.0
    fuel_moisture = np.maximum(fuel_moisture,simard_moisture)
    
    return fuel_moisture

def calc_fuel_load (time_since_fire, productivity,FTno_FDR):
    """Estimate fuel load (ton/ha) based on time since fire (years). [Range for fuel load: 0-20 ton/ha]
    Based on: pers. comm. Neil Burrows 16/10/2017.
    """
    #Default equation for productivity==1
    fuel_load = 2.046 * np.power(time_since_fire, 0.420)

    #Apply look up table values from BK analysis of CFI data
    fuel_load[(time_since_fire>5)&(productivity==2)&(FTno_FDR==400)] = 5.6
    fuel_load[(time_since_fire<=5)&(productivity==2)&(FTno_FDR==400)] = 4.96
    fuel_load[(time_since_fire<=4)&(productivity==2)&(FTno_FDR==400)] = 4.21
    fuel_load[(time_since_fire<=3)&(productivity==2)&(FTno_FDR==400)] = 3.36
    fuel_load[(time_since_fire<=2)&(productivity==2)&(FTno_FDR==400)] = 2.39
    fuel_load[(time_since_fire<=1)&(productivity==2)&(FTno_FDR==400)] = 1.28

    fuel_load[(time_since_fire>5)&(productivity==2)&(FTno_FDR==450)] = 5.86
    fuel_load[(time_since_fire<=5)&(productivity==2)&(FTno_FDR==450)] = 5.53
    fuel_load[(time_since_fire<=4)&(productivity==2)&(FTno_FDR==450)] = 5.06
    fuel_load[(time_since_fire<=3)&(productivity==2)&(FTno_FDR==450)] = 4.38
    fuel_load[(time_since_fire<=2)&(productivity==2)&(FTno_FDR==450)] = 3.4
    fuel_load[(time_since_fire<=1)&(productivity==2)&(FTno_FDR==450)] = 2.01

    fuel_load[(time_since_fire>5)&(productivity==3)&(FTno_FDR==400)] = 13.34
    fuel_load[(time_since_fire<=5)&(productivity==3)&(FTno_FDR==400)] = 9.21
    fuel_load[(time_since_fire<=4)&(productivity==3)&(FTno_FDR==400)] = 8.05
    fuel_load[(time_since_fire<=3)&(productivity==3)&(FTno_FDR==400)] = 6.73
    fuel_load[(time_since_fire<=2)&(productivity==3)&(FTno_FDR==400)] = 5.25
    fuel_load[(time_since_fire<=1)&(productivity==3)&(FTno_FDR==400)] = 3.58

    fuel_load[(time_since_fire>5)&(productivity==3)&(FTno_FDR==450)] = 7.38
    fuel_load[(time_since_fire<=5)&(productivity==3)&(FTno_FDR==450)] = 6.84
    fuel_load[(time_since_fire<=4)&(productivity==3)&(FTno_FDR==450)] = 6.49
    fuel_load[(time_since_fire<=3)&(productivity==3)&(FTno_FDR==450)] = 5.95
    fuel_load[(time_since_fire<=2)&(productivity==3)&(FTno_FDR==450)] = 5.11
    fuel_load[(time_since_fire<=1)&(productivity==3)&(FTno_FDR==450)] = 3.78
    
    return fuel_load

def calc_spread_index (wind_speed, time_since_fire, dead_fuel_moisture, productivity):
    """Calculate spread index (go/no-go). Very unlikely fire will spread at SI < 0.
    If SI > 0 fire is likely to spread.
    Based on:
    Burrows, N., Gill, M., and Sharples, J. (2018). Development and validation of a model for
    predicting fire behaviour in spinifex grasslands of arid Australia [IJWF].
    """
    wind_speed_2m = wind_speed / 1.35
    fuel_cover = calc_fuel_cover (time_since_fire, productivity)
    spread_index = 0.412 * wind_speed_2m + 0.311 * fuel_cover - 0.676 * dead_fuel_moisture -4.073
    spread_index[np.isnan(spread_index)] = 0
    return spread_index

def calc_rate_of_spread (spread_index, wind_speed, time_since_fire, dead_fuel_moisture, wind_reduction_savannah, productivity):
    """Based on:
    Burrows, N., Gill, M., and Sharples, J. (2018). Development and validation of a model for
    predicting fire behaviour in spinifex grasslands of arid Australia [IJWF].
    """

    wind_speed_2m = wind_speed / 1.35
    fuel_cover = calc_fuel_cover (time_since_fire, productivity)
    
    rate_of_spread = 40.982 * ((np.power(wind_speed_2m, 1.399)*np.power(fuel_cover, 1.201))/(np.power(dead_fuel_moisture, 1.699)))
    rate_of_spread[np.isnan(rate_of_spread)] = 0
    rate_of_spread[spread_index <= 0] = 0
    rate_of_spread[rate_of_spread < 0] = 0
    
    #Modify rate_of_spread using wind_reduction_savannah [wind reduction values range between 0.3 and 1.0]
    rate_of_spread = rate_of_spread * wind_reduction_savannah

    return rate_of_spread

def calc_intensity(rate_of_spread, time_since_fire, productivity, FTno_FDR):
    """Calculate fire line intensity (kW/m)
    Based on definition in Byram, G. M. (1959). Combustion of forest fuels.
    In Forest fire: control and use.(Ed. KP Davis) pp. 61 89.
    """
    fuel_load = calc_fuel_load (time_since_fire, productivity, FTno_FDR)
    intensity = (HEAT_CONTENT * (fuel_load / KGSQM_TO_TPH) *
                 (rate_of_spread / SECONDS_PER_HOUR))
    return intensity

def calc_flame_height(rate_of_spread, time_since_fire, productivity, FTno_FDR):
    """Calculate flame height in m [range: 0 - 6 m] 
    Based on: 	
    Burrows, N., Gill, M., and Sharples, J. (2018). Development and validation of a model for
    predicting fire behaviour in spinifex grasslands of arid Australia [IJWF].
    """
    fuel_load = calc_fuel_load(time_since_fire, productivity, FTno_FDR)
    flame_height = 0.097 * np.power(rate_of_spread, 0.424) + 0.102 * fuel_load

    return flame_height

def calc_spotting_distance(air_temperature):
    """Return an empty array because spinifex fuels don't spot
    """
    spotting_distance = np.full(air_temperature.shape,np.nan)
    return spotting_distance


def calculate(dataset, fuel_parameters):
    """
    Takes an xarray dataset and a pandas data row.

    Returns: rate_of_spread, flame_height, intensity, spotting_distance, rating, index
    """

    dead_fuel_moisture = calc_fuel_moisture (dataset['AWAP_uf'], 
                                             dataset['time_since_fire'], 
                                             dataset['RH_SFC'], 
                                             dataset['T_SFC'], 
                                             fuel_parameters.Prod_BG)
    
    spread_index = calc_spread_index(dataset['WindMagKmh_SFC'],
                                     dataset['time_since_fire'],
                                     dead_fuel_moisture,
                                     fuel_parameters.Prod_BG)

    rate_of_spread = calc_rate_of_spread(spread_index,
                                         dataset['WindMagKmh_SFC'],
                                         dataset['time_since_fire'],
                                         dead_fuel_moisture,
                                         fuel_parameters.WF_Sav,
                                         fuel_parameters.Prod_BG)

    flame_height = calc_flame_height(rate_of_spread, dataset ['time_since_fire'],fuel_parameters.Prod_BG, fuel_parameters.FTno_FDR)

    intensity = calc_intensity(rate_of_spread, dataset['time_since_fire'],fuel_parameters.Prod_BG, fuel_parameters.FTno_FDR)

    spotting_distance = calc_spotting_distance(dataset['T_SFC'])
    index_1 = fire_behaviour_index.spinifex(spread_index, rate_of_spread)
    rating_1 = fire_danger_rating.fire_danger_rating(index_1)

    return {'dead_fuel_moisture':dead_fuel_moisture,
            'rate_of_spread': rate_of_spread,
            'spread_index': spread_index,
            'flame_height': flame_height,
            'intensity': intensity,
            'spotting_distance': spotting_distance,
            'rating_1': rating_1,
            'index_1': index_1}

