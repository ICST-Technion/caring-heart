from abc import ABCMeta, abstractmethod


class IDb(object, metaclass=ABCMeta):
    """"""

    @abstractmethod
    def connect(self, *args, **kwargs):
        """Connects to the database"""

    @abstractmethod
    def close(self):
        """"""

    @abstractmethod
    def insert(self, *args, **kwargs):
        """"""

    @abstractmethod
    def update(self, *args, **kwargs):
        """"""

    @abstractmethod
    def get(self, *args, **kwargs):
        """"""
