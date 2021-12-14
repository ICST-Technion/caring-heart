
class ConverterProvider(object):
    """Converter Factory
    """
    @staticmethod
    def GetConverter(conv, *args, **kwargs):
        if conv is None:
            return None
        elif conv.lower() == "mailtoexcel":
            from inventory.converters.MailToExcelConverter import Converter
        else:
            raise Exception(f"Unknown converter {conv}")
        return Converter(*args, **kwargs)
