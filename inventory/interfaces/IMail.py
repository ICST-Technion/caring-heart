from abc import ABCMeta, abstractmethod


class IMail(object, metaclass=ABCMeta):
    @abstractmethod
    def get_mail(self, **kwargs) -> [str]:
        """"""
