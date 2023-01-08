__name__='fdrs_calcs'
from . import spread_models
from . import calc
__all__ = []
__doc__ = '''Australian Fire Danger Rating System spread and danger rating algorithms.'''

from .calc import calculate_indicies
from .calc import build_local_time_grids
from .calc import update_time_since_fire
