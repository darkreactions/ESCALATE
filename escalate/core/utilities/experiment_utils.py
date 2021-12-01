"""
Created on Mar 29, 2021

@author: jpannizzo
"""
import numpy as np
from copy import deepcopy
import os
from tkinter.constants import CURRENT
from django.db.models import F, Value
from django.db.models.query import QuerySet

from core.models.view_tables import (
    BomMaterial,
    Action,
    Parameter,
    ActionUnit,
    ExperimentTemplate,
    ExperimentInstance,
    ReagentMaterial,
    Reagent,
    Property,
    Vessel,
    ExperimentActionSequence,
    ReactionParameter,
)
from core.custom_types import Val
from core.models.core_tables import RetUUIDField
from core.utilities.randomSampling import generateExperiments
from core.utilities.wf1_utils import make_well_list
from .calculations import conc_to_amount


def hcl_mix(stock_concentration, solution_volume, target_concentrations):
    """
    # define the hcl vols and h2o vols
    """
    hcl_vols = (target_concentrations * solution_volume) / stock_concentration
    h2o_vols = solution_volume - hcl_vols
    return hcl_vols, h2o_vols


def update_dispense_action_set(dispense_action_set, volumes, unit="mL"):
    dispense_action_set_params = deepcopy(dispense_action_set.__dict__)
    """
    # deletes old action set and updates the action set
    """
    # delete keys from dispense action set that are not needed for creating a new action set
    delete_keys = [
        "uuid",
        "_state",
        "_prefetched_objects_cache",
        # the below keys are the annotations from q1..q3
        "object_description",
        "object_uuid",
        "parameter_def_description",
        "parameter_uuid",
        "parameter_value",
        "experiment_uuid",
        "experiment_description",
        "workflow_seq",
    ]
    [dispense_action_set_params.pop(k, None) for k in delete_keys]

    # delete the old action set
    dispense_action_set.delete()

    if isinstance(volumes, np.ndarray):
        # recall: needs to be a list of Val
        v = [
            Val.from_dict({"type": "num", "value": vol, "unit": unit})
            for vol in volumes
        ]
    elif isinstance(volumes, Val):
        v = [volumes]
    dispense_action_set_params["calculation_id"] = None
    dispense_action_set_params["parameter_val_nominal"] = v
    instance = WorkflowActionSet(**dispense_action_set_params)
    instance.save()


def update_lsr_edoc(
    template_edoc, experiment_copy_uuid, experiment_copy_name, **kwargs
):
    """Copy LSR file from the experiment template, update tagged maps with kwargs, save to experiment copy
    Returns the uuid if completed successfully, else none
    """
    from LSRGenerator.generate import generate_lsr_design
    import xml.etree.ElementTree as ET

    # copy the template edoc
    template_edoc.pk = None  # this effectively creates a copy of the original edoc

    # convert to format LSRGenerator understands
    lsr_template = template_edoc.edocument.tobytes().decode("utf-16")
    lsr_template = ET.ElementTree(ET.fromstring(lsr_template))

    # populate LSR design with kwargs, handling failure
    new_lsr_uuid = None
    message = None
    try:
        lsr_design = generate_lsr_design(lsr_template, **kwargs)
    except Exception as e:
        message = str(e)
    else:
        lsr_design = ET.tostring(lsr_design.getroot(), encoding="utf-16")
        # associate with the experiment copy and save
        template_edoc.ref_edocument_uuid = experiment_copy_uuid
        template_edoc.edocument = lsr_design
        template_edoc.filename = experiment_copy_name + ".lsr"
        template_edoc.save()
        new_lsr_uuid = template_edoc.pk

    return new_lsr_uuid, message


"""
# find template file names from experiment_templates dir, strips .py and .cpython from the files
# and populates SUPPORTED_CREATE_WFS in experiment.py. Ignores __init___.py.
# This prevents needing to hardcode template names
"""


