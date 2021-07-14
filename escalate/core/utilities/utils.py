from django.db import connection as con
from django.db.models import F
from core.models.view_tables import Parameter, BomMaterial, Action, ActionUnit, Experiment, BillOfMaterials, ExperimentWorkflow, Workflow, WorkflowObject, WorkflowStep
from copy import deepcopy
'''
def experiment_copy(template_experiment_uuid, copy_experiment_description):
    """Wrapper of the ESCALATE postgres function experiment_copy"""
    cur = con.cursor()
    cur.callproc('experiment_copy', [template_experiment_uuid, copy_experiment_description])
    copy_experiment_uuid = cur.fetchone()[0]  # there will always be only one element in the tuple from this PG fn
    return copy_experiment_uuid
'''
def experiment_copy(template_experiment_uuid, copy_experiment_description):
    # Get parent Experiment from template_experiment_uuid
    exp_get = Experiment.objects.get(uuid=template_experiment_uuid)
    old_exp_get = deepcopy(exp_get)
    # experiment row creation, overwrites original experiment template object with new experiment object. 
    # Makes an experiment template object parent    
    exp_get.uuid = None
    exp_get.parent_uuid = template_experiment_uuid
    # If copy_experiment_description null replace with "Copy of " + description from exp_get
    if copy_experiment_description is None:
        copy_experiment_description = "Copy of " + exp_get.description
    exp_get.description = copy_experiment_description
    # post
    exp_get.save()
    
    # create old bom object based on experiment uuid
    old_bom_get = BillOfMaterials.objects.get(experiment=template_experiment_uuid)
    # create copy for new bom
    bom_get = deepcopy(old_bom_get)
    # update new bom and update fields
    bom_get.uuid = None
    bom_get.experiment = exp_get.uuid
    # post
    bom_get.save()

    # Create old bom material object
    old_bom_material_get = BomMaterial.objects.get(bom=old_bom_get.uuid)
    # copy for new bom material
    bom_material_get = deepcopy(old_bom_material_get)
    # update new bom material
    bom_material_get.uuid = None
    bom_material_get.bom = bom_get.uuid
    # post
    bom_material_get.save()                          
    
    #Get all Experiment Workflow objects based on experiment template uuid
    experiment_workflow_filter = ExperimentWorkflow.objects.all().filter(experiment=template_experiment_uuid)
    #create empty workflow_step parent
    workflow_step_parent = None
    
    #itterate over them all and update workflow, experiment workflow, and workflowactionset(action, actionunit, parameter)
    for current_object in experiment_workflow_filter.iterator():
        #create new workflow for current object
        #this needs to be double checked to verify it works correctly
        this_workflow = Workflow.objects.get(uuid=current_object.workflow)
        #update uuid so it generates it's own uuid
        this_workflow.uuid = None
        #post
        this_workflow.save()
        
        #create copy of current experiment workflow object from experiment_workflow_filter
        this_experiment_workflow = deepcopy(current_object)
        #update experiment workflow uuid, workflow uuid, and experiment uuid for experiment workflow
        this_experiment_workflow.uuid = None
        this_experiment_workflow.workflow = this_workflow.uuid
        this_experiment_workflow.experiment__uuid = exp_get.uuid
        #post
        this_experiment_workflow.save()
        
        #create action query and loop through the actions and update
        #need to add loop
        get_action = Action.objects.filter(workflow=this_workflow.uuid)
        for current_action in get_action.iterator():
            #create new uuid, workflow should already be correct, if it is not set workflow uuid to current workflow uuid
            current_action.uuid = None
            #post
            current_action.save()

            #get all action units and create uuids for them and assign action uuid to action unit
            get_action_unit = ActionUnit.objects.filter(action__uuid=current_action.uuid)
            for current_action_unit in get_action_unit.iterator():
                current_action_unit.uuid = None
                current_action_unit.action__uuid = current_action.uuid
                current_action_unit.save()

            #get all parameters and create uuids for them and assign action uuid to each parameter
            get_parameter = Parameter.objects.filter(action__uuid=current_action.uuid)
            for current_parameter in get_parameter.iterator():
                current_parameter.uuid = None
                current_parameter.action__uuid = current_action.uuid
                current_parameter.save()

            '''
            This might not be needed because it only stores the action, condition, or workflow which is 
            already done in WorkflowStep
            #create workflow object
            q_workflow_object = WorkflowObject(workflow=this_workflow.uuid,
                                               action=current_action.uuid)
            q_workflow_object.save()   
            '''
            #create workflow steps
            #this is most likely going to need revisions and possible updates to model to change workflow_action_set_uuid -> action_uuid
            q_workflow_step = WorkflowStep(workflow=this_workflow.uuid,
                                           #workflow_object=q_workflow_object.uuid,
                                           parent=workflow_step_parent,
                                           status=current_action.status)
            q_workflow_step.save()
            workflow_step_parent=q_workflow_step.uuid
        
        #Do I need to update condition?
        #If so create condition, figure out conditional requirements, and loop through conditions like action
        # and update workflow_step
        # need to find out more about how this would work
    return exp_get.uuid    

        
                
view_names = ['Material', 'Inventory', 'Actor', 'Organization', 'Person',
              'Systemtool', 'SystemtoolType', 'UdfDef', 'Status', 'Tag',
              'TagType', 'MaterialType', 'InventoryMaterial', 'Edocument', 'Vessel']


def camel_to_snake(name):
    name = ''.join(['_'+i.lower() if i.isupper()
                    else i for i in name]).lstrip('_')
    return name
