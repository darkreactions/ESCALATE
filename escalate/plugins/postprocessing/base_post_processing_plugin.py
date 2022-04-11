from abc import ABC, abstractmethod
import core.models.view_tables as vt


class PostProcessPlugin(ABC):
    name = "Default PostProcess Plugin"

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
    def post_process(self, experiment_instance: "vt.ExperimentInstance"):
        pass

    def __str__(self):
        return self.name