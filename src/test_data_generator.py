'''test_data_generator.py

generates input data as csv file for a range of parameters given max, 
min and step for each parameter.

The output csv file contains all unique combinations (cartesian product)
of the input parameters
'''
import numpy as np
import pandas as pd

# parameter dictionary - 'parameter_name': (min, max, step)
param_dict = {
    'param1': (1,4,1),
    'param2': (0,6,2),
    'param3': (0,1,0.3)
}

# output filename
filename = "test_data.csv"

def cartesian(arrays, out=None):
    """
    Generate a cartesian product of input arrays.

    Fecursively builds the final array. 
    Final array contains all unique combinations from input arrays

    Args
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
    dtype = arrays[0].dtype

    n = np.prod([a.size for a in arrays])
    if out is None:
        out = np.zeros([n, len(arrays)], dtype=dtype)

    #m = n / arrays[0].size
    m = int(n / arrays[0].size) 
    out[:,0] = np.repeat(arrays[0], m)
    if arrays[1:]:
        cartesian(arrays[1:], out=out[0:m, 1:])
        for j in range(1, arrays[0].size):
            out[j*m:(j+1)*m, 1:] = out[0:m, 1:]
    return out

if __name__ == "__main__":
    header_list = []
    array_list = []
    for param, (min, max, step) in param_dict.items():
        header_list.append(param)
        param_array = np.arange(min,max+step/2,step)
        array_list.append(param_array)

    df = pd.DataFrame(cartesian(array_list),columns=header_list)

    print(df.head)
    df.to_csv(filename, index=False)
