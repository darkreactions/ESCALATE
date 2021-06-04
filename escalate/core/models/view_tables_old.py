import django
from django.db import models
from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType
from packaging import version
if version.parse(django.__version__) < version.parse('3.1'):
    from django.contrib.postgres.fields import JSONField
else:
    from django.db.models import JSONField
from django.db.models.fields import CharField, related
from .core_tables import RetUUIDField
from .custom_types import ValField

managed_value = False


class Actor(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='actor_uuid')
    organization = models.ForeignKey('Organization',
                                     on_delete=models.DO_NOTHING,
                                     blank=True, null=True,
                                     db_column='organization_uuid', related_name='actor_organization')
    person = models.ForeignKey('Person',
                               on_delete=models.DO_NOTHING,
                               blank=True, null=True,
                               db_column='person_uuid', related_name='actor_person')
    systemtool = models.ForeignKey('Systemtool',
                                   on_delete=models.DO_NOTHING,
                                   blank=True, null=True,
                                   db_column='systemtool_uuid',
                                   related_name='actor_systemtool')
    description = models.CharField(max_length=255, blank=True, null=True)
    status = models.ForeignKey('Status', on_delete=models.DO_NOTHING,
                               blank=True, null=True,
                               db_column='status_uuid',
                               related_name='actor_status')
    status_description = models.CharField(
        max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)
    org_full_name = models.CharField(
        max_length=255, blank=True, null=True, verbose_name='Organization Full Name')
    org_short_name = models.CharField(
        max_length=255, blank=True, null=True, verbose_name='Organization Short Name')

    person_last_name = models.CharField(
        max_length=255, blank=True, null=True, verbose_name='Person Lastname')
    person_first_name = models.CharField(
        max_length=255, blank=True, null=True)
    person_last_first = models.CharField(
        max_length=255, blank=True, null=True)
    person_org = models.CharField(max_length=255, blank=True, null=True)
    systemtool_name = models.CharField(
        max_length=255, blank=True, null=True)
    systemtool_description = models.CharField(
        max_length=255, blank=True, null=True)
    systemtool_type = models.CharField(
        max_length=255, blank=True, null=True)
    systemtool_vendor = models.CharField(
        max_length=255, blank=True, null=True)
    systemtool_model = models.CharField(
        max_length=255, blank=True, null=True)
    systemtool_serial = models.CharField(
        max_length=255, blank=True, null=True)
    systemtool_version = models.CharField(
        max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_actor'

    def __str__(self):
        return "{}".format(self.description)


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
    lab = models.ForeignKey('Actor', on_delete=models.DO_NOTHING,
                            blank=True, null=True,
                            db_column='lab_uuid',
                            related_name='inventory_lab')
    lab_description = models.CharField(max_length=255, blank=True, null=True)
    status = models.ForeignKey('Status', on_delete=models.DO_NOTHING,
                               blank=True, null=True,
                               db_column='status_uuid',
                               related_name='inventory_status')
    status_description = models.CharField(
        max_length=255, blank=True, null=True, editable=False)
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
    #onhand_amt = models.CharField(
    #    max_length=255, blank=True, null=True)
    onhand_amt = ValField(blank=True, null=True)
    # inventory_unit = models.CharField(max_length=255, blank=True, null=True)
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


class Systemtool(models.Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='systemtool_uuid')
    systemtool_name = models.CharField(max_length=255, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    vendor_organization = models.ForeignKey('Organization',
                                            models.DO_NOTHING,
                                            db_column='vendor_organization_uuid',
                                            related_name='systemtool_vendor_organization')
    organization_fullname = models.CharField(
        max_length=255, blank=True, null=True)
    systemtool_type = models.ForeignKey('SystemtoolType',
                                        models.DO_NOTHING,
                                        db_column='systemtool_type_uuid',
                                        related_name='systemtool_systemtool_type')
    systemtool_type_description = models.CharField(
        max_length=255, blank=True, null=True)
    model = models.CharField(max_length=255, blank=True, null=True)
    serial = models.CharField(max_length=255, blank=True, null=True)
    ver = models.CharField(max_length=255,  null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_systemtool'

    def __str__(self):
        return "{}".format(self.systemtool_name)


class SystemtoolType(models.Model):
    #systemtool_type_id = models.BigAutoField()
    uuid = RetUUIDField(primary_key=True, db_column='systemtool_type_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_systemtool_type'

    def __str__(self):
        return self.description


class Calculation(models.Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='calculation_uuid')
    in_val = ValField(blank=True, null=True)
    #in_val = CharField(max_length=255, blank=True, null=True)
    in_val_type = models.ForeignKey('TypeDef',
                                    models.DO_NOTHING,
                                    db_column='in_val_type_uuid',
                                    related_name='calculation_in_val_type', editable=False)
    in_val_value = models.TextField(blank=True, null=True, editable=False)
    in_val_unit = models.TextField(blank=True, null=True, editable=False)
    in_val_edocument = models.ForeignKey('Edocument',
                                         models.DO_NOTHING,
                                         db_column='in_val_edocument_uuid',
                                         related_name='calculation_in_val_edocument', editable=False)

    # in opt
    in_opt_val = ValField(blank=True, null=True)
    #in_opt_val = CharField(max_length=255, blank=True, null=True)
    in_opt_val_value = models.TextField(blank=True, null=True, editable=False)
    in_opt_val_type = models.ForeignKey('TypeDef',
                                        models.DO_NOTHING,
                                        related_name='calculation_in_opt_val_type',
                                        db_column='in_opt_val_type_uuid',
                                        blank=True, null=True, editable=False)
    in_opt_val_unit = models.TextField(blank=True, null=True, editable=False)
    in_opt_val_edocument = models.ForeignKey('Edocument',
                                             models.DO_NOTHING,
                                             db_column='in_opt_val_edocument_uuid',
                                             related_name='calculation_in_opt_val_edocument', editable=False)
    # out
    out_val = ValField(blank=True, null=True)
    #out_val = CharField(max_length=255, blank=True, null=True)
    out_val_type = models.ForeignKey('TypeDef',
                                     models.DO_NOTHING,
                                     related_name='calculation_out_val_type',
                                     db_column='out_val_type_uuid',
                                     blank=True, null=True, editable=False)
    out_val_value = models.TextField(blank=True, null=True, editable=False)
    out_val_unit = models.TextField(blank=True, null=True, editable=False)
    out_val_edocument = models.ForeignKey('Edocument',
                                          models.DO_NOTHING,
                                          db_column='out_val_edocument_uuid',
                                          related_name='calculation_out_val_edocument', editable=False)

    calculation_alias_name = models.CharField(
        max_length=255, blank=True, null=True)

    status = models.ForeignKey('Status',
                               models.DO_NOTHING,
                               db_column='calculation_status_uuid',
                               related_name='calculation_status')
    status_description = models.CharField(max_length=255,
                                          blank=True, null=True)
    calculation_def = models.ForeignKey('CalculationDef',
                                        models.DO_NOTHING,
                                        blank=True, null=True,
                                        db_column='calculation_def_uuid',
                                        related_name='calculation_calculation_def')
    short_name = models.CharField(max_length=255, blank=True, null=True)
    calc_definition = models.CharField(max_length=255, blank=True, null=True)

    description = models.CharField(max_length=1023, blank=True, null=True)

    systemtool = models.ForeignKey('Systemtool',
                                   models.DO_NOTHING,
                                   db_column='systemtool_uuid',
                                   related_name='calculation_systemtool')
    systemtool_name = models.CharField(max_length=1023, blank=True, null=True)
    systemtool_type_description = models.CharField(
        max_length=1023, blank=True, null=True)
    systemtool_vendor_organization = models.CharField(
        max_length=1023, blank=True, null=True, db_column='systemtool_vendor_organization')
    systemtool_version = models.CharField(
        max_length=1023, blank=True, null=True)

    actor = models.ForeignKey(
        'Actor', models.DO_NOTHING, db_column='actor_uuid', blank=True, null=True,
        related_name='calculation_actor')
    actor_description = models.CharField(
        max_length=1023, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_calculation'


class CalculationDef(models.Model):
    uuid = RetUUIDField(
        primary_key=True, db_column='calculation_def_uuid')
    short_name = models.CharField(max_length=255, blank=True, null=True)
    calc_definition = models.CharField(max_length=255, blank=True, null=True)
    description = models.CharField(max_length=1023, blank=True, null=True)
    in_type = models.ForeignKey('TypeDef',
                                models.DO_NOTHING,
                                db_column='in_type_uuid',
                                related_name='calculation_def_in_type')
    in_type_description = models.CharField(
        max_length=255, blank=True, null=True)
    out_type = models.ForeignKey('TypeDef',
                                 models.DO_NOTHING,
                                 blank=True, null=True,
                                 db_column='out_type_uuid',
                                 related_name='calculation_def_out_type')
    out_type_description = models.CharField(
        max_length=255, blank=True, null=True)
    systemtool = models.ForeignKey('Systemtool',
                                   models.DO_NOTHING,
                                   db_column='systemtool_uuid', related_name='calculation_def_systemtool')
    systemtool_name = models.CharField(max_length=255, blank=True, null=True)
    systemtool_type_description = models.CharField(
        max_length=255, blank=True, null=True)
    systemtool_vendor_organization = models.CharField(
        max_length=255, blank=True, null=True, db_column='systemtool_vendor_organization')
    systemtool_version = models.CharField(
        max_length=255, blank=True, null=True)
    actor = models.ForeignKey(
        'Actor', models.DO_NOTHING, blank=True, null=True, db_column='actor_uuid', related_name='calculation_def_actor')
    actor_description = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_calculation_def'

    def __str__(self):
        return "{}".format(self.description)


class Material(models.Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='material_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)
    consumable = models.BooleanField(blank=True, null=True)
    composite_flg = models.BooleanField(blank=True, null=True)
    actor = models.ForeignKey('Actor', models.DO_NOTHING, blank=True, null=True,
                              db_column='actor_uuid',
                              related_name='material_actor')
    actor_description = models.CharField(max_length=255, blank=True, null=True)

    status = models.ForeignKey('Status', on_delete=models.DO_NOTHING,
                               blank=True, null=True, db_column='status_uuid',
                               related_name='material_status')
    property = models.ManyToManyField(
        'Property', through='MaterialProperty', related_name='material_property')
    status_description = models.CharField(
        max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_material'

    def __str__(self):
        return "{}".format(self.description)


class CompositeMaterial(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='material_composite_uuid')
    composite = models.ForeignKey('Material', on_delete=models.DO_NOTHING,
                                  blank=True, null=True, db_column='composite_uuid',
                                  related_name='composite_material_composite')
    composite_description = models.CharField(
        max_length=255, blank=True, null=True)
    composite_flg = models.BooleanField(blank=True, null=True)
    component = models.ForeignKey('CompositeMaterial', on_delete=models.DO_NOTHING,
                                  blank=True, null=True, db_column='component_uuid',
                                  related_name='composite_material_component')
    component_description = models.CharField(
        max_length=255, blank=True, null=True)
    addressable = models.BooleanField(blank=True, null=True)
    property = models.ManyToManyField(
        'Property', through='CompositeMaterialProperty', related_name='composite_material_property',
        through_fields=('composite_material', 'property'))

    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='actor')
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='status')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_material_composite'


class BillOfMaterials(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='bom_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)
    experiment = models.ForeignKey('Experiment', on_delete=models.DO_NOTHING,
                                   blank=True, null=True, db_column='experiment_uuid',
                                   related_name='bom_experiment')
    experiment_description = models.CharField(
        max_length=255, blank=True, null=True)

    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='bom_actor')
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='bom_status')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_bom'


class BomMaterial(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='bom_material_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)
    bom = models.ForeignKey('BillOfMaterials', on_delete=models.DO_NOTHING,
                            blank=True, null=True, db_column='bom_uuid',
                            related_name='bom_material_bom')
    
    bom_description = models.CharField(max_length=255, blank=True, null=True)
    inventory_material = models.ForeignKey('InventoryMaterial', on_delete=models.DO_NOTHING,
                                           blank=True, null=True, db_column='inventory_material_uuid',
                                           related_name='bom_material_inventory_material')
    material = models.ForeignKey('Material', on_delete=models.DO_NOTHING,
                                 blank=True, null=True, db_column='material_uuid',
                                 related_name='bom_material_material')
    alloc_amt_val = ValField(blank=True, null=True)
    used_amt_val = ValField(blank=True, null=True)
    putback_amt_val = ValField(blank=True, null=True)
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='bom_material_actor')
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='bom_material_status')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)
    
    class Meta:
        managed = False
        db_table = 'vw_bom_material'


class BomCompositeMaterial(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='bom_material_composite_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)
    bom_material = models.ForeignKey('BomMaterial', on_delete=models.DO_NOTHING,
                            blank=True, null=True, db_column='bom_material_uuid',
                            related_name='bom_composite_material_bom_material')
    bom_material_description = models.CharField(max_length=255, blank=True, null=True)
    
    composite_material = models.ForeignKey('CompositeMaterial', on_delete=models.DO_NOTHING,
                                               blank=True, null=True, db_column='material_composite_uuid',
                                               related_name='bom_composite_material_composite_material')
    component = models.ForeignKey('Material', on_delete=models.DO_NOTHING,
                                               blank=True, null=True, db_column='component_uuid',
                                               related_name='bom_composite_material_component')
    material_description = models.CharField(max_length=255,
                                                          blank=True,
                                                          null=True)
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='bom_composite_material_actor')
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='bom_composite_material_status')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_bom_material_composite'


class MaterialCalculationJson(models.Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='material_uuid')
    material_status = RetUUIDField(db_column='material_status_uuid')
    material_status_description = models.CharField(
        max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)
    abbreviation = models.CharField(
        db_column='abbreviation', max_length=255, blank=True, null=True)
    chemical_name = models.CharField(
        db_column='chemical_name', max_length=255, blank=True, null=True)
    inchi = models.CharField(
        db_column='inchi', max_length=255, blank=True, null=True)
    inchikey = models.CharField(
        db_column='inchikey', max_length=255, blank=True, null=True)
    molecular_formula = models.CharField(
        db_column='molecular_formula', max_length=255, blank=True, null=True)
    smiles = models.CharField(
        db_column='smiles', max_length=255, blank=True, null=True)
    calculation_json = JSONField()

    class Meta:
        managed = False
        db_table = 'vw_material_calculation_json'

    def __str__(self):
        return "{}".format(self.chemical_name)


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


class Note(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='note_uuid')
    notetext = models.TextField(blank=True, null=True,
                                verbose_name='Note Text')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)
    actor = models.ForeignKey('Actor', models.DO_NOTHING,
                              db_column='actor_uuid', related_name='note_actor')
    actor_description = models.CharField(
        max_length=255, blank=True, null=True, editable=False)
    """
    note_x_uuid = models.ForeignKey('Note_x', models.DO_NOTHING,
                                  blank=True,
                                  null=True,
                                  editable=False,
                                  db_column='note_x_uuid',
                                  related_name='note_note_x')
    """
    ref_note_uuid = RetUUIDField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_note'

    def __str__(self):
        return "{}".format(self.notetext)


