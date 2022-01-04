from inventory.interfaces.IMail import IMail


class Gmail(IMail):
    def get_mail(self, **kwargs):
        return [
            ''' שם מלא:  דביר דוד ביטון
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
        ]
        # return ["Name1 , Address1 ,  Street1, City1, Phone1, Description1, Category1, Date1, Comments1, Email1"]
