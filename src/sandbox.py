import pandas as pd
values = (10)
param = 'foo'
df = pd.DataFrame(data=[values], columns=[param])
print(df.to_xarray())