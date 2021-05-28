from django.db.models.signals import pre_save, post_save
from django.dispatch import receiver
from core.models import Person, Actor, BomCompositeMaterial, CompositeMaterial, Measure, MeasureX, UdfX, Udf, \
Property, PropertyX, Parameter, ParameterX, Action, ActionParameter, WorkflowActionSet, Workflow, ExperimentWorkflow, \
BomCompositeMaterial, BomMaterialIndex
from core.models.view_tables.workflow import Experiment

@receiver(post_save, sender=Person)
def create_actor(sender, **kwargs):
    """Creates an actor in the actor table corresponding to the newly created 
    Person

    Args:
        sender (Person Instance): Instance of the newly created person
    """
    if kwargs['created']:
        #actor = Actor(person=kwargs['instance'],description=kwargs['instance']['first_name'])#description is an example of a specific call
        actor = Actor(person=kwargs['instance'])
    actor.save()

@receiver(post_save, sender=CompositeMaterial) 
def create_bom_material_composite(sender, **kwargs):
    """
    Creates composite_material in BomCompositeMaterial table based on CompositeMaterial model
    
    Args:
        sender (CompositeMaterial Instance): Instance of the newly created composite material
    """
    if kwargs['created']:
        bom_material_composite = BomCompositeMaterial(CompositeMaterial=kwargs['instance'])
    bom_material_composite.save()

@receiver(post_save, sender=Udf) 
def create_udf_x(sender, **kwargs):
    """
    Creates uuid, ref_uuid in udf_x table based on udf table
    
    Args:
        sender (Udf Instance): Instance of the newly created udf_x
    """
    if kwargs['created']:
        udf_x = UdfX(Udf=kwargs['instance'])
    udf_x.save()

@receiver(post_save, sender=Measure)  
def create_measure_x(sender, **kwargs):
    """
    Creates measure_x table based on Measure table
    
    Args:
        sender (Measure Instance): Instance of the newly created measure_x
    """
    if kwargs['created']:
        measure_x = MeasureX(Measure=kwargs['instance'])
    measure_x.save()
    
@receiver(post_save, sender=Property)  
def create_property_x(sender, **kwargs):
    """
        Creates property_x table based on property table
        
        Args:
            sender (Property Instance): Instance of the newly created property_x
    """

    if kwargs['created']:
        property_x = PropertyX(Property=kwargs['instance'])
    property_x.save()
    
@receiver(post_save, sender=Parameter)  
def create_parameter_x(sender, **kwargs):
    """
        Creates parameter_x table based on parameter table
        
        Args:
            sender (Parameter Instance): Instance of the newly created parameterx
    """

    if kwargs['created']:
        parameter_x = ParameterX(Parameter=kwargs['instance'])
    parameter_x.save()

@receiver(post_save, sender=Action)  
def create_action_parameter(sender, **kwargs):
    """
        Creates action_parameter table based on action table
        
        Args:
            sender (Action Instance): Instance of the newly created action_parameter
    """

    if kwargs['created']:
        action_parameter = ActionParameter(Action=kwargs['instance'])
    action_parameter.save()

"""
Verify with tests:
workflow_action_set ->
    experiment
    workflow
    experiment_workflow
"""    
@receiver(post_save, sender=WorkflowActionSet)  
def create_workflow_object(sender, **kwargs):
    """
        Creates experiment, workflow, experiment_workflow table based on workflowactionset table
        
        Args:
            sender (WorkflowActionSet Instance): Instance of the newly created action_parameter
    """

    if kwargs['created']:
        experiment = Experiment(WorkflowActionSet=kwargs['instance'])
        workflow = Workflow(WorkflowActionSet=kwargs['instance'])
        experiment_workflow = ExperimentWorkflow(WorkflowActionSet=kwargs['instance'])
    experiment.save()
    workflow.save()
    experiment_workflow.save()

@receiver(post_save, sender=BomCompositeMaterial)  
def create_bom_material_index(sender, **kwargs):
    """
        Creates bom_material_index table based on bom_composite_material table
        
        Args:
            sender (BomCompositeMaterial Instance): Instance of the newly created bom_material_index
    """

    if kwargs['created']:
        bom_material_index = BomMaterialIndex(BomCompositeMaterial=kwargs['instance'])
    bom_material_index.save()