class Converter(object):
    excel_to_mail_names = {
        "שם": 'שם מלא',
        "כתובת": 'כתובת איסוף החפץ',
        "תאריך": 'תאריך',
        "הערות": 'הערות',
        "E-mail": 'אימייל'
    }
    category_names = [
        "רהיט",
        'מוצר חשמלי',
        'אחר'
    ]

    def convert(self, item :dict):
        res = { excel_name : item.get(value,"") for excel_name, value in self.excel_to_mail_names.items()}
        res["תאור"] = self._get_description(item)
        res["נייד/טל'"] = self._get_phone(item)
        res["קטגוריית מוצר"] = self._get_category(item)
        return res

    def _get_description(self, item):
        description_list = [item.get("מצב החפץ", ""), self._get_category(item)]
        return "/".join([desc for desc in description_list if desc != ""])

    def _get_phone(self, item):
        numbers = [item.get("טלפון נייד",""),item.get("טלפון נוסף","")]
        return "/".join([number for number in numbers if number != ""])

    def _get_category(self, item):
        return "/".join([item.get(key) for key in self.category_names if item.get(key, "") != ""])