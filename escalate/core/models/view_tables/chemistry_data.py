from django.db import models
from core.models.core_tables import RetUUIDField, SlugField
from core.models.custom_types import ValField, PROPERTY_CLASS_CHOICES, PROPERTY_DEF_CLASS_CHOICES, MATERIAL_CLASS_CHOICES
import uuid
from core.models.base_classes import DateColumns, StatusColumn, ActorColumn, DescriptionColumn


manage_tables = True
manage_views = False

class Mixture(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='material_composite_uuid')
    composite = models.ForeignKey('Material', on_delete=models.DO_NOTHING,
                                  blank=True, null=True, db_column='composite_uuid',
                                  related_name='composite_material_composite')
    #composite_description = models.CharField(
    #    max_length=255, blank=True, null=True, editable=False)
    #composite_class = models.CharField(max_length=64, choices=MATERIAL_CLASS_CHOICES)
    #composite_flg = models.BooleanField(blank=True, null=True)
    component = models.ForeignKey('Material', on_delete=models.DO_NOTHING,
                                  blank=True, null=True, db_column='component_uuid',
                                  related_name='composite_material_component')
    #component_description = models.CharField(
    #    max_length=255, blank=True, null=True, editable=False)
    addressable = models.BooleanField(blank=True, null=True)
    #property = models.ManyToManyField('Property', through='CompositeMaterialProperty', related_name='composite_material_property',
    #    through_fields=('composite_material', 'property'))
    material_type = models.ManyToManyField('MaterialType', blank=True, 
                                      related_name='composite_material_material_type')
    internal_slug = SlugField(populate_from=[
                                    'composite__internal_slug',
                                    'component__internal_slug'
                                    ],
                              overwrite=True, 
                              max_length=255)
    
    def __str__(self):
        return "{} - {}".format(self.composite.description if self.composite else "", self.component.description if self.component else '')

class Vessel(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='vessel_uuid')
    plate_name = models.CharField(max_length = 64, blank=True, null=True)
    total_volume = models.CharField(max_length=255,blank=True, null=True)
    dead_volume = models.CharField(max_length=255,blank=True, null=True)
    #whole plate can leave well_number blank
    well_number = models.CharField(max_length = 16, blank=True, null=True)
    internal_slug = SlugField(populate_from=[
                                    'plate_name',
                                    'well_number'
                                    ],
                              overwrite=True, 
                              max_length=255)

    def __str__(self):
        return "{}  {}".format(self.plate_name, self.well_number)

class VesselInstance(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='vessel_instance_uuid')
    vessel_template = models.ForeignKey('Vessel', on_delete=models.DO_NOTHING,
                              blank=True, null=True,
                              related_name='vessel_instance_vessel_template')

    def __str__(self):
        return f'{self.description}'
    
class Contents(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='contents_uuid')
    vessel_instance = models.ForeignKey('VesselInstance', on_delete=models.DO_NOTHING,
                              blank=True, null=True,
                              related_name='contents_vessel_instance')
    base_bom_material = models.ForeignKey('BaseBomMaterial', on_delete=models.DO_NOTHING,
                                blank=True, null=True,
                                db_column='bom_material_uuid',
                                related_name='contents_bom_material_uuid')
    value = ValField(blank=True, null=True)
    
    def __str__(self):
        return f'{self.description}'

class Inventory(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='inventory_uuid')
    owner = models.ForeignKey('Actor', on_delete=models.DO_NOTHING,
                              blank=True, null=True,
                              db_column='owner_uuid',
                              related_name='inventory_owner')
    operator = models.ForeignKey('Actor', on_delete=models.DO_NOTHING,
                                 blank=True, null=True,
                                 db_column='operator_uuid',
                                 related_name='inventory_operator')
    lab = models.OneToOneField('Actor', on_delete=models.DO_NOTHING,
                                blank=True, null=True,
                                db_column='lab_uuid',
                                related_name='inventory_lab')
    internal_slug = SlugField(populate_from=[
                                    'description'
                                    ],
                              overwrite=True, 
                              max_length=255)

    def __str__(self):
        return "{}".format(self.description)


