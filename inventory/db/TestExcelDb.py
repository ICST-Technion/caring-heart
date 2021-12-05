import unittest
import openpyxl

from inventory.db.ExcelDb import ExcelDb


class TestExcelDb(unittest.TestCase):
    COLS = ('a', 'b', 'c')

    @staticmethod
    def item(row):
        return {col: val for col, val in zip(TestExcelDb.COLS, row)}

    @staticmethod
    def get_excel(rows=(('a1', 1, 1), ('a2', 2, 2), ('a3', 3, 3))):
        wb = openpyxl.Workbook()
        sheet = wb.create_sheet('sheet1', 0)
        sheet.append(['A', 'B', 'C'])  # headers
        for row in rows:
            sheet.append(row)
        cols_map = {c: c.upper() for c in TestExcelDb.COLS}
        excel = ExcelDb(columns=cols_map, workbook_loader=lambda: wb, sheetname_getter=lambda _: 'sheet1')
        return excel

    def test_get_eq(self):
        excel = self.get_excel()
        item = excel.get('where', 'a', '==', 'a2')[0]
        self.assertEqual(item, self.item(['a2', 2, 2]))

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


if __name__ == '__main__':
    unittest.main()
