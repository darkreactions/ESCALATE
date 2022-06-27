from typing import List, Dict
from math import ceil, floor
from core.custom_types import Val

from plugins.sampler.base_sampler_plugin import BaseSamplerPlugin
from core.utilities.randomSampling import generateExperiments
from core.dataclass import ExperimentData, ActionUnitData, ActionData

import pint
from pint import UnitRegistry

units = UnitRegistry()
Q_ = units.Quantity


class WF3SamplerPlugin(BaseSamplerPlugin):
    name = "Statespace sampler for WF3"

    sampler_vars = {
        "finalVolume": (
            "Target Volume (per well)",
            Val.from_dict(dict(value=500, unit="uL", type="num")),
        ),
        "maxMolarity": (
            "Max Molarity",
            Val.from_dict(dict(value=9.0, unit="M", type="num")),
        ),
        "antisolventVol": (
            "Desired Antisolvent Volume",
            Val.from_dict(dict(value=800, unit="uL", type="num")),
        ),
    }

    def __init__(self, *args, **kwargs):
        self.vars = kwargs
        super().__init__(*args, **kwargs)

    def validate(self, data: ExperimentData):
        if data.experiment_template.description not in ["Workflow 3"]:
            self.errors.append(
                f"Selected template is not Workflow 3. Found: {data.experiment_template.description}"
            )
        else:
            self.errors = []

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

        vol2 = self.vars["antisolventVol"].value
        try:
            vol2 = float(vol2)
            if vol2 < 0:
                self.errors.append(
                    f"Antisolvent volume value {vol2} must be greater than 0"
                )
        except TypeError:
            self.errors.append(
                f"Antisolvent volume value {vol2} must be numerical input"
            )

        target_vessel = None
        # verify that target volume does not exceed vessel capacity
        for vessel_template, vessel in data.vessel_data.items():
            if vessel_template.outcome_vessel == True:
                target_vessel = vessel
        desiredUnit = self.vars["finalVolume"].unit
        try:
            v = Q_(
                self.vars["antisolventVol"].value, self.vars["antisolventVol"].unit
            ).to(
                "uL"
            )  # attempt to convert antisolvent volume to verify its unit
            assert target_vessel
            if target_vessel.total_volume.value is not None:
                capacity = Q_(
                    target_vessel.total_volume.value, target_vessel.total_volume.unit
                ).to(desiredUnit)
                vol = self.vars["finalVolume"].value
                if vol > capacity:
                    self.errors.append(
                        f"Target volume {vol} {desiredUnit} exceeds capacity {capacity} for chosen vessel"
                    )
        except pint.errors.DimensionalityError as e:
            # self.errors.append(f"Check that the unit entered for target volume is an appropriate unit of volume. {desiredUnit} is not a valid unit of volume")
            self.errors.append(str(e))

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

        # exclude antisolvent from the sampler
        desired_volume = generateExperiments(
            reagent_template_names[0:-1],
            reagentDefs[0:-1],
            num_of_automated_experiments,
            finalVolume=vol,  # vars['finalVolume'].value,
            maxMolarity=float(self.vars["maxMolarity"].value),
            desiredUnit=self.vars["finalVolume"].unit,
        )

        # convent antisolvent volume to microliters
        v = self.vars["antisolventVol"]
        v1 = Q_(float(v.value), v.unit).to(units.ul)
        antisolvent_vol = v1.magnitude

        # add desired antisolvent volume to data
        desired_volume[reagent_template_names[-1]] = [
            antisolvent_vol for i in range(num_of_automated_experiments)
        ]

        action_templates = data.experiment_template.action_template_et.filter(
            dest_vessel_decomposable=True
        )
        action_to_reagent_mapping = {
            "Dispense Reagent 1 - Solvent": "Reagent 1 - Solvent",
            "Dispense Reagent 2 - Stock A": "Reagent 2 - Stock A",
            "Dispense Reagent 3 - Stock B": "Reagent 3 - Stock B",
            "Dispense Reagent 7 - Acid Volume 1": "Reagent 7 - Acid",
            "Dispense Reagent 7 - Acid Volume 2": "Reagent 7 - Acid",
            "Dispense Reagent 9 - Antisolvent": "Reagent 9 - Antisolvent",
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
