
class MailProvider(object):
    """Mail Factory
    """
    @staticmethod
    def GetMail(mail, *args, **kwargs):
        if mail is None or mail.lower() == "stub":
            from inventory.mail.StubGmail import Gmail
        elif mail.lower() == "gmailapi":
            from inventory.mail.GoogleAPIGmail import Gmail
        else:
            raise Exception(f"Unknown mail {mail}")
        return Gmail(*args, **kwargs)
