import dataclasses
from dataclasses import dataclass
from typing import Union, List

import PySimpleGUI as sg
import string
from configparser import ConfigParser
import os

AtoZ = list(string.ascii_uppercase)
NO_COLUMN = 'התעלם, הכנס הכל'
CONFIG_FILE = 'config.ini'
DEFAULT_COLUMNS = (
    ('name', 'שם'), ('address', 'כתובת'), ('neighborhood', 'שכונה'), ('city', 'עיר'), ('phone', 'טלפון'), ('description', 'תיאור'),
    ('category', 'קטגוריה'), ('date', 'תאריך'), ('comments', 'הערות')
)


@dataclass
class ConfigVar:
    name: str
    text: str
    default_value: Union[str, int]
    section: str


@dataclass
class ColumnVarType(ConfigVar):
    default_value: str
    no_column_option: bool = False


@dataclass
class FileVarType(ConfigVar):
    default_value: str


@dataclass
class NumberRangeVarType(ConfigVar):
    default_value: int
    start: int
    end: int


def config_var_ui(config_var: ConfigVar):
    def key_and_default(is_text):
        return {'key': config_var.name, ('default_text' if is_text else 'default_value'): config_var.default_value}

    text_element = sg.Text(config_var.text, justification="right")
    if type(config_var) == FileVarType:
        return [
            sg.In(size=(25, 1), enable_events=True, **key_and_default(is_text=True)),
            sg.FileBrowse(),
            text_element
        ]
    elif type(config_var) == ColumnVarType:
        no_column = [NO_COLUMN] if config_var.no_column_option else []
        return [
            sg.Combo(no_column + AtoZ, **key_and_default(is_text=False)),
            text_element
        ]
    elif type(config_var) == NumberRangeVarType:
        return [
            sg.Combo(list(range(config_var.start, config_var.end)), **key_and_default(is_text=False)),
            text_element
        ]


class MyConfig:
    def __init__(self, configs_vars: List[ConfigVar], path=CONFIG_FILE):
        self.config = ConfigParser()
        self.path = path
        self.config.read(path)

        if not os.path.exists(path):
            sections = set((var.section for var in configs_vars))
            for section in sections:
                self.config[section] = {config_var.name: config_var.default_value for config_var in configs_vars if config_var.section == section}
            self._write_config()
            self._config_vars = configs_vars
            return

        self._config_vars = []
        for config_var in configs_vars:
            val = self.config.get(config_var.section, config_var.name, fallback=config_var.default_value)
            new_config = dataclasses.replace(config_var, default_value=val)
            self._config_vars.append(new_config)

    def write_changes(self, values_dict):
        for var in config_vars:
            self.config.set(var.section, var.name, str(values_dict[var.name]))
        self._write_config()

    def _write_config(self):
        with open(self.path, 'w') as config_file:
            self.config.write(config_file)


if __name__ == '__main__':
    columns = ((name, 'עמודת ' + text, col) for col, (name, text) in zip(AtoZ, DEFAULT_COLUMNS))
    config_vars = (
        FileVarType('excel_path', 'קובץ האקסל', 'template.xlsx', section='main'),
        *map(lambda args: ColumnVarType(*args, section='columns'), columns),
        ColumnVarType('selection', "עמודה לסימון פריטים לתכנון מסלול", 'K', no_column_option=True, section='main'),
        NumberRangeVarType('max_show', "מספר מקסימלי של פריטים לתצוגה", default_value=8, start=3, end=20, section='main'),
    )

    my_config = MyConfig(config_vars)

    layout = [
        [sg.Text("הגדרות")],
        *map(config_var_ui, config_vars),
        [sg.Button("שמור")],
    ]

    # Create the window
    window = sg.Window("הגדרות", layout, element_justification='r')

    # Create an event loop
    while True:
        event, values = window.read()
        # End program if user closes window or
        # presses the OK button
        if event == sg.WIN_CLOSED:
            break
        if event == "שמור":
            my_config.write_changes(values)
            break
    window.close()
