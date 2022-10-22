"""Fire danger rating (FDR) calculations
   FBI is aligned to have round number values at the category
   boundaries in the fire danger rating definition tables
"""

import numpy as np

def fire_danger_rating(fire_behaviour_index):
    rating = np.full(fire_behaviour_index.shape,np.nan)
    rating[fire_behaviour_index >= 100] = 4 #Catastrophic
    rating[fire_behaviour_index < 100] = 3 #Extreme
    rating[fire_behaviour_index < 50] = 2 #High
    rating[fire_behaviour_index < 24] = 1 #Moderate
    rating[fire_behaviour_index < 12] = 0 #No rating
    return rating