class Note_x(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='note_x_uuid')
    ref_note = RetUUIDField(db_column='ref_note_uuid')
    note = models.ForeignKey('Note', models.DO_NOTHING,
                             blank=True,
                             null=True,
                             editable=False,
                             db_column='note_uuid',
                             related_name='note_x_note')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'note_x'

    def __str__(self):
        return "{}".format(self.note_uuid)


class Measure_x(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='measure_x_uuid')
    ref_measure = RetUUIDField(db_column='ref_measure_uuid')
    measure = models.ForeignKey('Measure', models.DO_NOTHING,
                             blank=True,
                             null=True,
                             editable=False,
                             db_column='measure_uuid',
                             related_name='measure_x_measure')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'measure_x'

    def __str__(self):
        return "{}".format(self.measure_uuid)


class Organization(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='organization_uuid')
    description = models.CharField(max_length=255)
    full_name = models.CharField(max_length=255)
    short_name = models.CharField(max_length=255, blank=True, null=True)
    address1 = models.CharField(max_length=255, blank=True, null=True)
    address2 = models.CharField(max_length=255, blank=True, null=True)
    city = models.CharField(max_length=255, blank=True, null=True)
    state_province = models.CharField(max_length=3, blank=True, null=True)
    zip = models.CharField(max_length=255, blank=True, null=True)
    country = models.CharField(max_length=255, blank=True, null=True)
    website_url = models.CharField(max_length=255, blank=True, null=True)
    phone = models.CharField(max_length=255, blank=True, null=True)

    parent = models.ForeignKey('self', models.DO_NOTHING,
                               blank=True, null=True,
                               db_column='parent_uuid',
                               related_name='organization_parent')
    parent_org_full_name = models.CharField(
        max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_organization'

    def __str__(self):
        return "{}".format(self.full_name)


class Person(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='person_uuid')
    first_name = models.CharField(
        max_length=255)
    last_name = models.CharField(max_length=255)
    middle_name = models.CharField(
        max_length=255, blank=True, null=True)
    address1 = models.CharField(max_length=255, blank=True, null=True)
    address2 = models.CharField(max_length=255, blank=True, null=True)
    city = models.CharField(max_length=255, blank=True, null=True)
    state_province = models.CharField(max_length=3, blank=True, null=True)
    zip = models.CharField(max_length=255, blank=True, null=True)
    country = models.CharField(max_length=255, blank=True, null=True)

    phone = models.CharField(max_length=255, blank=True, null=True)
    email = models.EmailField(max_length=255, blank=True, null=True)
    title = models.CharField(max_length=255, blank=True, null=True)
    suffix = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)
    organization = models.ForeignKey('Organization', models.DO_NOTHING,
                                     blank=True, null=True,
                                     db_column='organization_uuid',
                                     related_name='person_organization')
    organization_full_name = models.CharField(max_length=255,
                                              blank=True, null=True)
    added_organization = models.ManyToManyField(
        'Organization', through='Actor', related_name='person_added_organization')

    class Meta:
        managed = False
        db_table = 'vw_person'

    def __str__(self):
        return "{} {}".format(self.first_name, self.last_name)


