from abc import ABC, abstractmethod
from typing import List
from uuid import UUID
import core.models.view_tables as vt
from django.forms import ValidationError


class BaseRobotPlugin(ABC):
    name = "Default Robot Plugin"
    errors: List[str] = list()

    def __init__(self):
        pass

    @property
    @abstractmethod
    def validation_errors(self):
        return ValidationError(message=self.errors)

    @abstractmethod
    def validate(self, experiment_instance: "vt.ExperimentInstance"):
        pass

    @abstractmethod
    def robot_file(self, experiment_instance: "vt.ExperimentInstance"):
        pass

    def __str__(self):
        return self.name
