from openpyxl import load_workbook
from openpyxl.utils.cell import column_index_from_string as _col_idx
import operator
from extensions.MSingleton import Singleton
from extensions.MCExtensions import with_metaclass
from inventory.db.DateTimeHelper import sheetname_getter
from inventory.interfaces.IDb import IDb
from itertools import islice
from configparser import ConfigParser


def col_idx(letter):
    return _col_idx(letter) - 1


def skip_first(iterable):
    return islice(iterable, 1, None)


class ExcelDb(IDb, metaclass=with_metaclass(IDb.__class__, Singleton)):

    @staticmethod
    def from_config_file(config_path='config.ino'):
        config = ConfigParser()
        config.read(config_path)
        return ExcelDb.from_config(config)

    @staticmethod
    def from_config(config: ConfigParser):
        col_map = dict(config.items('columns'))
        return ExcelDb(filename=config.get('main', 'excel_path'),
                       columns=col_map)

    def __init__(self,
                 *args,
                 filename="template.xlsx",
                 sheetname_getter=sheetname_getter,
                 columns=None,
                 workbook_loader=None,
                 **kwargs):
        if columns is None:
            columns = {"שם": 'A', "כתובת": 'B', "שכונה": 'C', "עיר": 'D', "נייד/טל'": 'E', "תאור": 'F',
                       "קטגוריית מוצר": 'G', "תאריך": 'H', "הערות": 'I', "E-mail": 'J'}
        if workbook_loader is None:
            workbook_loader = lambda: load_workbook(filename=self._filename)
        self._workbook_loader = workbook_loader
        self._filename = filename
        self._wb = None
        self._sht = None
        self._sheetname_getter = sheetname_getter
        self._columns = columns

    def connect(self, *args, **kwargs):
        self._wb = self._workbook_loader()
        sheet_name = self._sheetname_getter(self._wb.sheetnames)
        if sheet_name not in self._wb:
            self._create_new_sheet(sheet_name)
        self._sht = self._wb[sheet_name]

    def close(self):
        self._sht = None
        self._wb.close()

    def insert(self, sync=True, *args, **kwargs):
        item = {self._columns[key]: value for key, value in kwargs.get("item").items()}
        with self:
            self._sht.append(item)
            if sync:
                self.sync_to_file()

    def sync_to_file(self):
        self._wb.save(filename=self._filename)

    def update(self, *args, **kwargs):
        pass

    def get(self, *args, **kwargs):
        """
        Only 'where' supported with '==', '!=', '>=', '<=', '>', '<'
        optional order_by, reverse and limit
        Example: get('where', 'age', '>=', 18, order_by='age', reverse=False, limit=5)  # youngest 5 above 18
        'age' must be a column found in 'columns' dict at __init__
        """
        action, *params = args
        action = action.lower()
        if action != 'where':
            raise NotImplementedError(f"{self.__class__.__name__} supports only where (e.g get('where', 'name' , '==', 'myname'))")

        key, comparison, value = params

        key = key.lower()
        assert key in self._columns.keys()
        col = col_idx(self._columns[key])

        if value is True:
            value = '1'
        if value is False:
            value = '0'

        comparisons = {'==': operator.eq, '!=': operator.ne, '>=': operator.ge, '<=': operator.le, '>': operator.gt, '<': operator.lt}
        assert comparison in comparisons.keys()
        cmp_func = comparisons[comparison]

        with self:
            cells_to_values = lambda row: list(map(lambda cell: cell.value, row))
            rows = map(cells_to_values, skip_first(self._sht.iter_rows()))   # skip first headers row
            if 'order_by' in kwargs:
                sortby_col = col_idx(self._columns[kwargs['order_by']])
                rows = sorted(rows, key=lambda row: row[sortby_col], reverse=kwargs.get('reverse', False))
            rows = list(filter(lambda row: cmp_func(row[col], value), rows))
            if 'limit' in kwargs:
                rows = rows[:kwargs['limit']]
            res = [{name: row[col_idx(col)] for name, col in self._columns.items()} for row in rows]
        return res

    def _create_new_sheet(self,name):
        sheet = self._wb.create_sheet(name)
        sheet.sheet_view.rightToLeft = True
        sheet.append({value : key for key, value in self._columns.items()})

    def __enter__(self):
        self.connect()
        return self

    def __exit__(self, exc_type, exc_value, tb):
        if exc_type is not None:
            # traceback.print_exception(exc_type, exc_value, tb)
            return False  # uncomment to pass exception through

        return True
