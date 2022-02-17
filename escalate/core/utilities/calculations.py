from logging import raiseExceptions
import requests
from pint import UnitRegistry

from core.models.view_tables.chemistry_data import ReagentMaterial, Reagent
from core.models.view_tables import ExperimentInstance

# from core.utilities.experiment_utils import get_action_parameter_querysets

units = UnitRegistry()
Q_ = units.Quantity


def conc_to_amount(exp_uuid):
    """
    Function to generate amounts from desired concentrations
    based on generate_input_f but using django models

    args:
        exp_instance - ExperimentInstance django model
    """

    # reagent_templates = exp_instance.parent.reagent_templates.all()
    exp_instance = ExperimentInstance.objects.filter(uuid=exp_uuid).prefetch_related()[
        0
    ]

    for reagent in exp_instance.reagent_ei.all():
        input_data = {}
        reagent_materials = reagent.reagent_material_r.all()
        for reagent_material in reagent_materials:
            conc = reagent_material.reagent_material_value_rmi.filter(
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
                property_template__description__icontains="molecularweight"
            ).first()
            if mw_prop is None:
                raise ValueError(
                    "Error: Missing molecular weight data for {}. Please check the inventory table".format(
                        reagent_material.material.description
                    )
                )
            mw = Q_(mw_prop.value.value, mw_prop.value.unit).to(units.g / units.mol)
            density_prop = reagent_material.material.material.property_m.filter(
                property_template__description__icontains="density"
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
        prop = reagent.property_r.filter(
            property_template__description__icontains="total volume"
        ).first()
        total_vol = Q_(f"{prop.nominal_value.value} {prop.nominal_value.unit}")

        dead_vol_prop = reagent.property_r.filter(
            property_template__description__icontains="dead volume"
        ).first()
        dead_vol = Q_(
            f"{dead_vol_prop.nominal_value.value} {dead_vol_prop.nominal_value.unit}"
        )

        amounts = calculate_amounts(input_data, total_vol, dead_vol=dead_vol)

        # Updating total volume to include dead volume
        total_vol = total_vol + dead_vol
        prop.nominal_value.value = total_vol.magnitude
        prop.nominal_value.unit = str(total_vol.units)
        prop.save()

        # Amounts should be a dictionary with key as ReagentMaterials and values as amounts
        for reagent_material, amount in amounts.items():
            db_amount = reagent_material.reagent_material_value_rmi.filter(
                template__description="amount"
            ).first()
            db_amount.nominal_value.value = amount.magnitude
            db_amount.nominal_value.unit = str(amount.units)
            db_amount.save()

    # return amounts


def generate_input_f(reagent, MW, density):
    """A helper function to properly formate input for concentration-to-amount calculations.
    Returns a dictionary where each key is a reagent component and each value is a sub-dictionary
    containing concentration, phase, molecular weight, and density.
    For reagents with multiple solvents, sub-dictionary also contains volume fraction for each solvent.

    reagent - a list of reagent-instance-value dictionaries specifying component and its concentration
        NOTE: this assumes that each component has a reagent-instance-value entry.
        - for liquids, concentration is 0.0 M by default.
        - for reagents with multiple solvents, an additional reagent-instance-value entry is required for
        each liquid component that describes the volume fraction
    MW - material definition URL for molecular weight
    density - material definition URL for density

    """

    input_data = {}  # instantiate dictionary to fill with data

    for (
        component
    ) in reagent:  # component = one of the reagent instance values inside the reagent

        if component["description"] == "Concentration":

            conc_val = component["nominal_value"]["value"]  # desired concentration
            conc_unit = component["nominal_value"]["unit"]  # concentration unit

            if units(conc_unit) != units(
                "molar"
            ):  # concentration must be in molarity. otherwise code breaks
                print("Concentration must be a molarity. Please convert and re-enter.")
                break
            else:
                conc = Q_(conc_val, conc_unit)  # store in proper Pint format

            phase = requests.get(component["material"]).json()[
                "phase"
            ]  # phase/state of matter

            # extract associated material URL
            r = requests.get(component["material"]).json()["material"]
            mat = requests.get(r).json()
            material = mat["description"]
            # loop through properties of the material to get MW and density
            for prop in mat["identifier"]:
                r = requests.get(prop).json()
                if (
                    r["material_identifier_def"] == MW
                ):  # url must match that of MW material identifier def
                    mw = r["description"]
                    mag = float(mw.split()[0])
                    unit = str(mw.split()[1])
                    mw = Q_(mag, unit).to(
                        units.g / units.mol
                    )  # convert to g/mol and store in proper Pint format

                if (
                    r["material_identifier_def"] == density
                ):  # url must match that of density material identifier def
                    d = r["description"]
                    mag = float(d.split()[0])
                    unit = str(d.split()[1])
                    d = Q_(mag, unit).to(
                        units.g / units.ml
                    )  # convert to g/mL and store in proper Pint format

        if (
            component["description"] == "Volume Fraction"
        ):  # for cases with more than one solvent...

            frac = component["nominal_value"]["value"]  # volume fraction

            # extract associated material URL
            r = requests.get(component["material"]).json()["material"]
            mat = requests.get(r).json()
            material = mat["description"]

            input_data[material].update(
                {"volume fraction": frac}
            )  # update dictionary to include volume fraction

        input_data[material] = {
            "concentration": conc,
            "phase": phase,
            "molecular weight": mw,
            "density": d,
        }

    return input_data


def calculate_amounts(input_data, target_vol, dead_vol="4000 uL"):

    """
    Given input data dictionary for reagents and target/dead volumes,
    returns amounts of each reagent component needed to achieve desired concentrations.
    For solids/solutes, amounts will be reported in grams.
    For liquid/solvent/acid, amount will be reported in mL.

    """

    amounts = {}
    exact_amounts = {}  # use this to store exact values for more precise calculations

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
                neat = ((100 / val["molecular weight"]) / (100 / val["density"])).to(
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
                if "volume fraction" in val.keys():  # if there is more than one solvent
                    amounts[key] = round(
                        total_vol * val["volume fraction"], 2
                    )  # amount is a fraction of the remaining available volume
                else:  # if there is just one solvent
                    amounts[key] = round(
                        total_vol, 2
                    )  # amount is the remaining available volume

    """
    for key, val in amounts.items(): #convert amounts from Pint format to strings with val and unit
        num=round(val.magnitude, 2)
        unit=val.units
        value=str(num) + ' ' + str(unit)
        amounts[key]=value
    """

    return amounts


def generate_input_b(reagent, MW, density):

    """A helper function to properly formate input for amount-to-concentration calculations.
    Returns a dictionary where each key is a reagent component and each value is a sub-dictionary
    containing amount, phase, molecular weight, and density.

    reagent - a list of reagent-instance-value dictionaries
    MW - material definition URL for molecular weight
    density - material definition URL for density

    """

    input_data = {}  # instantiate dictionary to fill with data

    for (
        component
    ) in reagent:  # component = one of the reagent instance values inside the reagent

        amount_val = component["nominal_value"]["value"]  # desired amount
        amount_unit = component["nominal_value"]["unit"]  # unit for amount

        amount = Q_(amount_val, amount_unit)  # store in proper Pint format

        phase = requests.get(component["material"]).json()[
            "phase"
        ]  # phase/state of matter

        # extract associated material URL
        r = requests.get(component["material"]).json()["material"]
        mat = requests.get(r).json()
        material = mat["description"]
        # loop through properties of the material to get MW and density
        for prop in mat["identifier"]:
            r = requests.get(prop).json()
            if (
                r["material_identifier_def"] == MW
            ):  # url must match that of MW material identifier def
                mw = r["description"]
                mag = float(mw.split()[0])
                unit = str(mw.split()[1])
                mw = Q_(mag, unit).to(
                    units.g / units.mol
                )  # convert to g/mol and store in proper Pint format

            if (
                r["material_identifier_def"] == density
            ):  # url must match that of density material identifier def
                d = r["description"]
                mag = float(d.split()[0])
                unit = str(d.split()[1])
                d = Q_(mag, unit).to(
                    units.g / units.ml
                )  # convert to g/mL and store in proper Pint format

        input_data[material] = {
            "amount": amount,
            "phase": phase,
            "molecular weight": mw,
            "density": d,
        }

    return input_data


def back_calculate(input_data):

    """
    Given input data from helper function,
    returns actual concentrations of each reagent component based on actual amounts of component added.

    NOTE- solvent concentrations are reported as 0.0 M by convention (a solvent does not have a concentration)
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
            vol = (val["amount"]).to(units.ml)  # make sure volume is in mL
            total_vol += vol  # add this to total volume
            concentrations[key] = Q_(0.0, "M")  # concentration of a solvent is 0 M

    for substance, amount in concentrations.items():
        if amount.magnitude != 0.0:  # for the solids
            concentrations[substance] = (amount / total_vol).to(
                units.molar
            )  # divide moles by volume to get concentration

    for (
        key,
        val,
    ) in (
        concentrations.items()
    ):  # convert values from Pint format to strings with val and unit
        num = val.magnitude
        unit = val.units
        value = str(num) + " " + str(unit)
        concentrations[key] = value

    return concentrations
