import xlwings as xw
from datetime import datetime as dt

with xw.App(visible=True) as app:
    print(app.books)
    try:
        wb = app.books["PyroXLwings.xlsm"]
    except KeyError:
        wb = app.books.open("PyroXLwings.xlsm")
    
    sheet = wb.sheets[0]
    target_cell_add = "C1"
    current_value = sheet[target_cell_add].value
    if current_value and "Hello xlwings!" in current_value:
        sheet[target_cell_add].value = f"Bye xlwings! {dt.now().strftime('%Y-%m-%d %H:%M:%S')}"
    else:
        sheet[target_cell_add].value = f"Hello xlwings! {dt.now().strftime('%Y-%m-%d %H:%M:%S')}"
    
    wb.save()
    wb.close()

print("Done!")