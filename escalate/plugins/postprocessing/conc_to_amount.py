from plugins.postprocessing.base_post_processing_plugin import PostProcessPlugin
import core.models.view_tables as vt
from core.models.core_tables import TypeDef
import pandas as pd
import tempfile
from logging import raiseExceptions
from pint import UnitRegistry


units = UnitRegistry()
Q_ = units.Quantity


class ConcentrationToAmountPlugin(PostProcessPlugin):
    name = "Concentration To Amount Post Process Plugin"

    def __init__(self):
        pass

    @property
    def validation_errors(self):
        pass

    def validate(self, experiment_instance: "vt.ExperimentInstance"):
        return True

    def post_process(self, experiment_instance: "vt.ExperimentInstance"):
        # This loop generates a dictionary for each reagent that contains the desired concentration,
        # material type, phase, MW, and density - data is then used for calculations
        for reagent in experiment_instance.reagent_ei.all():
            input_data = {}
            reagent_materials = reagent.reagent_material_r.all()
            for reagent_material in reagent_materials:
                conc = reagent_material.property_rm.filter(
                    template__description="concentration"
                ).first()
                conc_val = conc.nominal_value.value
                conc_unit = conc.nominal_value.unit
                conc = Q_(conc_val, conc_unit)
                mat_type = reagent_material.template.material_type.description
                phase = reagent_material.material.phase
                if not phase:
                    raise ValueError(
                        "Error: Invalid phase {} for {}. Should be solid, liquid or gas. Please check the inventory table".format(
                            phase, reagent_material.material.description
                        )
                    )

                mw_prop = reagent_material.material.material.property_m.filter(
                    template__description__icontains="molecularweight"
                ).first()
                if mw_prop is None:
                    raise ValueError(
                        "Error: Missing molecular weight data for {}. Please check the inventory table".format(
                            reagent_material.material.description
                        )
                    )
                mw = Q_(mw_prop.value.value, mw_prop.value.unit).to(units.g / units.mol)
                density_prop = reagent_material.material.material.property_m.filter(
                    template__description__icontains="density"
                ).first()
                d = d = Q_(density_prop.value.value, density_prop.value.unit).to(
                    units.g / units.ml
                )
                if density_prop is None:
                    raise ValueError(
                        "Error: Missing density data for {}. Please check the inventory table".format(
                            reagent_material.material.description
                        )
                    )
                input_data[reagent_material] = {
                    "concentration": conc,
                    "material_type": mat_type,
                    "phase": phase,
                    "molecular weight": mw,
                    "density": d,
                }

            # get total volume and dead volume for the reagent
            prop = reagent.property_r.filter(
                template__description__icontains="total volume"
            ).first()
            total_vol = Q_(f"{prop.nominal_value.value} {prop.nominal_value.unit}")

            dead_vol_prop = reagent.property_r.filter(
                template__description__icontains="dead volume"
            ).first()
            dead_vol = Q_(
                f"{dead_vol_prop.nominal_value.value} {dead_vol_prop.nominal_value.unit}"
            )
            # pass input data into amount calculator
            amounts = self._calculate_amounts(input_data, total_vol, dead_vol=dead_vol)

            # Update total volume to include dead volume
            total_vol = total_vol + dead_vol
            prop.nominal_value.value = total_vol.magnitude
            prop.nominal_value.unit = str(total_vol.units)
            prop.save()

            # save amounts to database
            for reagent_material, amount in amounts.items():
                db_amount = reagent_material.property_rm.filter(
                    template__description="amount"
                ).first()
                db_amount.nominal_value.value = amount.magnitude
                db_amount.nominal_value.unit = str(amount.units)
                db_amount.save()

    def _calculate_amounts(self, input_data, target_vol, dead_vol="4000 uL"):

        """Calculates amounts (mass/volumes) of each material in a reagent
           needed to achieve desired concentration

        Args:
            input_data([dic]): contains properties for calculations: desired concentration, material type, phase, MW, density
            target_vol: target volume for reagent, in Pint registry format
            dead_vol: dead volume for reagent, in Pint registry format

        Returns:
            [dic]: amount (mass/volume) of each material
                For solids/solutes, amounts will be reported in grams.
                For liquid/solvent/acid, amount will be reported in mL.

        """

        amounts = {}
        exact_amounts = (
            {}
        )  # use this to store exact values for more precise calculations

        # convert volumes to mL and store in proper Pint format
        vol = Q_(target_vol).to(units.ml)
        dead = Q_(dead_vol).to(units.ml)
        total_vol = vol + dead

        for key, val in input_data.items():
            if val["phase"] == "solid":  # for all solids
                grams = (
                    total_vol
                    * val["concentration"].to(units.mol / units.ml)
                    * val["molecular weight"]
                )
                # convert concentration to moles to mass
                exact_amounts[key] = grams
                amounts[key] = round(grams, 2)

        for key, val in input_data.items():
            if val["phase"] == "liquid":
                if val["material_type"] == "acid":  # for the acids
                    neat = (
                        (100 / val["molecular weight"]) / (100 / val["density"])
                    ).to(
                        units.mol / units.ml
                    )  # concentration of neat (pure) acid
                    vol = (
                        total_vol * val["concentration"].to(units.mol / units.ml) / neat
                    )  # dilution
                    exact_amounts[key] = vol
                    amounts[key] = round(vol, 2)

        for substance, amount in exact_amounts.items():
            # for solids
            if input_data[substance]["phase"] == "solid":
                total_vol -= (
                    amount / input_data[substance]["density"]
                )  # find the volume and subtract from total

            # for acids
            elif input_data[substance]["phase"] == "liquid":
                total_vol -= vol  # find the volume and subtract from total

        for key, val in input_data.items():
            if val["phase"] == "liquid":
                if val["material_type"] != "acid":  # for the solvent(s)
                    if (
                        "volume fraction" in val.keys()
                    ):  # if there is more than one solvent
                        amounts[key] = round(
                            total_vol * val["volume fraction"], 2
                        )  # amount is a fraction of the remaining available volume
                    else:  # if there is just one solvent
                        amounts[key] = round(
                            total_vol, 2
                        )  # amount is the remaining available volume
        return amounts

    def __str__(self):
        return self.name