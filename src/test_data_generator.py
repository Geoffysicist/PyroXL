'''test_data_generator.py
'''
import numpy as np
import pandas as pd
from datetime import date, time, timedelta

def generate_test_data(datetime_param_dict, num_param_dict, class_param_dict):
    """generates test data for a range of parameters

    The output contains all unique combinations (cartesian product)
    of the input parameters.

    note that cartesian product arrays grow exponetially. For example, 
    if there are 5 parameters each with 8 increments, the resultant array will
    be 8^5 x 5or 32768 x5

    If you want to use irregular increments to test boundary conditions add
    them to the categorical data

    Args:
        datetime_param_dict (Dict): datetime parameters
            'parameter_name': (start, stop, date_step, time_step)
            date format must be iso1806 (YYYY-MM-DD or YYYY-MM-DDTHH:MM
            date_step is days
            time_step is hours
        num_param_dict (Dict): numerical parameters
            'parameter_name': (min, max, step)
        class_param_dict (Dict): categorical parameter
            'parameter_name': (class1, class2...classn)

    Returns:
        Dataframe
    """
    df_array = []
    cartesian_df = None

    for param, (start, stop, date_step, time_step) in datetime_param_dict.items():
            # header_list.append(param)
        start = date.fromisoformat(start)
        stop = date.fromisoformat(stop)
        date_step = timedelta(days=date_step)
        time_step = timedelta(hours=time_step)
        
        date_array = np.arange(start,stop+date_step/2,date_step)
        datetime_array = np.array([],dtype='datetime64')
        for d in date_array:
            start = d
            datetime_array = np.append(
                datetime_array,np.arange(d,d+np.timedelta64(1,'D'),time_step)
                )

        df_array.append(pd.DataFrame(data =datetime_array, columns=[param]))

    for param, (min, max, step) in num_param_dict.items():
        num_array = np.arange(min,max+step/2,step)
        df_array.append(pd.DataFrame(data=num_array, columns=[param]))

    for param, values in class_param_dict.items():
        df_array.append(pd.DataFrame(data=values,columns=[param]))

    for df in df_array:
        if cartesian_df is None:
            cartesian_df = df
        else:
            cartesian_df = cartesian_df.merge(df, how='cross')
    
    return cartesian_df


if __name__ == '__main__':

    datetime_param_dict = {
        'DateTime': ('2022-01-01', '2022-09-01', 90, 6),
    }

    # dictionary for numerical inputs - 'parameter_name': (min, max, step)
    num_param_dict = {
        'num_param1': (1,4,1),
        'num_param2': (0,1,0.3),
    }

    # dictionary for categorical inputs - 'parameter_name': (class1, class2...classn)
    class_param_dict = {
        'class_param1': ('foo','bar'),
        'class_param2': (-1,0,99),
    }

    df = generate_test_data(datetime_param_dict,num_param_dict,class_param_dict)

    print(df)
