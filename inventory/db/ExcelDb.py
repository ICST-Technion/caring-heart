from openpyxl import load_workbook

from extensions.MSingleton import Singleton
from extensions.MCExtensions import with_metaclass
from inventory.interfaces.IDb import IDb


class ExcelDb(IDb, metaclass=with_metaclass(IDb.__class__, Singleton)):

    def __init__(self, *args, **kwargs):
        self._filename = kwargs.get("filename")
        self._wb = None
        self._sht = None
        self._columns = {"Name": 'A', "Address": 'B', "Street": 'C', "City": 'D', "Phone": 'E', "Description": 'F',
                         "Category": 'G', "Date": 'H', "Comments": 'I', "Email": 'J'}

    def connect(self, *args, **kwargs):
        self._wb = load_workbook(filename=self._filename)
        self._sht = self._wb['גיליון1']

    def close(self):
        self._sht = None
        self._wb.close()

    def insert(self, *args, **kwargs):
        item = {self._columns[key]: value for key, value in kwargs.get("item").items()}
        self.connect()
        self._sht.append(item)
        self._wb.save(filename=self._filename)
        self.close()

    def update(self, *args, **kwargs):
        pass

    def get(self, *args, **kwargs):
        pass
