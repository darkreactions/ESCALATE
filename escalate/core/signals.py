from django.db.models.signals import pre_save, post_save
from django.dispatch import receiver
from core.models import Person, Actor, BomCompositeMaterial, CompositeMaterial
from core.models.view_tables.generic_data import UdfX, Udf


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
        sender (Udf Instance): Instance of the newly created udfx
    """
    if kwargs['created']:
        udf_x = UdfX(Udf=kwargs['instance'])
    udf_x.save()
    
