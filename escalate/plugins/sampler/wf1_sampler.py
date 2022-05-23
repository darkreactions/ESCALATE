from typing import List, Dict
from math import ceil, floor
from core.custom_types import Val
from core.dataclass import VesselData
from core.utilities.utils import make_well_labels_list
from plugins.sampler.base_sampler_plugin import BaseSamplerPlugin
from core.utilities.randomSampling import generateExperiments
from core.dataclass import ExperimentData, ActionUnitData, ActionData

import pint
from pint import UnitRegistry

units = UnitRegistry()
Q_ = units.Quantity


class WF1SamplerPlugin(BaseSamplerPlugin):
    name = "Statespace sampler for WF1"

    sampler_vars = {
        "finalVolume": (
            "Target Volume (per well)",
            Val.from_dict({"value": 500, "unit": "uL", "type": "num"}),
        ),
        "maxMolarity": (
            "Max Molarity",
            Val.from_dict({"value": 9.0, "unit": "M", "type": "num"}),
        ),
    }

    def __init__(self, *args, **kwargs):
        self.vars = kwargs
        super().__init__(*args, **kwargs)

    def validate(self, data: ExperimentData):
        if data.experiment_template.description not in ["Workflow 1"]:
            self.errors.append(
                f"Selected template is not Workflow 1. Found: {data.experiment_template.description}"
            )

        # verify validity of numerical inputs for volume and molarity
        vol = self.vars["finalVolume"].value
        try:
            vol = float(vol)
            if vol < 0:
                self.errors.append(f"Target volume value {vol} must be greater than 0")
        except TypeError:
            self.errors.append(f"Target volume value {vol} must be numerical input")

        mol = self.vars["maxMolarity"].value
        try:
            mol = float(mol)
            if mol < 0:
                self.errors.append(f"Molarity value {mol} must be greater than 0")
        except TypeError:
            self.errors.append(f"Molarity value {mol} must be numerical input")

        # verify that target volume does not exceed vessel capacity
        target_vessel = None
        for vessel_template, vessel in data.vessel_data.items():
            if vessel_template.outcome_vessel == True:
                target_vessel = vessel

        desiredUnit = self.vars["finalVolume"].unit
        try:
            if target_vessel:
                if target_vessel.total_volume.value is not None:
                    capacity = Q_(
                        target_vessel.total_volume.value,
                        target_vessel.total_volume.unit,
                    ).to(desiredUnit)
                    vol = self.vars["finalVolume"].value
                    if vol > capacity:
                        self.errors.append(
                            f"Target volume {vol} {desiredUnit} exceeds capacity {capacity} for chosen vessel"
                        )
        except pint.errors.DimensionalityError as e:
            # self.errors.append(f"Check that the unit entered for target volume is an appropriate unit of volume. {desiredUnit} is not a valid unit of volume")
            self.errors.append(str(e))
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

    def sample_experiments(self, data: ExperimentData):
        reagent_template_names: List[str] = [
            rt.description for rt in data.reagent_properties
        ]
        reagentDefs = []
        for rpd in data.reagent_properties.values():
            rmt_data: "Dict[str, str| Val | None]" = {}
            for rmd in rpd.reagent_materials.values():
                for prop_template, value in rmd.properties.items():
                    if prop_template.description == "concentration":
                        rmt_data[rmd.inventory_material.description] = value.value
                        break
            reagentDefs.append(rmt_data)
        num_of_automated_experiments = data.num_of_sampled_experiments

        # convert volume to uL to pass into sampler
        v = Q_(float(self.vars["finalVolume"].value), self.vars["finalVolume"].unit).to(
            units.ul
        )
        vol = v.magnitude

        desired_volume = generateExperiments(
            reagent_template_names,
            reagentDefs,
            num_of_automated_experiments,
            finalVolume=vol,  # vars['finalVolume'].value,
            maxMolarity=float(self.vars["maxMolarity"].value),
            desiredUnit=self.vars["finalVolume"].unit,
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
