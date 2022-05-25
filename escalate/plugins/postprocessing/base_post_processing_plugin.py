from abc import ABC, abstractmethod
import core.models.view_tables as vt
from typing import List
from django.forms import ValidationError


class BasePostProcessPlugin(ABC):
    name = "Default PostProcess Plugin"
    errors: List[str] = list()

    def __init__(self):
        pass

    @property
    def validation_errors(self):
        return ValidationError(message=self.errors)

    @abstractmethod
    def validate(self, experiment_instance: "vt.ExperimentInstance"):
        pass

    @abstractmethod
    def post_process(self, experiment_instance: "vt.ExperimentInstance"):
        pass

    def __str__(self):
        return self.name