'''
Created on Mar 30, 2021

@author: jpannizzo
'''
from core.utilities.experiment_utils import hcl_mix, update_dispense_action_set, update_lsr_edoc
from core.models.view_tables import Edocument
import numpy as np

def liquid_solid_extraction(data, q3,experiment_copy_uuid,exp_name, exp_template):
    '''
    # logic for liquid solid extraction experiment
    '''
    #workflow for experiment
    related_exp = 'workflow__experiment_workflow_workflow__experiment'
    
    '''
    # q3 contains concentration logic
    # original code contained an if nested in a class within experiment.py
    # I don't believe it is necessary in order to run properly now that it is factored out
    # if there is an issue down the line uncomment the if...else and re-indent the logic in order to reimplement
    '''
    lsr_edoc = Edocument.objects.get(ref_edocument_uuid=exp_template.uuid, title='LSR file')
    xls_edoc = Edocument.objects.get(ref_edocument_uuid=exp_template.uuid, title='XLS file')

    hcl_vols, h2o_vols = hcl_mix(data['stock_concentration'],
                                 data['total_vol'],
                                 np.fromstring(data['hcl_concentrations'].strip(']['), sep=',')
                                 )
    h2o_dispense_action_set = WorkflowActionSet.objects.get(**{f'{related_exp}': experiment_copy_uuid,
                                                               'description__contains': 'H2O'})
    hcl_dispense_action_set = WorkflowActionSet.objects.get(**{f'{related_exp}': experiment_copy_uuid,
                                                               'description__contains': 'HCl'})
    update_dispense_action_set(h2o_dispense_action_set, h2o_vols)
    update_dispense_action_set(hcl_dispense_action_set, hcl_vols)
    new_lsr_pk, lsr_msg = update_lsr_edoc(lsr_edoc,
                                          experiment_copy_uuid,
                                          exp_name,
                                          vol_hcl=list(hcl_vols*1000),
                                          vol_h2o=list(h2o_vols*1000))
    #else:
    #    new_lsr_pk = None  
        
          
    return new_lsr_pk, lsr_msg