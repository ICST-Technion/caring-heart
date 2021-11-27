
class DbProvider(object):
    """Database Factory
    """
    @staticmethod
    def GetDb(db, *args, **kwargs):
        if db is None or db.lower() == "stub":
            return None
        elif db.lower() == "excel":
            from inventory.db.CExcelDb import CExcelDb as database
        else:
            raise Exception(f"Unknown db {db}")
        return database(*args, **kwargs)
