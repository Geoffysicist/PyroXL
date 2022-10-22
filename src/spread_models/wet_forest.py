"""Fire behaviour calculations for wet forests
"""
import numpy as np

from . import fire_behaviour_index
from . import fire_danger_rating

from .dry_forest import calc_fuel_amount
from .dry_forest import calc_flame_height
from .dry_forest import calc_spotting_distance

START_PEAK_MONTH = 10 #October
END_PEAK_MONTH = 3 #March
START_AFTERNOON = 12
END_AFTERNOON = 17
SUNRISE = 6
SUNSET = 19
THRESHOLD_WIND_SPEED = 5.0 #km/h
FLAME_HEIGHT_ELEVATED = 1 #m
FLAME_HEIGHT_CROWN_FRACTION = 0.66 #m
HEAT_CONTENT = 18600 #KJ/kg
KGSQM_TO_TPH = 10.0
SECONDS_PER_HOUR = 3600 #s

def fuel_availability(drought_factor,drought_index,WRF):
    """Use drought factor to estimate amount of fuel available to burn
       From Cruz et al. (2022) Vesta Mk 2 model
    """
    C1 = 0.1*((0.0046*np.power(WRF,2)-0.0079*WRF-0.0175)*drought_index+(-0.9167*np.power(WRF,2)+1.5833*WRF+13.5))
    C1 = np.clip(C1,0,1)
    
    return 1.008/(1+104.9*np.exp(-0.9306*C1*drought_factor))

def fuel_moisture_model(air_temperature, relative_humidity, time):
    """Calculate dead fuel moisture (%)
    Based on Matthews, S., Gould, J., & McCaw, L. (2010). Simple models for
    predicting dead fuel moisture in eucalyptus forests. International Journal
    of Wildland Fire, 19(4), 459-467.
    """
    months, hours = time
    fuel_moisture = np.empty(relative_humidity.shape)

    fuel_moisture_2 = 3.60+0.169*relative_humidity-0.0450*air_temperature
    fuel_moisture_3 = 3.08+0.198*relative_humidity-0.0483*air_temperature

    selector_3 = ((hours <= SUNRISE) | (hours >= SUNSET))

    fuel_moisture = fuel_moisture_2
    fuel_moisture[selector_3] = fuel_moisture_3[selector_3]
    
    return fuel_moisture
    
    
#This is the same as in dry_forest but calls local fuel_availability function
#TODO Is there are way to import from .dry_forest but use the local fuel availability function?
def calc_rate_of_spread(fuel_moisture, wind_speed,
                        drought_factor, drought_index,time_since_fire,
                        FHS_s, FHS_ns, H_ns,
                        Fk_s, Fk_ns, Hk_ns,
                        wind_reduction_factor):
    """Calculate rate of spread in m/h
    Based on Cheney, N. P., Gould, J. S., McCaw, W. L., & Anderson, W. R. (2012).
    Predicting fire behaviour in dry eucalypt forest in southern Australia.
    Forest Ecology and Management, 280, 120-131.
    """
    #Use fire history to modify fuel parameters
    hazard_score_s_grid = calc_fuel_amount(time_since_fire, FHS_s, Fk_s)
    hazard_score_ns_grid = calc_fuel_amount(time_since_fire, FHS_ns, Fk_ns)
    height_ns_grid = calc_fuel_amount(time_since_fire, H_ns, Hk_ns)
    height_ns_grid = np.clip(height_ns_grid,0,20)

    #Use drought factor to modify fuel parameters
    fuel_modifier = fuel_availability(drought_factor,drought_index,wind_reduction_factor)
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

def calc_intensity(drought_factor, drought_index, time_since_fire, flame_height, rate_of_spread,
                   FL_s, FL_ns, FL_el, FL_b, FL_o, H_o,
                   Fk_s, Fk_ns, Fk_el, Fk_b, wind_reduction_factor):
    """Calculate fire line intensity (kW/m)
    Based on definition in Byram, G. M. (1959). Combustion of forest fuels.
    In ‘Forest fire: control and use’.(Ed. KP Davis) pp. 61–89.
    Modified by RFS to include fuel layers based on flame height.
    """
    #Use fire history to modify fuel parameters
    fuel_load_surface_grid = calc_fuel_amount(time_since_fire, FL_s, Fk_s)
    fuel_load_near_surface_grid = calc_fuel_amount(time_since_fire, FL_ns, Fk_ns)
    fuel_load_elevated_grid = calc_fuel_amount(time_since_fire, FL_el, Fk_el)
    fuel_load_bark_grid = calc_fuel_amount(time_since_fire, FL_b, Fk_b)
    fuel_load_canopy_grid = FL_o

    #Use drought factor to modify fuel parameters
    fuel_modifier_df = fuel_availability(drought_factor,drought_index,wind_reduction_factor)
    fuel_load_surface_grid = fuel_modifier_df*fuel_load_surface_grid
    fuel_load_surface_grid = np.clip(fuel_load_surface_grid,0,10)
    fuel_load_near_surface_grid = fuel_modifier_df*fuel_load_near_surface_grid
    fuel_load_elevated_grid = fuel_modifier_df*fuel_load_elevated_grid
    fuel_load_bark_grid = fuel_modifier_df*fuel_load_bark_grid
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

def calculate(dataset, fuel_parameters):
    """
    Takes an xarray dataset and a pandas data row.

    Returns: rate_of_spread, flame_height, intensity, spotting_distance, rating, index
    """

    months = dataset['months']
    hours = dataset['hours']

    if fuel_parameters.FTno_State>=7000:
        drought_index = dataset['SDI_SFC']
    else:
        drought_index = dataset['KBDI_SFC']
    
    dead_fuel_moisture = fuel_moisture_model(dataset['T_SFC'],
                                             dataset['RH_SFC'],
                                             (months, hours))

    rate_of_spread = calc_rate_of_spread(dead_fuel_moisture,
                                         dataset['WindMagKmh_SFC'],
                                         dataset['DF_SFC'],
                                         drought_index,
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
                               drought_index,
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
                               fuel_parameters.Fk_b,
                               fuel_parameters.WRF_For)

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

