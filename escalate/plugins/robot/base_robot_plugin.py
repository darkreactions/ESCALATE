from abc import ABC, abstractmethod
from uuid import UUID
import core.models.view_tables as vt


class RobotPlugin(ABC):
    name = "Default Robot Plugin"

    def __init__(self):
        pass

    @property
    @abstractmethod
    def validation_errors(self):
        pass

    @abstractmethod
    def validate(self, experiment_instance: "vt.ExperimentInstance"):
        pass

    @abstractmethod
    def robot_file(self, experiment_instance: "vt.ExperimentInstance"):
        pass

    def __str__(self):
        return self.name