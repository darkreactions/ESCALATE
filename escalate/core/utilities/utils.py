from typing import Any
from django.db import connection as con
from django.db.models import F
from core.models import ExperimentTemplate, Action
from core.models.view_tables import (
    BaseBomMaterial,
    Action,
    ActionUnit,
    ExperimentTemplate,
    ExperimentInstance,
    BillOfMaterials,
    ReagentMaterial,
    Outcome,
    Reagent,
    ReagentTemplate,
    VesselType,
    Parameter,
    Vessel,
)
from copy import deepcopy

import pandas as pd
import tempfile
import math
from itertools import product
import uuid

from core.models.app_tables import ActionTemplateDesign

# import core.models.view_tables as vt


def camel_to_snake(name):
    name = "".join(["_" + i.lower() if i.isupper() else i for i in name]).lstrip("_")
    return name


def get_colors(
    number_of_colors: int,
    colors: "list[str]" = [
        "#8FBDD3",
        "#BE8C63",
        "#A97155",
        "#1572A1",
    ],
) -> "list[str]":
    """Colors for forms that display on UI"""
    factor = int(number_of_colors / len(colors))
    remainder = number_of_colors % len(colors)
    total_colors = colors * factor + colors[:remainder]
    return total_colors


def make_well_labels_list(well_count=96, column_order=None, robot="True"):
    """[summary]

    Args:
        well_count ([int]): number of wells
        column_order ([list]): letters to use in well labels
        robot([str]): if "True", well labels will be ordered the way robot dispenses liquid. otherwise, chronological

    Returns:
        [list]: List of well labels ([str])
    """

    if well_count not in [
        6,
        12,
        24,
        48,
        96,
    ]:  # for arbitrary vessels, label wells in consecutive numerical order
        if well_count is None:  # beakers, tubes, etc -> one compartment
            well_labels = [1]
        else:
            well_labels = [i for i in range(1, well_count + 1)]

    else:
        # get dimensions for standard well plates
        if well_count in [6, 24, 96]:
            num_rows = math.ceil((well_count * 3 / 2) ** (1 / 2))
        else:
            num_rows = math.ceil((well_count * 4 / 3) ** (1 / 2))

        num_columns = well_count / num_rows

        column_options = ["A", "B", "C", "D", "E", "F", "G", "H"]
        column_order = []

        if robot == "True":  # order list by how the robot draws from the solvent wells

            for i in range(int(math.ceil(num_columns / 2))):
                column_order.append(column_options[i * 2])
            for i in range(int(num_columns / 2)):
                column_order.append(column_options[i * 2 + 1])

        else:  # chronological order for outcomes
            for i in range(int(num_columns)):
                column_order.append(column_options[i])

        row_limit = math.ceil(well_count / num_columns)
        well_labels = [
            f"{col}{row}" for row in range(1, row_limit + 1) for col in column_order
        ][:well_count]

    return well_labels


def generate_vp_spec_file(exp_template_uuid, vessel):
    """Function generates an excel spredsheet to specify volumes and parameters for manual experiments.
    The spreadsheet can be downloaded via UI and uploaded once edited. Spreadsheet is then parsed to save
    values into the database."""
    plate = vessel.description
    well_count = vessel.well_number

    params = []
    values = []
    units = []
    exp_template = ExperimentTemplate.objects.get(uuid=exp_template_uuid)

    for action_template in exp_template.action_template_et.select_related(
        "action_def"
    ).all():
        for param in action_template.action_def.parameter_def.all():
            if "dispense" not in action_template.description.lower():
                desc = action_template.description + "-" + param.description
                params.append(desc)
                val = param.default_val.value
                unit = param.default_val.unit
                values.append(val)
                units.append(unit)

    rxn_parameters = pd.DataFrame(
        {
            "Reaction Parameters": params,
            "Parameter Values": values,
            "Units": units,
        }
    )

    well_names = make_well_labels_list(
        well_count, column_order=["A", "C", "E", "G", "B", "D", "F", "H"], robot="True"
    )
    df_tray = pd.DataFrame(
        {
            "Vial Site": well_names,
        }
    )  # "Labware ID:": plate})

    reagent_colnames = []
    reagents = ExperimentTemplate.objects.get(
        uuid=exp_template_uuid
    ).reagent_templates.all()
    for r in reagents:
        reagent_colnames.append(r.description)

    reaction_volumes_output = pd.DataFrame(
        {reagent_col: [0] * len(df_tray) for reagent_col in reagent_colnames}
    )

    # if reaction_volumes is not None:
    reaction_volumes_output = pd.concat(
        [df_tray["Vial Site"], reaction_volumes_output], axis=1
    )

    volume_units = pd.DataFrame({"Units": ["uL"]})
    volume_units[" "] = None
    volume_units.reindex(columns=[" ", "Units"])  # type: ignore

    outframe = pd.concat(
        [  # df_tray['Vial Site'],
            reaction_volumes_output,
            # volume_units,
            volume_units.reindex(columns=[" ", "Units"]),  # type: ignore
            # df_tray["Labware ID:"],
            rxn_parameters,
            # rxn_conditions,
        ],
        sort=False,
        axis=1,
    )
    temp = tempfile.TemporaryFile()
    # xlwt is no longer maintained and will be removed from pandas in future versions
    # use io.excel.xls.writer as the engine once xlwt is removed
    outframe.to_excel(
        temp, sheet_name=exp_template.description, index=False, engine="xlwt"
    )
    temp.seek(0)
    return temp


