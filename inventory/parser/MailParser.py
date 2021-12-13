from inventory.interfaces.IParser import IParser


def extract(text, tag):
    index = text.rfind(tag)
    if index == -1:
        raise Exception("Extract: tag not found!")
    return text[:index], text[index + len(tag):].strip()

# this can be used for testing - I've used it to check that everything works.
test_in = ''' שם מלא:  דביר דוד ביטון
טלפון נייד:  0522384238
טלפון נוסף: 03-9588260
אימייל:  dbiton@gmail.com
כתובת איסוף החפץ:  מוסאל יצחק 11 ב, ראשון לציון - ישראל
רהיט:  שידה חומה גדולה
מוצר חשמלי:  טוסטר אובן
אחר:
מצב החפץ:  כמו חדש
הערות:  זה טסט שאני כותב מה הולך אחי
העלאת תמונה:
תאריך: 23 בנובמבר 2021
זמן: 20:52
קישור לעמוד:  -
פרטי משתמש: dbiton
IP השולח:  127.0.0.1
מופעל באמצעות: אלמנטור
'''


class Parser(IParser):
    def __init__(self):
        pass

    def _extract(self, text, tag):
        index = text.rfind(tag)
        if index == -1:
            raise Exception("Extract: tag not found!")
        return text[:index], text[index + len(tag):].strip()

    def parse(self, text):
        tags = [
            'שם מלא:',
            'טלפון נייד:',
            'טלפון נוסף:',
            'אימייל:',
            'כתובת איסוף החפץ:',
            'רהיט:',
            'מוצר חשמלי:',
            'אחר:',
            'מצב החפץ:',
            'הערות:',
            'העלאת תמונה:',
            'תאריך:',
            'זמן:',
            'קישור לעמוד:',
            'פרטי משתמש:',
            'IP השולח:',
            'מופעל באמצעות:']
        content = []
        for tag in tags[::-1]:
            text, extracted = self._extract(text, tag)
            content.insert(0, extracted)
        return {tags[index][:-1]: item for index, item in enumerate(content)}
