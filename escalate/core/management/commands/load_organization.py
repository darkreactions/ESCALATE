from django.core.management.base import BaseCommand, CommandError
from core.models import Actor, Organization

import core

org_relevant_fields = ["description", "full_name", "short_name"]


org_data = [
    ["Cheminfomatics software", "ChemAxon", "ChemAxon"],
    ["Laboratory", "Emerald Cloud Lab", "ECL"],
    ["DBMS", "PostgreSQL", "postgres"],
    ["Chemical vendor", "Sigma-Aldrich", "Sigma-Aldrich"],
    ["Chemical vendor", "Greatcell Solar", "Greatcell"],
    ["Test Co", "TestCo", "TC"],
    ["Cheminfomatics software", "RDKit open source software", "RDKit"],
    ["Laboratory", "Norquist Lab", "NL"],
    ["College", "Haverford College", "HC"],
    ["Laboratory", "Lawrence Berkeley National Laboratory", "LBL"],
]

orgs_to_add = [dict(zip(org_relevant_fields, data)) for data in org_data]


class Command(BaseCommand):
    help = "Loads initial organizations"

    def handle(self, *args, **options):
        self.stdout.write(self.style.NOTICE("Beginning adding organization data"))
        for fields_bunch in orgs_to_add:
            org_instance, created = Organization.objects.get_or_create(**fields_bunch)
            if created:
                Actor.objects.get_or_create(organization=org_instance)
                self.stdout.write(
                    self.style.SUCCESS(f"Created Organization {org_instance}")
                )
            else:
                self.stdout.write(
                    self.style.NOTICE(
                        f"Did NOT create Organization {org_instance}, already exists"
                    )
                )

        self.stdout.write(self.style.NOTICE("Finished adding organization data"))


# def get_or_none(model, **kwargs):
#     try:
#         return model.objects.get(**kwargs)
#     except model.DoesNotExist:
#         return None
