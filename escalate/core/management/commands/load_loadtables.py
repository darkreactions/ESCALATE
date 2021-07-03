from django.core.management.base import BaseCommand, CommandError
from core.models import (
TypeDef,
Material, 
MaterialType, 
MaterialIdentifier,
MaterialIdentifierDef, 
Status,
Vessel,
ParameterDef,
ActionDef,
CalculationDef,
Systemtool
)

import csv
import os
import json

class Command(BaseCommand):
    help = 'Loads initial data from load tables after a datebase refresh'

    def handle(self, *args, **options):
        self.stdout.write(self.style.NOTICE('Loading load tables'))
        self._load_chem_inventory()
        self._load_vessels()
        self._load_experiment_related_def()
        self.stdout.write(self.style.NOTICE('Finished loading load tables'))
        return

    def _load_chem_inventory(self):
        self.stdout.write(self.style.NOTICE('Beginning loading chem'))
        filename = 'load_chem_inventory.csv'
        LOAD_CHEM_INVENTORY = path_to_file(filename)
        with open(LOAD_CHEM_INVENTORY, newline='') as f:
            reader = csv.reader(f, delimiter="\t")

            #first row should be header
            column_names = next(reader)

            #{'col_0': 0, 'col_1': 1, ...}
            column_names_to_index = list_data_to_index(column_names)

            #this block of code loads new material types not in db
            material_types = set()
            for row in reader:
                #material_type
                material_types_this_row = [x.strip() for x in row[column_names_to_index['ChemicalCategory']].split(',')]
                for mat_type_description in material_types_this_row:
                    if mat_type_description != "":
                        material_types.add(mat_type_description)
            new_mat_types_counter = 0
            for mat_type_description in material_types:
                new_mat_type, created = MaterialType.objects.get_or_create(description=mat_type_description)
                if created:
                    new_mat_types_counter += 1
            self.stdout.write(self.style.SUCCESS(f'Added {new_mat_types_counter} new material types'))

            #jump to top of csv
            f.seek(0)
            #skip initial header row
            next(reader)

            #query it once 
            active_status = Status.objects.get(description="active")
            # active_status = get_or_none(Status,description='active')

            #this block of code loads new materials not in db
            new_mat_counter = 0
            for row in reader:
                mat_description = row[column_names_to_index['ChemicalName']]
                if mat_description == "":
                    continue
                material, created = Material.objects.get_or_create(description=mat_description,status=active_status)
                if created:
                    new_mat_counter += 1
            self.stdout.write(self.style.SUCCESS(f'Added {new_mat_counter} new materials'))

            #jump to top of csv
            f.seek(0)
            #skip initial header row
            next(reader)
            
            #this block of code matches each material to its material types(s)
            for row in reader:
                row_desc = row[column_names_to_index['ChemicalName']]
                row_material_types_raw = [x.strip() for x in row[column_names_to_index['ChemicalCategory']].split(',')]
                row_material_types = [MaterialType.objects.get(description=y) for y in row_material_types_raw]
                row_material = Material.objects.get(description=row_desc)
                row_material.material_type.add(*row_material_types)
            self.stdout.write(self.style.SUCCESS(f'Updated material types of materials'))

            #jump to top of csv
            f.seek(0)
            #skip initial header row
            next(reader)

            #this block of code loads the chemical reference (MaterialIdentifier) names not in db
            ref_name_cols = [
                'ChemicalName',
                'ChemicalAbbreviation',
                'InChI',
                'InChIKey',
                'CanonicalSMILES',
                'MolecularFormula'
            ]
            col_name_to_material_identifier_def = {
                'ChemicalName': MaterialIdentifierDef.objects.get(description='Chemical_Name'),
                'ChemicalAbbreviation': MaterialIdentifierDef.objects.get(description='Abbreviation'),
                'InChI': MaterialIdentifierDef.objects.get(description='InChI'),
                'InChIKey': MaterialIdentifierDef.objects.get(description='InChIKey'),
                'CanonicalSMILES': MaterialIdentifierDef.objects.get(description='SMILES'),
                'MolecularFormula': MaterialIdentifierDef.objects.get(description='Molecular_Formula'),
            }
            new_refname_counter = 0
            for row in reader:
                for col_name in ref_name_cols:
                    ref_name = row[column_names_to_index[col_name]]
                    if ref_name == "":
                        continue
                    new_material_identifier, created = MaterialIdentifier.objects.get_or_create(
                            description=ref_name,
                            material_identifier_def=col_name_to_material_identifier_def[col_name],
                            status=active_status
                        )
                    if created:
                        new_refname_counter += 1
            self.stdout.write(self.style.SUCCESS(f'Added {new_refname_counter} new material identifiers'))

            #jump to top of csv
            f.seek(0)
            #skip initial header row
            next(reader)

            #this block of code matches each material to its material identifier(s)
            for row in reader:
                row_desc = row[column_names_to_index['ChemicalName']]
                some_material = Material.objects.get(description=row_desc)
                for col_name in ref_name_cols:
                    ref_name = row[column_names_to_index[col_name]]
                    if ref_name == "":
                        continue
                    material_identifier = get_or_none(MaterialIdentifier,
                            description=ref_name,
                            material_identifier_def=col_name_to_material_identifier_def[col_name],
                            status=active_status)
                    if material_identifier != None:
                        some_material.identifier.add(material_identifier)
            self.stdout.write(self.style.SUCCESS(f'Updated material identifier for materials'))
 
        self.stdout.write(self.style.NOTICE('Finished loading chem'))

    def _load_vessels(self):
        self.stdout.write(self.style.NOTICE('Beginning loading vessels'))
        filename = 'old_dev_schema_materials.csv'
        OLD_DEV_SCHEMA_MATERIALS = path_to_file(filename)
        with open(OLD_DEV_SCHEMA_MATERIALS, newline='') as f:
            reader = csv.reader(f, delimiter="\t")

            #first row should be header
            column_names = next(reader)

            #{'col_0': 0, 'col_1': 1, ...}
            column_names_to_index = list_data_to_index(column_names)

            new_vessels = 0
            new_plates = 0
            active_status = Status.objects.get(description="active")
            for row in reader:
                row_desc = row[column_names_to_index['description']]
                if "Plate" in row_desc:
                    parts = row_desc.split('#:')
                    assert(1 <= len(parts) <= 2)
                    plate_name = parts[0].strip() if len(parts) >= 1 else None
                    well_number = parts[1].strip() if len(parts) > 1 else None
                    fields = {
                            'plate_name': plate_name,
                            'well_number': well_number,
                            'status': active_status
                        }
                    #whole plate or single vessel
                    if "#" in row_desc and ':' in row_desc:
                        #single vessel
                        row_vessel_instance, created = Vessel.objects.get_or_create(**fields)
                        if created:
                            new_vessels += 1
                    else:   
                        #whole plate
                        row_plate_instance, created = Vessel.objects.get_or_create(**fields)
                        if created:
                            new_plates += 1
            self.stdout.write(self.style.SUCCESS(f'Added {new_vessels} new vessels'))
            self.stdout.write(self.style.SUCCESS(f'Added {new_plates} new plates'))
            # #jump to top of csv
            # f.seek(0)
            # #skip initial header row
            # next(reader)
        self.stdout.write(self.style.NOTICE('Finished loading vessels'))
    
    def _load_experiment_related_def(self):
        self.stdout.write(self.style.NOTICE('Beginning experiment related def'))
        self._load_parameter_def()
        self._load_action_def()
        self._load_calculation_def()
        self.stdout.write(self.style.NOTICE('Finished loading experiment related def'))
    
    def _load_parameter_def(self):
        self.stdout.write(self.style.NOTICE('Beginning loading parameter def'))
        filename = 'load_parameter_def.csv'
        PARAMETER_DEF = path_to_file(filename)
        
        active_status = Status.objects.get(description="active")

        def to_bool(s):
            if x == 't' or s == 'true' or s == 'TRUE' or s:
                return True
            else:
                return False

        with open(PARAMETER_DEF, newline='') as f:
            reader = csv.reader(f, delimiter="\t")

            #first row should be header
            column_names = next(reader)

            #{'col_0': 0, 'col_1': 1, ...}
            column_names_to_index = list_data_to_index(column_names)

            new_parameter_def = 0
            for row in reader:
                description = row[column_names_to_index['description']]
                type_ = row[column_names_to_index['type']]
                value_from_csv = row[column_names_to_index['value']]
                if type_ == 'text':
                    value = value_from_csv
                elif type_ == 'num':
                    value = float(value_from_csv)
                elif type_ == 'int':
                    value = int(value_from_csv)
                elif type_ == 'array_int':
                    value = [int(x.strip()) for x in value_from_csv.split(',')]
                elif type_ == 'array_num':
                    value = [float(x.strip()) for x in value_from_csv.split(',')]
                elif type_ == 'bool':
                    value = to_bool(value_from_csv)
                elif type_ == 'array_bool':
                    value = [to_bool(x.strip()) for x in value_from_csv.split(',')]
                elif type_ == 'array_text':
                    value = [x.strip() for x in value_from_csv.split(',')]
                else:
                    assert False, f'{type_} is an invalid type'
                unit = row[column_names_to_index['unit']]
                if (x := row[column_names_to_index['required']]) == 't' or x == 'true' or x == 'TRUE' or x:
                    required = True
                else:
                    required = False
                unit_type = None if (y := row[column_names_to_index['unit_type']]) == '' else y
                fields = {
                    'description': description.strip(),
                    'default_val': {
                        'value': value,
                        'type': type_,
                        'unit': unit
                    },
                    'unit_type': unit_type,
                    'required': required,
                    'status': active_status
                }
                row_parameter_def_instance, created = ParameterDef.objects.get_or_create(**fields)
                if created:
                    new_parameter_def += 1
            self.stdout.write(self.style.SUCCESS(f'Added {new_parameter_def} new parameter def'))   
        self.stdout.write(self.style.NOTICE('Finished loading parameter def'))         

    def _load_action_def(self):
        self.stdout.write(self.style.NOTICE('Beginning loading action def'))
        filename = 'load_action_def.csv'
        ACTION_DEF = path_to_file(filename)
        with open(ACTION_DEF, newline='') as f:
            reader = csv.reader(f, delimiter="\t")

            #first row should be header
            column_names = next(reader)

            #{'col_0': 0, 'col_1': 1, ...}
            column_names_to_index = list_data_to_index(column_names)

            new_action_def = 0
            for row in reader:
                description = row[column_names_to_index['description']]
                parameter_def_descriptions = [x.strip() for x in y.split(',')] if (y := row[column_names_to_index['parameter_def_descriptions']]) != '' else []
                action_def_instance, created = ActionDef.objects.get_or_create(description=description)
                if created:
                    new_action_def += 1
                action_def_instance.parameter_def.add(*[ParameterDef.objects.get(description=x) for x in parameter_def_descriptions])
            self.stdout.write(self.style.SUCCESS(f'Added {new_action_def} new action def'))            
        self.stdout.write(self.style.NOTICE('Finished loading action def'))
    
    def _load_calculation_def(self):
        self.stdout.write(self.style.NOTICE('Beginning loading calculation def'))
        filename = 'load_calculation_def.csv'
        CALCULATION_DEF = path_to_file(filename)
        with open(CALCULATION_DEF, newline='') as f:
            reader = csv.reader(f, delimiter="\t")

            #first row should be header
            column_names = next(reader)

            #{'col_0': 0, 'col_1': 1, ...}
            column_names_to_index = list_data_to_index(column_names)

            new_calculation_def = 0

            # create calculation def
            for row in reader:
                description = row[column_names_to_index['description']]
                short_name = row[column_names_to_index['short_name']]
                calc_definition = row[column_names_to_index['calc_definition']]
                in_type__description = row[column_names_to_index['in_type__description']]
                in_opt_type__description = row[column_names_to_index['in_opt_type__description']]
                out_type__description = row[column_names_to_index['out_type__description']]
                systemtool_name = row[column_names_to_index['systemtool_name']]
                fields = {
                    'description': description,
                    'short_name': short_name,
                    'calc_definition': calc_definition,
                    'in_type': TypeDef.objects.get(description=in_type__description,category='data') if in_type__description != '' else None,
                    'in_opt_type': TypeDef.objects.get(description=in_opt_type__description,category='data') if in_opt_type__description != '' else None,
                    'out_type': TypeDef.objects.get(description=out_type__description,category='data') if out_type__description != '' else None,
                    'systemtool': Systemtool.objects.get(systemtool_name=systemtool_name) if systemtool_name != '' else None
                }
                calculation_def_instance, created = CalculationDef.objects.get_or_create(**fields)
                if created:
                    new_calculation_def += 1
                parameter_def_descriptions = [x.strip() for x in y.split(',')] if (y := row[column_names_to_index['parameter_def_descriptions']]) != '' else [] 
                calculation_def_instance.parameter_def.add(*[ParameterDef.objects.get(description=d) for d in parameter_def_descriptions])
            #jump to top of csv
            f.seek(0)
            #skip initial header row
            next(reader)

            #go back and save self foreign keys 
            for row in reader:
                short_name = row[column_names_to_index['short_name']]
                row_calculation_def_instance = CalculationDef.objects.get(short_name=short_name)
                
                in_source__short_name = row[column_names_to_index['in_source__short_name']]
                in_opt_source__short_name = row[column_names_to_index['in_opt_source__short_name']]
                fields = {
                    'in_source': CalculationDef.objects.get(short_name=in_source__short_name) if in_source__short_name != '' else None,
                    'in_opt_source': CalculationDef.objects.get(short_name=in_opt_source__short_name) if in_opt_source__short_name != '' else None
                }
                for field, value in fields.items():
                    setattr(row_calculation_def_instance, field, value)
                row_calculation_def_instance.save(update_fields=['in_source','in_opt_source'])
            self.stdout.write(self.style.SUCCESS(f'Added {new_calculation_def} new calculation def'))            
        self.stdout.write(self.style.NOTICE('Finished loading calculation def'))

def path_to_file(filename):
    script_dir = os.path.dirname(__file__)
    csv_dir = '../../../../data_model/dataload_csv'
    return os.path.join(script_dir, f'{csv_dir}/{filename}')

def list_data_to_index(list_data):
    #hopefully list has hashable elements
    return {list_data[i]:i for i in range(len(list_data))}

def get_or_none(model, **kwargs):
    try:
        return model.objects.get(**kwargs)
    except model.DoesNotExist:
        return None

# def dump_json(data, filename):
#     with open(filename, 'w', encoding='utf-8') as f:
#         json.dump(data, f, ensure_ascii=False, indent=4)

    