from django.core.management.base import BaseCommand, CommandError
from core.models import (
    Actor,
    Person,
)

import core

person_relevant_fields = ["first_name", "last_name"]

person_data = [
    ["Wesley", "Wang"],
    ["Isaac", "Chang"],
    ["Shekar", "V"],
    ["Nicole", "Smina"],
    ["Philip", "Nega"],
    ["Mansoor", "Nellikkal"],
    ["Ian", "Pendleton"],
    ["Minji", "Lee"],
    ["Mike", "Tynes"],
    ["Liana", "Alves"],
    ["Zhi", "Li"],
    ["Gary", "Cattabriga"],
    ["T", "Testuser"],
    ["Matt", "Castillo"],
    ["Joseph", "Kawamura"],
]

person_to_add = [dict(zip(person_relevant_fields, data)) for data in person_data]


class Command(BaseCommand):
    help = "Loads initial people"

    def handle(self, *args, **options):
        self.stdout.write(self.style.NOTICE("Beginning adding person data"))
        for fields_bunch in person_to_add:
            person_instance, created = Person.objects.get_or_create(**fields_bunch)
            if created:
                Actor.objects.get_or_create(person=person_instance)
                self.stdout.write(
                    self.style.SUCCESS(f"Created Person {person_instance}")
                )
            else:
                self.stdout.write(
                    self.style.NOTICE(
                        f"Did NOT create Person {person_instance}, already exists"
                    )
                )
        self.stdout.write(self.style.NOTICE("Finished adding person data"))


# def get_or_none(model, **kwargs):
#     try:
#         return model.objects.get(**kwargs)
#     except model.DoesNotExist:
#         return None
