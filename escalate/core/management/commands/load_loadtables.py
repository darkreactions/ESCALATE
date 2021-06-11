from django.core.management.base import BaseCommand, CommandError
from core.models import (
TypeDef,
Material, 
MaterialType, 
MaterialIdentifier,
MaterialIdentifierDef, 
Status
)

import csv
import os
import json

class Command(BaseCommand):
    help = 'Loads initial data from load tables after a datebase refresh'

    def handle(self, *args, **options):
        self.stdout.write(self.style.NOTICE('Loading load tables'))
        self._load_chem_inventory()
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
                if get_or_none(MaterialType,description=mat_type_description) == None:
                    new_mat_type = MaterialType(description=mat_type_description)
                    new_mat_type.save()
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
                if get_or_none(Material,description=mat_description) == None:
                    material = Material(description=mat_description,status=active_status)
                    material.save()
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
                some_material = Material.objects.get(description=row_desc)
                some_material.material_type.add(*row_material_types)
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
                    if get_or_none(MaterialIdentifier,description=ref_name) == None:
                        new_material_identifier = MaterialIdentifier(
                            description=ref_name,
                            material_identifier_def=col_name_to_material_identifier_def[col_name],
                            status=active_status
                        )
                        new_material_identifier.save()
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
                    material_identifier = get_or_none(MaterialIdentifier,description=ref_name)
                    if material_identifier != None:
                        some_material.identifier.add(material_identifier)
            self.stdout.write(self.style.SUCCESS(f'Updated material identifier for materials'))
 
        self.stdout.write(self.style.NOTICE('Finished loading chem'))

    # def _load_hc_inventory(self):
    #     self.stdout.write(self.style.NOTICE('Beginning loading HC'))
    #     filename = 'load_hc_inventory.csv'
    #     LOAD_CHEM_INVENTORY = path_to_file(filename)
    #     with open(LOAD_CHEM_INVENTORY, newline='') as f:
    #         reader = csv.reader(f, delimiter="\t")

    #         #first row should be header
    #         column_names = next(reader)

    #         #{'col_0': 0, 'col_1': 1, ...}
    #         column_names_to_index = list_data_to_index(column_names)

    #         print(column_names)
    #         # for row in reader:
    #         #     print(row)

    #         #jump to top of csv
    #         f.seek(0)
    #         #skip initial header row
    #         next(reader)
    #     self.stdout.write(self.style.NOTICE('Finished loading HC'))


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

    