import random
import unittest

import gspread
import pandas as pd
from oauth2client.service_account import ServiceAccountCredentials
import pyrebase

SHEET_NAME = 'sheet'
COLLECTION_NAME = 'Collection'


class SyncTest(unittest.TestCase):
    sheet_instance = None
    collection = None

    def gen_row(self):
        return [1, "9/12/2021", "8:30-9:00", 123456789, "My Name", "Some comments"]

    def connect_sheets(self):
        scope = ['https://spreadsheets.google.com/feeds', 'https://www.googleapis.com/auth/drive']
        creds = ServiceAccountCredentials.from_json_keyfile_name('cred.json', scope)
        client = gspread.authorize(creds)
        sheet = client.open(SHEET_NAME)
        self.sheet_instance = sheet.get_worksheet(0)

    def get_data_sheets(self):
        if self.sheet_instance is None:
            self.connect_sheets()
        sheet_data_js = self.sheet_instance.get_all_records()
        sheet_data_df = pd.DataFrame.from_dict(sheet_data_js)
        return sheet_data_df.sort_values(by=['ID'])

    def append_row_sheet(self, row):
        if self.sheet_instance is None:
            self.connect_sheets()
        self.sheet_instance.append_row(row)

    def get_cell_sheet(self, row, cell):
        if self.sheet_instance is None:
            self.connect_sheets()
        return self.sheet_instance.cell(row, cell).value

    def get_dims_sheet(self):
        if self.sheet_instance is None:
            self.connect_sheets()
        values = self.sheet_instance.get_all_values()
        num_rows = len(values)
        num_cols = len(values[0])
        return num_rows, num_cols

    def modify_sheet(self, row, cell, value):
        if self.sheet_instance is None:
            self.connect_sheets()
        self.sheet_instance.update_cell(row, cell, value)

    def delete_last_row_sheet(self):
        if self.sheet_instance is None:
            self.connect_sheets()
        num_rows, _ = self.get_dims_sheet()
        self.sheet_instance.delete_rows(num_rows, num_rows + 1)

    def connect_firebase(self):
        firebase = pyrebase.initialize_app('cred.json')
        db = firebase.database()
        self.collection = db.child(COLLECTION_NAME)

    def get_data_firebase(self):
        if self.collection is None:
            self.connect_firebase()
        firebase_data_js = self.collection.get().val()
        firebase_data_df = pd.DataFrame.from_dict(firebase_data_js)
        return firebase_data_df.sort_values(by=['ID'])

    def append_row_firebase(self, row):
        if self.collection is None:
            self.connect_firebase()
        self.collection.push(row)

    def get_cell_firebase(self, id, property):
        if self.collection is None:
            self.connect_firebase()
        return self.collection.child(id).child(property).get().val()

    def modify_firebase(self, id, property, value):
        if self.collection is None:
            self.connect_firebase()
        self.collection.child(id).update({property: value})

    def delete_row_firebase(self, id):
        if self.collection is None:
            self.connect_firebase()
        self.collection.child(id).remove()

    def is_synced(self):
        sheet_data_df = self.get_data_sheets()
        firebase_data_df = self.get_data_firebase()
        if not sheet_data_df.equals(firebase_data_df):
            print(sheet_data_df.compare(firebase_data_df))
            return False
        return True

    def test_modify_sheets(self):
        self.assertTrue(self.is_synced())
        rows, cols = self.get_dims_sheet()
        num_modify = 8
        for i in range(num_modify):
            row = random.randrange(1, rows)
            col = random.randrange(0, cols)
            prev_v = self.get_cell_sheet(row, col)
            v = random.random()
            self.modify_sheet(row, col, v)
            self.assertTrue(self.is_synced())
            self.modify_sheet(row, col, prev_v)
            self.assertTrue(self.is_synced())

    def test_append_delete_sheets(self):
        self.assertTrue(self.is_synced())
        self.append_row_sheet(self.gen_row())
        self.assertTrue(self.is_synced())
        self.delete_last_row_sheet()
        self.assertTrue(self.is_synced())

    def test_modify_firebase(self):
        self.assertTrue(self.is_synced())
        # not done yet
        pass

    def test_append_delete_firebase(self):
        self.assertTrue(self.is_synced())
        # not done yet
        pass


if __name__ == '__main__':
    unittest.main()
