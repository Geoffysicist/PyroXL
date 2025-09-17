import xlwings as xw
import fdrs_calcs as fdrs
from fdrs_calcs.spread_models import dry_forest as forest
from fdrs_calcs.spread_models import fire_behaviour_index as fbi

def main():
    wb = xw.Book.caller()
    sheet = wb.sheets[0]
    target_cell_add = "C1"
    if sheet[target_cell_add].value == "Hello xlwings!":
        sheet[target_cell_add].value = "Bye xlwings!"
    else:
        sheet[target_cell_add].value = "Hello xlwings!"


@xw.func
def hello(name):
    return f"Hello {name}!"


if __name__ == "__main__":
    xw.Book("PyroXLwings.xlsm").set_mock_caller()
    main()
    print('done')