class Status(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='status_uuid')
    description = models.CharField(max_length=255, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_status'

    def __str__(self):
        return "{}".format(self.description)


class Tag(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='tag_uuid', editable=False)
    display_text = models.CharField(max_length=255,  null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    actor = models.ForeignKey('Actor', models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True, null=True, related_name='tag_actor')
    actor_description = models.CharField(
        max_length=255, blank=True, null=True, editable=False)

    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    tag_type = models.ForeignKey('TagType', models.DO_NOTHING,
                                 db_column='tag_type_uuid',
                                 blank=True, null=True, related_name='tag_tag_type')
    type = models.CharField(
        max_length=255, blank=True, null=True, editable=False)
    type_description = models.CharField(
        max_length=255, blank=True, null=True, editable=False)

    class Meta:
        managed = False
        db_table = 'vw_tag'

    def __str__(self):
        return "{}".format(self.display_text)


class TagAssign(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='tag_x_uuid')
    ref_tag = RetUUIDField(db_column='ref_tag_uuid')
    tag = models.ForeignKey('Tag', models.DO_NOTHING,
                            blank=True,
                            null=True,
                            db_column='tag_uuid', related_name='tag_assign_tag')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_tag_assign'

    def __str__(self):
        return "{}".format(self.uuid)


class TagType(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='tag_type_uuid')
    type = models.CharField(max_length=255,  null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_tag_type'

    def __str__(self):
        return "{}".format(self.type)


class Edocument(models.Model):
    uuid = RetUUIDField(
        primary_key=True, db_column='edocument_uuid', editable=False)
    title = models.CharField(max_length=255, blank=True,
                             null=True, db_column='title')
    description = models.CharField(max_length=255, blank=True, null=True,
                                   db_column='description')
    filename = models.CharField(max_length=255, blank=True, null=True,
                                db_column='filename')
    source = models.CharField(
        max_length=255, blank=True, null=True, db_column='source')
    doc_type_description = models.CharField(max_length=255, blank=True,
                                 null=True, db_column='doc_type_description')
    edocument = models.BinaryField(blank=True, null=True, editable=False)
    edoc_ver = models.CharField(max_length=255, blank=True,
                                null=True, db_column='doc_ver')
    doc_type_uuid = models.ForeignKey('TypeDef', db_column='doc_type_uuid',
                                      on_delete=models.DO_NOTHING, blank=True, null=True, editable=False)
    actor = models.ForeignKey(
        'Actor', models.DO_NOTHING, db_column='actor_uuid', blank=True, null=True, related_name='edocument_actor')
    actor_description = models.CharField(
        max_length=255, blank=True, null=True, editable=False)
    status = models.ForeignKey(
        'Status', models.DO_NOTHING, db_column='status_uuid', blank=True, null=True, related_name='edocument_status')
    status_description = models.CharField(
        max_length=255, blank=True, null=True, editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)
    edocument_x_uuid = RetUUIDField(editable=False)
    ref_edocument_uuid = RetUUIDField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_edocument'

    def __str__(self):
        return "{}".format(self.title)


class ExperimentMeasureCalculation(models.Model):
    uid = models.CharField(max_length=255, primary_key=True, db_column='uid')
    row_to_json = JSONField()

    class Meta:
        managed = False
        db_table = 'vw_experiment_measure_calculation_json'


class Experiment(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='experiment_uuid')
    ref_uid = models.CharField(max_length=255, db_column='ref_uid')
    description = models.CharField(max_length=255,  db_column='description')
    parent = models.ForeignKey('TypeDef', db_column='parent_uuid',
                               on_delete=models.DO_NOTHING, blank=True, null=True, related_name='experiment_parent')
    owner = models.ForeignKey('Actor', db_column='owner_uuid', on_delete=models.DO_NOTHING, blank=True, null=True,
                              related_name='experiment_owner')
    owner_description = models.CharField(
        max_length=255, db_column='owner_description')
    operator = models.ForeignKey('Actor', db_column='operator_uuid', on_delete=models.DO_NOTHING, blank=True, null=True,
                                 related_name='experiment_operator')
    operator_description = models.CharField(
        max_length=255, db_column='operator_description')
    lab = models.ForeignKey('Actor', db_column='lab_uuid', on_delete=models.DO_NOTHING, blank=True, null=True,
                            related_name='experiment_lab')
    lab_description = models.CharField(
        max_length=255, db_column='lab_description')
    status = models.ForeignKey(
        'Status', on_delete=models.DO_NOTHING, db_column='status_uuid', blank=True, null=True, related_name='experiment_status')
    status_description = models.CharField(
        max_length=255, blank=True, null=True, db_column='status_description', editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_experiment'


class ExperimentWorkflow(models.Model):
    # note: omitted much detail here because should be nested under
    # experiment, no need for redundancy.
    uuid = RetUUIDField(primary_key=True, db_column='experiment_workflow_uuid')
    experiment = models.ForeignKey('Experiment', db_column='experiment_uuid', on_delete=models.DO_NOTHING,
                                   blank=True, null=True, related_name='experiment_workflow_experiment')
    experiment_ref_uid = models.CharField(max_length=255)
    experiment_description = models.CharField(max_length=255)
    experiment_workflow_seq = models.IntegerField()
    workflow = models.ForeignKey('Workflow', db_column='workflow_uuid',
                                 on_delete=models.DO_NOTHING, blank=True, null=True, related_name='experiment_workflow_workflow')
    workflow_type_uuid = models.ForeignKey('WorkflowType', db_column='workflow_type_uuid',
                                           on_delete=models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_experiment_workflow'


class Outcome(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='outcome_uuid')
    description = models.CharField(max_length=255,  db_column='description')
    experiment = models.ForeignKey('Experiment', db_column='experiment_uuid', on_delete=models.DO_NOTHING,
                                   blank=True, null=True, related_name='outcome_experiment')
    actor = models.ForeignKey(
        'Actor', models.DO_NOTHING, db_column='actor_uuid', blank=True, null=True, related_name='outcome_actor')
    actor_description = models.CharField(
        max_length=255, blank=True, null=True, editable=False)
    status = models.ForeignKey(
        'Status', models.DO_NOTHING, db_column='status_uuid', blank=True, null=True, related_name='outcome_status')
    status_description = models.CharField(
        max_length=255, blank=True, null=True, editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_outcome'


class UdfDef(models.Model):
    """

    """
    uuid = RetUUIDField(primary_key=True, db_column='udf_def_uuid')
    description = models.CharField(
        max_length=255,  null=True)
    val_type = models.ForeignKey('TypeDef',
                                 db_column='val_type_uuid',
                                 on_delete=models.DO_NOTHING,
                                 blank=True,
                                 null=True, related_name='udf_def_val_type')
    val_type_description = models.CharField(
        max_length=255, blank=True, null=True)
    unit = models.CharField(
        max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_udf_def'

    def __str__(self):
        return "{}".format(self.description)


class Property(models.Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='property_uuid')

    property_def = models.ForeignKey('PropertyDef',
                                     db_column='property_def_uuid',
                                     on_delete=models.DO_NOTHING,
                                     blank=True,
                                     null=True, related_name='property_property_def')
    short_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='short_description')

    property_val = models.CharField(max_length=255,
                                    blank=True,
                                    null=True,
                                    db_column='property_val')
    """
    # TODO: Any way to represent arrays with sqaure brackets? One of the arrays
    # is represented as \"{0.5,10}\" in the val string. We'll have to write a special 
    # case to parse arrays in custom_types.py/Val.from_db() function
    
    property_val = ValField(
                                   blank=True,
                                   null=True,
                                   db_column='property_val')
    """
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='property_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='actor_description',
                                         editable=False)
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               blank=True,
                               null=True,
                               db_column='status_uuid', related_name='property_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_property'

    def __str__(self):
        return "{}".format(self.short_description)


class PropertyDef(models.Model):

    uuid = RetUUIDField(primary_key=True,
                        db_column='property_def_uuid')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description')
    short_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='short_description')
    val_type = models.ForeignKey('TypeDef',
                                 db_column='val_type_uuid',
                                 on_delete=models.DO_NOTHING,
                                 blank=True,
                                 null=True, related_name='property_def_val_type')
    val_unit = models.CharField(max_length=255,
                                blank=True,
                                null=True,
                                db_column='valunit')
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='property_def_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='actor_description',
                                         editable=False)
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               blank=True,
                               null=True,
                               db_column='status_uuid', related_name='property_def_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_property_def'

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
    value = ValField(blank=True, null=True, db_column='property_value_val')
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


class CompositeMaterialProperty(models.Model):
    # TODO: Material property may need fixing. Endpoint displays all tags for all rows
    uuid = RetUUIDField(primary_key=True,
                        db_column='material_composite_uuid')
    composite_material = models.ForeignKey('CompositeMaterial',
                                           db_column='composite_uuid',
                                           on_delete=models.DO_NOTHING,
                                           blank=True, null=True,
                                           related_name='composite_material_property_composite_material')
    composite_material_description = models.CharField(max_length=255,
                                                      blank=True,
                                                      null=True,
                                                      db_column='description',
                                                      editable=False)
    component = models.ForeignKey('CompositeMaterial',
                                  db_column='component_uuid',
                                  on_delete=models.DO_NOTHING,
                                  blank=True, null=True,
                                  related_name='composite_material_property_component')

    property = models.ForeignKey('Property',
                                 on_delete=models.DO_NOTHING,
                                 db_column='property_uuid',
                                 blank=True,
                                 null=True,
                                 editable=False,
                                 related_name='composite_material_property_property')
    property_def = models.ForeignKey('PropertyDef',
                                     on_delete=models.DO_NOTHING,
                                     db_column='property_def_uuid',
                                     blank=True,
                                     null=True, related_name='composite_material_property_property_def')
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
    value = ValField(
        blank=True,
        null=True,
        db_column='val_val')
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


class ParameterDef(models.Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='parameter_def_uuid')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description',
                                   editable=False)
    val_type_description = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            db_column='val_type_description',
                                            editable=False)
    val_type = models.ForeignKey('TypeDef',
                                 db_column='val_type_uuid',
                                 on_delete=models.DO_NOTHING,
                                 blank=True,
                                 null=True, related_name='parameter_def_val_type')
    default_val_val = models.CharField(max_length=255,
                                       blank=True,
                                       null=True,
                                       db_column='default_val_val',
                                       editable=False)
    valunit = models.CharField(max_length=255,
                               blank=True,
                               null=True,
                               db_column='valunit',
                               editable=False)
    """
    default_val = ValField(
                           blank=True,
                           null=True,
                           db_column='default_val',
                           editable=False)
    """
    default_val = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='default_val',
                                   editable=False)
    required = models.CharField(max_length=255,
                                blank=True,
                                null=True,
                                db_column='required',
                                editable=False)
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='parameter_def_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='actor_description',
                                         editable=False)
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='parameter_def_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_parameter_def'