def supported_wfs():
    # current_path = .../.../ESCALTE/escalate
    current_path = os.getcwd()
    # core_path = .../.../ESCLATE/escalate/core
    core_path = os.path.join(current_path, "core")
    # template_path = .../.../ESCALATE/escalate/core/experiment_templates
    template_path = os.path.join(core_path, "experiment_templates")

    template_list = []
    for r, d, f in os.walk(template_path):
        for file in f:
            if ".py" in file:
                if not "__init__" in file and not ".cpython" in file:
                    # remove .py from filename
                    outfile = os.path.splitext(file)[0]
                    template_list.append(outfile)

    return template_list


def get_action_parameter_querysets(exp_uuid: str, template=True) -> QuerySet:
    related_exp = "workflow__experiment_workflow_workflow__experiment"
    # related_exp_wf = 'workflow__experiment_workflow_workflow'
    # factored out until new workflow changes are implemented

    # Related action unit
    # related_au = 'workflow__action_workflow__action_unit_action'
    # related_a = 'workflow__action_workflow'
    related_au = "action_sequence__action_action_sequence__action_unit_action"
    related_a = "action_sequence__action_action_sequence"
    related_exp_wf = "action_sequence__experiment_action_sequence_as"

    if template:
        model = ExperimentTemplate
    else:
        model = ExperimentInstance

    q1: QuerySet = (
        model.objects.filter(uuid=exp_uuid)
        .prefetch_related(related_au)
        .annotate(object_description=F(f"{related_a}__description"))
        .annotate(object_def_description=F(f"{related_a}__action_def__description"))
        .annotate(object_uuid=F(f"{related_a}__uuid"))
        .annotate(action_unit_description=F(f"{related_au}__description"))
        .annotate(
            action_unit_source=F(f"{related_au}__source_material__vessel__description")
        )
        .annotate(
            action_unit_destination=F(
                f"{related_au}__destination_material__vessel__description"
            )
        )
        .annotate(parameter_uuid=F(f"{related_au}__parameter_action_unit"))
        .annotate(
            parameter_value=F(
                f"{related_au}__parameter_action_unit__parameter_val_nominal"
            )
        )
        .annotate(
            parameter_value_actual=F(
                f"{related_au}__parameter_action_unit__parameter_val_actual"
            )
        )
        .annotate(
            parameter_def_description=F(
                f"{related_au}__parameter_action_unit__parameter_def__description"
            )
        )
        .annotate(experiment_uuid=F("uuid"))
        .annotate(experiment_description=F("description"))
        .annotate(workflow_seq=F(f"{related_exp_wf}__experiment_action_sequence_seq"))
    )  # .filter(workflow_action_set__isnull=True).prefetch_related(f'{related_exp}')

    return q1


def get_material_querysets(exp_uuid, template=True):
    """[summary]

    Args:
        exp_uuid ([str]): UUID of the experiment to retrieve

    Returns:
        [Queryset]: Queryset that contains the experiment data
    """
    if template:
        exp_relation = "bom__experiment"
    else:
        exp_relation = "bom__experiment_instance"

    # bom__experiment=exp_uuid
    mat_q = (
        BomMaterial.objects.filter(**{exp_relation: exp_uuid})
        .only("uuid")
        .annotate(object_description=F("description"))
        .annotate(object_uuid=F("uuid"))
        .annotate(experiment_uuid=F(f"{exp_relation}__uuid"))
        .annotate(experiment_description=F(f"{exp_relation}__description"))
        .prefetch_related(f"{exp_relation}")
    )

    return mat_q


def get_vessel_querysets():
    """
    Return vessels with no well numbers. This will return all the parent vessels.
    """
    vessel_q = Vessel.objects.filter(well_number__isnull=True)
    return vessel_q


