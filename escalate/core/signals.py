from django.db.models.signals import pre_save, post_save
from django.dispatch import receiver
from core.models import (
    Person, 
    Actor, 
    Organization, 
    Systemtool, 
    Action, 
    Mixture, 
    Measure, 
    MeasureX, 
    UdfX, 
    Udf,
    BomCompositeMaterial, 
    Parameter, 
    BomMaterial, 
    ActionUnit)
#from core.models.view_tables.workflow import Experiment

@receiver(post_save, sender=Person)
@receiver(post_save, sender=Organization)
@receiver(post_save, sender=Systemtool)
def create_actor(sender, **kwargs):
    """Creates an actor in the actor table corresponding to the newly created 
    Person/Organization/Systemtool

    Args:
        sender (Model Instance): Instance of the newly created model
    """
    if kwargs['created']:
        fields = {sender.__name__.lower(): kwargs['instance']}
        fields['description'] = str(kwargs['instance'])
        #actor = Actor(person=kwargs['instance'],description=kwargs['instance']['first_name'])#description is an example of a specific call
        actor = Actor(**fields)
        actor.save()
"""
@receiver(post_save, sender=CompositeMaterial) 
def create_bom_material_composite(sender, **kwargs):
    if kwargs['created']:
        bom_material_composite = BomCompositeMaterial(CompositeMaterial=kwargs['instance'])
        bom_material_composite.save()
"""
    

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
        action = kwargs['instance']
        parameter_defs = action.action_def.parameter_def.all()
        action.parameter_def.add(*parameter_defs)
        action.save()

"""

@receiver(pre_save, sender=ActionUnit)
def create_parameters(sender, **kwargs):
    """
    Creates the appropriate parameter in actionunit based on 
    its action's parameter_def
    """
    if kwargs['created']:
        action_unit = kwargs['instance']
        param_defs = action_unit.action.action_def.parameter_def.all()
        for p_def in param_defs:
            p = Parameter(parameter_def=p_def, 
                          nominal_value=p_def.default_val, 
                          actual_value=p_def.default_val,
                          ref_object=action_unit.uuid)
            p.save()
        


@receiver(post_save, sender=BomMaterial)
def create_bom_composite_material(sender, **kwargs):
    """
    Checks if there are component materials associated
    with Material, if there are then create corresponding 
    BomCompositeMaterials
    """
    if kwargs['created']:
        bom_material = kwargs['instance']
        material = bom_material.inventory_material.material
        if not material.consumable:
            c_materials = Mixture.objects.filter(composite=material)
            for cm in c_materials:
                bcm = BomCompositeMaterial(description=f'{bom_material.description}: {cm.description}', 
                                    mixture=cm, bom_material=bom_material)
                bcm.save()

