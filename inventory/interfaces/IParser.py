from abc import ABCMeta, abstractmethod


class IParser(object, metaclass=ABCMeta):

    @abstractmethod
    def parse(self, text) -> {}:
        """"""
