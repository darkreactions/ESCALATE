from plugins.sampler.base_sampler_plugin import SamplerPlugin
from uuid import UUID
import core.models.view_tables as vt
from core.models.core_tables import TypeDef
import pandas as pd
from core.utilities.utils import make_well_labels_list
import tempfile


class WF1SamplerPlugin(SamplerPlugin):
    name = "Statespace sampler for WF1"

    def __init__(self):
        super().__init__()

    @property
    def validation_errors(self):
        pass

    def validate(self, *args, **kwargs):
        return True

    def sample_experiments(self, *args, **kwargs):
        pass