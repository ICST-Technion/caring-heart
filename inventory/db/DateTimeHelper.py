from datetime import datetime
#import locale


MONTHS = ['ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני', 'יולי', 'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר',
          'דצמבר']


def sheetname_getter():
    month = datetime.now().month
    year = datetime.now().year
    return f'{MONTHS[month - 1]} {year}'

#def sheetname_getter():
#    locale.setlocale(locale.LC_ALL, 'he_IL')
#    d = datetime.now()
#    month_year = d.strftime('%B %Y')
#    locale.resetlocale(locale.LC_ALL)
#    return month_year
