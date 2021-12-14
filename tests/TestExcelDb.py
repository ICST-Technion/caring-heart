import unittest
import openpyxl

from inventory.db.ExcelDb import ExcelDb


class TestExcelDb(unittest.TestCase):
    COLS = ('a', 'b', 'c')

    @staticmethod
    def item(row):
        return {col: val for col, val in zip(TestExcelDb.COLS, row)}

    @staticmethod
    def get_excel(rows=(('a1', 1, 1), ('a2', 2, 2), ('a3', 3, 3)), **excel_db_kwargs):
        wb = openpyxl.Workbook()
        sheet = wb.create_sheet('sheet1', 0)
        sheet.append(['A', 'B', 'C'])  # headers
        for row in rows:
            sheet.append(row)
        cols_map = {c: c.upper() for c in TestExcelDb.COLS}
        excel = ExcelDb(filename=None, key_column_map=cols_map, workbook_loader=lambda: wb, sheetname_getter=lambda _: 'sheet1', **excel_db_kwargs)
        return excel

    def test_get_eq(self):
        excel = self.get_excel()
        items = excel.get('where', 'a', '==', 'a2')
        self.assertEqual(items[0], self.item(['a2', 2, 2]))

    def test_get_gt(self):
        excel = self.get_excel()
        item = excel.get('where', 'b', '>', 2)[0]
        self.assertEqual(item, self.item(['a3', 3, 3]))

    def test_insert(self):
        excel = self.get_excel()
        inserted_item = {'a': 'my a', 'b': 5, 'c': 7}
        excel.insert(item=inserted_item)
        item = excel.get('where', 'a', '==', 'my a')[0]
        self.assertEqual(item, inserted_item)

    def test_bool_get_and_set(self):
        excel = self.get_excel([], boolean_keys=('b', ))
        inserted_item1 = {'a': 'my a', 'b': True, 'c': 7}
        inserted_item2 = {'a': 'my a2', 'b': False, 'c': 7}
        inserted_item3 = {'a': 'my a3', 'b': False, 'c': 7}
        excel.insert(item=inserted_item1)
        excel.insert(item=inserted_item2)
        excel.insert(item=inserted_item3)
        items = excel.get('where', 'b', '==', False)
        self.assertEqual(items, [inserted_item2, inserted_item3])
        pass


if __name__ == '__main__':
    unittest.main()
