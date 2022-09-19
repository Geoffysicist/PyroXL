"""Fire behaviour calculations for dry forests
"""
from xmlrpc.client import DateTime
import numpy as np
import pandas as pd

from . import fire_behaviour_index
from . import fire_danger_rating

START_PEAK_MONTH = 10 #October
END_PEAK_MONTH = 3 #March
START_AFTERNOON = 12
END_AFTERNOON = 17
SUNRISE = 6
SUNSET = 19
THRESHOLD_WIND_SPEED = 5.0 #km/h
FLAME_HEIGHT_ELEVATED = 1 #m
FLAME_HEIGHT_CROWN_FRACTION = 0.66 #unitless
HEAT_CONTENT = 18600 #KJ/kg
KGSQM_TO_TPH = 10.0
SECONDS_PER_HOUR = 3600 #s

def calc_fuel_amount(time_since_fire, fuel_max, k):
    """Use exponetial decay model to adjust fuel load or hazard for age
    Based on Olson, J. S. (1963). Energy storage and the balance of producers
    and decomposers in ecological systems. Ecology, 44(2), 322-331.
    """
    return fuel_max*(1-(np.exp(-time_since_fire*k)))

def fuel_availability(drought_factor):
    """Use drought factor to estimate amount of fuel available to burn
    Based on original drought factor definition.
    """
    return 0.1*drought_factor

def fuel_moisture_model(air_temperature, relative_humidity, datetimes):
    """Calculate dead fuel moisture (%)
    Based on Matthews, S., Gould, J., & McCaw, L. (2010). Simple models for
    predicting dead fuel moisture in eucalyptus forests. International Journal
    of Wildland Fire, 19(4), 459-467.
    """
    # datetimes = datetimes.to_frame(name='datetime')
    months = datetimes.dt.month
    hours = datetimes.dt.hour
    
    fuel_moisture = np.empty(relative_humidity.shape)

    fuel_moisture_1 = 2.76+0.124*relative_humidity-0.0187*air_temperature
    fuel_moisture_2 = 3.60+0.169*relative_humidity-0.0450*air_temperature
    fuel_moisture_3 = 3.08+0.198*relative_humidity-0.0483*air_temperature

    selector_1 = (((months >= START_PEAK_MONTH) | (months <= END_PEAK_MONTH)) &
                  (hours >= START_AFTERNOON) & (hours <= END_AFTERNOON))
    selector_3 = ((hours <= SUNRISE) | (hours >= SUNSET))
    selector_2 = (np.logical_not(selector_1 | selector_3))

    fuel_moisture[selector_1] = fuel_moisture_1[selector_1]
    fuel_moisture[selector_2] = fuel_moisture_2[selector_2]
    fuel_moisture[selector_3] = fuel_moisture_3[selector_3]

    return fuel_moisture

def calc_rate_of_spread(fuel_moisture, wind_speed,
                        drought_factor, 
                        FHS_s, FHS_ns, H_ns,
                        wind_reduction_factor):
    """Calculate rate of spread in m/h
    Based on Cheney, N. P., Gould, J. S., McCaw, W. L., & Anderson, W. R. (2012).
    Predicting fire behaviour in dry eucalypt forest in southern Australia.
    Forest Ecology and Management, 280, 120-131.
    """
    #Use fire history to modify fuel parameters
    # hazard_score_s_grid = calc_fuel_amount(time_since_fire, FHS_s, Fk_s)
    # hazard_score_ns_grid = calc_fuel_amount(time_since_fire, FHS_ns, Fk_ns)
    # height_ns_grid = calc_fuel_amount(time_since_fire, H_ns, Hk_ns)
    hazard_score_s_grid = FHS_s
    hazard_score_ns_grid = FHS_ns
    height_ns_grid = H_ns
    height_ns_grid = np.clip(height_ns_grid,0,20)

    #Use drought factor to modify fuel parameters
    fuel_modifier = fuel_availability(drought_factor)
    hazard_score_s_grid = fuel_modifier*hazard_score_s_grid
    hazard_score_ns_grid = fuel_modifier*hazard_score_ns_grid

    #Modify wind speed using wind_reduction_factor
    wind_speed_mod = wind_speed*3.0/wind_reduction_factor

    #Fuel moisture factor
    fuel_moisture_factor = 18.35*np.power(fuel_moisture, -1.495)
    fuel_moisture_factor[fuel_moisture<4] = 18.35*np.power(4, -1.495)
    fuel_moisture_factor[fuel_moisture>20] = 0.05
    
    #Rate of spread at 7% moisture
    rate_of_spread = np.empty(np.shape(wind_speed))
    rate_of_spread_1 = (30+1.5308*
                        np.power(wind_speed_mod-THRESHOLD_WIND_SPEED, 0.8576)*
                        np.power(hazard_score_s_grid, 0.9301)*
                        np.power(hazard_score_ns_grid*height_ns_grid, 0.6366)*1.03)
    rate_of_spread_2 = np.full(np.shape(wind_speed), 30)
    rate_of_spread[wind_speed_mod > THRESHOLD_WIND_SPEED] = (
        rate_of_spread_1[wind_speed_mod > THRESHOLD_WIND_SPEED])
    rate_of_spread[wind_speed_mod <= THRESHOLD_WIND_SPEED] = (
        rate_of_spread_2[wind_speed_mod <= THRESHOLD_WIND_SPEED])

    #Apply moisture correction
    rate_of_spread = fuel_moisture_factor*rate_of_spread

    return rate_of_spread

