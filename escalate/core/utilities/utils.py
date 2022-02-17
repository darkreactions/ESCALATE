from django.db import connection as con
from django.db.models import F
from core.models import ExperimentTemplate, ActionSequence, Action
from core.models.view_tables import (
    BomMaterial,
    Action,
    ActionUnit,
    ExperimentTemplate,
    ExperimentInstance,
    BillOfMaterials,
    ExperimentActionSequence,
    ReagentMaterial,
    OutcomeInstance,
    ReagentMaterialValue,
    Reagent,
    ReagentTemplate,
    VesselType,
)
from copy import deepcopy

import pandas as pd
import tempfile
import math

# import core.models.view_tables as vt


def camel_to_snake(name):
    name = "".join(["_" + i.lower() if i.isupper() else i for i in name]).lstrip("_")
    return name


def make_well_labels_list(well_count=96, column_order=None, robot="True"):
    """Generates a list of well labels for a vessel with number of wells = well_count.
    column_order specifies order of alphabetical characters in labels list (e.g. ACBD versus ABCD)"""
    if well_count not in [
        24,
        96,
    ]:  # for arbitrary vessels, label wells in consecutive numerical order
        if well_count is None:  # beakers, tubes, etc -> one compartment
            well_labels = [1]
        else:
            well_labels = [i for i in range(1, well_count + 1)]

    else:
        num_rows = math.ceil((well_count * 3 / 2) ** (1 / 2))

        if robot == "True":  # order list by how the robot draws from the solvent wells
            if well_count == 96:
                if column_order is None:
                    column_order = ["A", "C", "E", "G", "B", "D", "F", "H"]
            if well_count == 24:
                if column_order is None:
                    column_order = ["A", "C", "B", "D"]

            total_columns = len(column_order)
            row_limit = math.ceil(well_count / total_columns)
            well_labels = [
                f"{col}{row}" for row in range(1, row_limit + 1) for col in column_order
            ][:well_count]

        else:  # chronological order for outcomes
            if well_count == 96:
                column_order = ["A", "B", "C", "D", "E", "F", "G", "H"]
            if well_count == 24:
                column_order = ["A", "B", "C", "D"]
            well_labels = [
                f"{col}{row}" for col in column_order for row in range(1, num_rows + 1)
            ][:well_count]

    return well_labels


def generate_vp_spec_file(reaction_volumes, reaction_parameters, plate, well_count):
    """Function generates an excel spredsheet to specify volumes and parameters for manual experiments.
    The spreadsheet can be downloaded via UI and uploaded once edited. Spreadsheet is then parsed to save 
    values into the database."""

    params = []
    values = []
    units = []
    exp_template = ExperimentTemplate.objects.get(uuid=reaction_volumes[0].uuid)
    for action_sequence in ActionSequence.objects.filter(experiment=exp_template):
        actions = Action.objects.filter(action_sequence=action_sequence)
        for action in actions:
            for a in action.action_def.parameter_def.all():
                if "dispense" in action.description.lower():
                    pass
                else:
                    desc = action.description + "-" + a.description
                    params.append(desc)
                    val = a.default_val.value
                    unit = a.default_val.unit
                    values.append(val)
                    units.append(unit)

    rxn_parameters = pd.DataFrame(
        {"Reaction Parameters": params, "Parameter Values": values, "Units": units,}
    )

    well_names = make_well_labels_list(
        well_count, column_order=["A", "C", "E", "G", "B", "D", "F", "H"], robot="True"
    )
    df_tray = pd.DataFrame({"Vial Site": well_names, "Labware ID:": plate})

    reagent_colnames = []
    reagents = ExperimentTemplate.objects.get(
        uuid=reaction_volumes[0].experiment_uuid
    ).reagent_templates.all()
    for r in reagents:
        reagent_colnames.append(r.description)

    reaction_volumes_output = pd.DataFrame(
        {reagent_col: [0] * len(df_tray) for reagent_col in reagent_colnames}
    )

    if reaction_volumes is not None:
        reaction_volumes_output = pd.concat(
            [df_tray["Vial Site"], reaction_volumes_output], axis=1
        )

    volume_units = pd.DataFrame({"Units": ["uL"]})
    volume_units[" "] = None
    volume_units.reindex(columns=[" ", "Units"])

    outframe = pd.concat(
        [  # df_tray['Vial Site'],
            reaction_volumes_output,
            # volume_units,
            volume_units.reindex(columns=[" ", "Units"]),
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
        experiment_template_reagent_template=ExperimentTemplate(uuid=exp_template_uuid)
    ):
        # include all reagents associated with experiment template as action sources/destinations
        source_choices.append(reagent.description)
        dest_choices.append(reagent.description)
    for vt in VesselType.objects.all():  # include all vessels as destinations
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
                        "hint": "destination material/vessel",
                        "options": {"items": [i for i in dest_choices]},
                    },
                ],
            }
        )
    return json_data