def generate_action_def_json(action_defs, exp_template_uuid):
    """[summary]

    Args:
        action_defs([list]): ActionDef objects
        exp_template_uuid ([str]): UUID of the experiment template to retrieve

    Returns:
        [dictionary]: json data to populate action def options in UI
    """

    # by convention, transfer-type actions(e.g. dispense) involve moving a source into a destination
    # other actions, e.g. heat, involve only one material/vessel.
    # this is specified as the destination and source is left blank

    source_choices = [
        " "
    ]  # add a "blank" source for actions that do not involve transferring
    dest_choices = []

    for reagent in ReagentTemplate.objects.filter(
        experiment_template_rt=ExperimentTemplate(uuid=exp_template_uuid)
    ):
        # include all reagents associated with experiment template as action sources/destinations
        source_choices.append(reagent.description)
        # dest_choices.append(reagent.description)

    """for vt in VesselTemplate.objects.all():
        # for vt in VesselType.objects.all():  # include all vessels as destinations
        if 'Outcome' not in vt.description:
            source_choices.append(vt.default_vessel.description+ ': ' + vt.description)
            dest_choices.append(vt.default_vessel.description+ ': ' + vt.description)"""

    for vt in VesselType.objects.all():
        source_choices.append(vt.description)
        dest_choices.append(vt.description)

    json_data = []

    for i in range(len(action_defs)):

        json_data.append(
            {
                "type": action_defs[i].description,
                "displayName": action_defs[i].description,
                "runtimeDescription": " ",
                "description": action_defs[i].description,
                "category": "template",
                "outcomes": ["Done"],
                "properties": [
                    {
                        "name": "source",
                        "type": "select",
                        "label": "From:",
                        "hint": "source material/vessel",
                        "options": {"items": [i for i in source_choices]},
                    },
                    {
                        "name": "destination",
                        "type": "select",
                        "label": "To:",
                        "hint": "destination vessel",
                        "options": {"items": [i for i in dest_choices]},
                    },
                ],
            }
        )
    return json_data


def custom_pairing(source_vessels, dest_vessels):
    raise NotImplementedError


