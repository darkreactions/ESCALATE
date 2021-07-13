from django.core.management.base import BaseCommand, CommandError
from core.models import (
    Actor,
    Action,
    ActionDef,
    ActionUnit,
    BaseBomMaterial,
    BomMaterial,
    BillOfMaterials,
    CalculationDef,
    Experiment,
    ExperimentType,
    ExperimentWorkflow,
    Inventory,
    InventoryMaterial,
    Material, 
    MaterialType, 
    MaterialIdentifier,
    MaterialIdentifierDef, 
    Mixture,
    ParameterDef,
    Status,
    Systemtool,
    TypeDef,
    Vessel,
    Workflow,
    WorkflowType
)

import csv
import os
import json

class Command(BaseCommand):
    help = 'Loads initial data from load tables after a datebase refresh'

    def handle(self, *args, **options):
        self.stdout.write(self.style.NOTICE('Loading load tables'))
        # self._load_chem_inventory()
        self._load_material_identifier()
        self._load_material()
        self._load_inventory_material()
        self._load_vessels()
        self._load_experiment_related_def()
        self._load_experiment_and_workflow()
        self._load_mixture()
        self._load_base_bom_material()
        self._load_action()
        self._load_action_unit()
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
                    material_identifier = MaterialIdentifier.objects.get(
                            description=ref_name,
                            material_identifier_def=col_name_to_material_identifier_def[col_name],
                            status=active_status)
                    if material_identifier != None:
                        some_material.identifier.add(material_identifier)
            self.stdout.write(self.style.SUCCESS(f'Updated material identifier for materials'))
 
        self.stdout.write(self.style.NOTICE('Finished loading chem'))
    
    def _load_material_identifier(self):
        self.stdout.write(self.style.NOTICE('Beginning loading material identifier'))
        filename = 'load_material_identifier.csv'
        MATERIAL_IDENTIFIERS = path_to_file(filename)
        with open(MATERIAL_IDENTIFIERS, newline='') as f:
            reader = csv.reader(f, delimiter="\t")

            #first row should be header
            column_names = next(reader)

            #{'col_0': 0, 'col_1': 1, ...}
            column_names_to_index = list_data_to_index(column_names)

            active_status = Status.objects.get(description="active")

            material_identifier_def = {x.description:x for x in MaterialIdentifierDef.objects.all()}

            new_material_identifier = 0
            for row in reader:
                description = clean_string(row[column_names_to_index['description']])
                material_identifier_def__description = clean_string(row[column_names_to_index['material_identifier_def__description']])
                fields = {
                    'description': description,
                    'material_identifier_def': material_identifier_def[y] if not string_is_null(y := material_identifier_def__description) else None,
                    'status': active_status
                }
                material_identifier_instance, created = MaterialIdentifier.objects.get_or_create(**fields)
                if created:
                    new_material_identifier += 1
            # #jump to top of csv
            # f.seek(0)
            # #skip initial header row
            # next(reader)

            self.stdout.write(self.style.SUCCESS(f'Added {new_material_identifier} new material identifiers'))
        self.stdout.write(self.style.NOTICE('Finished loading material identifier'))

    def _load_material(self):
        self.stdout.write(self.style.NOTICE('Beginning loading material'))
        filename = 'load_material.csv'
        MATERIAL = path_to_file(filename)
        with open(MATERIAL, newline='') as f:
            reader = csv.reader(f, delimiter="\t")

            #first row should be header
            column_names = next(reader)

            #{'col_0': 0, 'col_1': 1, ...}
            column_names_to_index = list_data_to_index(column_names)

            material_identifier_def = {x.description:x for x in MaterialIdentifierDef.objects.all()}

            new_material = 0
            for row in reader:
                description = clean_string(row[column_names_to_index['description']])
                material_class = clean_string(row[column_names_to_index['material_class']])
                consumable = clean_string(row[column_names_to_index['consumable']])
                
                fields = {
                    'description': description,
                    'material_class': material_class,
                    'consumable': to_bool(consumable),
                }
                material_instance, created = Material.objects.get_or_create(**fields)
                
                material_identifier__description = [x.strip() for x in y.split('|')] if not string_is_null(y := row[column_names_to_index['material_identifier__description']]) else []
                material_identifier_def__description = [x.strip() for x in y.split('|')] if not string_is_null(y := row[column_names_to_index['material_identifier_def__description']]) else []

                material_type__description = [x.strip() for x in z.split('|')] if not string_is_null(z := row[column_names_to_index['material_type__description']]) else []

                material_instance.identifier.add(*[MaterialIdentifier.objects.get(description=descr,
                                                material_identifier_def=material_identifier_def[def_descr])
                                                for descr,def_descr in zip(material_identifier__description,material_identifier_def__description)])
                material_instance.material_type.add(*[MaterialType.objects.get(description=d) for d in material_type__description])
                
                if created:
                    new_material += 1
            # #jump to top of csv
            # f.seek(0)
            # #skip initial header row
            # next(reader)

            self.stdout.write(self.style.SUCCESS(f'Added {new_material} new materials'))
        self.stdout.write(self.style.NOTICE('Finished loading material'))

    def _load_inventory_material(self):
        self.stdout.write(self.style.NOTICE('Beginning loading inventory material'))
        filename = 'load_inventory_material.csv'
        INVENTORY_MATERIALS = path_to_file(filename)
        with open(INVENTORY_MATERIALS, newline='') as f:
            reader = csv.reader(f, delimiter="\t")

            #first row should be header
            column_names = next(reader)

            #{'col_0': 0, 'col_1': 1, ...}
            column_names_to_index = list_data_to_index(column_names)

            new_inventory_material = 0
            for row in reader:
                description = clean_string(row[column_names_to_index['description']])
                inventory_description = clean_string(row[column_names_to_index['inventory_description']])
                material_description = clean_string(row[column_names_to_index['material_description']])
                part_no = clean_string(row[column_names_to_index['part_no']])
                
                onhand_amt_type = clean_string(row[column_names_to_index['onhand_amt_type']])
                onhand_amt_unit = clean_string(row[column_names_to_index['onhand_amt_unit']])
                onhand_amt_value = clean_string(row[column_names_to_index['onhand_amt_value']])

                expiration_date = clean_string(row[column_names_to_index['expiration_date']])
                location = clean_string(row[column_names_to_index['location']])

                fields = {
                    'description': description,
                    'inventory': Inventory.objects.get(description=inventory_description) if not string_is_null(inventory_description) else None,
                    'material': Material.objects.get(description=material_description) if not string_is_null(material_description) else None,
                    'part_no': part_no,
                    'onhand_amt': get_val_field_dict(onhand_amt_type, onhand_amt_unit, onhand_amt_value),
                    'expiration_date': expiration_date if not string_is_null(expiration_date) else None,
                    'location': location
                }

                inventory_material_instance, created = InventoryMaterial.objects.get_or_create(**fields)
                if created:
                    new_inventory_material += 1
            self.stdout.write(self.style.SUCCESS(f'Added {new_inventory_material} new inventory materials'))
            # #jump to top of csv
            # f.seek(0)
            # #skip initial header row
            # next(reader)
        self.stdout.write(self.style.NOTICE('Finished loading inventory material'))

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
                row_desc = clean_string(row[column_names_to_index['description']])
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
    
