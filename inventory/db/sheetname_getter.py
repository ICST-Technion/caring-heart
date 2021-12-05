from datetime import datetime


MONTHS = ['ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני', 'יולי', 'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר',
          'דצמבר']


def sheetname_getter(sheetnames):
    month = datetime.now().month
    year = datetime.now().year
    return f'{MONTHS[month - 1]} {year}'