def experiment_copy(
    template_experiment_uuid: str,
    copy_experiment_description: str,
    vessels: "dict[str, Any]",
) -> uuid.UUID:
    """Creates an experiment instance based on the template uuid

    Args:
        template_experiment_uuid (str): UUID of the experiment template
        copy_experiment_description (str): Description of experiment instance
        vessel (model): Vessel used for this experiment

    Returns:
        str: UUID of the newly created experiment
    """
    # Get parent Experiment from template_experiment_uuid
    exp_template = ExperimentTemplate.objects.get(uuid=template_experiment_uuid)
    # experiment row creation, overwrites original experiment template object with new experiment object.
    # Makes an experiment template object parent
    exp_instance = ExperimentInstance.objects.create(
        ref_uid=exp_template.ref_uid,
        template=exp_template,
        owner=exp_template.owner,
        operator=exp_template.operator,
        lab=exp_template.lab,
        description=copy_experiment_description
        if copy_experiment_description
        else f"Copy of {exp_template.description}",
    )

    bom = BillOfMaterials.objects.create(experiment_instance=exp_instance)

    # Get all action sequences related to this experiment template
    # for asq in exp_template.action_sequence.all():
    for at in exp_template.action_template_et.all():
        action = Action.objects.create(
            description=at.action_def.description,
            # parent=
            experiment=exp_instance,
            template=at,
        )

        # Create a list of all source vessels
        source_vessels = []
        if svt := at.source_vessel_template:
            contents = svt.description
            base_vessel = vessels[svt.description]
            if at.source_vessel_decomposable:
                source_vessels = list(base_vessel.children.all())
            else:
                source_vessels = [base_vessel]
        else:
            contents = None

        # Create a list of all destination vessels
        dest_vessels = []
        if dvt := at.dest_vessel_template:
            base_vessel = vessels[dvt.description]
            if at.dest_vessel_decomposable:
                dest_vessels = list(base_vessel.children.all())
            else:
                dest_vessels = [base_vessel]

        if not source_vessels:
            vessel_pairs = product([None], dest_vessels)
        elif len(source_vessels) == 1:
            vessel_pairs = product(source_vessels, dest_vessels)
        elif len(source_vessels) == len(dest_vessels):
            vessel_pairs = zip(source_vessels, dest_vessels)
        else:
            vessel_pairs = custom_pairing(source_vessels, dest_vessels)

        bom_vessels = {}
        aunits = []
        parameters = []
        sv: "None|Vessel"
        dv: "None|Vessel"
        for sv, dv in vessel_pairs:
            if dv is not None:
                if dv.description not in bom_vessels:
                    bom_vessels[dv.description] = BaseBomMaterial.objects.create(
                        bom=bom, vessel=dv, description=dv.description
                    )
                    dest_bbm = bom_vessels[dv.description]
                else:
                    dest_bbm = dv.description
            else:
                dest_bbm = dv

            if sv is not None:
                if sv.description not in bom_vessels:
                    bom_vessels[sv.description] = BaseBomMaterial.objects.create(
                        bom=bom, vessel=sv, description=contents
                    )
                source_bbm = bom_vessels[sv.description]
            else:
                source_bbm = sv

            au = ActionUnit(
                description=f"{action.description} : {source_bbm} -> {dest_bbm}",
                action=action,
                destination_material=dest_bbm,
                source_material=source_bbm,
            )
            param_defs = au.action.template.action_def.parameter_def.all()
            for p_def in param_defs:
                p = Parameter(
                    parameter_def=p_def,
                    parameter_val_nominal=p_def.default_val,
                    parameter_val_actual=p_def.default_val,
                    action_unit=au,
                )
                parameters.append(p)
            aunits.append(au)

        ActionUnit.objects.bulk_create(aunits)
        Parameter.objects.bulk_create(parameters)

    # Iterate over all reagent-templates and create reagentintances and properties
    for reagent_template in exp_template.reagent_templates.all():
        # Iterate over value_descriptions so that there are different ReagentInstanceValues based on
        # different requirements. For e.g. "concentration" and "amount" for the same
        # reagent need different ReagentInstanceValues
        # for val_description in reagent_template.value_descriptions:
        reagent = Reagent(experiment=exp_instance, template=reagent_template)
        reagent.save()
        for (
            reagent_material_template
        ) in reagent_template.reagent_material_template_rt.all():
            reagent_material = ReagentMaterial(
                template=reagent_material_template,
                reagent=reagent,
                description=f"{exp_instance.description} : {reagent_template.description} : {reagent_material_template.description}",
            )
            reagent_material.save()

    # well_num = vessel.well_number
    # col_order = vessel.column_order
    # well_list = make_well_labels_list(well_num, col_order, robot="False")

    for outcome_template in exp_template.outcome_templates.all():
        for vt in exp_template.vessel_templates.all():
            if vt.outcome_vessel:
                selected_vessel = vessels[vt.description]
                for child in selected_vessel.children.all():
                    outcome_instance = Outcome(
                        outcome_template=outcome_template,
                        experiment_instance=exp_instance,
                        description=child.description,
                    )
                    outcome_instance.save()

    return exp_instance.uuid


# list of model class names that have at least one view auto generated
view_names = [
    "Material",
    "Inventory",
    "Actor",
    "Organization",
    "Person",
    "Systemtool",
    "InventoryMaterial",
    "Vessel",
    "SystemtoolType",
    "UdfDef",
    "Status",
    "Tag",
    "TagType",
    "MaterialType",
    "ExperimentInstance",
    "Edocument",
    "ExperimentCompletedInstance",
    "ExperimentPendingInstance",
    "ExperimentTemplate",
]
