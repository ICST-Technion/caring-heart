from inventory.interfaces.IParser import IParser


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
