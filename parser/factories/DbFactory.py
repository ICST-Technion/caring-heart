
class DbProvider(object):
    """Database Factory
    """
    @staticmethod
    def GetDb(db, *args, **kwargs):
        if db is None or db.lower() == "stub":
            return None
        if db.lower() == "excel":
            from parser.db.CExcelDb import CExcelDb as database
        else:
            raise Exception(f"Unknown db {db}")
        return database(*args, **kwargs)