class InventoryMaterial(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='inventory_material_uuid')
    inventory = models.ForeignKey('Inventory', models.DO_NOTHING, db_column='inventory_uuid',
                                  related_name='inventory_material_inventory')
    material = models.ForeignKey('Material', models.DO_NOTHING,
                                 db_column='material_uuid',
                                 blank=True, null=True,
                                 related_name='inventory_material_material')
    #material_consumable = models.BooleanField()
    #material_composite_flg = models.BooleanField()
    part_no = models.CharField(max_length=255,
                               blank=True, null=True)
    onhand_amt = ValField( blank=True, null=True)
    expiration_date = models.DateTimeField(blank=True, null=True)
    location = models.CharField(max_length=255, blank=True, null=True)
    internal_slug = SlugField(populate_from=[
                                    'inventory__internal_slug',
                                    'material__internal_slug'
                                    ],
                              overwrite=True, 
                              max_length=255)
    phase = models.CharField(max_length=6, 
                             choices=[('liquid', 'Liquid'), 
                                      ('solid', 'Solid'),
                                      ('gas', 'Gas')],
                            blank=True, null=True)

    def __str__(self):
        return "{} : {}".format(self.inventory, self.material)


class Material(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='material_uuid')
    consumable = models.BooleanField(blank=True, null=True)
    #composite_flg = models.BooleanField(blank=True, null=True)
    #material_types = models.ManyToManyField('MaterialType', 
    #                                        through='MaterialTypeAssign',
    #                                        related_name='material_material_types')
    material_class = models.CharField(max_length=64, choices=MATERIAL_CLASS_CHOICES)
    
    #need to remove through crosstables when managed by django
    #property = models.ManyToManyField('Property', blank=True, 
    #                                  related_name='material_property')
    identifier = models.ManyToManyField('MaterialIdentifier', blank=True, 
                                      related_name='material_material_identifier')
    material_type = models.ManyToManyField('MaterialType', blank=True, 
                                      related_name='material_material_type')
    internal_slug = SlugField(populate_from=[
                                    'description'
                                    ],
                              overwrite=True, 
                              max_length=255)

    def __str__(self):
        return "{}".format(self.description)



class MaterialIdentifier(DateColumns, StatusColumn, DescriptionColumn):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column='material_refname_uuid')
    material_identifier_def = models.ForeignKey('MaterialIdentifierDef',
                               on_delete=models.DO_NOTHING,
                               blank=True,
                               null=True,
                               db_column='material_refname_def_uuid',
                               related_name='material_identifier_material_identifier_def')
    internal_slug = SlugField(populate_from=[
                                    'material_identifier_def__internal_slug',
                                    'description'
                                    ],
                              overwrite=True, 
                              max_length=255)
    full_description = models.CharField(max_length=1024, blank=True, null=True)
    
    def __str__(self):
        #return "{}: {}".format(self.material_identifier_def, self.description)
        return self.full_description

    def save(self, *args, **kwargs):
        self.full_description = f"{self.material_identifier_def}: {self.description}"
        super().save(*args, **kwargs)

class MaterialIdentifierDef(DateColumns, DescriptionColumn):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column='material_refname_def_uuid')
    internal_slug = SlugField(populate_from=[
                                    'description'
                                    ],
                              overwrite=True, 
                              max_length=255)

    def __str__(self):
        return "{}".format(self.description)

class MaterialType(DateColumns, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='material_type_uuid')
    internal_slug = SlugField(populate_from=[
                                'description'
                                ],
                            overwrite=True, 
                            max_length=255)

    def __str__(self):
        return "{}".format(self.description)


class ReagentTemplate(DateColumns, DescriptionColumn, StatusColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4)
    internal_slug = SlugField(populate_from=[
                                'description'
                                ],
                            overwrite=True, 
                            max_length=255)
    material_type = models.ManyToManyField('MaterialType', blank=True, 
                                      related_name='reagent_template_material_type')

    def __str__(self):
        return self.description

class ReagentInstance(DateColumns, DescriptionColumn, StatusColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4)
    reagent_template = models.ForeignKey('ReagentTemplate', on_delete=models.DO_NOTHING,
                          related_name='reagent_instance_reagent_template')
    experiment = models.ForeignKey('ExperimentInstance', on_delete=models.DO_NOTHING,
                          related_name='reagent_instance_experiment_instance')
    
    def __str__(self):
        return self.description

class ReagentInstanceValue(DateColumns, DescriptionColumn, StatusColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4)
    reagent_instance = models.ForeignKey('ReagentInstance', on_delete=models.DO_NOTHING,
                          related_name='reagent_instance_value_reagent_instance')
    nominal_value = ValField(null=True, blank=True)
    actual_value = ValField(null=True, blank=True)
    material = models.ForeignKey('InventoryMaterial', on_delete=models.DO_NOTHING,
                          related_name='reagent_instance_value_inventory_material')


