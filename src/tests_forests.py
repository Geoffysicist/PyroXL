from spread_models import dry_forest_mod_for_testing as dfm
import test_data_generator as tdg

# forest ROS
# datetime_param_dict = {}

# num_param_dict = {
#     'U_10': (0,70,10),
#     'fhs_s': (1,4,1),
#     'fhs_ns': (1,4,1),
#     'h_ns': (5,25,5),
#     'fmc': (0,30,10),
#     'DF': (1,10,2),
#     'wrf': (2,6,1)
# }

# class_param_dict = {}

# df = tdg.generate_test_data(datetime_param_dict,num_param_dict,class_param_dict)
# df['ROS'] =dfm.calc_rate_of_spread(
#     df.fmc, df.U_10, df.DF,df.fhs_s,df.fhs_ns, df.h_ns, df.wrf
# )

# print(df.head())
# df.to_csv('forest_ROS.csv', index=False)

# forest flame height
# datetime_param_dict = {}

# num_param_dict = {
#     'ROS': (0,10000,250),
#     'fh_e': (0,4,0.5),
# }

# class_param_dict = {}

# df = tdg.generate_test_data(datetime_param_dict,num_param_dict,class_param_dict)
# df['flame_h'] =dfm.calc_flame_height(
#     df.ROS, df.fh_e
# )

# print(df.head())
# df.to_csv('forest_flame_height.csv', index=False)

# # forest spotting distance
# datetime_param_dict = {}

# num_param_dict = {
#     'ROS': (0,10000,250),
#     'U_10': (0,70,10),
#     'fhs_s': (1,4,1),
# }

# class_param_dict = {}

# df = tdg.generate_test_data(datetime_param_dict,num_param_dict,class_param_dict)
# df['spotting'] =dfm.calc_spotting_distance(
#     df.ROS, df.U_10, df.fhs_s
# )

# print(df.head())
# df.to_csv('forest_spotting_dist.csv', index=False)

# forest fuel moisture
# datetime_param_dict = {
#     'datetime': ('2022-01-01', '2022-09-01', 90, 6),
# }

# num_param_dict = {
#     'temp': (0,40,10),
#     'rh': (0,100,10),
# }

# class_param_dict = {}

# df = tdg.generate_test_data(datetime_param_dict,num_param_dict,class_param_dict)
# df['fmc'] =dfm.fuel_moisture_model(
#     df.temp, df.rh, df.datetime
# )

# print(df.head())
# df.to_csv('forest_fuel_moist.csv', index=False)

# forest intensity
datetime_param_dict = {}

num_param_dict = {
    'ROS': (0,10000,2000),
    'fl_s': (0,12,4),
    'fl_ns': (1,8,4),
    'fl_e': (1,8,4),
    'fl_o': (0,15,5),
    'h_o': (10,60,10),
    'DF': (1,10,2),
    'flame_h': (0,20,4)
}

class_param_dict = {}

df = tdg.generate_test_data(datetime_param_dict,num_param_dict,class_param_dict)
df['intensity'] =dfm.calc_intensity(
    df.DF, df.flame_h, df.ROS,df.fl_s,df.fl_ns, df.fl_e, None, df.fl_o, df.h_o
)

print(df.head())
df.to_csv('forest_intensity.csv', index=False)
