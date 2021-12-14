from route_planner import constants

from extensions.MSingleton import SingletonProvider
from inventory.db.ExcelDb import ExcelDb
from configparser import ConfigParser


def args_from_config_file(config_path=constants.CONFIG_FILE, **kwargs):
    config = ConfigParser()
    config.read(config_path)
    return args_from_config(config, **kwargs)


def args_from_config(config: ConfigParser, **kwargs):
    col_map = dict(config.items('columns'))
    col_map['selection'] = config.get('main', 'selection')
    bool_keys = ['selection']
    return dict(filename=config.get('main', 'excel_path'),
                boolean_keys=bool_keys,
                key_column_map=col_map,
                **kwargs)


class DbProvider(object):
    """
    Database Factory
    """
    DBs = {
        "stub": SingletonProvider(lambda: None),
        "excel": SingletonProvider(lambda: ExcelDb(**args_from_config_file()))
    }

    @staticmethod
    def GetDb(db, *args, **kwargs):
        if db is None:
            return None
        db = db.lower()
        if db not in DbProvider.DBs.keys():
            raise Exception(f"Unknown db {db}")
        return DbProvider.DBs[db](*args, **kwargs)
