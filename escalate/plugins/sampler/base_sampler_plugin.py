from abc import ABC, abstractmethod
from typing import Dict, List, Any
from core.dataclass import ExperimentData
from django.forms import ValidationError


class BaseSamplerPlugin(ABC):
    name = "Default Sampler Plugin"
    errors: List[str] = list()
    sampler_vars: Dict[str, Any] = dict()

    def __init__(self, *args, **kwargs):
        pass

    @property
    def validation_errors(self):
        return ValidationError(message=self.errors)

    @property
    def get_variables(self):
        '''Users can input sampler variables that are optional, if different from default'''
        return self.sampler_vars

    @abstractmethod
    def validate(self, data: ExperimentData, **kwargs) -> bool:
        """Validation code goes here. You can check for the required values stored in
        ExperimentData dataclass. If an error is found, add the error message string to
        the self.errors list and they will be rendered in the form

        Args:
            form_data (_type_, optional): _description_. Defaults to None.

        Returns:
            bool: _description_
        """
        pass

    @abstractmethod
    def sample_experiments(self, data: ExperimentData, **kwargs) -> ExperimentData:
        pass

    def __str__(self):
        return self.name