from django.core.management.base import BaseCommand, CommandError
from core.models import (
Actor,
Systemtool,
SystemtoolType,
Organization
)

import core

systemtool_relevant_fields = [
    'systemtool_name', 'description', 'systemtool_type', 'vendor_organization'
    ]

systemtool_data = [
    [
        "standardize",
        "Molecule Standardizer",
        SystemtoolType.objects.get(description='Command-line tool'),
        Organization.objects.get(short_name='ChemAxon')
    ],
    [
        "escalate",
        "ESCALATE function call",
        SystemtoolType.objects.get(description='ESCALATE function'),
        Organization.objects.get(short_name='HC')
    ],
    [
        "generatemd",
        "Molecular Descriptor Generator",
        SystemtoolType.objects.get(description='Command-line tool'),
        Organization.objects.get(short_name='ChemAxon')
    ],
    [
        "cxcalc",
        "Molecular Descriptor Generator",
        SystemtoolType.objects.get(description='Command-line tool'),
        Organization.objects.get(short_name='ChemAxon')
    ],
    [
        "MRROBOT",
        "MR Robot to you",
        SystemtoolType.objects.get(description='API'),
        Organization.objects.get(short_name='ChemAxon')
    ],
    [
        "RDKit",
        "Cheminformatics Toolkit for Python",
        SystemtoolType.objects.get(description='Python toolkit'),
        Organization.objects.get(short_name='ChemAxon')
    ],
    [
        "molconvert",
        "Molecule File Converter",
        SystemtoolType.objects.get(description='Command-line tool'),
        Organization.objects.get(short_name='ChemAxon')
    ],
    [
        "postgres",
        "PostgreSQL DBMS",
        SystemtoolType.objects.get(description='Database Management System'),
        Organization.objects.get(short_name='HC')
    ],
]

systemtool_to_add = [dict(zip(systemtool_relevant_fields, data)) for data in systemtool_data]



class Command(BaseCommand):
    help = 'Loads initial systemtools'

    def handle(self, *args, **options):
        self.stdout.write(self.style.NOTICE('Beginning adding systemtool'))
        for fields_bunch in systemtool_to_add:
            systemtool_instance = Systemtool(**fields_bunch)
            if get_or_none(Systemtool, **fields_bunch) == None:
                systemtool_instance.save()
                systemtool_instance_actor = Actor(systemtool=systemtool_instance)
                systemtool_instance_actor.save()
                self.stdout.write(self.style.SUCCESS(f'Created Systemtool {systemtool_instance}'))
            else:
                self.stdout.write(self.style.NOTICE(f'Did NOT create systemtool {systemtool_instance}, already exists'))

        self.stdout.write(self.style.NOTICE('Finished adding systemtool'))

def get_or_none(model, **kwargs):
    try:
        return model.objects.get(**kwargs)
    except model.DoesNotExist:
        return None
