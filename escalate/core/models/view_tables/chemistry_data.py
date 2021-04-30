from django.db import models
from core.models.core_tables import RetUUIDField
from core.models.custom_types import ValField, PROPERTY_CLASS_CHOICES, PROPERTY_DEF_CLASS_CHOICES, MATERIAL_CLASS_CHOICES


class CompositeMaterial(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='material_composite_uuid')
    composite = models.ForeignKey('Material', on_delete=models.DO_NOTHING,
                                  blank=True, null=True, db_column='composite_uuid',
                                  related_name='composite_material_composite')
    composite_description = models.CharField(
        max_length=255, blank=True, null=True, editable=False)
    composite_class = models.CharField(max_length=64, choices=MATERIAL_CLASS_CHOICES)
    composite_flg = models.BooleanField(blank=True, null=True)
    component = models.ForeignKey('Material', on_delete=models.DO_NOTHING,
                                  blank=True, null=True, db_column='component_uuid',
                                  related_name='composite_material_component')
    component_description = models.CharField(
        max_length=255, blank=True, null=True, editable=False)
    addressable = models.BooleanField(blank=True, null=True)
    property = models.ManyToManyField(
        'Property', through='CompositeMaterialProperty', related_name='composite_material_property',
        through_fields=('composite_material', 'property'))

    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              related_name='composite_material_actor')
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               related_name='composite_material_status')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_material_composite'


class CompositeMaterialProperty(models.Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='material_composite_uuid')
    composite_material = models.ForeignKey('CompositeMaterial',
                                           db_column='composite_uuid',
                                           on_delete=models.DO_NOTHING,
                                           blank=True, null=True,
                                           related_name='composite_material_property_composite_material')
    composite_class = models.CharField(max_length=64, choices=MATERIAL_CLASS_CHOICES, editable=False)
    composite_material_description = models.CharField(max_length=255,
                                                      blank=True,
                                                      null=True,
                                                      db_column='composite_description',
                                                      editable=False)
    component = models.ForeignKey('CompositeMaterial',
                                  db_column='component_uuid',
                                  on_delete=models.DO_NOTHING,
                                  blank=True, null=True,
                                  related_name='composite_material_property_component')
    component_class = models.CharField(max_length=64, choices=MATERIAL_CLASS_CHOICES, editable=False)
    property = models.ForeignKey('Property',
                                 on_delete=models.DO_NOTHING,
                                 db_column='property_uuid',
                                 blank=True,
                                 null=True,
                                 editable=False,
                                 related_name='composite_material_property_property')
    property_class = models.CharField(max_length=64, choices=PROPERTY_CLASS_CHOICES)
    property_def = models.ForeignKey('PropertyDef',
                                     on_delete=models.DO_NOTHING,
                                     db_column='property_def_uuid',
                                     blank=True,
                                     null=True, related_name='composite_material_property_property_def')
    property_def_class = models.CharField(max_length=64, choices=PROPERTY_DEF_CLASS_CHOICES, editable=False)
    property_description = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            db_column='property_description',
                                            editable=False)
    property_short_description = models.CharField(max_length=255,
                                                  blank=True,
                                                  null=True,
                                                  db_column='property_short_description',
                                                  editable=False)
    value = ValField(max_length=255,
        blank=True,
        null=True,
        db_column='property_value_val')
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='property_actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='composite_material_property_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='property_actor_description',
                                         editable=False)
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               blank=True,
                               null=True,
                               db_column='property_status_uuid',
                               related_name='composite_material_property_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='property_status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_material_composite_property'