class ActionDef(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='action_def_uuid')
    parameter_def = models.ManyToManyField(
        'ParameterDef', through='ActionParameterDefAssign')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description',
                                   editable=False)
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='action_def_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='actor_description',
                                         editable=False)
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='action_def_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.description}"

    class Meta:
        managed = False
        db_table = 'vw_action_def'


class Condition(models.Model):
    # todo: link to condition calculation
    uuid = RetUUIDField(primary_key=True, db_column='condition_uuid')
    condition_description = models.CharField(max_length=255,
                                             blank=True,
                                             null=True,
                                             editable=False)
    condition_def = models.ForeignKey('ConditionDef', models.DO_NOTHING,
                                      db_column='condition_def_uuid', related_name='condition_condition_def')
    calculation_description = models.CharField(max_length=255,
                                               blank=True,
                                               null=True,
                                               editable=False)
    # TODO: Fix in_val and out_val on Postgres to return strings not JSON!
    #in_val = ValField(blank=True, null=True)
    #out_val = ValField(blank=True, null=True)
    
    in_val = models.CharField(max_length=255,
                              blank=True,
                              null=True,
                              editable=False)
    out_val = models.CharField(max_length=255,
                               blank=True,
                               null=True,
                               editable=False)
    
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='condition_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='actor_description',
                                         editable=False)
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='condition_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_condition'


