from spread_models import pasture
import test_data_generator as tdg
import pandas as pd

fuel_params_dict = {
    # 'FHS_s': 3,
    # 'FHS_ns': 3,
    # 'FL_s': 10,
    # 'FL_ns': 3.5,
    # 'FL_el': 2,
    # 'FL_b': 2,
    # 'FL_o': 4.5,
    # 'FL_total': 12,
    # 'Fk_s': 0.3,
    # 'Fk_ns': 0.3,
    # 'Fk_el': 0.3,
    # 'Fk_b': 0.3,
    # 'Fk_o': 0.3,
    # 'Fk_total': 0.3,
    # 'Hk_ns': 0.3,
    # 'Cov_o': 40,
    # 'H_ns': 20,
    # 'H_el': 2,
    # 'H_o': 20,
    # 'WRF_For': 3,
    # 'WF_Heath': 0.667,
    # 'WF_Sav': 0.5,
    # 'FTno_State': 0, # 7000 if Tasmania
    # 'FTno_FDR': 450,
    # 'Prod_BG': 1,
}

fuel_params_df = pd.DataFrame(fuel_params_dict, index=[0])

# small dataset
datetime_param_dict = {
    # 'datetime': ('2022-01-01', '2022-09-01', 90, 6),
}

num_param_dict = {
    # 'WindMagKmh_SFC': (10,50,20),
    # 'RH_SFC': (32,32,1),
    # 'T_SFC': (33.4,33.4,1),
    # 'Td_SFC': (0,30,15),
    # 'Curing_SFC': (91,91,1),
    # 'precipitation': (0,100,50),
    # 'time_since_rain': (0,48,24),
    # 'time_since_fire': (0,15,7.5),
    # 'DF_SFC': (2,10,4),
    # 'SDI_SFC': (0,200,50),
    # 'KBDI_SFC': (0,200,50),
    # 'AWAP_uf': (0, 1, 2.5),
    # 'GrassFuelLoad_SFC': (1,12,3),
}

class_param_dict = {
        'WindMagKmh_SFC': (25,26),
        'RH_SFC': (32,33),
        'T_SFC': (33.4,34),
        'Curing_SFC': (91,92),
        'grass_condition': (3,2), # 1 = eaten-out, 2 = grazed, 3 = natural
        'GrassFuelLoad_SFC': (6.1,6) # note this will create inconsistent cartesian product with grass_condition but OK for testing
}

df = tdg.generate_test_data(datetime_param_dict,num_param_dict,class_param_dict)
# df['months'] = df.datetime.dt.month
# df['hours'] = df.datetime.dt.hour

output_dict =pasture.calculate(df.to_xarray(),fuel_params_df.iloc[0])

for param, series in output_dict.items():
    df[param] = series

print(df.head())
print(df.shape)
df.to_csv('tests/pasture_musa.csv', index=False)
# df.to_pickle('tests/pasture_small.pkl')