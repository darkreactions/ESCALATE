from typing import List, Dict
from math import ceil, floor
from core.custom_types import Val
from core.dataclass import VesselData
from core.utilities.utils import make_well_labels_list
from plugins.sampler.base_sampler_plugin import BaseSamplerPlugin
from core.utilities.randomSampling import generateExperiments
from core.dataclass import ExperimentData, ActionUnitData, ActionData


class WF1SamplerPlugin(BaseSamplerPlugin):
    name = "Statespace sampler for WF1"

    def __init__(self):
        super().__init__()

    def validate(self, data: ExperimentData, **kwargs):
        if data.experiment_template.description not in ["Workflow 1"]:
            self.errors.append(
                f"Selected template is not Workflow 1. Found: {data.experiment_template.description}"
            )
        """for rt, r_props in data.reagent_properties.items():
            for rmt, rm_props in r_props.reagent_materials.items():
                # Check if all materials have a phase
                if rm_props.inventory_material.phase is None:
                    self.errors.append(
                        f"Phase data not found for {rm_props.inventory_material}. Please update the inventory material table"
                    )

                if not rm_props.inventory_material.material.property_m.filter(
                    template__description="MolecularWeight"
                ).exists():
                    self.errors.append(
                        f'Molecular weight not found for {rm_props.inventory_material.material}. Please update the material table'
                    )
                if not rm_props.inventory_material.material.property_m.filter(
                    template__description="Density"
                ).exists():
                    self.errors.append(
                        f'Density not found for {rm_props.inventory_material.material}. Please update the material table'
                    )"""
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

        desired_volume = generateExperiments(
            reagent_template_names,
            reagentDefs,
            num_of_automated_experiments,
        )

        action_templates = data.experiment_template.get_action_templates(
            dest_vessel_decomposable=True
        )
        action_to_reagent_mapping = {
            "Dispense Reagent 1 - Solvent": "Reagent 1 - Solvent",
            "Dispense Reagent 2 - Stock A": "Reagent 2 - Stock A",
            "Dispense Reagent 3 - Stock B": "Reagent 3 - Stock B",
            "Dispense Reagent 7 - Acid Volume 1": "Reagent 7 - Acid",
            "Dispense Reagent 7 - Acid Volume 2": "Reagent 7 - Acid",
        }

        well_names = make_well_labels_list(
            96,
            column_order=["A", "C", "E", "G", "B", "D", "F", "H"],
            robot="True",
        )

        for at in action_templates:
            reagent_desc = action_to_reagent_mapping[at.description]
            parameter_def = at.action_def.parameter_def.get(description="volume")
            a_data = ActionData(parameters={})
            dispense_vols: List[ActionUnitData] = []
            dest_vt = data.experiment_template.vessel_templates.get(
                description="Outcome vessel"
            )
            source_vt = data.experiment_template.vessel_templates.get(
                description=reagent_desc
            )

            source_vessel = data.vessel_data[source_vt]
            dest_base_vessel = data.vessel_data[dest_vt]
            # for i, vol in enumerate(desired_volume[reagent_desc]):
            if (children := dest_base_vessel.children.all().order_by("description")) :

                for dest_vessel_name, vol in zip(
                    well_names[: len(desired_volume[reagent_desc])],
                    desired_volume[reagent_desc],
                ):
                    if at.description == "Dispense Reagent 7 - Acid Volume 1":
                        vol = ceil(vol / 2.0)
                    elif at.description == "Dispense Reagent 7 - Acid Volume 2":
                        vol = floor(vol / 2.0)
                    volume = Val.from_dict({"value": vol, "unit": "uL", "type": "num"})
                    dest_vessel = children.get(description=dest_vessel_name)
                    aud = ActionUnitData(
                        source_vessel=VesselData(
                            vessel=source_vessel, vessel_template=source_vt
                        ),
                        dest_vessel=VesselData(
                            vessel=dest_vessel, vessel_template=dest_vt
                        ),
                        nominal_value=volume,
                    )
                    dispense_vols.append(aud)
                a_data.parameters[parameter_def] = dispense_vols
                # a_data.parameters['a'] = dispense_vols
            data.action_parameters[at] = a_data

        return data
