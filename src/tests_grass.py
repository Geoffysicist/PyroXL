from spread_models import csiro_grassland as grass
import test_data_generator as tdg

# #grass fuel moist content
# datetime_param_dict = {}

# num_param_dict = {
#     'temp': (0,40,10),
#     'rh': (0,100,10),
# }

# class_param_dict = {}
# df = tdg.generate_test_data(datetime_param_dict,num_param_dict,class_param_dict)
# df['fmc'] = grass.calc_fuel_moisture(df.temp, df.rh)

# print(df.head())
# df.to_csv('grass_fmc.csv', index=False)

# grass fuel moist coeff
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

# #grass ROS
# datetime_param_dict = {}

# num_param_dict = {
#     'U_10': (0,70,10),
#     'fmc': (5,30,5),
#     'curing': (0,100,10)
# }

# class_param_dict = {
#     'condition': ('natural', 'grazed', 'eaten-out')
#     # 'condition': (3, 2, 1)
# }

# df = tdg.generate_test_data(datetime_param_dict,num_param_dict,class_param_dict)
# # df['ROS'] = grass.calc_rate_of_spread(df.fmc, df.U_10, df.curing,df.condition)

# print(df.head())
# df.to_csv('grass_ROS_inputs.csv', index=False)

#grass flame height
datetime_param_dict = {}

num_param_dict = {
    'ROS': (0,20000,200),
    # 'fuel_load': (1.5,7.5,3)
}

class_param_dict = {
    'condition': ('eaten-out', 'grazed', 'natural')
    # 'condition': (3, 2, 1)
}

df = tdg.generate_test_data(datetime_param_dict,num_param_dict,class_param_dict)
# df['flame_h'] = grass.calc_flame_height(df.ROS, df.fuel_load)

print(df.head())
df.to_csv('grass_flame_height_state.csv', index=False)
