from django.core.management.base import BaseCommand, CommandError
from core.models import (
    TypeDef,
    Status,
    MaterialIdentifierDef,
    MaterialType,
    MeasureType,
    TagType
    )
import core.models

'''
Keys should be model name in snake case all lower case format
Ex: TypeDef => type_def
Values are arrays of dictionaries
Each dictionary is the json eqivalent of a model instance
Standard models should be basic with no foreign keys except actor and status, but
we leave them out for now
This command may be temporary
In the future, each model's table data will be in separate a json file formatted
in a way so that we can use a django management command: loaddata 
'''
# standard = {
#     'type_def': [
#         {'category': 'data', 'description': 'text'},
#         {'category': 'data', 'description': 'num'},
#         {'category': 'data', 'description': 'int'},
#         {'category': 'data', 'description': 'array_int'},
#         {'category': 'data', 'description': 'array_num'},
#         {'category': 'data', 'description': 'bool'},
#     ],
#     'status': [
#         {'description':'inactive'},
#         {'description':'prototype'},
#         {'description':'active'},
#         {'description':'do_not_use'},
#         {'description':'test'}
#     ],
#     'material_identifier_def': [
#         {'description': 'SMIRKS'},
#         {'description': 'Chemical_Name'},
#         {'description': 'InChI'},
#         {'description': 'SMILES'},
#         {'description': 'Molecular_Formula'},
#         {'description': 'SMARTS'},
#         {'description': 'RInChI'},
#         {'description': 'InChIKey'},
#         {'description': 'Abbreviation'}
#     ],
#     'material_type': [
#         {'description': "plate"},
#         {'description': "nominal"},
#         {'description': "reference"},
#         {'description': "human prepared"},
#         {'description': "solvent"},
#         {'description': "halide"},
#         {'description': "derived"},
#         {'description': "actual"},
#         {'description': "solute"},
#         {'description': "catalog"},
#         {'description': "stock solution"},
#         {'description': "a-cation"},
#         {'description': "b-cation"},
#         {'description': "gas"},
#         {'description': "separation target"},
#         {'description': "antisolvent"},
#     ],
#     'measure_type': [
#         {'description': 'robot'},
#         {'description': 'manual'}
#     ],
#     'tag_type': [
#         {
#             'type': 'material',
#             'description': 'tags used to assist in identifying material types'
#         },
#         {
#             'type': 'actor',
#             'description': 'tags used to assist in charactizing actors'
#         },
#         {
#             'type': 'measure',
#             'description': 'tags used to assist in charactizing measures'
#         },
#         {
#             'type': 'experiment',
#             'description': 'tags used to assist in charactizing experiments, visibility'
#         }
#     ]
# }
# if object above gets too large, we can move it to its own file and import it
model_field_names = {
    'type_def' : ['category','description'],
    'status': ['description'],
    'material_identifier_def': ['description'],
    'material_type': ['description'],
    'measure_type': ['description'],
    'tag_type': ['type', 'description']
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
                model_instance = model(**fields_bunch)
                if get_or_none(model, **fields_bunch) == None:
                    #doesn't exist in table already
                    model_instance.save()
                    self.stdout.write(self.style.SUCCESS(f'Created {model_name} {model_instance}'))
                else:
                    self.stdout.write(self.style.NOTICE(f'Did NOT create {model_name} {model_instance}, already exists'))
        self.stdout.write(self.style.NOTICE('Finished loading standard data')) 

def get_or_none(model, **kwargs):
    try:
        return model.objects.get(**kwargs)
    except model.DoesNotExist:
        return None