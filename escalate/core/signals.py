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
    ActionUnit,
    Status,
)

# from core.models.view_tables.workflow import Experiment


@receiver(post_save, sender=Person)
@receiver(post_save, sender=Organization)
@receiver(post_save, sender=Systemtool)
def create_actor(sender, **kwargs):
    """Creates an actor in the actor table corresponding to the newly created
    Person/Organization/Systemtool

    Args:
        sender (Model Instance): Instance of the newly created model
    """
    if kwargs["created"]:
        fields = {sender.__name__.lower(): kwargs["instance"]}
        fields["description"] = str(kwargs["instance"])
        fields["status"] = Status.objects.get(description="active")
        # actor = Actor(**fields)
        # actor.save()
        Actor.objects.get_or_create(**fields)


@receiver(post_save, sender=Udf)
def create_udf_x(sender, **kwargs):
    """
    Creates uuid, ref_uuid in udf_x table based on udf table

    Args:
        sender (Udf Instance): Instance of the newly created udf_x
    TODO: Missing ref_udf_uuid
    """
    if kwargs["created"]:
        udf_x = UdfX(Udf=kwargs["instance"])
        udf_x.save()


@receiver(post_save, sender=Measure)
def create_measure_x(sender, **kwargs):
    """
    Creates measure_x table based on Measure table

    Args:
        sender (Measure Instance): Instance of the newly created measure_x
    """
    if kwargs["created"]:
        measure_x = MeasureX(measure=kwargs["instance"])
        measure_x.save()


@receiver(post_save, sender=ActionUnit)
def create_parameters(sender, **kwargs):
    """
    Creates the appropriate parameter in actionunit based on
    its action's parameter_def
    """

    # created isnt a kwarg for pre-save. Either make it post save or
    # do something like this

    action_unit = kwargs["instance"]
    """
    try:
        ActionUnit.objects.get(pk=action_unit.pk)
    except ActionUnit.DoesNotExist:
    """
    try:
        param_defs = action_unit.action.template.action_def.parameter_def.all()
        active_status = Status.objects.get(description="active")
        for p_def in param_defs:
            p = Parameter.objects.create(
                parameter_def=p_def,
                parameter_val_nominal=p_def.default_val,
                parameter_val_actual=p_def.default_val,
                action_unit=action_unit,
                status=active_status,
            )
            # p.save()
    except Exception as e:
        print(f"Exception {e}")


@receiver(post_save, sender=BomMaterial)
def create_bom_composite_material(sender, **kwargs):
    """
    Checks if there are component materials associated
    with Material, if there are then create corresponding
    BomCompositeMaterials
    """
    if kwargs["created"]:
        bom_material = kwargs["instance"]
        material = bom_material.inventory_material.material
        if not material.consumable:
            c_materials = Mixture.objects.filter(composite=material)
            for cm in c_materials:
                bcm = BomCompositeMaterial(
                    description=f"{bom_material.description}: {cm.description}",
                    mixture=cm,
                    bom_material=bom_material,
                )
                bcm.save()
