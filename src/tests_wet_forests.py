from spread_models import wet_forest
import test_data_generator as tdg
import pandas as pd

fuel_params_dict = {
    'FHS_s': 3,
    'FHS_ns': 3,
    'FL_s': 10,
    'FL_ns': 3.5,
    'FL_el': 2,
    'FL_b': 2,
    'FL_o': 4.5,
    # 'FL_total': 12,
    'Fk_s': 0.3,
    'Fk_ns': 0.3,
    'Fk_el': 0.3,
    'Fk_b': 0.3,
    # 'Fk_o': 0.3,
    'Hk_ns': 0.3,
    # 'Cov_o': 40,
    'H_ns': 20,
    'H_el': 2,
    'H_o': 10,
    'WRF_For': 3,
    'FTno_State': 2000,
}

fuel_params_df = pd.DataFrame(fuel_params_dict, index=[0])

# small dataset
datetime_param_dict = {
    'datetime': ('2022-11-01', '2022-12-01', 90, 6),
}

num_param_dict = {
}

class_param_dict = {
    'T_SFC': (25,25),
    'RH_SFC': (30,30),
    'WindMagKmh_SFC': (20,20),
    'DF_SFC': (8,8),
    'KBDI_SFC': (100,100),
    'time_since_fire': (20,20),
}

df = tdg.generate_test_data(datetime_param_dict,num_param_dict,class_param_dict)
df['months'] = df.datetime.dt.month
df['hours'] = df.datetime.dt.hour
df['SDI_SFC'] = df.KBDI_SFC

print(df)

output_dict =wet_forest.calculate(df.to_xarray(),fuel_params_df.iloc[0])

for param, series in output_dict.items():
    df[param] = series

print(df.head())
print(df.shape)
df.to_csv('tests/wet_forest_small.csv', index=False)
# df.to_pickle('tests/wet_forest_small.pkl')