def calc_intensity(drought_factor, flame_height, rate_of_spread,
                   FL_s, FL_ns, FL_el, FL_b, FL_o, H_o,
                   ):
    """Calculate fire line intensity (kW/m)
    Based on definition in Byram, G. M. (1959). Combustion of forest fuels.
    In ‘Forest fire: control and use’.(Ed. KP Davis) pp. 61–89.
    Modified by RFS to include fuel layers based on flame height.
    """
    #Use fire history to modify fuel parameters
    fuel_load_surface_grid = FL_s
    fuel_load_near_surface_grid = FL_ns
    fuel_load_elevated_grid = FL_el
    # fuel_load_bark_grid = FL_b
    fuel_load_canopy_grid = FL_o

    #Use drought factor to modify fuel parameters
    fuel_modifier_df = fuel_availability(drought_factor)
    fuel_load_surface_grid = fuel_modifier_df*fuel_load_surface_grid
    fuel_load_surface_grid = np.clip(fuel_load_surface_grid,0,10)
    fuel_load_near_surface_grid = fuel_modifier_df*fuel_load_near_surface_grid
    fuel_load_elevated_grid = fuel_modifier_df*fuel_load_elevated_grid
    # fuel_load_bark_grid = fuel_modifier_df*fuel_load_bark_grid
    fuel_load_canopy_grid = fuel_modifier_df*fuel_load_canopy_grid

    #Accumulate fuel load based on flame height
    fuel_load = fuel_load_surface_grid + fuel_load_near_surface_grid

    fuel_load[flame_height > FLAME_HEIGHT_ELEVATED] += (
        fuel_load_elevated_grid[flame_height > FLAME_HEIGHT_ELEVATED]) 
    fuel_load[flame_height > (H_o*FLAME_HEIGHT_CROWN_FRACTION)] += (
        0.5*fuel_load_canopy_grid[flame_height > (H_o*FLAME_HEIGHT_CROWN_FRACTION)])

    intensity = (HEAT_CONTENT * (fuel_load / KGSQM_TO_TPH) *
                 (rate_of_spread / SECONDS_PER_HOUR))
    return intensity

def calc_flame_height(rate_of_spread, height_el):
    """Calculate flame height in m
    Based on Cheney, N. P., Gould, J. S., McCaw, W. L., & Anderson, W. R. (2012).
    Predicting fire behaviour in dry eucalypt forest in southern Australia.
    Forest Ecology and Management, 280, 120-131.
    """
    flame_height = 0.0193*np.power(rate_of_spread, 0.723)*np.exp(0.64*height_el)*1.07
    return flame_height

def calc_spotting_distance(rate_of_spread,wind_speed,FHS_s):
    """Calculate spotting distance in m.
    Based on Cheney, N. P., Gould, J. S., McCaw, W. L., & Anderson, W. R. (2012).
    Predicting fire behaviour in dry eucalypt forest in southern Australia.
    Forest Ecology and Management, 280, 120-131.
    """

    spotting_distance = np.absolute(176.969*(np.arctan(FHS_s)*np.power(rate_of_spread/np.power(wind_speed,0.25),0.5))+
                                    1568800*(np.power(FHS_s,-1)*np.power(rate_of_spread/np.power(wind_speed,0.25),-1.5))-
                                    3015.09)
    spotting_distance[rate_of_spread<150.0]=50.0

    return spotting_distance

def calculate(dataset, fuel_parameters):
    """
    Takes an xarray dataset and a pandas data row.

    Returns: rate_of_spread, flame_height, intensity, spotting_distance, rating, index
    """

    months = dataset['months']
    hours = dataset['hours']

    dead_fuel_moisture = fuel_moisture_model(dataset['T_SFC'],
                                             dataset['RH_SFC'],
                                             (months, hours))

    rate_of_spread = calc_rate_of_spread(dead_fuel_moisture,
                                         dataset['WindMagKmh_SFC'],
                                         dataset['DF_SFC'],
                                         dataset['time_since_fire'],
                                         fuel_parameters.FHS_s,
                                         fuel_parameters.FHS_ns,
                                         fuel_parameters.H_ns,
                                         fuel_parameters.Fk_s,
                                         fuel_parameters.Fk_ns,
                                         fuel_parameters.Hk_ns,
                                         fuel_parameters.WRF_For)

    flame_height = calc_flame_height(rate_of_spread,
                                     fuel_parameters.H_el)

    intensity = calc_intensity(dataset['DF_SFC'],
                               dataset['time_since_fire'],
                               flame_height,
                               rate_of_spread,
                               fuel_parameters.FL_s,
                               fuel_parameters.FL_ns,
                               fuel_parameters.FL_el,
                               fuel_parameters.FL_b,
                               fuel_parameters.FL_o,
                               fuel_parameters.H_o,
                               fuel_parameters.Fk_s,
                               fuel_parameters.Fk_ns,
                               fuel_parameters.Fk_el,
                               fuel_parameters.Fk_b)

    spotting_distance = calc_spotting_distance(rate_of_spread,
                                               dataset['WindMagKmh_SFC'],
                                               fuel_parameters.FHS_s)

    index_1 = fire_behaviour_index.forest(intensity)
    rating_1 = fire_danger_rating.fire_danger_rating(index_1)

    return {'dead_fuel_moisture': dead_fuel_moisture,
            'rate_of_spread': rate_of_spread,
            'flame_height': flame_height,
            'intensity': intensity,
            'spotting_distance': spotting_distance,
            'rating_1': rating_1,
            'index_1': index_1}