def save_reaction_parameters(
    exp_template, rp_value, rp_unit, rp_type, rp_label, experiment_copy_uuid
):
    # for reaction_parameter_label, reaction_parameter_form in reaction_parameter_labels
    # rp_label might be a list so need to itterate over and pass to this
    rp = ReactionParameter.objects.create(
        experiment_template=exp_template,
        # organization = organization,
        value=rp_value,
        unit=rp_unit,
        type=rp_type,
        description=rp_label,
        experiment_uuid=experiment_copy_uuid,
    )
    return rp


def save_parameter(rp_uuid, rp_value, rp_unit):
    """
    get specific parameter via uuid that was saved as a hidden field.
    update the value and unit for the nominal field
    """
    param_q = Parameter.objects.get(uuid=rp_uuid)
    param_q.parameter_val_nominal.value = rp_value
    param_q.parameter_val_nominal.unit = rp_unit
    param_q.save()
    return param_q


def get_reagent_querysets(exp_uuid):
    """[summary]

    Args:
        exp_uuid ([str]): UUID of the experiment to retrieve

    Returns:
        [Queryset]: Queryset that contains the reagent data
    """
    reagent_q = ReagentMaterial.objects.filter(experiment__uuid=exp_uuid)

    return reagent_q


def prepare_reagents(reagent_formset, exp_concentrations):

    current_mat_list = reagent_formset.form_kwargs["mat_types_list"]
    if len(current_mat_list) == 1:
        if "acid" in (current_mat_list[0].description).lower():
            # reagent 7, Acid
            concentration1 = reagent_formset.cleaned_data[0][
                "desired_concentration"
            ].value
            #if concentration1 <0:
                #raise TypeError(
                #"Error: {} is an invalid concentration for {}. Should be a non-negative number".format(concentration1, current_mat_list[0].description))
            exp_concentrations["Reagent 7"] = [0, 0, concentration1, 0]
        elif "solvent" in (current_mat_list[0].description).lower():
            # reagent 1, Solvent
            concentration1 = reagent_formset.cleaned_data[0][
                "desired_concentration"
            ].value
            exp_concentrations["Reagent 1"] = [0, concentration1, 0, 0]
    elif len(current_mat_list) == 2:
        # reagent 2, Stock A
        for element in current_mat_list:
            if "organic" in (element.description).lower():
                # organic
                concentration1 = reagent_formset.cleaned_data[0][
                    "desired_concentration"
                ].value
            elif "solvent" in (element.description).lower():
                # solvent
                concentration2 = reagent_formset.cleaned_data[1][
                    "desired_concentration"
                ].value
        exp_concentrations["Reagent 2"] = [concentration1, concentration2, 0, 0]
    elif len(current_mat_list) == 3:
        # reagent 3, Stock B
        for element in current_mat_list:
            if "inorganic" in (element.description).lower():
                # inorganic
                concentration1 = reagent_formset.cleaned_data[0][
                    "desired_concentration"
                ].value
            elif "organic" in (element.description).lower():
                # organic
                concentration2 = reagent_formset.cleaned_data[1][
                    "desired_concentration"
                ].value
            elif "solvent" in (element.description).lower():
                # solvent
                concentration3 = reagent_formset.cleaned_data[2][
                    "desired_concentration"
                ].value
        exp_concentrations["Reagent 3"] = [
            concentration2,
            concentration3,
            0,
            concentration1,
        ]

    return exp_concentrations