#---------------EXPERIMENT--------------

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

        with open(PARAMETER_DEF, newline='') as f:
            reader = csv.reader(f, delimiter="\t")

            #first row should be header
            column_names = next(reader)

            #{'col_0': 0, 'col_1': 1, ...}
            column_names_to_index = list_data_to_index(column_names)

            new_parameter_def = 0
            for row in reader:
                description = clean_string(row[column_names_to_index['description']])
                type_ = clean_string(row[column_names_to_index['type']])
                value_from_csv = clean_string(row[column_names_to_index['value']])
                unit = clean_string(row[column_names_to_index['unit']])
                required = to_bool(row[column_names_to_index['required']])
                unit_type = clean_string(row[column_names_to_index['unit_type']])
                fields = {
                    'description': description,
                    'default_val': get_val_field_dict(type_, unit, value_from_csv),
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
                description = clean_string(row[column_names_to_index['description']])
                parameter_def_descriptions = [x.strip() for x in y.split(',')] if not string_is_null(y := row[column_names_to_index['parameter_def_descriptions']]) else []
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
                description = clean_string(row[column_names_to_index['description']])
                short_name = clean_string(row[column_names_to_index['short_name']])
                calc_definition = clean_string(row[column_names_to_index['calc_definition']])
                in_type__description = clean_string(row[column_names_to_index['in_type__description']])
                in_opt_type__description = clean_string(row[column_names_to_index['in_opt_type__description']])
                out_type__description = clean_string(row[column_names_to_index['out_type__description']])
                systemtool_name = clean_string(row[column_names_to_index['systemtool_name']])
                fields = {
                    'description': description,
                    'short_name': short_name,
                    'calc_definition': calc_definition,
                    'in_type': TypeDef.objects.get(description=in_type__description,category='data') if not string_is_null(in_type__description) else None,
                    'in_opt_type': TypeDef.objects.get(description=in_opt_type__description,category='data') if not string_is_null(in_opt_type__description) else None,
                    'out_type': TypeDef.objects.get(description=out_type__description,category='data') if not string_is_null(out_type__description) else None,
                    'systemtool': Systemtool.objects.get(systemtool_name=systemtool_name) if not string_is_null(systemtool_name) else None
                }
                calculation_def_instance, created = CalculationDef.objects.get_or_create(**fields)
                if created:
                    new_calculation_def += 1
                parameter_def_descriptions = [x.strip() for x in y.split(',')] if not string_is_null(y := row[column_names_to_index['parameter_def_descriptions']]) else [] 
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
                    'in_source': CalculationDef.objects.get(short_name=in_source__short_name) if not string_is_null(in_source__short_name) else None,
                    'in_opt_source': CalculationDef.objects.get(short_name=in_opt_source__short_name) if not string_is_null(in_opt_source__short_name) else None
                }
                for field, value in fields.items():
                    setattr(row_calculation_def_instance, field, value)
                row_calculation_def_instance.save(update_fields=['in_source','in_opt_source'])
            self.stdout.write(self.style.SUCCESS(f'Added {new_calculation_def} new calculation def'))            
        self.stdout.write(self.style.NOTICE('Finished loading calculation def'))

    def _load_experiment_and_workflow(self):
        self.stdout.write(self.style.NOTICE('Beginning loading experiment and workflow'))

        EXPERIMENT = path_to_file('load_experiment.csv')
        with open(EXPERIMENT, newline='') as f:
            reader = csv.reader(f, delimiter="\t")

            #first row should be header
            column_names = next(reader)

            #{'col_0': 0, 'col_1': 1, ...}
            column_names_to_index = list_data_to_index(column_names)

            experiment_type = {x.description:x for x in ExperimentType.objects.all()}

            new_experiment = 0
            for row in reader:
                description = clean_string(row[column_names_to_index['description']])
                ref_uid = clean_string(row[column_names_to_index['ref_uid']])
                experiment_type_description = clean_string(row[column_names_to_index['experiment_type_description']])
                owner_description = clean_string(row[column_names_to_index['owner_description']])
                operator_description = clean_string(row[column_names_to_index['operator_description']])
                lab_description = clean_string(row[column_names_to_index['lab_description']])

                fields = {
                    'description': description,
                    'ref_uid': ref_uid,
                    'experiment_type': experiment_type[descr] if not string_is_null(descr := experiment_type_description) else None,
                    'owner': Actor.objects.get(description=owner_description) if not string_is_null(owner_description) else None,
                    'operator': Actor.objects.get(description=operator_description) if not string_is_null(operator_description) else None,
                    'lab': Actor.objects.get(description=lab_description) if not string_is_null(lab_description) else None,
                }
                experiment_instance, created = Experiment.objects.get_or_create(**fields)
                if created:
                    new_experiment += 1

                bom_description = clean_string(row[column_names_to_index['bom_description']])
                BillOfMaterials.objects.get_or_create(description=bom_description,experiment=experiment_instance)

            #jump to top of csv
            f.seek(0)
            #skip initial header row
            next(reader)

            # go back and save parent
            for row in reader:
                description = clean_string(row[column_names_to_index['description']])
                parent_description = clean_string(row[column_names_to_index['parent_description']])
                row_experiment_instance = Experiment.objects.get(description=description)
                row_experiment_instance.parent = Experiment.objects.get(description=parent_description) if not string_is_null(parent_description) else None
                row_experiment_instance.save(update_fields=['parent'])
            self.stdout.write(self.style.SUCCESS(f'Added {new_experiment} new experiments')) 

        WORKFLOW = path_to_file('load_workflow.csv') 
        with open(WORKFLOW, newline='') as f:
            reader = csv.reader(f, delimiter="\t")

            #first row should be header
            column_names = next(reader)

            #{'col_0': 0, 'col_1': 1, ...}
            column_names_to_index = list_data_to_index(column_names)  

            workflow_type = {x.description:x for x in WorkflowType.objects.all()} 

            new_workflow = 0
            for row in reader:
                description = clean_string(row[column_names_to_index['description']])
                workflow_type_description = clean_string(row[column_names_to_index['workflow_type_description']])

                fields = {
                    'description': description,
                    'workflow_type': workflow_type[y] if not string_is_null(y := workflow_type_description) else None,
                }
                workflow_instance, created = Workflow.objects.get_or_create(**fields)
                if created:
                    new_workflow += 1
                experiment_description = [x.strip() for x in y.split(',')] if not string_is_null(y := clean_string(row[column_names_to_index['experiment_description']])) else []
                experiment_workflow_seq_num = [x.strip() for x in y.split(',')] if not string_is_null(y := clean_string(row[column_names_to_index['experiment_workflow_seq_num']])) else []

                for exp_desc, exp_wf_seq_num in zip(experiment_description, experiment_workflow_seq_num):
                    fields = {
                        'experiment': Experiment.objects.get(description=exp_desc) if not string_is_null(exp_desc) else None,
                        'workflow': workflow_instance,
                        'experiment_workflow_seq': int(exp_wf_seq_num) if not string_is_null(exp_wf_seq_num) else -1
                    }
                    ExperimentWorkflow.objects.get_or_create(**fields)
 
            #jump to top of csv
            f.seek(0)
            #skip initial header row
            next(reader)

            for row in reader:
                description = clean_string(row[column_names_to_index['description']])
                parent_description = clean_string(row[column_names_to_index['parent_description']])
                
                row_workflow_instance = Workflow.objects.get(description=description)
                parent = Workflow.objects.get(description=parent_description) if not string_is_null(parent_description) else None

                row_workflow_instance.parent = parent

                row_workflow_instance.save(update_fields=['parent'])
            self.stdout.write(self.style.SUCCESS(f'Added {new_workflow} new workflows'))

        self.stdout.write(self.style.NOTICE('Finished loading experiment and workflow'))

    def _load_mixture(self):
        self.stdout.write(self.style.NOTICE('Beginning loading mixture'))
        filename = 'load_mixture.csv'
        MIXTURE = path_to_file(filename)
        with open(MIXTURE, newline='') as f:
            reader = csv.reader(f, delimiter="\t")

            #first row should be header
            column_names = next(reader)

            #{'col_0': 0, 'col_1': 1, ...}
            column_names_to_index = list_data_to_index(column_names)

            new_mixture = 0
            for row in reader:
                material_composite_description = clean_string(row[column_names_to_index['material_composite_description']])
                material_component_description = clean_string(row[column_names_to_index['material_component_description']])
                addressable = clean_string(row[column_names_to_index['addressable']])
                fields = {
                    'composite': Material.objects.get(description=y) if not string_is_null(y := material_composite_description) else None,
                    'component': Material.objects.get(description=y) if not string_is_null(y := material_component_description) else None,
                    'addressable': to_bool(addressable)
                }
                mixture_instance, created = Mixture.objects.get_or_create(**fields)
                if created:
                    new_mixture += 1
            self.stdout.write(self.style.SUCCESS(f'Added {new_mixture} new mixture'))            
        self.stdout.write(self.style.NOTICE('Finished loading mixture'))

    def _load_base_bom_material(self):
        self.stdout.write(self.style.NOTICE('Beginning loading base bom material'))

        filename = 'load_base_bom_material.csv'
        BASE_BOM_MATERIAL = path_to_file(filename)
        with open(BASE_BOM_MATERIAL, newline='') as f:
            reader = csv.reader(f, delimiter="\t")

            #first row should be header
            column_names = next(reader)

            #{'col_0': 0, 'col_1': 1, ...}
            column_names_to_index = list_data_to_index(column_names)

            new_base_bom_material = 0
            new_bom_material = 0
            new_bom_composite_material = 0
            for row in reader:
                description = clean_string(row[column_names_to_index['description']])
                bom_description = clean_string(row[column_names_to_index['bom_description']])
                inventory_material_description = clean_string(row[column_names_to_index['inventory_material_description']])
                alloc_amt_val_type = clean_string(row[column_names_to_index['alloc_amt_val_type']])
                alloc_amt_val_unit = clean_string(row[column_names_to_index['alloc_amt_val_unit']])
                alloc_amt_val_value = clean_string(row[column_names_to_index['alloc_amt_val_value']])
                used_amt_val_type = clean_string(row[column_names_to_index['used_amt_val_type']])
                used_amt_val_unit = clean_string(row[column_names_to_index['used_amt_val_unit']])
                used_amt_val_value = clean_string(row[column_names_to_index['used_amt_val_value']])
                putback_amt_val_type = clean_string(row[column_names_to_index['putback_amt_val_type']])
                putback_amt_val_unit = clean_string(row[column_names_to_index['putback_amt_val_unit']])
                putback_amt_val_value = clean_string(row[column_names_to_index['putback_amt_val_value']])
                mixture_composite_description = clean_string(row[column_names_to_index['mixture_composite_description']])
                mixture_component_description = clean_string(row[column_names_to_index['mixture_component_description']])

                mixture_composite = Material.objects.get(description=y) if not string_is_null(y := mixture_composite_description) else None
                mixture_component = Material.objects.get(description=y) if not string_is_null(y := mixture_component_description) else None

                fields = {
                    'description': description,
                    'bom': BillOfMaterials.objects.get(description=bom_description) if not string_is_null(bom_description) else None,
                    'inventory_material': InventoryMaterial.objects.get(description=y) if not string_is_null(y := inventory_material_description) else None,
                    'alloc_amt_val': get_val_field_dict(alloc_amt_val_type, alloc_amt_val_unit, alloc_amt_val_value),
                    'used_amt_val': get_val_field_dict(used_amt_val_type, used_amt_val_unit, used_amt_val_value),
                    'putback_amt_val': get_val_field_dict(putback_amt_val_type, putback_amt_val_unit, putback_amt_val_value),
                    'mixture': Mixture.objects.get(composite=mixture_composite,component=mixture_component) if mixture_composite != None or mixture_component != None else None
                }

                base_bom_material_instance, created = BaseBomMaterial.objects.get_or_create(**fields)

                if created:
                    new_base_bom_material += 1
                    if fields['inventory_material'] != None and fields['mixture'] == None:
                        new_bom_material += 1
                    elif fields['inventory_material'] == None and fields['mixture'] != None:
                        new_bom_composite_material += 1

            #jump to top of csv
            f.seek(0)
            #skip initial header row
            next(reader)

            # go back and save self bom_material fk
            for row in reader:
                description = clean_string(row[column_names_to_index['description']])
                bom_description = clean_string(row[column_names_to_index['bom_description']])
                inventory_material_description = clean_string(row[column_names_to_index['inventory_material_description']])
                mixture_composite_description = clean_string(row[column_names_to_index['mixture_composite_description']])
                mixture_component_description = clean_string(row[column_names_to_index['mixture_component_description']])

                mixture_composite = Material.objects.get(description=y) if not string_is_null(y := mixture_composite_description) else None
                mixture_component = Material.objects.get(description=y) if not string_is_null(y := mixture_component_description) else None

                fields = {
                    'description': description,
                    'bom': BillOfMaterials.objects.get(description=bom_description) if not string_is_null(bom_description) else None,
                    'inventory_material': InventoryMaterial.objects.get(description=y) if not string_is_null(y := inventory_material_description) else None,
                    'mixture': Mixture.objects.get(composite=mixture_composite,component=mixture_component) if mixture_composite != None or mixture_component != None else None
                }

                bom_material_description = clean_string(row[column_names_to_index['bom_material_description']])
                bom_material_bom_description = clean_string(row[column_names_to_index['bom_material_bom_description']])
                bom_material_bom = BillOfMaterials.objects.get(description=y) if not string_is_null(y := bom_material_bom_description) else None

                row_base_bom_material_instance = BaseBomMaterial.objects.get(**fields)
                
                row_base_bom_material_instance.bom_material = BomMaterial.objects.get(description=y,bom=bom_material_bom) if not string_is_null(y := bom_material_description) else None

                row_base_bom_material_instance.save(update_fields=['bom_material'])
            self.stdout.write(self.style.SUCCESS(f'Added {new_base_bom_material} new base bom materials')) 
            self.stdout.write(self.style.SUCCESS(f'Added {new_bom_material} new bom materials')) 
            self.stdout.write(self.style.SUCCESS(f'Added {new_bom_composite_material} new bom composite materials')) 

    def _load_action(self):
        self.stdout.write(self.style.NOTICE('Beginning loading action'))
        filename = 'load_action.csv'
        ACTION = path_to_file(filename)
        with open(ACTION, newline='') as f:
            reader = csv.reader(f, delimiter="\t")

            #first row should be header
            column_names = next(reader)

            #{'col_0': 0, 'col_1': 1, ...}
            column_names_to_index = list_data_to_index(column_names)

            new_action = 0
            for row in reader:
                description = clean_string(row[column_names_to_index['description']])
                action_def_description = clean_string(row[column_names_to_index['action_def_description']])
                workflow_description = clean_string(row[column_names_to_index['workflow_description']])
                start_date = clean_string(row[column_names_to_index['start_date']])
                end_date = clean_string(row[column_names_to_index['end_date']])
                duration = clean_string(row[column_names_to_index['duration']])
                repeating = clean_string(row[column_names_to_index['repeating']])
                calculation_def_short_name = clean_string(row[column_names_to_index['calculation_def_short_name']])

                fields = {
                    'description': description,
                    'action_def': ActionDef.objects.get(description=y) if not string_is_null(y := action_def_description) else None,
                    'workflow': Workflow.objects.get(description=y) if not string_is_null(y := workflow_description) else None,
                    'start_date': start_date if not string_is_null(start_date) else None,
                    'end_date': end_date if not string_is_null(end_date) else None,
                    'duration': int(duration) if not string_is_null(duration) else None,
                    'repeating': int(repeating) if not string_is_null(repeating) else None,
                    'calculation_def': CalculationDef.objects.get(short_name=y) if not string_is_null(y:=calculation_def_short_name) else None
                }

                action_instance, created = Action.objects.get_or_create(**fields)

                if created:
                    new_action += 1

                parameter_def_description = [x.strip() for x in y.split(',')] if not string_is_null(y := row[column_names_to_index['parameter_def_description']]) else []
                action_instance.parameter_def.add(*[ParameterDef.objects.get(description=d) for d in parameter_def_description])

            self.stdout.write(self.style.SUCCESS(f'Added {new_action} new action'))            
        self.stdout.write(self.style.NOTICE('Finished loading action'))

    def _load_action_unit(self):
        self.stdout.write(self.style.NOTICE('Beginning loading action unit'))
        filename = 'load_action_unit.csv'
        ACTION_UNIT = path_to_file(filename)
        with open(ACTION_UNIT, newline='') as f:
            reader = csv.reader(f, delimiter="\t")

            #first row should be header
            column_names = next(reader)

            #{'col_0': 0, 'col_1': 1, ...}
            column_names_to_index = list_data_to_index(column_names)

            new_action_unit = 0
            for row in reader:
                action_description = clean_string(row[column_names_to_index['action_description']])
                action_workflow_description = clean_string(row[column_names_to_index['action_workflow_description']])

                source_material_description = clean_string(row[column_names_to_index['source_material_description']])
                source_material_bom_description = clean_string(row[column_names_to_index['source_material_bom_description']])
                
                destination_material_description = clean_string(row[column_names_to_index['destination_material_description']])
                destination_material_bom_description = clean_string(row[column_names_to_index['destination_material_bom_description']])

                source_material_bom = BillOfMaterials.objects.get(
                    description=source_material_bom_description,
                ) if not string_is_null(source_material_bom_description) else None

                destination_material_bom = BillOfMaterials.objects.get(
                    description=destination_material_bom_description,
                ) if not string_is_null(destination_material_bom_description) else None

                fields = {
                    'action': Action.objects.get(description=action_description,
                                                 workflow__description=action_workflow_description
                    ) if not string_is_null(action_description) else None,
                    'source_material': BaseBomMaterial.objects.get(description=source_material_description,
                                                                   bom=source_material_bom
                    ) if not string_is_null(source_material_description) else None,
                    'destination_material': BaseBomMaterial.objects.get(description=destination_material_description,
                                                                   bom=destination_material_bom
                    ) if not string_is_null(destination_material_description) else None,
                }

                action_unit_instance = ActionUnit.objects.create(**fields)

                new_action_unit += 1
            self.stdout.write(self.style.SUCCESS(f'Added {new_action_unit} new action units'))            
        self.stdout.write(self.style.NOTICE('Finished loading action unit'))

