from abc import ABC, abstractmethod
from uuid import UUID


class SamplerPlugin(ABC):
    name = "Default Sampler Plugin"

    def __init__(self):
        pass

    @property
    @abstractmethod
    def validation_errors(self):
        pass

    @abstractmethod
    def validate(self, *args, **kwargs):
        pass

    @abstractmethod
    def sample_experiments(self, *args, **kwargs):
        pass

    def __str__(self):
        return self.name