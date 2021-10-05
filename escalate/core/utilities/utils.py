from django.db import connection as con
from django.db.models import F
from core.models.view_tables import (Parameter, BomMaterial, Action, ActionUnit, 
                                     ExperimentTemplate, ExperimentInstance, 
                                     BillOfMaterials, ExperimentWorkflow, 
                                     WorkflowObject, WorkflowStep,
                                     ReagentMaterialInstance,
                                     )
from copy import deepcopy
import uuid
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
    exp_template = ExperimentTemplate.objects.get(uuid=template_experiment_uuid)
    # experiment row creation, overwrites original experiment template object with new experiment object.
    # Makes an experiment template object parent
    exp_instance = ExperimentInstance(ref_uid=exp_template.ref_uid, parent = exp_template,
                                 owner = exp_template.owner, operator = exp_template.operator,
                                 lab = exp_template.lab,)
    

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
    experiment_workflow_filter = ExperimentWorkflow.objects.all().filter(
        experiment_template=exp_template)
    # create empty workflow_step parent
    workflow_step_parent = None

    # itterate over them all and update workflow, experiment workflow, and workflowactionset(action, actionunit, parameter)
    for template_exp_wf in experiment_workflow_filter.iterator():
        # create new workflow for current object
        # this needs to be double checked to verify it works correctly
        #this_workflow = Workflow.objects.get(uuid=current_object.workflow.uuid)
        instance_workflow = template_exp_wf.workflow
        template_workflow = deepcopy(instance_workflow)
        # update uuid so it generates it's own uuid
        instance_workflow.uuid = None
        #this_workflow.experiment = exp_get
        # post
        instance_workflow.save()

        # create copy of current experiment workflow object from experiment_workflow_filter
        #this_experiment_workflow = current_object
        instance_exp_wf = ExperimentWorkflow(workflow=instance_workflow,
                                                      experiment_instance=exp_instance,
                                                      experiment_workflow_seq=template_exp_wf.experiment_workflow_seq)
        # update experiment workflow uuid, workflow uuid, and experiment uuid for experiment workflow
        #this_experiment_workflow.uuid = None
        #this_experiment_workflow.workflow = this_workflow
        #this_experiment_workflow.experiment = exp_get
        # post
        instance_exp_wf.save()

        # create action query and loop through the actions and update
        # need to add loop
        template_actions = Action.objects.filter(workflow=template_workflow)
        for temp_action in template_actions.iterator():
            instance_action = deepcopy(temp_action)
            # create new uuid, workflow should already be correct, if it is not set workflow uuid to current workflow uuid
            instance_action.uuid = None
            instance_action.workflow = instance_workflow
            # post
            instance_action.save()

            # get all action units and create uuids for them and assign action uuid to action unit
            template_action_units = ActionUnit.objects.filter(action=temp_action)
            for current_action_unit in template_action_units.iterator():
                current_action_unit.uuid = None
                current_action_unit.action = instance_action
                current_action_unit.save()

            # get all parameters and create uuids for them and assign action uuid to each parameter
            '''
            get_parameter = Parameter.objects.filter(action=action_template)
            for current_parameter in get_parameter.iterator():
                current_parameter.uuid = None
                current_parameter.action = current_action
                current_parameter.save()
            '''
            ''' 
            This might not be needed because it only stores the action, condition, or workflow which is 
            already done in WorkflowStep
            '''
            # create workflow object
            q_workflow_object = WorkflowObject(workflow=instance_workflow,
                                               action=instance_action)
            q_workflow_object.save()

            # create workflow steps
            # this is most likely going to need revisions and possible updates to model to change workflow_action_set_uuid -> action_uuid
            q_workflow_step = WorkflowStep(workflow=instance_workflow,
                                           workflow_object=q_workflow_object,
                                           parent=instance_workflow,  # this was workflowstep and needs to be fixed
                                           status=instance_action.status)
            q_workflow_step.save()
            workflow_step_parent = q_workflow_step.uuid

        # Do I need to update condition?
        # If so create condition, figure out conditional requirements, and loop through conditions like action
        # and update workflow_step
        # need to find out more about how this would work
    
    # Iterate over all reagent-templates and create reagentintances and reagentinstancevalues
    for reagent_template in exp_template.reagent_templates.all():
        #Iterate over value_descriptions so that there are different ReagentInstanceValues based on
        # different requirements. For e.g. "concentration" and "amount" for the same
        # reagent need different ReagentInstanceValues
        #for val_description in reagent_template.value_descriptions:
        for reagent_material_template in reagent_template.reagent_material_template_reagent_template.filter(value_description='concentration'):
            #for material_type in reagent_template.material_type.all():
            reagent_instance = ReagentMaterialInstance(reagent_material_template=reagent_material_template,
                                        experiment=exp_instance,
                                        description=f'{exp_instance.description} : {reagent_template.description} : {reagent_material_template.value_description}',
                                        )
            reagent_instance.save()

    return exp_instance.uuid

# list of model class names that have at least one view auto generated
view_names = ['Material', 'Inventory', 'Actor', 'Organization', 'Person',
              'Systemtool', 'InventoryMaterial', 'Vessel',
              'SystemtoolType', 'UdfDef', 'Status', 'Tag',
              'TagType', 'MaterialType', 'ExperimentInstance', 'Edocument'
              ]


def camel_to_snake(name):
    name = ''.join(['_'+i.lower() if i.isupper()
                    else i for i in name]).lstrip('_')
    return name

class Node:
    def __init__(self, data):
        self.left = None
        self.right = None
        self.data = data

    # Insert Node
    def insert(self, data):
        if self.data:
            if data < self.data:
                if self.left is None:
                    self.left = Node(data)
                else:
                    self.left.insert(data)
            else:# data > self.data:
                if self.right is None:
                    self.right = Node(data)
                else:
                    self.right.insert(data)
        else:
            self.data = data
    
    # Print the Tree
    def PrintTree(self):
        if self.left:
            self.left.PrintTree()
        print( self.data),
        if self.right:
            self.right.PrintTree()
    
    # Inorder traversal
    # Left -> Root -> Right
    def inorderTraversal(self, root):
        res = []
        if root:
            res = self.inorderTraversal(root.left)
            res.append(root.data)
            res = res + self.inorderTraversal(root.right)
        return res