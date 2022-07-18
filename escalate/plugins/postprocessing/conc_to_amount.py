import tempfile
from logging import raiseExceptions

import core.models.view_tables as vt
import pandas as pd
from core.models.core_tables import TypeDef
from core.models.view_tables import Property
from pint import DimensionalityError, Quantity, UnitRegistry
from plugins.postprocessing.base_post_processing_plugin import BasePostProcessPlugin

units = UnitRegistry()
Q_ = units.Quantity


class ConcentrationToAmountPlugin(BasePostProcessPlugin):
    name = "Reagent Preparation: Concentration to Amount"

    def validate(self):
        for reagent in self.experiment_instance.reagent_ei.all():
            reagent_materials = reagent.reagent_material_r.all()
            for reagent_material in reagent_materials:
                phase = reagent_material.material.phase
                if not phase:
                    self.errors.append(
                        "Error: Invalid phase {} for {}. Should be solid, liquid or gas. Please check the inventory table".format(
                            phase, reagent_material.material.description
                        )
                    )

                mw_prop = reagent_material.material.material.property_m.filter(
                    template__description__icontains="molecularweight"
                ).first()
                if mw_prop is None:
                    self.errors.append(
                        "Error: Missing molecular weight data for {}. Please check the inventory table".format(
                            reagent_material.material.description
                        )
                    )

                density_prop = reagent_material.material.material.property_m.filter(
                    template__description__icontains="density"
                ).first()

                if density_prop is None:
                    self.errors.append(
                        "Error: Missing density data for {}. Please check the inventory table".format(
                            reagent_material.material.description
                        )
                    )
        if self.errors:
            return False
        return True

    def post_process(self):
        # This loop generates a dictionary for each reagent that contains the desired concentration,
        # material type, phase, MW, and density - data is then used for calculations
        for reagent in self.experiment_instance.reagent_ei.all():
            input_data = {}
            reagent_materials = reagent.reagent_material_r.all()
            for reagent_material in reagent_materials:
                conc = reagent_material.property_rm.filter(
                    template__description="concentration"
                ).first()
                if conc is not None:
                    conc_val = conc.nominal_value.value
                    conc_unit = conc.nominal_value.unit
                    conc = Q_(conc_val, conc_unit)
                mat_type = reagent_material.template.material_type.description
                phase = reagent_material.material.phase

                mw_prop = reagent_material.material.material.property_m.filter(
                    template__description__icontains="molecularweight"
                ).first()

                mw = Q_(mw_prop.value.value, mw_prop.value.unit).to(units.g / units.mol)
                density_prop = reagent_material.material.material.property_m.filter(
                    template__description__icontains="density"
                ).first()
                d = d = Q_(density_prop.value.value, density_prop.value.unit).to(
                    units.g / units.ml
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
            assert isinstance(prop, Property)
            total_vol: Quantity = Q_(
                f"{prop.nominal_value.value} {prop.nominal_value.unit}"
            )

            dead_vol_prop: "Property|None" = reagent.property_r.filter(
                template__description__icontains="dead volume"
            ).first()
            assert isinstance(dead_vol_prop, Property)
            dead_vol: Quantity = Q_(
                f"{dead_vol_prop.nominal_value.value} {dead_vol_prop.nominal_value.unit}"
            )
            # pass input data into amount calculator
            amounts = self._calculate_amounts(input_data, total_vol, dead_vol=dead_vol)

            # Update total volume to include dead volume
            total_vol: Quantity = total_vol + dead_vol
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

    def _calculate_amounts(
        self, input_data, target_vol, dead_vol: "Quantity|str" = "4000 uL"
    ):

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
        vol: Quantity = Q_(target_vol).to(units.ml)
        dead: Quantity = Q_(dead_vol).to(units.ml)
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


class AmountToConcentrationPlugin(BasePostProcessPlugin):
    name = "Reagent Preparation: Amount to Concentration"

    def validate(self):
        for reagent in self.experiment_instance.reagent_ei.all():
            for reagent_material in reagent.reagent_material_r.all():
                phase = reagent_material.material.phase
                if not phase:
                    self.errors.append(
                        "Error: Invalid phase {} for {}. Should be solid, liquid or gas. Please check the inventory table".format(
                            phase, reagent_material.material.description
                        )
                    )

                prop = reagent_material.property_rm.filter(
                    template__description="amount"
                ).first()
                amount = Q_(prop.value.value, prop.value.unit)
                if amount.magnitude != 0.0:
                    try:
                        if phase == "solid":
                            amount.to(units.g)
                        elif phase == "liquid":
                            amount.to(units.ml)
                    except DimensionalityError:
                        self.errors.append(
                            "Error: Invalid unit of measure for {} in {}. Please enter a unit that is appropriate for materials of {} phase".format(
                                reagent_material.material.description,
                                reagent_material.template,
                                phase,
                            )
                        )
                mw_prop = reagent_material.material.material.property_m.filter(
                    template__description__icontains="molecularweight"
                ).first()
                if mw_prop is None:
                    self.errors.append(
                        "Error: Missing molecular weight data for {}. Please check the inventory table".format(
                            reagent_material.material.description
                        )
                    )

                density_prop = reagent_material.material.material.property_m.filter(
                    template__description__icontains="density"
                ).first()

                if density_prop is None:
                    self.errors.append(
                        "Error: Missing density data for {}. Please check the inventory table".format(
                            reagent_material.material.description
                        )
                    )

        if self.errors:
            return False
        return True

    def _get_input_data(self):
        input_data = {}
        for reagent in self.experiment_instance.reagent_ei.all():
            input_data[reagent] = {}
            reagent_materials = reagent.reagent_material_r.all()
            for reagent_material in reagent_materials:
                prop = reagent_material.property_rm.filter(
                    template__description="amount"
                ).first()
                prop: "Property|None"
                if prop is None:
                    continue
                amount = Q_(prop.nominal_value.value, prop.nominal_value.unit)
                mat_type = reagent_material.template.material_type.description
                phase = reagent_material.material.phase

                mw_prop = reagent_material.material.material.property_m.filter(
                    template__description__icontains="molecularweight"
                ).first()
                mw = Q_(mw_prop.value.value, mw_prop.value.unit).to(units.g / units.mol)

                density_prop = reagent_material.material.material.property_m.filter(
                    template__description__icontains="density"
                ).first()
                d = d = Q_(density_prop.value.value, density_prop.value.unit).to(
                    units.g / units.ml
                )

                input_data[reagent][reagent_material] = {
                    "amount": amount,
                    "material_type": mat_type,
                    "phase": phase,
                    "molecular weight": mw,
                    "density": d,
                }
        return input_data

    def post_process(self):  # properties_lookup):
        """[summary]
        For each reagent in an experiment, this function obtains reagent material properties
        needed to calculate actual concentrations of each material based on solution preparation
        Args:
            experiment_instance([str]): UUID of experiment instance
        Returns:
            N/A
            saves calculated concentrations to database
        """
        # This loop generates a dictionary for each reagent that contains the desired concentration,
        # material type, phase, MW, and density - data is then used for calculations
        input_data = self._get_input_data()
        for reagent in self.experiment_instance.reagent_ei.all():
            # pass input data into amount calculator
            concentrations = self._back_calculate(input_data[reagent])

            # save amounts to database
            for reagent_material, conc in concentrations.items():
                db_conc = reagent_material.property_rm.filter(
                    template__description="concentration"
                ).first()
                db_conc.value.value = conc.magnitude
                db_conc.value.unit = str(conc.units)
                db_conc.save()

    def _back_calculate(self, input_data):

        """[summary]
        Calculates actual concentration of each material in a reagent given actual amounts used to prepare the reagents
        Args:
            input_data([dic]):
        Returns:
            [dic]: concentration (M) of each material
                NOTE: solvent concentrations are reported as 0.0 M by convention (a solvent does not have a concentration)
        """

        concentrations = {}

        total_vol = Q_(0.0, "mL")  # instantiate volume in proper Pint format

        for key, val in input_data.items():
            if val["phase"] == "solid":  # for all solids
                moles = (val["amount"] / val["molecular weight"]).to(
                    units.mol
                )  # convert mass to moles
                concentrations[key] = moles  # store the mole values
                vol = (val["amount"] / val["density"]).to(
                    units.ml
                )  # convert mass to volume
                total_vol += vol  # add this to total volume
            elif val["phase"] == "liquid":  # for the solvent(s)
                if val["amount"].magnitude == 0:
                    vol = Q_(0, "ml")
                else:
                    vol = (val["amount"]).to(units.ml)  # make sure volume is in mL
                total_vol += vol  # add this to total volume
                concentrations[key] = Q_(0.0, "M")  # concentration of a solvent is 0 M

        for substance, amount in concentrations.items():
            if amount.magnitude != 0.0:  # for the solids
                if total_vol.magnitude != 0.0:
                    concentrations[substance] = (amount / total_vol).to(
                        units.molar
                    )  # divide moles by volume to get concentration
            else:
                concentrations[substance] = Q_(amount.magnitude, "molar")

        return concentrations

    def __str__(self):
        return self.name
