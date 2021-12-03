from inventory.interfaces.IParser import IParser


class Parser(IParser):
    def __init__(self):
        pass

    def parse(self, text):
        raise NotImplementedError()
