from spread_models import mallee_heath
import test_data_generator as tdg
import pandas as pd

fuel_params_dict = {
    'FL_s': 10,
    'FL_o': 4.5,
    'Fk_s': 0.3,
    'Fk_o': 0.3,
    'Cov_o': 40,
    'H_o': 5,
}

fuel_params_df = pd.DataFrame(fuel_params_dict, index=[0])

# small dataset
datetime_param_dict = {
    'datetime': ('2022-01-01', '2022-09-01', 90, 6),
}

num_param_dict = {
    'WindMagKmh_SFC': (10,50,20),
    'RH_SFC': (10,100,50),
    'T_SFC': (10,40,15),
    'precipitation': (0,100,50),
    'time_since_rain': (0,48,24),
    'time_since_fire': (0,15,7.5),
}

class_param_dict = {}

df = tdg.generate_test_data(datetime_param_dict,num_param_dict,class_param_dict)
df['months'] = df.datetime.dt.month
df['hours'] = df.datetime.dt.hour

output_dict =mallee_heath.calculate(df.to_xarray(),fuel_params_df.iloc[0])

for param, series in output_dict.items():
    df[param] = series

print(df.head())
print(df.shape)
df.to_csv('tests/mallee_heath_small.csv', index=False)
# df.to_pickle('mallee_heath_small.pkl')

