"""Region IDE imports"""
from .interfaces.IDb import IDb


class Inventory(object):
    def __init__(self, db: IDb):
        self._db = db

    def add_to_inventory(self, item: {}):
        self._db.insert(item=item)
