from django.db import models
#from django.contrib.postgres.fields import JSONField
from django.db.models import JSONField
managed_value = False


class Actor(models.Model):
    uuid = models.UUIDField(primary_key=True, db_column='actor_uuid')
    organization_uuid = models.ForeignKey('Organization',
                                          on_delete=models.DO_NOTHING,
                                          blank=True, null=True,
                                          db_column='organization_uuid')
    person_uuid = models.ForeignKey('Person',
                                    on_delete=models.DO_NOTHING,
                                    blank=True, null=True,
                                    db_column='person_uuid')
    systemtool_uuid = models.ForeignKey('Systemtool',
                                        on_delete=models.DO_NOTHING,
                                        blank=True, null=True,
                                        db_column='systemtool_uuid',
                                        related_name='+')
    description = models.CharField(max_length=255, blank=True, null=True)
    status_uuid = models.ForeignKey('Status', on_delete=models.DO_NOTHING,
                                    blank=True, null=True,
                                    db_column='status_uuid')
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
    uuid = models.UUIDField(
        primary_key=True, db_column='inventory_uuid')
    inventory_description = models.CharField(
        max_length=255, blank=True, null=True)
    part_no = models.CharField(max_length=255, blank=True, null=True)
    onhand_amt = models.FloatField(blank=True, null=True)
    unit = models.CharField(max_length=255, blank=True, null=True)
    # create_date = models.DateTimeField(blank=True, null=True)
    expiration_date = models.DateTimeField(blank=True, null=True)
    inventory_location = models.CharField(max_length=255,
                                          blank=True, null=True)
    status_uuid = models.ForeignKey('Status', on_delete=models.DO_NOTHING,
                                    blank=True, null=True, db_column='status_uuid')
    status_description = models.CharField(
        max_length=255, blank=True, null=True)
    material_uuid = models.ForeignKey('Material',
                                      models.DO_NOTHING,
                                      db_column='material_uuid',
                                      )
    material_description = models.CharField(max_length=255,
                                            blank=True, null=True)
    actor_uuid = models.ForeignKey('Actor', models.DO_NOTHING,
                                   db_column='actor_uuid',
                                   blank=True, null=True)
    actor_description = models.CharField(max_length=255,
                                         blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_inventory'

    def __str__(self):
        return "{}".format(self.inventory_description)


class InventoryMaterial(models.Model):
    uuid = models.UUIDField(primary_key=True, db_column='inventory_uuid')
    inventory_description = models.CharField(max_length=255,
                                             blank=True, null=True)
    inventory_part_no = models.CharField(max_length=255,
                                         blank=True, null=True)
    inventory_onhand_amt = models.FloatField(blank=True, null=True)
    inventory_unit = models.CharField(max_length=255, blank=True, null=True)
    inventory_expiration_date = models.DateTimeField(blank=True, null=True)
    inventory_add_date = models.DateTimeField()
    inventory_location = models.CharField(
        max_length=255, blank=True, null=True)
    inventory_status = models.ForeignKey('Status', models.DO_NOTHING,
                                         db_column='inventory_status_uuid',
                                         blank=True, null=True, related_name='inventory_status')
    inventory_status_description = models.CharField(
        max_length=255, blank=True, null=True)

    actor_uuid = models.ForeignKey('Actor', models.DO_NOTHING,
                                   db_column='actor_uuid',
                                   blank=True, null=True)
    actor_description = models.CharField(max_length=255, blank=True, null=True)
    org_full_name = models.CharField(max_length=255, blank=True, null=True)
    material_uuid = models.ForeignKey('Material', models.DO_NOTHING,
                                      db_column='material_uuid',
                                      blank=True, null=True)
    material_status = models.ForeignKey('Status', models.DO_NOTHING,
                                        db_column='material_status_uuid',
                                        blank=True, null=True, related_name='material_status')
    material_status_description = models.CharField(
        max_length=255, blank=True, null=True)
    material_add_date = models.DateTimeField()
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
    uuid = models.UUIDField(primary_key=True,
                            db_column='systemtool_uuid')
    systemtool_name = models.CharField(max_length=255, null=True)
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
    uuid = models.UUIDField(primary_key=True, db_column='systemtool_type_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_systemtool_type'

    def __str__(self):
        return self.description


class Calculation(models.Model):
    uuid = models.UUIDField(primary_key=True,
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

    calculation_status = models.ForeignKey('Status',
                                           models.DO_NOTHING,
                                           db_column='calculation_status_uuid',)
    calculation_status_description = models.CharField(max_length=255,
                                                      blank=True, null=True)
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
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_calculation'


class CalculationDef(models.Model):
    uuid = models.UUIDField(
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
    uuid = models.UUIDField(primary_key=True,
                            db_column='material_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)
    parent_uuid = models.ForeignKey('Material', on_delete=models.DO_NOTHING,
                                    blank=True, null=True, db_column='parent_uuid')

    material_status_uuid = models.ForeignKey('Status', on_delete=models.DO_NOTHING,
                                             blank=True, null=True, db_column='material_status_uuid')
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

    class Meta:
        managed = False
        db_table = 'vw_material'

    def __str__(self):
        return "{}".format(self.chemical_name)


class MaterialCalculationJson(models.Model):
    uuid = models.UUIDField(primary_key=True,
                            db_column='material_uuid')
    material_status_uuid = models.UUIDField()
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
    uuid = models.UUIDField(
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
    uuid = models.UUIDField(primary_key=True, db_column='material_type_uuid')
    description = models.TextField(blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_material_type'

    def __str__(self):
        return "{}".format(self.description)


class Note(models.Model):
    uuid = models.UUIDField(primary_key=True, db_column='note_uuid')
    notetext = models.TextField(blank=True, null=True,
                                verbose_name='Note Text')
    add_date = models.DateTimeField()
    mod_date = models.DateTimeField()
    """edocument_uuid = models.ForeignKey('Edocument',
                                       models.DO_NOTHING,
                                       db_column='edocument_uuid')
    edocument_type = models.CharField(max_length=255, blank=True, null=True)"""
    actor_uuid = models.ForeignKey('Actor', models.DO_NOTHING,
                                   db_column='actor_uuid')
    note_x_uuid = models.ForeignKey(
        'Note_x', models.DO_NOTHING, db_column='note_x_uuid')
    actor_description = models.CharField(max_length=255, blank=True, null=True)
    ref_note_uuid = models.UUIDField()

    class Meta:
        managed = False
        db_table = 'vw_note'

    def __str__(self):
        return "{}".format(self.notetext)


class Note_x(models.Model):
    uuid = models.UUIDField(primary_key=True, db_column='note_x_uuid')

    add_date = models.DateTimeField()
    mod_date = models.DateTimeField()
    note_uuid = models.ForeignKey('Note', models.DO_NOTHING,
                                  db_column='note_uuid')
    ref_note_uuid = models.UUIDField()

    class Meta:
        managed = False
        db_table = 'note_x'

    def __str__(self):
        return "{}".format(self.note_uuid)


class Organization(models.Model):
    uuid = models.UUIDField(primary_key=True, db_column='organization_uuid')
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
                                    blank=True, null=True,
                                    db_column='parent_uuid')
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
    uuid = models.UUIDField(primary_key=True, db_column='person_uuid')
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
    organization_uuid = models.ForeignKey('Organization', models.DO_NOTHING,
                                          blank=True, null=True,
                                          db_column='organization_uuid')
    organization_full_name = models.CharField(max_length=255,
                                              blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_person'

    def __str__(self):
        return "{} {}".format(self.first_name, self.last_name)


class Status(models.Model):
    uuid = models.UUIDField(primary_key=True, db_column='status_uuid')
    description = models.CharField(max_length=255, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_status'

    def __str__(self):
        return "{}".format(self.description)


class Tag(models.Model):
    uuid = models.UUIDField(primary_key=True, db_column='tag_uuid')
    display_text = models.CharField(max_length=255,  null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    tag_type_uuid = models.ForeignKey('TagType', models.DO_NOTHING,
                                      db_column='tag_type_uuid',
                                      blank=True, null=True)
    type = models.CharField(
        max_length=255, blank=True, null=True)
    type_description = models.CharField(
        max_length=255, blank=True, null=True)

    actor_uuid = models.ForeignKey('Actor', models.DO_NOTHING,
                                   db_column='actor_uuid',
                                   blank=True, null=True)
    actor_description = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_tag'

    def __str__(self):
        return "{}".format(self.display_text)


class Tag_X(models.Model):
    uuid = models.UUIDField(primary_key=True, db_column='tag_x_uuid')
    ref_tag_uuid = models.UUIDField()
    tag_uuid = models.ForeignKey('Tag', models.DO_NOTHING,
                                 db_column='tag_uuid')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_tag_x'

    def __str__(self):
        return "{}".format(self.uuid)


class TagType(models.Model):
    uuid = models.UUIDField(primary_key=True, db_column='tag_type_uuid')
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
    uuid = models.UUIDField(primary_key=True, db_column='edocument_uuid')
    title = models.CharField(max_length=255, blank=True,
                             null=True, db_column='title')
    description = models.CharField(max_length=255, blank=True, null=True,
                                   db_column='description')
    filename = models.CharField(max_length=255, blank=True, null=True,
                                db_column='filename')
    source = models.CharField(
        max_length=255, blank=True, null=True, db_column='source')
    doc_type = models.CharField(max_length=255, blank=True,
                                 null=True, db_column='doc_type_description')
    edocument = models.BinaryField(blank=True, null=True)
    doc_ver = models.CharField(max_length=255, blank=True,
                                null=True, db_column='doc_ver')
    actor_uuid = models.ForeignKey(
        'Actor', models.DO_NOTHING, db_column='actor_uuid', blank=True, null=True)
    actor_description = models.CharField(
        max_length=255, blank=True, null=True)
    status_uuid = models.ForeignKey(
        'Status', models.DO_NOTHING, db_column='status_uuid', blank=True, null=True)
    status_description = models.CharField(
        max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

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
    uuid = models.UUIDField(primary_key=True, db_column='udf_def_uuid')
    description = models.CharField(
        max_length=255,  null=True)
    valtype = models.CharField(
        max_length=255, blank=True, null=True)
    add_date = models.DateTimeField()
    mod_date = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'vw_udf_def'

    def __str__(self):
        return "{}".format(self.description)



class TypeDef(models.Model):

    uuid = models.UUIDField(primary_key=True,
                            db_column='type_def_uuid')

    category = models.CharField(max_length=255,
                                blank=True,
                                null=True,
                                db_column='category')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)
    class Meta:
        managed = False
        db_table = 'vw_type_def'

    def __str__(self):
        return self.description


class PropertyDef(models.Model):

    uuid = models.UUIDField(primary_key=True,
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
                                 null=True)
    val_unit = models.CharField(max_length=255,
                                blank=True,
                                null=True,
                                db_column='valunit')
    actor_uuid = models.ForeignKey('Actor',
                                   on_delete=models.DO_NOTHING,
                                   db_column='actor_uuid',
                                   blank=True,
                                   null=True,
                                   editable=False)
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='actor_description',
                                         editable=False)
    status_uuid = models.ForeignKey('Status',
                                    on_delete=models.DO_NOTHING,
                                    blank=True,
                                    null=True,
                                    db_column='status_uuid')
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

    property_x_uuid = models.UUIDField(primary_key=True,
                                       db_column='property_x_uuid')
    material_uuid = models.ForeignKey('Material',
                                      db_column='material_uuid',
                                      on_delete=models.DO_NOTHING,
                                      blank=True,
                                      null=True)
    property_description = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            db_column='description',
                                            editable=False)
    parent_uuid = models.ForeignKey('Material',
                                    on_delete=models.DO_NOTHING,
                                    db_column='parent_uuid',
                                    blank=True,
                                    null=True,
                                    related_name="material_uuid",
                                    editable=False)
    property_def_uuid = models.ForeignKey('PropertyDef',
                                          on_delete=models.DO_NOTHING,
                                          db_column='property_def_uuid',
                                          blank=True,
                                          null=True)
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
    value = models.CharField(max_length=255,
                                    blank=True,
                                    null=True,
                                    db_column='val_val')
    actor_uuid = models.ForeignKey('Actor',
                                   on_delete=models.DO_NOTHING,
                                   db_column='property_actor_uuid',
                                   blank=True,
                                   null=True,
                                   editable=False)
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='actor_description',
                                         editable=False)
    status_uuid = models.ForeignKey('Status',
                                    on_delete=models.DO_NOTHING,
                                    blank=True,
                                    null=True,
                                    db_column='property_status_uuid')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_material_property'
