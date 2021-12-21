from django.db import connection as con
from django.db.models import F
from core.models.view_tables import (
    Parameter,
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
)
from copy import deepcopy
import uuid

# import core.models.view_tables as vt

'''
def experiment_copy(template_experiment_uuid, copy_experiment_description):
    """Wrapper of the ESCALATE postgres function experiment_copy"""
    cur = con.cursor()
    cur.callproc('experiment_copy', [template_experiment_uuid, copy_experiment_description])
    copy_experiment_uuid = cur.fetchone()[0]  # there will always be only one element in the tuple from this PG fn
    return copy_experiment_uuid
'''


def generate_action_def_json(action_defs):
    # action_defs = [a for a in vt.ActionDef.objects.all()]

    json_data = []

    for i in range(len(action_defs)):

        json_data.append(
            {
                "type": action_defs[i].description,
                "displayName": action_defs[i].description,
                "runtimeDescription": "x => ` ",
                "description": action_defs[i].description,
                "category": "template",
                "outcomes": ["Done"],
                "properties": [
                    {
                        "name": "source",
                        "type": "text",
                        "label": "From:",
                        "hint": "source material/vessel",
                        "options": {},
                    },
                    {
                        "name": "destination",
                        "type": "text",
                        "label": "To:",
                        "hint": "destination material/vessel",
                        "options": {},
                    },
                ],
            }
        )
        for param in action_defs[i].parameter_def.all():

            json_data[i]["properties"].append(
                {
                    "name": param.description,
                    "type": "text",
                    "label": param.description,
                    "hint": "",
                    "options": {},
                }
            )
            json_data[i]["runtimeDescription"] += (
                " {}: ".format(param.description)
                + "${ "
                + "x.state.{} ".format(param.description)
                + "} \n"
            )

        json_data[i]["runtimeDescription"] += " ` "

    return json_data


def generate_action_sequence_json(action_sequences):

    json_data = []

    for i in range(len(action_sequences)):

        json_data.append(
            {
                "type": str(action_sequences[i].uuid),
                "displayName": action_sequences[i].description,
                "runtimeDescription": " ",
                "properties": [],
                "description": action_sequences[i].description,
                "category": "template",
                "outcomes": ["Done"],
            }
        )
    return json_data


def experiment_copy(template_experiment_uuid, copy_experiment_description):
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
            """
            get_parameter = Parameter.objects.filter(action=action_template)
            for current_parameter in get_parameter.iterator():
                current_parameter.uuid = None
                current_parameter.action = current_action
                current_parameter.save()
            """
            """ 
            This might not be needed because it only stores the action, condition, or workflow which is 
            already done in WorkflowStep
            
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
            """

        # Do I need to update condition?
        # If so create condition, figure out conditional requirements, and loop through conditions like action
        # and update workflow_step
        # need to find out more about how this would work

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

    for outcome_template in exp_template.outcome_template_experiment_template.all():
        for label in outcome_template.instance_labels:
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


def camel_to_snake(name):
    name = "".join(["_" + i.lower() if i.isupper() else i for i in name]).lstrip("_")
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
            else:  # data > self.data:
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
        print(self.data),
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
