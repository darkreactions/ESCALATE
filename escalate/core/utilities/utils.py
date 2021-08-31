from django.db import connection as con
from django.db.models import F
from core.models.view_tables import Parameter, BomMaterial, Action, ActionUnit, Experiment, BillOfMaterials, ExperimentWorkflow, Workflow, WorkflowObject, WorkflowStep
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
    exp_get = Experiment.objects.get(uuid=template_experiment_uuid)
    old_exp_get = deepcopy(exp_get)
    # experiment row creation, overwrites original experiment template object with new experiment object.
    # Makes an experiment template object parent
    exp_get.uuid = None
    exp_get.parent = old_exp_get
    # If copy_experiment_description null replace with "Copy of " + description from exp_get
    if copy_experiment_description is None:
        copy_experiment_description = "Copy of " + exp_get.description
    exp_get.description = copy_experiment_description
    # post
    exp_get.save()

    # create old bom object based on experiment uuid
    old_bom_get = BillOfMaterials.objects.filter(
        experiment=template_experiment_uuid)
    for this_bom in old_bom_get.iterator():
        # create copy for new bom
        bom_get = deepcopy(this_bom)
        # update new bom and update fields
        bom_get.uuid = None
        bom_get.experiment = exp_get
        # post
        bom_get.save()

        # Create old bom material object
        old_bom_material_get = BomMaterial.objects.filter(bom=this_bom.uuid)
        for this_bom_material in old_bom_material_get:
            # copy for new bom material
            bom_material_get = deepcopy(this_bom_material)
            # update new bom material
            bom_material_get.uuid = None
            bom_material_get.bom = bom_get
            # post
            bom_material_get.save()

    # Get all Experiment Workflow objects based on experiment template uuid
    experiment_workflow_filter = ExperimentWorkflow.objects.all().filter(
        experiment=old_exp_get)
    # create empty workflow_step parent
    workflow_step_parent = None

    # itterate over them all and update workflow, experiment workflow, and workflowactionset(action, actionunit, parameter)
    for current_object in experiment_workflow_filter.iterator():
        # create new workflow for current object
        # this needs to be double checked to verify it works correctly
        #this_workflow = Workflow.objects.get(uuid=current_object.workflow.uuid)
        this_workflow = current_object.workflow
        template_workflow = deepcopy(this_workflow)
        # update uuid so it generates it's own uuid
        this_workflow.uuid = None
        #this_workflow.experiment = exp_get
        # post
        this_workflow.save()

        # create copy of current experiment workflow object from experiment_workflow_filter
        #this_experiment_workflow = current_object
        this_experiment_workflow = ExperimentWorkflow(workflow=this_workflow,
                                                      experiment=exp_get,
                                                      experiment_workflow_seq=current_object.experiment_workflow_seq)
        # update experiment workflow uuid, workflow uuid, and experiment uuid for experiment workflow
        #this_experiment_workflow.uuid = None
        #this_experiment_workflow.workflow = this_workflow
        #this_experiment_workflow.experiment = exp_get
        # post
        this_experiment_workflow.save()

        # create action query and loop through the actions and update
        # need to add loop
        get_action = Action.objects.filter(workflow=template_workflow)
        for current_action in get_action.iterator():
            action_template = deepcopy(current_action)
            # create new uuid, workflow should already be correct, if it is not set workflow uuid to current workflow uuid
            current_action.uuid = None
            current_action.workflow = this_workflow
            # post
            current_action.save()

            # get all action units and create uuids for them and assign action uuid to action unit
            get_action_unit = ActionUnit.objects.filter(action=action_template)
            for current_action_unit in get_action_unit.iterator():
                current_action_unit.uuid = None
                current_action_unit.action = current_action
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
            q_workflow_object = WorkflowObject(workflow=this_workflow,
                                               action=current_action)
            q_workflow_object.save()

            # create workflow steps
            # this is most likely going to need revisions and possible updates to model to change workflow_action_set_uuid -> action_uuid
            q_workflow_step = WorkflowStep(workflow=this_workflow,
                                           workflow_object=q_workflow_object,
                                           parent=this_workflow,  # this was workflowstep and needs to be fixed
                                           status=current_action.status)
            q_workflow_step.save()
            workflow_step_parent = q_workflow_step.uuid

        # Do I need to update condition?
        # If so create condition, figure out conditional requirements, and loop through conditions like action
        # and update workflow_step
        # need to find out more about how this would work
    return exp_get.uuid

# list of model class names that have at least one view auto generated
view_names = ['Material', 'Inventory', 'Actor', 'Organization', 'Person',
              'Systemtool', 'InventoryMaterial', 'Vessel',
              'SystemtoolType', 'UdfDef', 'Status', 'Tag',
              'TagType', 'MaterialType', 'Experiment'
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