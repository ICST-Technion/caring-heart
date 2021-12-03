from time import sleep
import os

from inventory.factories.DbFactory import DbProvider
from inventory.factories.MailFactory import MailProvider
from inventory.factories.ParserFactory import ParserProvider
from inventory.Inventory import Inventory


class Controller(object):
    def __init__(self):
        self._db = None
        self._mail = None
        self._parser = None
        self._inventory = None

    def _set_stub(self):
        self._db = DbProvider.GetDb("excel", filename=f'{os.path.dirname(os.path.realpath(__file__))}\\db\\template.xlsx')
        self._mail = MailProvider.GetMail("stub")
        self._parser = ParserProvider.GetParser("stub")

    def _set_gmail(self):
        self._db = DbProvider.GetDb("excel", filename=f'{os.path.dirname(os.path.realpath(__file__))}\\db\\template.xlsx')
        self._mail = MailProvider.GetMail("gmailapi")
        self._parser = ParserProvider.GetParser("stub")

    def run(self):
        self._set_stub()
        self._inventory = Inventory(self._db)
        while True:
            try:
                mail = self._mail.get_mail()
                if len(mail) > 0:
                    for msg in mail:
                        item = self._parser.parse(msg)
                        self._inventory.add_to_inventory(item)
                sleep(1 * 60)
            except Exception as ex:
                print(ex)


if __name__ == '__main__':
    Controller().run()
