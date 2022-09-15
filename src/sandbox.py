from datetime import datetime as dt
from datetime import date, time, timedelta
import numpy as np

# dictionary for datetime inputs - 'parameter_name': (start, stop, date_step, time_step)
# date format must be iso1806 YYYY-MM-DD
# time format must be iso1806 HH:MM
# date_step is days
# time_step is hours
datetime_param_dict = {
    'date': ('2022-01-01', '2022-09-01', 90, 12),
}

header_list = []
array_list = []
for param, (start, stop, date_step, time_step) in datetime_param_dict.items():
    header_list.append(param)
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
    
        print(datetime_array)