def generate_experiments_and_save(
    experiment_copy_uuid, exp_concentrations, num_of_experiments, dead_volume
):
    """
    Generates random experiments using sampler and saves it to
    different actions hard coded in action_reagent_map
    TODO: Change ReagentTemplate descriptions or change here to standard names
    In ReagentTemplate a reagent is called organic, inorganic, solvent
    In action it is called stock a
    In the mapper it is called 'Reagent 2'
    """
    desired_volume = generateExperiments(
        #reagent_template_names,
        exp_concentrations,
        #["Reagent1", "Reagent2", "Reagent3", "Reagent7"],
        num_of_experiments,
    )
    # desired_volume = generateExperiments(reagents, descriptions, num_of_experiments)
    # retrieve q1 information to update
    q1 = get_action_parameter_querysets(experiment_copy_uuid, template=False)
    experiment = ExperimentInstance.objects.get(uuid=experiment_copy_uuid)

    # create counters for acid, solvent, stock a, stock b to keep track of current element in those lists
    if "workflow 1" in experiment.parent.description.lower():
        action_reagent_map = {
            "dispense solvent": ("Reagent 1", 1.0),
            "dispense acid volume 1": ("Reagent 7", 0.5),
            "dispense acid volume 2": ("Reagent 7", 0.5),
            "dispense stock a": ("Reagent 2", 1.0),
            "dispense stock b": ("Reagent 3", 1.0),
        }

        reagent_template_reagent_map = {
            "Reagent 1 - Solvent": "Reagent 1",
            "Reagent 7 - Acid": "Reagent 7",
            "Reagent 2 - Stock A": "Reagent 2",
            "Reagent 3 - Stock B": "Reagent 3",
        }
    elif "workflow 3" in experiment.parent.description.lower():
        action_reagent_map = {
            "dispense solvent": ("Reagent 1", 1.0),
            "dispense acid volume 1": ("Reagent 7", 0.5),
            "dispense acid volume 2": ("Reagent 7", 0.5),
            "dispense stock a": ("Reagent 2", 1.0),
            "dispense stock b": ("Reagent 3", 1.0),
            "dispense antisolvent": ("Reagent 9", 1.0),
        }

        reagent_template_reagent_map = {
            "Reagent 1 - Solvent": "Reagent 1",
            "Reagent 7 - Acid": "Reagent 7",
            "Reagent 2 - Stock A": "Reagent 2",
            "Reagent 3 - Stock B": "Reagent 3",
            "Reagent 9 - Antisolvent": "Reagent 9",
        }
    # This loop sums the volume of all generated experiment for each reagent and saves to database
    # Also saves dead volume if passed to function
    reagents = Reagent.objects.filter(experiment=experiment_copy_uuid)
    for reagent in reagents:
        label = reagent_template_reagent_map[reagent.template.description]
        prop = reagent.property_r.get(
            property_template__description__icontains="total volume"
        )
        prop.nominal_value.value = sum(desired_volume[label])
        prop.nominal_value.unit = "uL"
        prop.save()
        if dead_volume is not None:
            dv_prop = reagent.property_r.get(
                property_template__description__icontains="dead volume"
            )
            dv_prop.nominal_value = dead_volume
            dv_prop.save()

    # This loop adds individual well volmes to each action in the database
    for action_description, (reagent_name, mult_factor) in action_reagent_map.items():
        if experiment.parent.ref_uid == "workflow_1":
            well_list = make_well_list(
                container_name="Symyx_96_well_0003",
                well_count=num_of_experiments,
                column_order=["A", "C", "E", "G", "B", "D", "F", "H"],
                total_columns=8,
            )["Vial Site"]
        elif experiment.parent.ref_uid == "perovskite_demo":
            well_list = make_well_list(
                container_name="Symyx_96_well_0003", well_count=num_of_experiments
            )["Vial Site"]

        for i, vial in enumerate(well_list):
            # get actions from q1 based on keys in action_reagent_map
            if experiment.parent.ref_uid == "workflow_1":
                action = q1.get(
                    action_unit_description__icontains=action_description,
                    action_unit_description__endswith=vial,
                )
            elif experiment.parent.ref_uid == "perovskite_demo":
                action = q1.get(
                    object_description__icontains=action_description,
                    object_description__contains=vial,
                )

            # If number of experiments requested is < actions only choose the first n actions
            # Otherwise choose all
            # actions = actions[:num_of_experiments] if num_of_experiments < len(actions) else actions
            # for i, action in enumerate(actions):
            parameter = Parameter.objects.get(uuid=action.parameter_uuid)
            # action.parameter_value.value = desired_volume[reagent_name][i] * mult_factor
            parameter.parameter_val_nominal.value = (
                desired_volume[reagent_name][i] * mult_factor
            )
            parameter.save()

    #try:
    conc_to_amount(experiment_copy_uuid)
    #except ValueError:
        #raise ValueError('Invalid phase data')
        #print(ValueError)

    return q1