class Inventory(models.Model):
    uuid = RetUUIDField(
        primary_key=True, db_column='inventory_uuid')
    description = models.CharField(
        max_length=255, blank=True, null=True)
    owner = models.ForeignKey('Actor', on_delete=models.DO_NOTHING,
                              blank=True, null=True,
                              db_column='owner_uuid',
                              related_name='inventory_owner')
    owner_description = models.CharField(max_length=255, blank=True, null=True)
    operator = models.ForeignKey('Actor', on_delete=models.DO_NOTHING,
                                 blank=True, null=True,
                                 db_column='operator_uuid',
                                 related_name='inventory_operator')
    operator_description = models.CharField(
        max_length=255, blank=True, null=True)
    lab = models.OneToOneField('Actor', on_delete=models.DO_NOTHING,
                                blank=True, null=True,
                                db_column='lab_uuid',
                                related_name='inventory_lab')
    lab_description = models.CharField(max_length=255, blank=True, null=True)
    status = models.ForeignKey('Status', on_delete=models.DO_NOTHING,
                               blank=True, null=True,
                               db_column='status_uuid',
                               related_name='inventory_status')
    status_description = models.CharField(max_length=255, blank=True, 
                                          null=True, editable=False)
    actor = models.ForeignKey('Actor', models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True, null=True,
                              related_name='inventory_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True, null=True, editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_inventory'

    def __str__(self):
        return "{}".format(self.description)


class InventoryMaterial(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='inventory_material_uuid')
    description = models.CharField(
        max_length=255, blank=True, null=True)
    inventory = models.ForeignKey('Inventory', models.DO_NOTHING, db_column='inventory_uuid',
                                  related_name='inventory_material_inventory')
    inventory_description = models.CharField(max_length=255,
                                             blank=True, null=True)
    material = models.ForeignKey('Material', models.DO_NOTHING,
                                 db_column='material_uuid',
                                 blank=True, null=True,
                                 related_name='inventory_material_material')
    material_description = models.CharField(max_length=255,
                                            blank=True, null=True)
    material_consumable = models.BooleanField()
    material_composite_flg = models.BooleanField()
    part_no = models.CharField(max_length=255,
                               blank=True, null=True)
    onhand_amt = ValField(max_length=255, blank=True, null=True)
    expiration_date = models.DateTimeField(blank=True, null=True)
    location = models.CharField(
        max_length=255, blank=True, null=True)
    actor = models.ForeignKey('Actor', models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True, null=True, related_name='inventory_material_actor')
    actor_description = models.CharField(max_length=255, blank=True, null=True)
    status = models.ForeignKey('Status', models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True, null=True,
                               related_name='inventory_material_status')
    status_description = models.CharField(
        max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_inventory_material'

    def __str__(self):
        return "{} : {}".format(self.inventory_description, self.material_description)


class InventoryMaterialMaterial(models.Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='inventory_material_uuid')
    inventory = models.ForeignKey('Inventory',
                                    db_column='inventory_uuid',
                                    on_delete=models.DO_NOTHING,
                                    blank=True, null=True,
                                    related_name='inventory_material_material_inventory')
    actor = models.ForeignKey('Actor',
                                    db_column='actor_uuid',
                                    on_delete=models.DO_NOTHING,
                                    blank=True, null=True,
                                    related_name='inventory_material_material_actor')
    material =  models.ForeignKey('Material',
                                    db_column='material_uuid',
                                    on_delete=models.DO_NOTHING,
                                    blank=True, null=True,
                                    related_name='inventory_material_material_material')
    
    class Meta:
        managed = False
        db_table = 'vw_inventory_material_material'


class Material(models.Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='material_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)
    consumable = models.BooleanField(blank=True, null=True)
    composite_flg = models.BooleanField(blank=True, null=True)
    material_types = models.ManyToManyField('MaterialType', 
                                            through='MaterialTypeAssign',
                                            related_name='material_material_types')
    material_class = models.CharField(max_length=64, choices=MATERIAL_CLASS_CHOICES)

    actor = models.ForeignKey('Actor', models.DO_NOTHING, blank=True, null=True,
                              db_column='actor_uuid',
                              related_name='material_actor')
    actor_description = models.CharField(max_length=255, blank=True, null=True, editable=False)

    status = models.ForeignKey('Status', on_delete=models.DO_NOTHING,
                               blank=True, null=True, db_column='status_uuid',
                               related_name='material_status')
    property = models.ManyToManyField('Property', through='MaterialProperty', 
                                      related_name='material_property')
    status_description = models.CharField(
        max_length=255, blank=True, null=True, editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_material'

    def __str__(self):
        return "{}".format(self.description)


class MaterialProperty(models.Model):
    # TODO: Material property may need fixing. Endpoint displays all tags for all rows
    uuid = RetUUIDField(primary_key=True,
                        db_column='property_x_uuid')
    material = models.ForeignKey('Material',
                                 db_column='material_uuid',
                                 on_delete=models.DO_NOTHING,
                                 blank=True,
                                 null=True, related_name='material_property_material')
    material_class = models.CharField(max_length=64, choices=MATERIAL_CLASS_CHOICES, editable=False)
    description = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            db_column='description',
                                            editable=False)
    property = models.ForeignKey('Property',
                                 on_delete=models.DO_NOTHING,
                                 db_column='property_uuid',
                                 blank=True,
                                 null=True,
                                 editable=False,
                                 related_name='material_property_property')
    property_def = models.ForeignKey('PropertyDef',
                                     on_delete=models.DO_NOTHING,
                                     db_column='property_def_uuid',
                                     blank=True,
                                     null=True, related_name='material_property_property_def')
    property_description = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            db_column='property_description',
                                            editable=False)
    property_short_description = models.CharField(max_length=255,
                                                  blank=True,
                                                  null=True,
                                                  db_column='property_short_description',
                                                  editable=False)
    value = models.CharField(max_length=255, blank=True, null=True, db_column='property_value')
    value_unit = models.CharField(max_length=255, blank=True, null=True, editable=False, db_column='property_value_unit')
    #value = CharField(max_length=255, blank=True, null=True, db_column='property_value_val')
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='property_actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='material_property_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='property_actor_description',
                                         editable=False)
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               blank=True,
                               null=True,
                               db_column='property_status_uuid',
                               related_name='material_property_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='property_status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True, db_column='property_add_date')
    mod_date = models.DateTimeField(auto_now=True, db_column='property_mod_date')

    class Meta:
        managed = False
        db_table = 'vw_material_property'


