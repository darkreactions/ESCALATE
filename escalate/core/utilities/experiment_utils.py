"""
Created on Mar 29, 2021

"""
import numpy as np
from copy import deepcopy
import os
from tkinter.constants import CURRENT
from django.db.models import F
from django.db.models.query import QuerySet

from core.models.view_tables import (
    BomMaterial,
    Parameter,
    ExperimentTemplate,
    ExperimentInstance,
    ReagentMaterial,
    Reagent,
    Vessel,
    ReactionParameter,
    ActionSequence,
)
from core.custom_types import Val
from core.utilities.randomSampling import generateExperiments
from core.utilities.utils import make_well_labels_list


def update_dispense_action_set(dispense_action_set, volumes, unit="mL"):
    """Create a new action set based on the action set passed

    Args:
        dispense_action_set (Queryset): Queryset that contains the dispense actions
        volumes (list): List of volumes used to update the queryset
        unit (str, optional): Unit of volumes. Defaults to "mL".
    """

    dispense_action_set_params = deepcopy(dispense_action_set.__dict__)
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
    instance = ActionSequence(**dispense_action_set_params)
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


def supported_wfs():
    """
    # find template file names from experiment_templates dir, strips .py and .cpython from the files
    # and populates SUPPORTED_CREATE_WFS in experiment.py. Ignores __init___.py.
    # This prevents needing to hardcode template names
    """
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
    """Get a queryset that has data related to the given experiment

    Args:
        exp_uuid (str): UUID of the experiment
        template (bool, optional): Whether the experiment is a template or not. Defaults to True.

    Returns:
        QuerySet: Returns action parameters related to the experiment
    """

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
    Return vessels with no well numbers. This will return all the parent vessels (i.e. plates, not wells).
    """
    vessel_q = Vessel.objects.filter(well_number__isnull=True)
    return vessel_q


def save_reaction_parameters(
    exp_template, rp_value, rp_unit, rp_type, rp_label, experiment_copy_uuid
):
    """Saves reaction parameters to database table

    Args:
        exp_template (str): Experiment template UUID
        rp_value (Any): Value of reaction parameter
        rp_unit (str): Unit of reaction parameter
        rp_type (str): Type of reaction parameter
        rp_label (str): Label of parameter
        experiment_copy_uuid (str): UUID of the experiment copt

    Returns:
        _type_: _description_
    """

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


def prepare_reagents(reagent_formset):
    """[summary]

    Args:
        reagent_formset([Formset]_: contains forms with reagent/concentration data

    Returns:
       [dictionary]: keys are reagent descriptions and values are desired concentrations
    """
    reagents = {}
    current_mat_list = reagent_formset.form_kwargs["mat_types_list"]
    for num, element in enumerate(current_mat_list):
        reagents[element.description] = reagent_formset.cleaned_data[num][
            "desired_concentration"
        ].value
    return reagents


def generate_experiments_and_save(
    exp_template,
    experiment_copy_uuid,
    reagent_template_names,
    reagentDefs,
    num_of_automated_experiments,
    num_of_manual_experiments,
    dead_volume,
    total_volume,
    vessel,
):
    """
    Generates random experiments using sampler and saves volumes
    associated with dispense actions in an experiment template
    """
    if (
        exp_template.description == "Workflow 3"
    ):  # exclude antisolvent from sampling for wf3 only
        desired_volume = generateExperiments(
            reagent_template_names[0:-1],
            reagentDefs[0:-1],
            num_of_automated_experiments,
            finalVolume=str(total_volume.value) + " " + total_volume.unit,
        )
        desired_volume[reagent_template_names[-1]] = [
            800.0
            for i in range(
                num_of_automated_experiments
            )  # default volume for antisolvent is 800 uL
        ]
    else:

        desired_volume = generateExperiments(
            reagent_template_names,
            reagentDefs,
            num_of_automated_experiments,
            finalVolume=str(total_volume.value) + " " + total_volume.unit,
        )

    # retrieve q1 information to update
    q1 = get_action_parameter_querysets(experiment_copy_uuid, template=False)

    # This loop sums the volume of all generated experiment for each reagent and saves to database
    # Also saves dead volume if passed to function
    reagents = Reagent.objects.filter(experiment=experiment_copy_uuid)
    for reagent in reagents:
        # label = reagent_template_reagent_map[reagent.template.description]
        prop = reagent.property_r.get(
            property_template__description__icontains="total volume"
        )
        prop.nominal_value.value += sum(desired_volume[reagent.template.description])
        prop.nominal_value.unit = "uL"
        prop.save()
        if dead_volume is not None:
            dv_prop = reagent.property_r.get(
                property_template__description__icontains="dead volume"
            )
            dv_prop.nominal_value = dead_volume
            dv_prop.save()

    # This loop adds individual well volmes to each action in the database
    # without overwriting manual entries for experiments that have both automated and manual components

    # for action_description, (reagent_name, mult_factor) in action_reagent_map.items():
    well_list = make_well_labels_list(
        well_count=vessel.well_number,
        column_order=vessel.column_order,
        robot="True",
    )

    for reagent_name in reagent_template_names:
        saved_actions = []
        for i, vial in enumerate(well_list):
            action = (
                q1.filter(action_unit_description__icontains=reagent_name)
                .filter(action_unit_description__icontains="dispense")
                .filter(action_unit_description__endswith=vial)
                .first()
            )

            # get actions from q1 based on keys in action_reagent_map

            # If number of experiments requested is < actions only choose the first n actions
            # Otherwise choose all
            # actions = actions[:num_of_experiments] if num_of_experiments < len(actions) else actions
            # for i, action in enumerate(actions):
            if action is not None:
                saved_actions.append(action)

        for i, action in enumerate(saved_actions[num_of_manual_experiments:]):

            parameter = Parameter.objects.get(uuid=action.parameter_uuid)
            # action.parameter_value.value = desired_volume[reagent_name][i] * mult_factor
            try:
                parameter.parameter_val_nominal.value = desired_volume[reagent_name][
                    i
                ]  # * mult_factor
            except IndexError:
                parameter.parameter_val_nominal.value = 0.0
            parameter.save()

    # conc_to_amount(experiment_copy_uuid)

    return q1


def save_manual_parameters(df, exp_template, experiment_copy_uuid):
    """[summary]

    Args:
        df: Pandas dataframe from uploaded excel spreadsheet with volume/parameter data
        exp_template: ExperimentTemplate object of the experiment template to retrieve
        experiment_copy_uuid ([str]): UUID of the experiment to retrieve

    Returns:
        N/A
        saves parameters from df into database
    """

    for i, param in enumerate(df["Reaction Parameters"]):
        if type(param) == str:
            rp = ReactionParameter.objects.create(
                experiment_template=exp_template,
                # organization = organization,
                value=df["Parameter Values"][i],
                unit=df["Units"][i],
                # type=rp_type,
                description=param.split("-")[1],
                experiment_uuid=experiment_copy_uuid,
            )
            rp.save()
            # return rp


def save_manual_volumes(
    df, experiment_copy_uuid, reagent_template_names, dead_volume, vessel
):
    """[summary]

    Args:
        df: Pandas dataframe from uploaded excel spreadsheet with volume/parameter data
        experiment_copy_uuid ([str]): UUID of the experiment to retrieve
        reagent_template_names ([dict]): dictionary of reagent template names ([str]) for the experiment
        dead_volume: ValField entry for dead volume for the experiment

    Returns:
        N/A
        saves volumes from df into database
    """

    q1 = get_action_parameter_querysets(experiment_copy_uuid, template=False)
    # experiment = ExperimentInstance.objects.get(uuid=experiment_copy_uuid)
    reagents = Reagent.objects.filter(experiment=experiment_copy_uuid)

    well_list = []
    for well in df["Vial Site"]:
        well_list.append(well)

    volume_by_well = {}
    # for reagent in reagents:
    for reagent_name in reagent_template_names:
        total_volume = 0

        for i, vial in enumerate(well_list):
            action = (
                q1.filter(action_unit_description__icontains=reagent_name)
                .filter(action_unit_description__icontains="dispense")
                .filter(action_unit_description__endswith=vial)
                .first()
            )
            if action is not None:
                parameter = Parameter.objects.get(uuid=action.parameter_uuid)
                # action.parameter_value.value = desired_volume[reagent_name][i] * mult_factor

                if (
                    type(df[reagent_name][i]) == np.int64
                ):  # check that volumes are non-negative floats
                    if df[reagent_name][i] >= 0.0:
                        parameter.parameter_val_nominal.value = df[reagent_name][i]

                        if vial not in volume_by_well.keys():
                            volume_by_well[vial] = df[reagent_name][i]
                        else:
                            volume_by_well[vial] += df[reagent_name][i]
                else:
                    raise TypeError(
                        "Volumes input in the manual specification file must be numbers greater than or equal to 0"
                    )
                parameter.parameter_val_nominal.unit = df["Units"][0]
                # parameter.parameter_val_nominal.value = desired_volume[reagent_name][i]
                parameter.save()

            total_volume += df[reagent_name][i]

            for reagent in reagents:
                if reagent.template.description == reagent_name:
                    prop = reagent.property_r.get(
                        property_template__description__icontains="total volume"
                    )
                    prop.nominal_value.value = total_volume
                    prop.nominal_value.unit = df["Units"][0]
                    prop.save()
                    if dead_volume is not None:
                        dv_prop = reagent.property_r.get(
                            property_template__description__icontains="dead volume"
                        )
                        dv_prop.nominal_value = dead_volume
                        dv_prop.save()

    if vessel.total_volume is not None:
        for vial, vol in volume_by_well.items():
            if vol > vessel.total_volume:
                raise ValueError(
                    "Total volume specified for vial {} exceeds capacity {}".format(
                        vial, vessel.total_volume
                    )
                )
