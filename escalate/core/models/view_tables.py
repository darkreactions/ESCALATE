from django.db import models
from django.contrib.postgres.fields import JSONField

managed_value = False


class Actor(models.Model):
    actor_uuid = models.UUIDField(primary_key=True)
    organization_uuid = models.ForeignKey('Organization',
                                          on_delete=models.DO_NOTHING,
                                          blank=True, null=True, db_column='organization_uuid')
    person_uuid = models.ForeignKey('Person',
                                    on_delete=models.DO_NOTHING,
                                    blank=True, null=True, db_column='person_uuid')
    systemtool_uuid = models.ForeignKey('Systemtool',
                                        on_delete=models.DO_NOTHING,
                                        blank=True, null=True, db_column='systemtool_uuid', related_name='+')
    actor_description = models.CharField(max_length=255, blank=True, null=True)
    actor_status = models.CharField(max_length=255, blank=True, null=True)
    org_full_name = models.CharField(
        max_length=255, blank=True, null=True, verbose_name='Organization Full Name')
    org_short_name = models.CharField(
        max_length=255, blank=True, null=True, verbose_name='Organization Short Name')
    person_last_name = models.CharField(
        max_length=255, blank=True, null=True, verbose_name='Person Lastname')
    person_first_name = models.CharField(max_length=255, blank=True, null=True)
    person_last_first = models.CharField(max_length=255, blank=True, null=True)
    person_org = models.CharField(max_length=255, blank=True, null=True)
    systemtool_name = models.CharField(max_length=255, blank=True, null=True)
    systemtool_description = models.CharField(
        max_length=255, blank=True, null=True)
    systemtool_type = models.CharField(max_length=255, blank=True, null=True)
    systemtool_vendor = models.CharField(max_length=255, blank=True, null=True)
    systemtool_model = models.CharField(max_length=255, blank=True, null=True)
    systemtool_serial = models.CharField(max_length=255, blank=True, null=True)
    systemtool_version = models.CharField(
        max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_actor'

    def __str__(self):
        return "{}".format(self.actor_description)


class Inventory(models.Model):
    inventory_uuid = models.UUIDField(
        primary_key=True, db_column='inventory_uuid')
    inventory_description = models.CharField(
        max_length=255, blank=True, null=True)
    part_no = models.CharField(max_length=255, blank=True, null=True)
    onhand_amt = models.FloatField(blank=True, null=True)
    unit = models.CharField(max_length=255, blank=True, null=True)
    create_date = models.DateTimeField(blank=True, null=True)
    expiration_date = models.DateTimeField(blank=True, null=True)
    inventory_location = models.CharField(max_length=255,
                                          blank=True, null=True)
    status = models.CharField(max_length=255,
                              blank=True, null=True)
    material_uuid = models.ForeignKey('Material',
                                      models.DO_NOTHING,
                                      db_column='material_uuid',
                                      )
    material_description = models.CharField(max_length=255,
                                            blank=True, null=True)
    actor_uuid = models.ForeignKey('Actor', models.DO_NOTHING,
                                   db_column='actor_uuid',
                                   blank=True, null=True)
    # description = models.CharField(max_length=255,
    #                               blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_inventory'

    def __str__(self):
        return "{}".format(self.inventory_description)


class InventoryMaterial(models.Model):
    inventory_uuid = models.UUIDField(primary_key=True)
    inventory_description = models.CharField(max_length=255,
                                             blank=True, null=True)
    inventory_part_no = models.CharField(max_length=255,
                                         blank=True, null=True)
    inventory_onhand_amt = models.FloatField(blank=True, null=True)
    inventory_unit = models.CharField(max_length=255, blank=True, null=True)
    inventory_create_date = models.DateTimeField(blank=True, null=True)
    inventory_expiration_date = models.DateTimeField(blank=True, null=True)
    inventory_location = models.CharField(
        max_length=255, blank=True, null=True)
    inventory_status = models.CharField(max_length=255, blank=True, null=True)

    actor_uuid = models.ForeignKey('Actor', models.DO_NOTHING,
                                   db_column='actor_uuid',
                                   blank=True, null=True)
    actor_description = models.CharField(max_length=255, blank=True, null=True)
    org_full_name = models.CharField(max_length=255, blank=True, null=True)
    material_uuid = models.ForeignKey('Material', models.DO_NOTHING,
                                      db_column='material_uuid',
                                      blank=True, null=True)
    material_status = models.CharField(max_length=255, blank=True, null=True)
    material_create_date = models.DateTimeField()
    material_name = models.CharField(max_length=255, blank=True, null=True)
    material_abbreviation = models.CharField(
        max_length=255, blank=True, null=True)
    material_inchi = models.CharField(max_length=255, blank=True, null=True)
    material_inchikey = models.CharField(max_length=255, blank=True, null=True)
    material_molecular_formula = models.CharField(
        max_length=255, blank=True, null=True)
    material_smiles = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_inventory_material'

    def __str__(self):
        return "{} : {}".format(self.inventory_description, self.material_name)


class LatestSystemtool(models.Model):
    systemtool_uuid = models.UUIDField(primary_key=True,
                                       db_column='systemtool_uuid')
    systemtool_name = models.CharField(max_length=255, blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    vendor_organization_uuid = models.ForeignKey('Organization',
                                                 models.DO_NOTHING,
                                                 db_column='vendor_organization_uuid')
    organization_fullname = models.CharField(
        max_length=255, blank=True, null=True)
    systemtool_type_uuid = models.ForeignKey('SystemtoolType',
                                             models.DO_NOTHING,
                                             db_column='systemtool_type_uuid')
    systemtool_type_description = models.CharField(
        max_length=255, blank=True, null=True)
    model = models.CharField(max_length=255, blank=True, null=True)
    serial = models.CharField(max_length=255, blank=True, null=True)
    ver = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_latest_systemtool'

    def __str__(self):
        return "{}".format(self.systemtool_name)


class ViewSystemtoolType(models.Model):
    systemtool_type_uuid = models.UUIDField(primary_key=True,
                                            db_column='systemtool_type_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)
    note_uuid = models.ForeignKey('Note', models.DO_NOTHING,
                                  db_column='note_uuid')
    notetext = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_systemtool_type'

    def __str__(self):
        return "{}".format(self.description)


class Calculation(models.Model):
    calculation_uuid = models.UUIDField(primary_key=True,
                                        db_column='calculation_uuid')
    in_val = models.TextField(blank=True, null=True)
    in_type = models.CharField(max_length=255, blank=True, null=True)
    in_val_type = models.TextField(blank=True, null=True)
    in_val_value = models.TextField(blank=True, null=True)
    in_val_unit = models.TextField(blank=True, null=True)
    in_val_edocument = models.ForeignKey('Edocument',
                                         models.DO_NOTHING,
                                         db_column='in_val_edocument_uuid',
                                         related_name='in_val_edocument')
    in_opt_val = models.TextField(blank=True, null=True)
    in_opt_val_type = models.TextField(blank=True, null=True)
    in_opt_val_value = models.TextField(blank=True, null=True)
    in_opt_val_unit = models.TextField(blank=True, null=True)
    in_opt_val_edocument = models.ForeignKey('Edocument',
                                             models.DO_NOTHING,
                                             db_column='in_opt_val_edocument_uuid',
                                             related_name='in_opt_val_edocument')

    out_val = models.TextField(blank=True, null=True)
    out_val_type = models.TextField(blank=True, null=True)
    out_val_value = models.TextField(blank=True, null=True)
    out_val_unit = models.TextField(blank=True, null=True)
    out_val_edocument = models.ForeignKey('Edocument',
                                          models.DO_NOTHING,
                                          db_column='out_val_edocument_uuid',
                                          related_name='out_val_edocument')

    calculation_alias_name = models.CharField(
        max_length=255, blank=True, null=True)
    create_date = models.DateTimeField(blank=True, null=True)
    status = models.CharField(max_length=255, blank=True, null=True)
    actor_descr = models.CharField(max_length=255, blank=True, null=True)
    notetext = models.CharField(max_length=255, blank=True, null=True)

    calculation_def = models.ForeignKey('CalculationDef',
                                        models.DO_NOTHING,
                                        blank=True, null=True,
                                        db_column='calculation_def_uuid')
    short_name = models.CharField(max_length=255, blank=True, null=True)
    calc_definition = models.CharField(max_length=255, blank=True, null=True)

    description = models.CharField(max_length=1023, blank=True, null=True)

    out_type = models.CharField(max_length=255, blank=True, null=True)

    systemtool = models.ForeignKey('Systemtool',
                                   models.DO_NOTHING,
                                   db_column='systemtool_uuid')
    systemtool_name = models.CharField(max_length=1023, blank=True, null=True)
    systemtool_type_description = models.CharField(
        max_length=1023, blank=True, null=True)
    systemtool_vendor_organization = models.CharField(
        max_length=1023, blank=True, null=True, db_column='systemtool_vendor_organization')
    systemtool_version = models.CharField(
        max_length=1023, blank=True, null=True)

    actor_uuid = models.ForeignKey(
        'Actor', models.DO_NOTHING, db_column='actor_uuid', blank=True, null=True)
    actor_description = models.CharField(
        max_length=1023, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_calculation'


class CalculationDef(models.Model):
    calculation_def_uuid = models.UUIDField(
        primary_key=True, db_column='calculation_def_uuid')
    short_name = models.CharField(max_length=255, blank=True, null=True)
    calc_definition = models.CharField(max_length=255, blank=True, null=True)
    description = models.CharField(max_length=1023, blank=True, null=True)
    in_type = models.CharField(max_length=255, blank=True, null=True)
    out_type = models.CharField(max_length=255, blank=True, null=True)
    systemtool = models.ForeignKey('Systemtool',
                                   models.DO_NOTHING,
                                   db_column='systemtool_uuid')
    systemtool_name = models.CharField(max_length=255, blank=True, null=True)
    systemtool_type_description = models.CharField(
        max_length=255, blank=True, null=True)
    systemtool_vendor_organization = models.CharField(
        max_length=255, blank=True, null=True, db_column='systemtool_vendor_organization')
    systemtool_version = models.CharField(
        max_length=255, blank=True, null=True)
    actor = models.ForeignKey(
        'Actor', models.DO_NOTHING, blank=True, null=True, db_column='actor_uuid')
    actor_description = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_calculation_def'

    def __str__(self):
        return "{}".format(self.description)


class Material(models.Model):
    material_uuid = models.UUIDField(primary_key=True,
                                     db_column='material_uuid')
    material_status = models.CharField(max_length=255, blank=True, null=True)
    create_date = models.DateTimeField()
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

    class Meta:
        managed = False
        db_table = 'vw_material'

    def __str__(self):
        return "{}".format(self.chemical_name)


class MaterialCalculationJson(models.Model):
    material_uuid = models.UUIDField(primary_key=True,
                                     db_column='material_uuid')
    material_status = models.CharField(max_length=255, blank=True, null=True)
    create_date = models.DateTimeField()
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


class MaterialRefnameType(models.Model):
    material_refname_type_uuid = models.UUIDField(primary_key=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    notetext = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_material_refname_type'

    def __str__(self):
        return "{}".format(self.description)


class MaterialType(models.Model):
    material_type_uuid = models.UUIDField(primary_key=True)
    description = models.TextField(blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_material_type'

    def __str__(self):
        return "{}".format(self.description)


class Note(models.Model):
    note_uuid = models.UUIDField(primary_key=True)
    notetext = models.TextField(blank=True, null=True)
    add_date = models.DateTimeField()
    mod_date = models.DateTimeField()
    edocument_uuid = models.ForeignKey('Edocument',
                                       models.DO_NOTHING,
                                       db_column='edocument_uuid')
    edocument_type = models.CharField(max_length=255, blank=True, null=True)
    actor_uuid = models.ForeignKey('Actor', models.DO_NOTHING,
                                   db_column='actor_uuid')
    actor_description = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_note'

    def __str__(self):
        return "{}".format(self.notetext)


class Organization(models.Model):
    organization_uuid = models.UUIDField(primary_key=True)
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

    parent_uuid = models.ForeignKey('self', models.DO_NOTHING,
                                    blank=True, null=True, db_column='parent_uuid')
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
    person_uuid = models.UUIDField(primary_key=True)
    first_name = models.CharField(
        max_length=255, blank=True, null=True)
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
    email = models.CharField(max_length=255, blank=True, null=True)
    title = models.CharField(max_length=255, blank=True, null=True)
    suffix = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)
    organization_uuid = models.ForeignKey('Organization', models.DO_NOTHING,
                                          blank=True, null=True,
                                          db_column='organization_uuid')
    organization_full_name = models.CharField(max_length=255)

    class Meta:
        managed = False
        db_table = 'vw_person'

    def __str__(self):
        return "{} {}".format(self.first_name, self.last_name)


class Status(models.Model):
    status_uuid = models.UUIDField(primary_key=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_status'

    def __str__(self):
        return "{}".format(self.description)


class Tag(models.Model):
    tag_uuid = models.UUIDField(primary_key=True)
    display_text = models.CharField(max_length=255, blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    tag_type_uuid = models.ForeignKey(
        'TagType', models.DO_NOTHING, db_column='tag_type_uuid', blank=True, null=True)
    tag_type_short_descr = models.CharField(
        max_length=255, blank=True, null=True)
    tag_type_description = models.CharField(
        max_length=255, blank=True, null=True)

    actor_uuid = models.ForeignKey(
        'Actor', models.DO_NOTHING, db_column='actor_uuid', blank=True, null=True)
    actor_description = models.CharField(max_length=255, blank=True, null=True)

    note_uuid = models.ForeignKey(
        'Note', models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
    notetext = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_tag'

    def __str__(self):
        return "{}".format(self.display_text)


class TagType(models.Model):
    tag_type_uuid = models.UUIDField(primary_key=True)
    short_description = models.CharField(max_length=255, blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_tag_type'

    def __str__(self):
        return "{}".format(self.short_description)


class Edocument(models.Model):
    """

    """
    edocument_uuid = models.UUIDField(primary_key=True)
    title = models.CharField(max_length=255, blank=True,
                             null=True, db_column='edocument_title')
    description = models.CharField(
        max_length=255, blank=True, null=True, db_column='edocument_description')
    filename = models.CharField(
        max_length=255, blank=True, null=True, db_column='edocument_filename')
    source = models.CharField(
        max_length=255, blank=True, null=True, db_column='edocument_source')
    type = models.CharField(max_length=255, blank=True,
                            null=True, db_column='edocument_type')
    edocument = models.BinaryField(blank=True, null=True)
    actor_uuid = models.ForeignKey(
        'Actor', models.DO_NOTHING, db_column='actor_uuid', blank=True, null=True)
    actor_description = models.CharField(
        max_length=255, blank=True, null=True)

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


class UdfDef(models.Model):
    """

    """
    udf_def_uuid = models.UUIDField(primary_key=True)
    description = models.CharField(
        max_length=255, blank=True, null=True)
    valtype = models.CharField(
        max_length=255, blank=True, null=True)
    note_uuid = models.ForeignKey(
        'Note', models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
    notetext = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField()
    mod_date = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'vw_udf_def'

    def __str__(self):
        return "{}".format(self.description)