class ConditionDef(models.Model):

    uuid = uuid = RetUUIDField(
        primary_key=True, db_column='condition_def_uuid')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description',
                                   editable=False)
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='condition_def_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='actor_description',
                                         editable=False)
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='condition_def_status')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_condition_def'


class ActionParameterDef(models.Model):
    uuid = RetUUIDField(
        primary_key=True, db_column='action_parameter_def_x_uuid')
    action_def = models.ForeignKey('ActionDef',
                                   on_delete=models.DO_NOTHING,
                                   db_column='action_def_uuid',
                                   blank=True,
                                   null=True,
                                   editable=False, related_name='action_parameter_def_action_def')

    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description',
                                   editable=False)
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='action_parameter_def_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='actor_description',
                                         editable=False)
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='action_parameter_def_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)
    # parameter_def_uuid = RetUUIDField(primary_key=True,
    #                                      db_column='parameter_def_uuid')

    parameter_def = models.ForeignKey('ParameterDef',
                                      on_delete=models.DO_NOTHING,
                                      db_column='parameter_def_uuid',
                                      blank=True,
                                      null=True,
                                      editable=False, related_name='action_parameter_def_parameter_def')

    parameter_description = models.CharField(max_length=255,
                                             blank=True,
                                             null=True,
                                             db_column='parameter_description',
                                             editable=False)
    parameter_val_type = models.ForeignKey('TypeDef',
                                           db_column='parameter_val_type_uuid',
                                           on_delete=models.DO_NOTHING,
                                           blank=True,
                                           null=True, related_name='action_parameter_def_parameter_val_type')

    class Meta:
        managed = False
        db_table = 'vw_action_parameter_def'
        unique_together = ['action_def', 'parameter_def']