def experiment_copy(template_experiment_uuid, copy_experiment_description, vessel):
    # TODO: header/documentation

    # Get parent Experiment from template_experiment_uuid
    exp_template = ExperimentTemplate.objects.get(uuid=template_experiment_uuid)
    # experiment row creation, overwrites original experiment template object with new experiment object.
    # Makes an experiment template object parent
    exp_instance = ExperimentInstance(
        ref_uid=exp_template.ref_uid,
        parent=exp_template,
        owner=exp_template.owner,
        operator=exp_template.operator,
        lab=exp_template.lab,
    )

    # If copy_experiment_description null replace with "Copy of " + description from exp_get
    if copy_experiment_description is None:
        copy_experiment_description = "Copy of " + exp_instance.description

    exp_instance.description = copy_experiment_description
    # post
    exp_instance.save()

    # create old bom object based on experiment uuid
    template_boms = BillOfMaterials.objects.filter(experiment=template_experiment_uuid)
    for temp_bom in template_boms.iterator():
        # create copy for new bom
        instance_bom = deepcopy(temp_bom)
        # update new bom and update fields
        instance_bom.uuid = None
        instance_bom.experiment = None
        instance_bom.experiment_instance = exp_instance
        # post
        instance_bom.save()

        # Create old bom material object
        template_bom_mats = BomMaterial.objects.filter(bom=temp_bom.uuid)
        for temp_bom_mat in template_bom_mats:
            # copy for new bom material
            instance_bom_mat = deepcopy(temp_bom_mat)
            # update new bom material
            instance_bom_mat.uuid = None
            instance_bom_mat.bom = instance_bom
            # post
            instance_bom_mat.save()

    # Get all Experiment Workflow objects based on experiment template uuid
    experiment_action_sequence_filter = ExperimentActionSequence.objects.all().filter(
        experiment_template=exp_template
    )

    # itterate over them all and update workflow, experiment workflow, and workflowactionset(action, actionunit, parameter)
    for template_exp_wf in experiment_action_sequence_filter.iterator():
        # create new workflow for current object
        # this needs to be double checked to verify it works correctly
        # this_workflow = Workflow.objects.get(uuid=current_object.workflow.uuid)
        instance_workflow = template_exp_wf.action_sequence
        template_workflow = deepcopy(instance_workflow)
        # update uuid so it generates it's own uuid
        instance_workflow.uuid = None
        # this_workflow.experiment = exp_get
        # post
        instance_workflow.save()

        # create copy of current experiment workflow object from experiment_workflow_filter
        # this_experiment_workflow = current_object
        instance_exp_wf = ExperimentActionSequence(
            action_sequence=instance_workflow,
            experiment_instance=exp_instance,
            experiment_action_sequence_seq=template_exp_wf.experiment_action_sequence_seq,
        )
        # update experiment workflow uuid, workflow uuid, and experiment uuid for experiment workflow
        # this_experiment_workflow.uuid = None
        # this_experiment_workflow.workflow = this_workflow
        # this_experiment_workflow.experiment = exp_get
        # post
        instance_exp_wf.save()

        # create action query and loop through the actions and update
        # need to add loop
        template_actions = Action.objects.filter(action_sequence=template_workflow)
        for temp_action in template_actions.iterator():
            instance_action = deepcopy(temp_action)
            # create new uuid, workflow should already be correct, if it is not set workflow uuid to current workflow uuid
            instance_action.uuid = None
            instance_action.action_sequence = instance_workflow
            # post
            instance_action.save()

            # get all action units and create uuids for them and assign action uuid to action unit
            template_action_units = ActionUnit.objects.filter(action=temp_action)
            for current_action_unit in template_action_units.iterator():
                current_action_unit.uuid = None
                current_action_unit.action = instance_action
                current_action_unit.save()

            # get all parameters and create uuids for them and assign action uuid to each parameter

    # Iterate over all reagent-templates and create reagentintances and reagentinstancevalues
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
            for (
                reagent_material_value_template
            ) in reagent_material_template.reagent_material_value_template_rmt.all():
                reagent_material_value = ReagentMaterialValue(
                    reagent_material=reagent_material,
                    template=reagent_material_value_template,
                    description=reagent_material_value_template.description,
                )
                reagent_material_value.save()

    well_num = vessel.well_number
    col_order = vessel.column_order
    well_list = make_well_labels_list(well_num, col_order, robot="False")

    for outcome_template in exp_template.outcome_template_experiment_template.all():
        for label in well_list:
            outcome_instance = OutcomeInstance(
                outcome_template=outcome_template,
                experiment_instance=exp_instance,
                description=label,
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