class MaterialRefname(models.Model):
    uuid = RetUUIDField(
        primary_key=True, db_column='material_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               blank=True,
                               null=True,
                               db_column='material_status_uuid',
                               related_name='material_refname_status')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)
    abbreviation = models.CharField(max_length=255, blank=True, null=True)
    chemical_name = models.CharField(max_length=255, blank=True, null=True)
    inchi = models.CharField(max_length=255, blank=True, null=True)
    inchikey = models.CharField(max_length=255, blank=True, null=True)
    molecular_formula = models.CharField(max_length=255, blank=True, null=True)
    smiles = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_material_refname'


class MaterialRefnameDef(models.Model):
    uuid = RetUUIDField(
        primary_key=True, db_column='material_refname_def_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_material_refname_def'

    def __str__(self):
        return "{}".format(self.description)


class MaterialType(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='material_type_uuid')
    description = models.TextField(blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_material_type'

    def __str__(self):
        return "{}".format(self.description)


class MaterialTypeAssign(models.Model):
    uuid = RetUUIDField(
        primary_key=True, db_column='material_type_x_uuid')
    material = models.ForeignKey('Material',
                               on_delete=models.DO_NOTHING,
                               blank=True,
                               null=True,
                               db_column='material_uuid',
                               related_name='material_type_assign_material')
    material_type = models.ForeignKey('MaterialType',
                               on_delete=models.DO_NOTHING,
                               blank=True,
                               null=True,
                               db_column='material_type_uuid',
                               related_name='material_type_assign')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_material_type_assign'