class ActionParameterDefAssign(models.Model):
    uuid = RetUUIDField(
        primary_key=True, db_column='action_parameter_def_x_uuid')
    parameter_def = models.ForeignKey('ParameterDef',
                                      on_delete=models.DO_NOTHING,
                                      blank=True,
                                      null=True,
                                      editable=False,
                                      db_column='parameter_def_uuid',
                                      related_name='action_parameter_def_assign_parameter_def')
    action_def = models.ForeignKey('ActionDef', on_delete=models.DO_NOTHING,
                                   blank=True,
                                   null=True,
                                   editable=False, db_column='action_def_uuid', related_name='action_parameter_def_assign_action_def')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_action_parameter_def_assign'


class ActionParameterAssign(models.Model):
    action_parameter_x = RetUUIDField(
        primary_key=True, db_column='action_parameter_x_uuid')
    parameter = models.ForeignKey('ActionParameter',
                                  on_delete=models.DO_NOTHING,
                                  blank=True,
                                  null=True,
                                  editable=False,
                                  db_column='parameter_uuid',
                                  related_name='action_parameter_assign_parameter')
    action = models.ForeignKey('Action',
                               on_delete=models.DO_NOTHING,
                               blank=True,
                               null=True,
                               editable=False,
                               db_column='action_uuid',
                               related_name='action_parameter_assign_action')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_action_parameter'


