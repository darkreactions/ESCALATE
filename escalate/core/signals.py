from django.db.models.signals import pre_save, post_save
from django.dispatch import receiver
from core.models import Person, Actor


@receiver(post_save, sender=Person)
def create_actor(sender, **kwargs):
    """Creates an actor in the actor table corresponding to the newly created 
    Person

    Args:
        sender (Person Instance): Instance of the newly created person
    """
    if kwargs['created']:
        actor = Actor(person=kwargs['instance'])
    actor.save()