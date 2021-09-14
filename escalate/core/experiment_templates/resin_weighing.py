'''
Created on Mar 30, 2021

@author: jpannizzo
'''
from core.utilities.experiment_utils import update_lsr_edoc
from core.models.view_tables import WorkflowActionSet, Edocument

def resin_weighing(data, q1, experiment_copy_uuid, exp_name, exp_template):
    '''
    # logic for resin weighing experiment
    '''
    lsr_edoc = Edocument.objects.get(ref_edocument_uuid=exp_template.uuid, title='LSR file')
    xls_edoc = Edocument.objects.get(ref_edocument_uuid=exp_template.uuid, title='XLS file')
    #workflow for experiment
    related_exp = 'workflow__experiment_workflow_workflow__experiment'
    resin_dispense_action_set = WorkflowActionSet.objects.get(**{f'{related_exp}': experiment_copy_uuid,
                                                                 'description__contains': 'Dispense Resin'})
    #generate new lsr pk for success and lsr msg to report any errors
    new_lsr_pk, lsr_msg = update_lsr_edoc(lsr_edoc,
                                          experiment_copy_uuid,
                                          exp_name,
                                          resin_amt=resin_dispense_action_set.parameter_val_nominal[0].value)
    
    return new_lsr_pk, lsr_msg