def save_manual_volumes(df, experiment_copy_uuid, dead_volume):
    q1 = get_action_parameter_querysets(experiment_copy_uuid, template=False)
    experiment = ExperimentInstance.objects.get(uuid=experiment_copy_uuid)
    reagents = Reagent.objects.filter(experiment=experiment_copy_uuid)

    if "workflow 1" in experiment.parent.description.lower():
    
        reagent_action_map = {
            "Reagent1 (ul)": "dispense solvent",
            "Reagent7 (ul)": "dispense acid volume 1",
            "Reagent8 (ul)": "dispense acid volume 2",
            "Reagent2 (ul)": "dispense stock a",
            "Reagent3 (ul)": "dispense stock b",
        }

        reagent_template_robot_map = {
                "Reagent 1 - Solvent": "Reagent1 (ul)",
                "Reagent 7 - Acid": "Reagent7 (ul)",
                "Reagent 2 - Stock A": "Reagent2 (ul)",
                "Reagent 3 - Stock B": "Reagent3 (ul)",
            }
    
    elif "workflow 3" in experiment.parent.description.lower():
        reagent_action_map = {
            "Reagent1 (ul)": "dispense solvent",
            "Reagent7 (ul)": "dispense acid volume 1",
            "Reagent8 (ul)": "dispense acid volume 2",
            "Reagent2 (ul)": "dispense stock a",
            "Reagent3 (ul)": "dispense stock b",
            "Reagent9 (ul)": "dispense antisolvent",
        }

        reagent_template_robot_map = {
                "Reagent 1 - Solvent": "Reagent1 (ul)",
                "Reagent 7 - Acid": "Reagent7 (ul)",
                "Reagent 2 - Stock A": "Reagent2 (ul)",
                "Reagent 3 - Stock B": "Reagent3 (ul)",
                "Reagent 9 - Antisolvent": "Reagent9 (ul)",
            }

    for reagent_name, action_description in reagent_action_map.items():
        well_list = []
        for well in df["Vial Site"]:
            well_list.append(well)
        
        total_volume=0

        for i, vial in enumerate(well_list):
            # get actions from q1 based on keys in action_reagent_map
            if experiment.parent.ref_uid == "workflow_1" or experiment.parent.ref_uid == "workflow_3":
                action = q1.get(
                    action_unit_description__icontains=action_description,
                    action_unit_description__endswith=vial,
                )
            elif experiment.parent.ref_uid == "perovskite_demo":
                action = q1.get(
                    object_description__icontains=action_description,
                    object_description__endswith=vial,
                )

            # If number of experiments requested is < actions only choose the first n actions
            # Otherwise choose all
            # actions = actions[:num_of_experiments] if num_of_experiments < len(actions) else actions
            # for i, action in enumerate(actions):
            parameter = Parameter.objects.get(uuid=action.parameter_uuid)
            # action.parameter_value.value = desired_volume[reagent_name][i] * mult_factor
            parameter.parameter_val_nominal.value = df[reagent_name][i]
            # parameter.parameter_val_nominal.value = desired_volume[reagent_name][i]
            parameter.save()
            total_volume+=df[reagent_name][i]
        
        for reagent in reagents:
            if reagent_name == reagent_template_robot_map[reagent.template.description]:
            #if robot_api_map[reagent_name]== reagent.description:
        
                prop = reagent.property_r.get(
                        property_template__description__icontains="total volume"
                    )
                prop.nominal_value.value = total_volume
                prop.nominal_value.unit = "uL"
                prop.save()
                if dead_volume is not None:
                    dv_prop = reagent.property_r.get(
                        property_template__description__icontains="dead volume"
                    )
                    dv_prop.nominal_value = dead_volume
                    dv_prop.save()
