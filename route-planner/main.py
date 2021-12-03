import xlrd
import webbrowser
from configparser import ConfigParser
from itertools import chain


def read_config(config_filepath):
    """

    :param config_filepath:
    :return:
    {
        excel_path: excel file path
        address_column: (int >= 0)

        selection_column: column number (int >=0) that tell the program which addresses to include, or -1 to include all
        max_show: maximum addresses to show
    }
    """
    config = ConfigParser()
    config.read('config.ini')
    return dict(
        excel_path=config.get('main', 'excel_path'),
        address_column=config.getint('main', 'address_column'),
        selection_column=config.getint('main', 'selection_column'),
        max_show=config.getint('main', 'max_show')
    )


def get_excel_rows(excel_path):
    spreadsheet = xlrd.open_workbook(excel_path)
    sheets = spreadsheet.sheets()[-2:]
    rows_with_cells = list(chain(
        *map(xlrd.sheet.Sheet.get_rows, sheets))
    )
    # print(list(rows_with_cells[0]))
    cells_to_values = lambda row: list(map(lambda cell: cell.value, row))
    rows = map(cells_to_values, rows_with_cells)
    return rows


def get_donation_data(all_rows, data_columns, selection_column, max_show):
    """

    :param all_rows: list of rows, each row is list of cell values (string or int)
    :param data_columns: dictionary of column_name -> column_number to extract (e.g {address: 1})
    :param selection_column: the column that marks (with 1's) which rows to take. IF -1 THEN TAKE ALL
    :param max_show: maximum number of donations to return
    :return: list of donations, where each donation is a dictionary with the data_columns data
    """
    filtered_rows = filter(lambda r: selection_column < 0 or r[selection_column] == 1, all_rows)
    filtered_rows = filter(lambda r: r[data_columns['address']] != '', filtered_rows)
    organized_rows = [{data_name: row[col] for data_name, col in data_columns.items()} for row in filtered_rows]
    return organized_rows[-max_show:]


def get_google_maps_directions_url(addresses, base_url='https://www.google.com/maps/dir/'):
    return base_url + '/'.join(addresses)


def open_google_maps(url):
    webbrowser.open(url)


if __name__ == '__main__':
    config = read_config('config.json')
    rows = get_excel_rows(config['excel_path'])
    donations = get_donation_data(rows,
                                  data_columns={'address': config['address_column']},
                                  max_show=config['max_show'],
                                  selection_column=config['selection_column']
                                  )
    addresses = [donation['address'] for donation in donations]
    url = get_google_maps_directions_url(addresses)
    print(url)
    # open_google_maps(url)
