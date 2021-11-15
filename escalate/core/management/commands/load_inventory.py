from django.core.management.base import BaseCommand, CommandError
from core.models import Actor, Inventory, Status

inventory_relevant_fields = ["description", "owner", "operator", "lab", "status"]

active_status = Status.objects.get(description="active")
inventory_data = [
    [
        "Test Inventory",
        Actor.objects.get(description="Mike Tynes"),
        Actor.objects.get(description="Mike Tynes"),
        Actor.objects.get(description="TestCo"),
        active_status,
    ],
    [
        "Haverford Inventory",
        Actor.objects.get(description="Mansoor Nellikkal"),
        Actor.objects.get(description="Mansoor Nellikkal"),
        Actor.objects.get(description="Haverford College"),
        active_status,
    ],
    [
        "LBL Inventory",
        Actor.objects.get(description="Zhi Li"),
        Actor.objects.get(description="Zhi Li"),
        Actor.objects.get(description="Lawrence Berkeley National Laboratory"),
        active_status,
    ],
]

inventory_to_add = [
    dict(zip(inventory_relevant_fields, data)) for data in inventory_data
]


class Command(BaseCommand):
    help = "Loads initial inventory"

    def handle(self, *args, **options):
        self.stdout.write(self.style.NOTICE("Beginning adding inventory data"))
        for fields_bunch in inventory_to_add:
            inventory_instance, created = Inventory.objects.get_or_create(
                **fields_bunch
            )
            if created:
                self.stdout.write(
                    self.style.SUCCESS(f"Created inventory {inventory_instance}")
                )
            else:
                self.stdout.write(
                    self.style.NOTICE(
                        f"Did NOT create inventory {inventory_instance}, already exists"
                    )
                )
        self.stdout.write(self.style.NOTICE("Finished adding inventory data"))
