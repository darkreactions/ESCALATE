from django.core.management.base import BaseCommand, CommandError
from core.models import (
    TypeDef,
    Status,
    MaterialIdentifierDef,
    MaterialType,
    MeasureType,
    TagType,
    SystemtoolType
    )
import core.models

model_field_names = {
    'type_def' : ['category','description'],
    'status': ['description'],
    'material_identifier_def': ['description'],
    'material_type': ['description'],
    'measure_type': ['description'],
    'tag_type': ['type', 'description'],
    'systemtool_type': ['description'],
    }

#fields for each model instance
#the data for each field is in an array and is in the same order as the fields
#defined above
model_field_data = {
    'type_def': [
        ['data', 'text'],
        ['data', 'num'],
        ['data', 'int'],
        ['data', 'array_int'],
        ['data', 'array_num'],
        ['data', 'bool'],
        ["data", "blob"],
        ["data", "array_bool"],
        ["data", "array_text"],
        ["file", "svg"],
        ["file", "text"],
        ["file", "pdf"],
        ["file", "xrd"],
        ["file", "png"],
        ["file", "jpg"],
    ],
    'status': [
        ['inactive'],
        ['prototype'],
        ['active'],
        ['do_not_use'],
        ['test'],
    ],
    'material_identifier_def': [
        ['SMIRKS'],
        ['Chemical_Name'],
        ['InChI'],
        ['SMILES'],
        ['Molecular_Formula'],
        ['SMARTS'],
        ['RInChI'],
        ['InChIKey'],
        ['Abbreviation'],
    ],
    'material_type': [
        ["plate"],
        ["nominal"],
        ["reference"],
        ["human prepared"],
        ["solvent"],
        ["halide"],
        ["derived"],
        ["actual"],
        ["solute"],
        ["catalog"],
        ["stock solution"],
        ["a-cation"],
        ["b-cation"],
        ["gas"],
        ["separation target"],
        ["antisolvent"],
    ],
    'measure_type': [
        ['robot'],
        ['manual'],
    ],
    'tag_type': [
        ['material', 'tags used to assist in identifying material types'],
        ['actor', 'tags used to assist in charactizing actors'],
        ['measure', 'tags used to assist in charactizing measures'],
        ['experiment', 'tags used to assist in charactizing experiments, visibility'],
    ],
    'systemtool_type': [
        ["Database Management System"],
        ["ESCALATE function"],
        ["Command-line tool"],
        ["API"],
        ["Python toolkit"],
    ]
}

standard = {}
for model_name, field_names in model_field_names.items():
    model_instances = [dict(zip(field_names, data)) for data in model_field_data[model_name]]
    standard[model_name] = model_instances

class Command(BaseCommand):
    help = 'Loads in initial data into the base tables'

    def handle(self, *args, **options):
        self.stdout.write(self.style.NOTICE('Beginning loading standard data'))
        for model_name_raw, array_of_fields in standard.items():
            model_name = "".join([x.capitalize() for x in model_name_raw.split('_')])
            model = getattr(core.models, model_name)
            for fields_bunch in array_of_fields:
                model_instance, created = model.objects.get_or_create(**fields_bunch)
                if created:
                    #doesn't exist in table already
                    self.stdout.write(self.style.SUCCESS(f'Created {model_name} {model_instance}'))
                else:
                    self.stdout.write(self.style.NOTICE(f'Did NOT create {model_name} {model_instance}, already exists'))
        self.stdout.write(self.style.NOTICE('Finished loading standard data')) 

# def get_or_none(model, **kwargs):
#     try:
#         return model.objects.get(**kwargs)
#     except model.DoesNotExist:
#         return None