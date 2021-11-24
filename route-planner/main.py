import xlrd
import webbrowser


def read_excel_sheet(filepath):
    spreadsheet = xlrd.open_workbook(filepath)
    last_sheet = spreadsheet.sheet_by_index(spreadsheet.nsheets - 1)
    return last_sheet


def sheet_to_addresses(sheet, col=1, first_row=1):
    cells = sheet.col_values(col, start_rowx=first_row)
    return list(filter(lambda v: v != '', cells))


def get_google_maps_directions_url(addresses, base_url='https://www.google.com/maps/dir/'):
    return base_url + '/'.join(addresses)


def open_google_maps(url):
    webbrowser.open(url)


if __name__ == '__main__':
    path = 'template.xlsx'  # TODO
    sheet = read_excel_sheet(path)
    # print(sheet.cell(0,0))
    addresses = sheet_to_addresses(sheet)
    # print(addresses)
    url = get_google_maps_directions_url(addresses)
    open_google_maps(url)
