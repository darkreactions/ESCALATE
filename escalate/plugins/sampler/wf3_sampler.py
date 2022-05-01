from typing import List, Dict
from math import ceil, floor
from core.custom_types import Val

from plugins.sampler.base_sampler_plugin import BaseSamplerPlugin
from core.utilities.randomSampling import generateExperiments
from core.dataclass import ExperimentData, ActionUnitData, ActionData

class WF3SamplerPlugin(BaseSamplerPlugin):
    name = "Statespace sampler for WF3"

    def __init__(self):
        super().__init__()

    def validate(self, data: ExperimentData, **kwargs):
        if data.experiment_template.description not in ["Workflow 3"]:
            self.errors.append(
                f"Selected template is not Workflow 3. Found: {data.experiment_template.description}"
            )
        if self.errors:
            return False
        return True

    def sample_experiments(self, data: ExperimentData, **kwargs):
        reagent_template_names: List[str] = [
            rt.description for rt in data.reagent_properties
        ]
        reagentDefs = []
        for rpd in data.reagent_properties.values():
            rmt_data: "Dict[str, str| Val | None]" = {}
            for rmd in rpd.reagent_materials.values():
                for prop_template, value in rmd.properties.items():
                    if prop_template.description == "concentration":
                        rmt_data[rmd.material_type.description] = value.value
                        break
            reagentDefs.append(rmt_data)

        num_of_automated_experiments = data.num_of_sampled_experiments

        #exclude antisolvent from the sampler 
        desired_volume = generateExperiments(
            reagent_template_names[0:-1],
            reagentDefs[0:-1],
            num_of_automated_experiments,
        )

        desired_volume[reagent_template_names[-1]] = [
            800.0
            for i in range(
                num_of_automated_experiments
            )  # default volume for antisolvent is 800 uL
        ]

        action_templates = data.experiment_template.get_action_templates(
            dest_vessel_decomposable=True
        )
        action_to_reagent_mapping = {
            "Dispense Reagent 1 - Solvent": "Reagent 1 - Solvent",
            "Dispense Reagent 2 - Stock A": "Reagent 2 - Stock A",
            "Dispense Reagent 3 - Stock B": "Reagent 3 - Stock B",
            "Dispense Reagent 7 - Acid Volume 1": "Reagent 7 - Acid",
            "Dispense Reagent 7 - Acid Volume 2": "Reagent 7 - Acid",
            "Dispense Reagent 9 - Antisolvent": "Reagent 9 - Antisolvent"
        }

        for at in action_templates:
            reagent_desc = action_to_reagent_mapping[at.description]
            parameter_def = at.action_def.parameter_def.get(description="volume")
            a_data = ActionData(parameters={})
            dispense_vols: List[ActionUnitData] = []
            for vol in desired_volume[reagent_desc]:
                if at.description == "Dispense Reagent 7 - Acid Volume 1":
                    vol = ceil(vol / 2.0)
                elif at.description == "Dispense Reagent 7 - Acid Volume 2":
                    vol = floor(vol / 2.0)
                volume = Val.from_dict({"value": vol, "unit": "uL", "type": "num"})
                aud = ActionUnitData(
                    source_vessel=None, dest_vessel=None, nominal_value=volume
                )
                dispense_vols.append(aud)
            a_data.parameters[parameter_def] = dispense_vols
            data.action_parameters[at] = a_data

        return data
