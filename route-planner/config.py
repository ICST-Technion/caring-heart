import PySimpleGUI as sg
import string
from configparser import ConfigParser
import os

AtoZ = string.ascii_uppercase
NO_COLUMN = 'התעלם, הכנס הכל'
CONFIG_FILE = 'config.ini'


def write_config(config):
    with open(CONFIG_FILE, 'w') as config_file:
        config.write(config_file)


def column_to_index(column_letter: str):
    if column_letter not in AtoZ:
        return -1
    return AtoZ.index(column_letter)


def index_to_column(column_index: int):
    if column_index < 0:
        return NO_COLUMN
    return AtoZ[column_index]


if __name__ == '__main__':
    config = ConfigParser()
    config.read(CONFIG_FILE)

    if not os.path.exists(CONFIG_FILE):
        config['main'] = {'excel_path': 'template.xlsx', 'address_column': 1, 'selection_column': 10, 'max_show': 8}
        write_config(config)

    excel_path = config.get('main', 'excel_path')
    address_column = config.getint('main', 'address_column')
    selection_column = config.getint('main', 'selection_column')
    max_show = config.getint('main', 'max_show')

    excel_path_chooser = [
            sg.In(size=(25, 1), enable_events=True, key="excel_path", default_text=excel_path),
            sg.FolderBrowse(),
            sg.Text("בחר קובץ אקסל", justification="right"),
    ]
    address_column_chooser = [
            sg.Combo([*AtoZ], key='address_column', default_value=index_to_column(address_column)),
            sg.Text("עמודת הכתובת", justification="right"),
    ]
    selected_column_chooser = [
            sg.Combo([NO_COLUMN, *AtoZ], key='selection_column', default_value=index_to_column(selection_column)),
            sg.Text("עמודה לסימון פריטים לתכנון מסלול", justification="right"),
    ]
    max_show_chooser = [
            sg.Combo(list(range(3, 30)), key='max_show', default_value=max_show),
            sg.Text("מספר מקסימלי של פריטים להראות", justification="right"),
    ]

    layout = [
        [sg.Text("הגדרות")],
        excel_path_chooser,
        address_column_chooser,
        selected_column_chooser,
        max_show_chooser,
        [sg.Button("שמור")],
    ]

    # Create the window
    window = sg.Window("Demo", layout, element_justification='r')

    # Create an event loop
    while True:
        event, values = window.read()
        # End program if user closes window or
        # presses the OK button
        if event == sg.WIN_CLOSED:
            break
        if event == "שמור":
            config.set('main', 'excel_path', values['excel_path'])
            config.set('main', 'address_column', str(column_to_index(values['address_column'])))
            config.set('main', 'selection_column', str(column_to_index(values['selection_column'])))
            config.set('main', 'max_show', str(values['max_show']))
            write_config(config)
            break
    window.close()