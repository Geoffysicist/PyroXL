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
    header_list = []
    array_list = []

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

        # it appears that the cartesian function doesn't play nicely with datetimes
        # so add them to categorical data
        class_param_dict[param] = datetime_array

    for param, (min, max, step) in num_param_dict.items():
        header_list.append(param)
        num_array = np.arange(min,max+step/2,step)
        array_list.append(num_array)

    for param, values in class_param_dict.items():
        #assign all classes a numerical id
        # header_list.append(f'{param}_id')
        header_list.append(param)
        ids = np.arange(len(values))
        array_list.append(ids)

    df = pd.DataFrame(cartesian(array_list),columns=header_list)

    # convert categorical ids back to values
    for param, values in class_param_dict.items():
        lookup = dict(zip(range(len(values)),values))
        # df[param] = df[param].astype(int)
        df[param] = df[param].replace(lookup)

    return df

def cartesian(arrays, out=None):
    """
    Generate a cartesian product of input arrays.

    Fecursively builds the final array. 
    Final array contains all unique combinations from input arrays

    Args:
        arrays : list of array-like 1-D arrays
        out : ndarray to place the cartesian product in.

    Returns
        2-D array of shape (M, len(arrays)) containing cartesian products
        formed of input arrays.

    Examples
    --------
    >>> cartesian(([1, 2, 3], [4, 5], [6, 7]))
    array([[1, 4, 6],
           [1, 4, 7],
           [1, 5, 6],
           [1, 5, 7],
           [2, 4, 6],
           [2, 4, 7],
           [2, 5, 6],
           [2, 5, 7],
           [3, 4, 6],
           [3, 4, 7],
           [3, 5, 6],
           [3, 5, 7]])
    """

    arrays = [np.asarray(a) for a in arrays]
    # dtype = arrays[0].dtype

    n = np.prod([a.size for a in arrays])
    if out is None:
        out = np.zeros([n, len(arrays)])

    m = int(n / arrays[0].size) 
    out[:,0] = np.repeat(arrays[0], m)
    if arrays[1:]:
        cartesian(arrays[1:], out=out[0:m, 1:])
        for j in range(1, arrays[0].size):
            out[j*m:(j+1)*m, 1:] = out[0:m, 1:]
    return out

if __name__ == "__main__":
    # dictionary for datetime inputs - 'parameter_name': (start, stop, date_step, time_step)
    # date format must be iso1806 (YYYY-MM-DD or YYYY-MM-DDTHH:MM
    # date_step is days
    # time_step is hours
    datetime_param_dict = {
        'date': ('2022-01-01', '2022-09-01', 90, 12),
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

    # output filename
    filename = "test_data.csv"
    df = generate_test_data(datetime_param_dict,num_param_dict,class_param_dict)
    df.to_csv(filename, index=False)
