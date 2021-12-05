from openpyxl import load_workbook
import operator
from extensions.MSingleton import Singleton
from extensions.MCExtensions import with_metaclass
from inventory.interfaces.IDb import IDb


class ExcelDb(IDb, metaclass=with_metaclass(IDb.__class__, Singleton)):

    def __init__(self, *args, **kwargs):
        self._filename = kwargs.get("filename", "template.xlsx")
        self._wb = None
        self._sht = None
        self._sheetname_getter = kwargs.get("sheetname_getter", lambda sheetnames: 'גיליון1')
        self._columns = kwargs.get("columns", {"Name": 'A', "Address": 'B', "Street": 'C', "City": 'D', "Phone": 'E', "Description": 'F',
                         "Category": 'G', "Date": 'H', "Comments": 'I', "Email": 'J'})

    def connect(self, *args, **kwargs):
        self._wb = load_workbook(filename=self._filename)
        self._sht = self._wb[self._sheetname_getter(self._wb.sheetnames)]

    def close(self):
        self._sht = None
        self._wb.close()

    def insert(self, *args, **kwargs):
        item = {self._columns[key]: value for key, value in kwargs.get("item").items()}
        with self:
            self._sht.append(item)
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

        key, comparison, value = args

        key = key.lower()
        assert key in self._columns.keys()
        col = self._columns[key]

        if value is True:
            value = '1'
        if value is False:
            value = '0'

        comparisons = {'==': operator.eq, '!=': operator.ne, '>=': operator.ge, '<=': operator.le, '>': operator.lt, '<': operator.lt}
        assert comparison in comparisons.keys()
        cmp_func = comparisons[comparison]

        with self:
            cells_to_values = lambda row: list(map(lambda cell: cell.value, row))
            rows = map(cells_to_values, self._sht.iter_rows())
            if 'order_by' in kwargs:
                sortby_col = self._columns[kwargs['order_by']]
                rows = sorted(rows, key=lambda row: row[sortby_col], reverse=kwargs.get('reverse', False))
            res = list(filter(lambda row: cmp_func(row[col], value), rows))
            if 'limit' in kwargs:
                res = res[:kwargs['limit']]
        return res

    def __enter__(self):
        self.connect()
        return self

    def __exit__(self):
        self.close()