class Action(models.Model):
    action_uuid = RetUUIDField(primary_key=True,
                               db_column='action_uuid')
    parameter = models.ManyToManyField(
        'ActionParameter', through='ActionParameterAssign', related_name='action_parameter')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='action_description')
    action_def = models.ForeignKey('ActionDef',
                                   on_delete=models.DO_NOTHING,
                                   db_column='action_def_uuid',
                                   blank=True,
                                   null=True, related_name='action_action_def')
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='action_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='actor_description',
                                         editable=False)
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True, related_name='action_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_action'


class ActionParameter(models.Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='parameter_uuid')
    action = models.ForeignKey('Action',
                               db_column='action_uuid',
                               on_delete=models.DO_NOTHING,
                               blank=True,
                               null=True,
                               editable=False,
                               related_name='parameter_action')
    parameter_def = models.ForeignKey('ParameterDef',
                                      db_column='parameter_def_uuid',
                                      on_delete=models.DO_NOTHING,
                                      blank=True,
                                      null=True,
                                      editable=False, related_name='action_parameter_parameter_def')
    parameter_def_description = models.CharField(max_length=255,
                                                 blank=True,
                                                 null=True,
                                                 db_column='parameter_def_description',
                                                 editable=False)
    parameter_val_nominal = ValField(blank=True,
                             null=True,
                             db_column='parameter_val_nominal')
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='parameter_actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='action_parameter_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='parameter_actor_description',
                                         editable=False)
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='parameter_status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='action_parameter_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='parameter_status_description',
                                          editable=False)
    add_date = models.DateTimeField(
        auto_now_add=True, db_column='parameter_add_date')
    mod_date = models.DateTimeField(
        auto_now=True, db_column='parameter_mod_date')

    class Meta:
        managed = False
        db_table = 'vw_action_parameter'


class Parameter(models.Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='parameter_uuid')
    parameter_def = models.ForeignKey('ParameterDef',
                                      db_column='parameter_def_uuid',
                                      on_delete=models.DO_NOTHING,
                                      blank=True,
                                      null=True,
                                      editable=False, related_name='parameter_parameter_def')
    parameter_def_description = models.CharField(max_length=255,
                                                 blank=True,
                                                 null=True,
                                                 db_column='parameter_def_description',
                                                 editable=False)
    parameter_val_nominal = ValField(blank=True,
                             null=True,
                             db_column='parameter_val_nominal')
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='parameter_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='actor_description',
                                         editable=False)
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='parameter_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True, db_column='add_date')
    mod_date = models.DateTimeField(auto_now=True, db_column='mod_date')

    class Meta:
        managed = False
        db_table = 'vw_parameter'


class WorkflowType(models.Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='workflow_type_uuid')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description',
                                   editable=False)
    add_date = models.DateTimeField(auto_now_add=True, db_column='add_date')
    mod_date = models.DateTimeField(auto_now=True, db_column='mod_date')

    class Meta:
        managed = False
        db_table = 'vw_workflow_type'


