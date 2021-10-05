'''
Created on Mar 29, 2021

@author: jpannizzo
'''
import numpy as np
from copy import deepcopy
import os
from tkinter.constants import CURRENT
from django.db.models import F, Value

from core.models.view_tables import (WorkflowActionSet, BomMaterial, Action, 
                                            ActionUnit, ExperimentTemplate, 
                                            ExperimentInstance, ReagentMaterialInstance)
from core.custom_types import Val
from core.models.core_tables import RetUUIDField


def hcl_mix(stock_concentration, solution_volume, target_concentrations):
    '''
    # define the hcl vols and h2o vols
    '''
    hcl_vols = (target_concentrations * solution_volume) / stock_concentration
    h2o_vols = solution_volume - hcl_vols
    return hcl_vols, h2o_vols


def update_dispense_action_set(dispense_action_set, volumes, unit='mL'):
    dispense_action_set_params = deepcopy(dispense_action_set.__dict__)
    '''
    # deletes old action set and updates the action set
    '''
    # delete keys from dispense action set that are not needed for creating a new action set
    delete_keys = ['uuid', '_state', '_prefetched_objects_cache',
                   # the below keys are the annotations from q1..q3
                   'object_description', 'object_uuid', 'parameter_def_description', 'parameter_uuid',
                   'parameter_value', 'experiment_uuid', 'experiment_description', 'workflow_seq'
                   ]
    [dispense_action_set_params.pop(k, None) for k in delete_keys]

    # delete the old action set
    dispense_action_set.delete()

    if isinstance(volumes, np.ndarray):
        #recall: needs to be a list of Val
        v = [Val.from_dict({'type': 'num', 'value': vol, 'unit': unit}) for vol in volumes]
    elif isinstance(volumes, Val):
        v = [volumes]
    dispense_action_set_params['calculation_id'] = None
    dispense_action_set_params['parameter_val_nominal'] = v
    instance = WorkflowActionSet(**dispense_action_set_params)
    instance.save()

def update_lsr_edoc(template_edoc,  experiment_copy_uuid, experiment_copy_name, **kwargs):
    """Copy LSR file from the experiment template, update tagged maps with kwargs, save to experiment copy
    Returns the uuid if completed successfully, else none
    """
    from LSRGenerator.generate import generate_lsr_design
    import xml.etree.ElementTree as ET

    # copy the template edoc
    template_edoc.pk = None # this effectively creates a copy of the original edoc

    # convert to format LSRGenerator understands
    lsr_template = template_edoc.edocument.tobytes().decode('utf-16')
    lsr_template = ET.ElementTree(ET.fromstring(lsr_template))

    # populate LSR design with kwargs, handling failure
    new_lsr_uuid = None
    message = None
    try:
        lsr_design = generate_lsr_design(lsr_template, **kwargs)
    except Exception as e:
        message = str(e)
    else:
        lsr_design = ET.tostring(lsr_design.getroot(), encoding='utf-16')
        # associate with the experiment copy and save
        template_edoc.ref_edocument_uuid = experiment_copy_uuid
        template_edoc.edocument = lsr_design
        template_edoc.filename = experiment_copy_name + '.lsr'
        template_edoc.save()
        new_lsr_uuid = template_edoc.pk

    return new_lsr_uuid, message

'''
# find template file names from experiment_templates dir, strips .py and .cpython from the files
# and populates SUPPORTED_CREATE_WFS in experiment.py. Ignores __init___.py.
# This prevents needing to hardcode template names
'''
def supported_wfs():
    #current_path = .../.../ESCALTE/escalate
    current_path = os.getcwd()
    #core_path = .../.../ESCLATE/escalate/core
    core_path = os.path.join(current_path,'core')
    #template_path = .../.../ESCALATE/escalate/core/experiment_templates
    template_path = os.path.join(core_path,'experiment_templates')

    template_list = []
    for r, d, f in os.walk(template_path):
        for file in f:
            if '.py' in file:
                if not "__init__" in file and not ".cpython" in file:
                    #remove .py from filename
                    outfile = os.path.splitext(file)[0]
                    template_list.append(outfile)
    
    return template_list

