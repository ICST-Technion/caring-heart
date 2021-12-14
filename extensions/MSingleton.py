from typing import Callable


class Singleton(type):
    _instances = {}

    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super(Singleton, cls).__call__(*args, **kwargs)
        return cls._instances[cls]


class SingletonProvider:
    def __init__(self, provider: Callable):
        self._value = None
        self._provider = provider

    def __call__(self, *args, **kwargs):
        if self._value is None:
            self._value = self._provider(*args, **kwargs)
        return self._value