class Workflow(models.Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='workflow_uuid')
    step = models.ManyToManyField(
        'WorkflowStep', through='WorkflowStep', related_name='workflow_step')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description',
                                   editable=False)
    parent = models.ForeignKey('Workflow', models.DO_NOTHING,
                               blank=True, null=True,
                               db_column='parent_uuid', related_name='workflow_parent')
    workflow_type = models.ForeignKey('WorkflowType', models.DO_NOTHING,
                                      blank=True, null=True,
                                      db_column='workflow_type_uuid', related_name='workflow_workflow_type')
    workflow_type_description = models.CharField(max_length=255,
                                                 blank=True,
                                                 null=True,
                                                 editable=False)
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='workflow_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='actor_description',
                                         editable=False)
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='workflow_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True, db_column='add_date')
    mod_date = models.DateTimeField(auto_now=True, db_column='mod_date')

    class Meta:
        managed = False
        db_table = 'vw_workflow'


class WorkflowStep(models.Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='workflow_step_uuid')
    workflow = models.ForeignKey('Workflow', models.DO_NOTHING,
                                 db_column='workflow_uuid',
                                 related_name='workflow_step_workflow')
    workflow_description = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            editable=False)
    parent = models.ForeignKey('WorkflowStep', models.DO_NOTHING,
                               blank=True, null=True, editable=False,
                               db_column='parent_uuid', related_name='workflow_step_parent')
    parent_object_type = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          editable=False)
    parent_object_description = models.CharField(max_length=255,
                                                 blank=True,
                                                 null=True,
                                                 editable=False)
    parent_path = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   editable=False)
    conditional_val = ValField(blank=True,
                               null=True,
                               editable=False)
    conditional_value = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         editable=False)
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='workflow_step_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True, db_column='add_date')
    mod_date = models.DateTimeField(auto_now=True, db_column='mod_date')

    workflow_object = models.ForeignKey('WorkflowObject', models.DO_NOTHING,
                                        db_column='workflow_object_uuid', related_name='workflow_step_workflow_object')
    # unclear how to make this an fk for django...
    """
    object_uuid = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='object_uuid',
                                   editable=False)
    object_type = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='object_type',
                                   editable=False)
    object_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='object_description',
                                          editable=False)
    object_def_description = models.CharField(max_length=255,
                                              blank=True,
                                              null=True,
                                              db_column='object_def_description',
                                              editable=False)
    """

    class Meta:
        managed = False
        db_table = 'vw_workflow_step'


class WorkflowObject(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='workflow_object_uuid')
    action = models.ForeignKey('Action', models.DO_NOTHING,
                               blank=True, null=True, editable=False,
                               db_column='action_uuid', related_name='workflow_object_action')
    condition = models.ForeignKey('Condition', models.DO_NOTHING,
                                  blank=True, null=True, editable=False,
                                  db_column='condition_uuid', related_name='workflow_object_condition')
    object_uuid = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   editable=False)

    object_type = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   editable=False)
    object_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          editable=False)
    object_def_description = models.CharField(max_length=255,
                                              blank=True,
                                              null=True,
                                              editable=False)
    add_date = models.DateTimeField(auto_now_add=True, db_column='add_date')
    mod_date = models.DateTimeField(auto_now=True, db_column='mod_date')

    class Meta:
        managed = False
        db_table = 'vw_workflow_object'


class Measure(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='measure_uuid')
    measure_type_uuid = models.ForeignKey('MeasureType',
                                          on_delete=models.DO_NOTHING,
                                          db_column='measure_type_uuid',
                                          blank=True,
                                          null=True,
                                          editable=False, related_name='measure_measure_type')
    ref_measure_uuid = models.ForeignKey('Measure',
                                         on_delete=models.DO_NOTHING,
                                         db_column='ref_measure_uuid',
                                         blank=True,
                                         null=True,
                                         editable=False, related_name='measure_measure')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   editable=False)
    measure_value = ValField()
    actor_uuid = models.ForeignKey('Actor',
                                   on_delete=models.DO_NOTHING,
                                   db_column='actor_uuid',
                                   blank=True,
                                   null=True,
                                   editable=False, related_name='measure_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         editable=False)
    status_uuid = models.ForeignKey('Status',
                                    on_delete=models.DO_NOTHING,
                                    db_column='status_uuid',
                                    blank=True,
                                    null=True,
                                    editable=False, related_name='measure_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True, db_column='add_date')
    mod_date = models.DateTimeField(auto_now=True, db_column='mod_date')

    class Meta:
        managed = False
        db_table = 'vw_measure'


class MeasureType(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='measure_type_uuid')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   editable=False)
    actor_uuid = models.ForeignKey('Actor',
                                   on_delete=models.DO_NOTHING,
                                   db_column='actor_uuid',
                                   blank=True,
                                   null=True,
                                   editable=False, related_name='measure_type_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         editable=False)
    status_uuid = models.ForeignKey('Status',
                                    on_delete=models.DO_NOTHING,
                                    db_column='status_uuid',
                                    blank=True,
                                    null=True,
                                    editable=False, related_name='measure_type_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True, db_column='add_date')
    mod_date = models.DateTimeField(auto_now=True, db_column='mod_date')

    class Meta:
        managed = False
        db_table = 'vw_measure_type'
