from spread_models import heathland as heath
import test_data_generator as tdg

# #heath fuel moist content
# datetime_param_dict = {}

# num_param_dict = {
#     'temp': (0,40,10),
#     'rh': (0,100,10),
#     'rain': (0,100,10), # recent rainfall mm
#     'hours': (0,48,8), # time since rain h
# }

# class_param_dict = {}

# df = tdg.generate_test_data(datetime_param_dict,num_param_dict,class_param_dict)
# df['fmc'] = heath.calc_fuel_moisture(df.rh, df.temp,df.rain,df.hours)

# print(df.head())
# df.to_csv('heath_fmc.csv', index=False)

# heath fuel moist coeff
# datetime_param_dict = {}

# num_param_dict = {
#     'U_10': (0,70,10),
#     'fmc': (5,30,5),
# }

# class_param_dict = {}

# df = tdg.generate_test_data(datetime_param_dict,num_param_dict,class_param_dict)
# df['moist_coeff'] = grass.calc_fuel_moisture_factor(df.fmc, df.U_10)

# print(df.head())
# df.to_csv('grass_moist_coeff.csv', index=False)

# # heath ROS
# datetime_param_dict = {}

# num_param_dict = {
#     'U_10': (0,70,10),
#     'fmc': (0,90,10),
#     'H_el': (0,4,0.5)
# }

# class_param_dict = {
#     # 'overstorey': ('true', 'false')
#     'wrf': (0.35, 0.667)
# }

# df = tdg.generate_test_data(datetime_param_dict,num_param_dict,class_param_dict)
# df['ROS'] = heath.calc_rate_of_spread(df.wrf, df.U_10, df.H_el,df.fmc)

# print(df.head())
# df.to_csv('heath_ROS.csv', index=False)

# heath intensity
# datetime_param_dict = {}

# num_param_dict = {
#     'ROS': (0,20000,200),
#     'fl_max': (20, 20, 1),
#     'tsf': (0,25,2),
#     'k': (0.2,0.2,1),
# }

# class_param_dict = {
#     # 'k': (0.2)
#     # 'fl_max': (20)
# }

# df = tdg.generate_test_data(datetime_param_dict,num_param_dict,class_param_dict)
# df['intensity'] = heath.calc_intensity(df.ROS, df.fl_max, df.tsf,df.k)

# print(df.head())
# df.to_csv('heath_intensity.csv', index=False)

# heath flame height
datetime_param_dict = {}

num_param_dict = {
    'intensity': (0,200000,500),
}

class_param_dict = {
}

df = tdg.generate_test_data(datetime_param_dict,num_param_dict,class_param_dict)
df['flame_h'] = heath.calc_flame_height(df.intensity)

print(df.head())
df.to_csv('heath_flame_height.csv', index=False)