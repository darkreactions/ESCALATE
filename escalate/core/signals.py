from django.db.models.signals import pre_save, post_save
from django.dispatch import receiver
from core.models import Person, Actor, BomCompositeMaterial, CompositeMaterial, Measure, MeasureX, UdfX, Udf, \
BomCompositeMaterial
#from core.models.view_tables.workflow import Experiment

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
    TODO: Probably not the right signal. Composite material should not automatically generate a BomCompositeMaterial
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
    TODO: Missing ref_udf_uuid 
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
        measure_x = MeasureX(measure=kwargs['instance'])
        measure_x.save()


"""
@receiver(post_save, sender=Property)  
def create_property_x(sender, **kwargs):
    if kwargs['created']:
        property_x = PropertyX(property=kwargs['instance'])
        property_x.save()


@receiver(post_save, sender=Parameter)  
def create_parameter_x(sender, **kwargs):
    if kwargs['created']:
        parameter_x = ParameterX(parameter=kwargs['instance'])
        parameter_x.save()


@receiver(post_save, sender=Action)  
def create_action_parameter(sender, **kwargs):

    if kwargs['created']:
        action_parameter = ActionParameter(parameter=kwargs['instance'])
        action_parameter.save()
"""