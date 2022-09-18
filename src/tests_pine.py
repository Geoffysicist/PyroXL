from spread_models import pine
import test_data_generator as tdg

# #pine fuel moist content
# datetime_param_dict = {}

# num_param_dict = {
#     'temp': (0,40,10),
#     'rh': (0,100,10),
# }

# class_param_dict = {}

# df = tdg.generate_test_data(datetime_param_dict,num_param_dict,class_param_dict)
# df['fmc'] =pine.fuel_moisture_model(df.temp, df.rh)

# print(df.head())
# df.to_csv('pine_fmc.csv', index=False)

#pine fuel availability
datetime_param_dict = {}

num_param_dict = {
    'DF': (0,40,10),
    'KBDI': (0,100,10),
    'WAF': (3,5,0.5)
}

class_param_dict = {}

df = tdg.generate_test_data(datetime_param_dict,num_param_dict,class_param_dict)
df['fuel_avail'] =pine.fuel_availability(df.DF, df.KBDI, df.WAF)

print(df.head())
df.to_csv('pine_fuel_avail.csv', index=False)

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

# pine fire behaviour
datetime_param_dict = {}

num_param_dict = {
    'U_10': (0,70,10),
    'fmc': (0,30,10),
    'DF': (0,10,2),
    'KBDI': (0,200,20)
}

class_param_dict = {
}

tsf = None #this is a zombie parameter in the code

df = tdg.generate_test_data(datetime_param_dict,num_param_dict,class_param_dict)
fire_behaviour = pine.calc_fire_spread_single(df.fmc, df.U_10, df.DF,df.KBDI,tsf)
df['ROS'], df['intensity'], df['flame_h'] = fire_behaviour
print(df.head())
df.to_csv('pine_fire_behaviour_single.csv', index=False)

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
# datetime_param_dict = {}

# num_param_dict = {
#     'intensity': (0,200000,500),
# }

# class_param_dict = {
# }

# df = tdg.generate_test_data(datetime_param_dict,num_param_dict,class_param_dict)
# df['flame_h'] = heath.calc_flame_height(df.intensity)

# print(df.head())
# df.to_csv('heath_flame_height.csv', index=False)
