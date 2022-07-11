from abc import ABC, abstractmethod
import core.models.view_tables as vt
from typing import List
from django.forms import ValidationError


class BasePostProcessPlugin(ABC):
    name = "Default PostProcess Plugin"
    errors: List[str] = list()
    experiment_instance: "vt.ExperimentInstance"

    def __init__(self, experiment_instance):
        self.experiment_instance = experiment_instance

    @property
    def validation_errors(self):
        return ValidationError(message=self.errors)

    @abstractmethod
    def validate(self):
        pass

    @abstractmethod
    def post_process(self):
        pass

    def __str__(self):
        return self.name