def get_action_parameter_querysets(exp_uuid, template=True):
    related_exp = 'workflow__experiment_workflow_workflow__experiment'
    related_exp_wf = 'workflow__experiment_workflow_workflow'
    #factored out until new workflow changes are implemented

    if template:
        model = ExperimentTemplate
    else:
        model = ExperimentInstance

    q1 = model.objects.filter(uuid=exp_uuid).prefetch_related('workflow__action_workflow__action_unit_action').annotate(
                object_description=F('workflow__action_workflow__description')).annotate(
                object_def_description=F('workflow__action_workflow__action_def__description')).annotate(
                object_uuid=F('workflow__action_workflow__uuid')).annotate(
                parameter_uuid=F('workflow__action_workflow__action_unit_action__parameter_action_unit')).annotate(
                parameter_value=F('workflow__action_workflow__action_unit_action__parameter_action_unit__parameter_val_nominal')).annotate(
                parameter_value_actual=F('workflow__action_workflow__action_unit_action__parameter_action_unit__parameter_val_actual')).annotate(
                parameter_def_description=F('workflow__action_workflow__action_unit_action__parameter_action_unit__parameter_def__description')).annotate(
                experiment_uuid=F('uuid')).annotate(
                experiment_description=F('description')).annotate(
                workflow_seq=F(f'{related_exp_wf}__experiment_workflow_seq'
                ))#.filter(workflow_action_set__isnull=True).prefetch_related(f'{related_exp}')
    
    return q1


def get_material_querysets(exp_uuid, template=True):
    """[summary]

    Args:
        exp_uuid ([str]): UUID of the experiment to retrieve

    Returns:
        [Queryset]: Queryset that contains the experiment data
    """
    if template:
        exp_relation = 'bom__experiment'
    else:
        exp_relation = 'bom__experiment_instance'

    #bom__experiment=exp_uuid
    mat_q = BomMaterial.objects.filter(**{exp_relation: exp_uuid}).only(
                        'uuid').annotate(
                        object_description=F('description')).annotate(
                        object_uuid=F('uuid')).annotate(
                        experiment_uuid=F(f'{exp_relation}__uuid')).annotate(
                        experiment_description=F(f'{exp_relation}__description')).prefetch_related(f'{exp_relation}')
    
    return mat_q

def get_reagent_querysets(exp_uuid):
    """[summary]

    Args:
        exp_uuid ([str]): UUID of the experiment to retrieve

    Returns:
        [Queryset]: Queryset that contains the reagent data
    """ 
    '''
    reagent_q = ReagentInstance.objects.filter(experiment__uuid=exp_uuid).annotate(
                object_uuid=F('uuid')).annotate(
                object_description=F('description')).annotate(
                instance_uuid=F('reagent_instance_value_reagent_instance__uuid')).annotate(
                instance_value=F('reagent_instance_value_reagent_instance__nominal_value')).annotate(
                instance_value_actual=F('reagent_instance_value_reagent_instance__actual_value')).annotate(
                instance_material_type_id=F('reagent_instance_value_reagent_instance__material_type')).annotate(
                instance_description=F('reagent_instance_value_reagent_instance__description')).annotate(
                experiment_uuid=F('experiment__uuid')).annotate(
                experiment_description=F('experiment__description'))#.annotate(
    '''
    reagent_q = ReagentMaterialInstance.objects.filter(experiment__uuid=exp_uuid)
    """
    .annotate(
    mat_type=F('material_type')).annotate(
    value_nominal=F('nominal_value')).annotate(
    value_actual=F('actual_value')).annotate(
    parent_uuid=F('reagent_instance__uuid'))
    """
    
    return reagent_q
                