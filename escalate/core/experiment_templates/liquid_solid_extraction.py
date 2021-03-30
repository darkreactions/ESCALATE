'''
Created on Mar 30, 2021

@author: jpannizzo
'''
from core.utilities.experiment_utils import hcl_mix, update_dispense_action_set, update_lsr_edoc
from core.models.view_tables import WorkflowActionSet
import numpy as np

def liquid_solid_extraction(q3_formset,q3,experiment_copy_uuid,lsr_edoc,exp_name):
    '''
    # logic for liquid solid extraction experiment
    '''
    #workflow for experiment
    related_exp = 'workflow__experiment_workflow_workflow__experiment'
    
    # q3 contains concentration logic
    # POSSIBLY REMOVE IF STATEMENT
    if any([f.has_changed() for f in q3_formset]):
        data = {}  # Stick form data into this dict
        for i, form in enumerate(q3_formset):
            if form.is_valid():
                query = q3[i]
                data[query.parameter_def_description] = form.cleaned_data['value'].value

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
    else:
        new_lsr_pk = None  
        
          
    return new_lsr_pk, lsr_msg