def path_to_file(filename):
    script_dir = os.path.dirname(__file__)
    csv_dir = '../../../../data_model/dataload_csv'
    return os.path.join(script_dir, f'{csv_dir}/{filename}')

def list_data_to_index(list_data):
    #hopefully list has hashable elements
    return {list_data[i]:i for i in range(len(list_data))}

def string_is_null(s):
    return s == None or s.strip() == '' or s.lower() == 'null'

def clean_string(s):
    if s != None:
        return s.strip()
    return None

def to_bool(s):
    if s == 't' or s.lower() == 'true' or s:
        return True
    else:
        return False

def get_val_field_dict(type_, unit, value_from_csv):
    if string_is_null(type_):
        return None
    if type_ == 'text':
        value = value_from_csv
    elif type_ == 'num':
        value = float(value_from_csv) if not string_is_null(value_from_csv) else 0.0
    elif type_ == 'int':
        value = int(value_from_csv) if not string_is_null(value_from_csv) else 0
    elif type_ == 'array_int':
        value = [int(x.strip()) for x in value_from_csv.split(',')] if not string_is_null(value_from_csv) else []
    elif type_ == 'array_num':
        value = [float(x.strip()) for x in value_from_csv.split(',')] if not string_is_null(value_from_csv) else []
    elif type_ == 'bool':
        value = to_bool(value_from_csv) if not string_is_null(value_from_csv) else False
    elif type_ == 'array_bool':
        value = [to_bool(x.strip()) for x in value_from_csv.split(',')] if not string_is_null(value_from_csv) else []
    elif type_ == 'array_text':
        value = [x.strip() for x in value_from_csv.split(',')] if not string_is_null(value_from_csv) else []
    elif type_ == 'blob':
        value = value_from_csv
    else:
        assert False, f'{type_} is an invalid type'
    return {
        'type': type_,
        'unit': unit,
        'value': value
    }


    