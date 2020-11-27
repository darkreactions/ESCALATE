from django.db import models
from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType
#from django.contrib.postgres.fields import JSONField
from django.db.models import JSONField
managed_value = False


class RetUUIDField(models.UUIDField):
    """A UUID field which populates with the UUID from Postgres on CREATE.
    
    **Use this instead of models.UUIDField**
    
    Our tables are managed by postgres, not django. Without this field, 
    django would have no direct way of knowing the UUID of newly created resources, 
    which would lead to errors. 
    """
    db_returning=True
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

class Actor(models.Model):
#class Actor(CommonData):
    uuid = RetUUIDField(primary_key=True, db_column='actor_uuid')
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
    uuid = RetUUIDField(
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
    uuid = RetUUIDField(primary_key=True, db_column='inventory_uuid')
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


class Systemtool(models.Model):
    uuid = RetUUIDField(primary_key=True,
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

    # in
    in_val = models.TextField(blank=True, null=True)
    in_val_type = models.ForeignKey('TypeDef',
                                         models.DO_NOTHING,
                                         db_column='in_val_type_uuid',
                                         related_name='in_val_type')
    in_val_value = models.TextField(blank=True, null=True)
    in_val_unit = models.TextField(blank=True, null=True)
    in_val_edocument = models.ForeignKey('Edocument',
                                         models.DO_NOTHING,
                                         db_column='in_val_edocument_uuid',
                                         related_name='in_val_edocument')

    # in opt
    in_opt_val = models.TextField(blank=True, null=True)
    in_opt_val_value = models.TextField(blank=True, null=True)
    in_opt_val_type = models.ForeignKey('TypeDef',
                                        models.DO_NOTHING,
                                        related_name='in_opt_val_type',
                                        db_column='in_opt_val_type_uuid',
                                        blank=True, null=True)
    in_opt_val_unit = models.TextField(blank=True, null=True)
    in_opt_val_edocument = models.ForeignKey('Edocument',
                                             models.DO_NOTHING,
                                             db_column='in_opt_val_edocument_uuid',
                                             related_name='in_opt_val_edocument')
    # out
    out_val = models.TextField(blank=True, null=True)
    out_val_type = models.ForeignKey('TypeDef',
                                     models.DO_NOTHING,
                                     related_name='out_val_type',
                                     db_column='out_val_type_uuid',
                                     blank=True, null=True)
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
    uuid = RetUUIDField(
        primary_key=True, db_column='calculation_def_uuid')
    short_name = models.CharField(max_length=255, blank=True, null=True)
    calc_definition = models.CharField(max_length=255, blank=True, null=True)
    description = models.CharField(max_length=1023, blank=True, null=True)
    in_type = models.ForeignKey('TypeDef',
                                models.DO_NOTHING,
                                db_column='in_type_uuid',
                                related_name='in_type')
    in_type_description = models.CharField(max_length=255, blank=True, null=True)
    out_type = models.ForeignKey('TypeDef',
                                 models.DO_NOTHING,
                                 blank=True, null=True,
                                 db_column='out_type_uuid',
                                 related_name='out_type')
    out_type_description = models.CharField(max_length=255, blank=True, null=True)
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
    uuid = RetUUIDField(primary_key=True,
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
    uuid = RetUUIDField(primary_key=True,
                            db_column='material_uuid')
    material_status_uuid = RetUUIDField()
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
    add_date = models.DateTimeField()
    mod_date = models.DateTimeField()
    """edocument_uuid = models.ForeignKey('Edocument',
                                       models.DO_NOTHING,
                                       db_column='edocument_uuid')
    edocument_type = models.CharField(max_length=255, blank=True, null=True)"""
    actor_uuid = models.ForeignKey('Actor', models.DO_NOTHING,
                                   db_column='actor_uuid')
    # note_x_uuid = models.ForeignKey('Note_x', models.DO_NOTHING,
    #                                 db_column='note_x_uuid')
    actor_description = models.CharField(max_length=255, blank=True, null=True)
    # ref_note_uuid = RetUUIDField()

    class Meta:
        managed = False
        db_table = 'vw_note'

    def __str__(self):
        return "{}".format(self.notetext)


class Note_x(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='note_x_uuid')
    ref_note_uuid = RetUUIDField()
    note_uuid = models.ForeignKey('Note', models.DO_NOTHING,
                                  blank=True,
                                  null=True,
                                  editable=False,
                                  db_column='note_uuid')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)
    class Meta:
        managed = False
        db_table = 'note_x'

    def __str__(self):
        return "{}".format(self.note_uuid)


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
    uuid = RetUUIDField(primary_key=True, db_column='tag_uuid')
    display_text = models.CharField(max_length=255,  null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    actor_uuid = models.ForeignKey('Actor', models.DO_NOTHING,
                                   db_column='actor_uuid',
                                   blank=True, null=True)
    actor_description = models.CharField(max_length=255, blank=True, null=True)
    
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    tag_type_uuid = models.ForeignKey('TagType', models.DO_NOTHING,
                                      db_column='tag_type_uuid',
                                      blank=True, null=True)
    type = models.CharField(
        max_length=255, blank=True, null=True)
    type_description = models.CharField(
        max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_tag'

    def __str__(self):
        return "{}".format(self.display_text)


class Tag_X(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='tag_x_uuid')
    ref_tag_uuid = RetUUIDField()
    tag_uuid = models.ForeignKey('Tag', models.DO_NOTHING,
                                 blank=True,
                                 null=True,
                                 editable=False,
                                 db_column='tag_uuid')
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
    uuid = RetUUIDField(primary_key=True, db_column='edocument_uuid')
    title = models.CharField(max_length=255, blank=True,
                             null=True, db_column='title')
    description = models.CharField(max_length=255, blank=True, null=True,
                                   db_column='description')
    filename = models.CharField(max_length=255, blank=True, null=True,
                                db_column='filename')
    source = models.CharField(
        max_length=255, blank=True, null=True, db_column='source')
    edoc_type = models.CharField(max_length=255, blank=True,
                                 null=True, db_column='doc_type_description')
    edocument = models.BinaryField(blank=True, null=True)
    edoc_ver = models.CharField(max_length=255, blank=True,
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
    uuid = RetUUIDField(primary_key=True, db_column='udf_def_uuid')
    description = models.CharField(
        max_length=255,  null=True)
    val_type_uuid = models.ForeignKey('TypeDef',
                                 db_column='val_type_uuid',
                                 on_delete=models.DO_NOTHING,
                                 blank=True,
                                 null=True)
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



class TypeDef(models.Model):

    uuid = RetUUIDField(primary_key=True,
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

    #property_x_uuid = RetUUIDField(primary_key=True,
    #                                   db_column='property_x_uuid')
    uuid = RetUUIDField(primary_key=True,
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


class ParameterDef(models.Model):
    #parameter_def_uuid = RetUUIDField(primary_key=True,
    #                                      db_column='parameter_def_uuid')
    uuid = RetUUIDField(primary_key=True,
                                          db_column='parameter_def_uuid')
    description = models.CharField(max_length=255,
                                    blank=True,
                                    null=True,
                                    db_column='description',
                                    editable=False)
    val_type_description  = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            db_column='val_type_description',
                                            editable=False)
    val_type_uuid = models.ForeignKey('TypeDef',
                                 db_column='val_type_uuid',
                                 on_delete=models.DO_NOTHING,
                                 blank=True,
                                 null=True)
    default_val_val  = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            db_column='default_val_val',
                                            editable=False)
    valunit  = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            db_column='valunit',
                                            editable=False)
    default_val  = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            db_column='default_val',
                                            editable=False)
    required  = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            db_column='required',
                                            editable=False)
    actor_uuid = models.ForeignKey('Actor',
                                   on_delete=models.DO_NOTHING,
                                   db_column='actor_uuid',
                                   blank=True,
                                   null=True,
                                   editable=False)
    actor_description  = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            db_column='actor_description',
                                            editable=False)
    status_uuid = models.ForeignKey('Status',
                                   on_delete=models.DO_NOTHING,
                                   db_column='status_uuid',
                                   blank=True,
                                   null=True,
                                   editable=False)
    status_description  = models.CharField(max_length=255,
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
    parameter_def = models.ManyToManyField('ParameterDef', through='ActionParameterDefAssign')
    description = models.CharField(max_length=255,
                                    blank=True,
                                    null=True,
                                    db_column='description',
                                    editable=False)
    actor_uuid = models.ForeignKey('Actor',
                                   on_delete=models.DO_NOTHING,
                                   db_column='actor_uuid',
                                   blank=True,
                                   null=True,
                                   editable=False)
    actor_description  = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            db_column='actor_description',
                                            editable=False)
    status_uuid = models.ForeignKey('Status',
                                   on_delete=models.DO_NOTHING,
                                   db_column='status_uuid',
                                   blank=True,
                                   null=True,
                                   editable=False)
    status_description  = models.CharField(max_length=255,
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
                                      db_column='condition_def_uuid')
    calculation_description = models.CharField(max_length=255,
                                blank=True,
                                null=True,
                                editable=False)
    in_val = models.CharField(max_length=255,
                                blank=True,
                                null=True,
                                editable=False)
    out_val = models.CharField(max_length=255,
                                blank=True,
                                null=True,
                                editable=False)
    actor_uuid = models.ForeignKey('Actor',
                                   on_delete=models.DO_NOTHING,
                                   db_column='actor_uuid',
                                   blank=True,
                                   null=True,
                                   editable=False)
    actor_description  = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            db_column='actor_description',
                                            editable=False)
    status_uuid = models.ForeignKey('Status',
                                   on_delete=models.DO_NOTHING,
                                   db_column='status_uuid',
                                   blank=True,
                                   null=True,
                                   editable=False)
    status_description  = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            db_column='status_description',
                                            editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed=False
        db_table='vw_condition'

class ConditionDef(models.Model):

    uuid = uuid = RetUUIDField(primary_key=True, db_column='condition_def_uuid')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description',
                                   editable=False)
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
                                    db_column='status_uuid',
                                    blank=True,
                                    null=True,
                                    editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed=False
        db_table='vw_condition_def'

class ActionParameterDef(models.Model):
    #action_parameter_def_x_uuid = RetUUIDField(primary_key=True, db_column='action_parameter_def_x_uuid')
    uuid = RetUUIDField(primary_key=True, db_column='action_parameter_def_x_uuid')
    action_def_uuid = models.ForeignKey('ActionDef',
                                   on_delete=models.DO_NOTHING,
                                   db_column='action_def_uuid',
                                   blank=True,
                                   null=True,
                                   editable=False, related_name='action_parameter_def')
    
    description = models.CharField(max_length=255,
                                    blank=True,
                                    null=True,
                                    db_column='description',
                                    editable=False)
    actor_uuid = models.ForeignKey('Actor',
                                   on_delete=models.DO_NOTHING,
                                   db_column='actor_uuid',
                                   blank=True,
                                   null=True,
                                   editable=False)
    actor_description  = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            db_column='actor_description',
                                            editable=False)
    status_uuid = models.ForeignKey('Status',
                                   on_delete=models.DO_NOTHING,
                                   db_column='status_uuid',
                                   blank=True,
                                   null=True,
                                   editable=False)
    status_description  = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            db_column='status_description',
                                            editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)
    #parameter_def_uuid = RetUUIDField(primary_key=True,
    #                                      db_column='parameter_def_uuid')
    
    parameter_def_uuid = models.ForeignKey('ParameterDef',
                                   on_delete=models.DO_NOTHING,
                                   db_column='parameter_def_uuid',
                                   blank=True,
                                   null=True,
                                   editable=False)
    
    parameter_description = models.CharField(max_length=255,
                                               blank=True,
                                               null=True,
                                               db_column='parameter_description',
                                               editable=False)
    parameter_val_type_uuid = models.ForeignKey('TypeDef',
                                      db_column='parameter_val_type_uuid',
                                      on_delete=models.DO_NOTHING,
                                      blank=True,
                                      null=True)
    class Meta:
        managed = False
        db_table = 'vw_action_parameter_def'
        unique_together = ['action_def_uuid', 'parameter_def_uuid']


class ActionParameterDefAssign(models.Model):
    #action_parameter_def_x_uuid = RetUUIDField(primary_key=True, db_column='action_parameter_def_x_uuid')
    uuid = RetUUIDField(primary_key=True, db_column='action_parameter_def_x_uuid')
    parameter_def_uuid = models.ForeignKey('ParameterDef', 
                                           on_delete=models.DO_NOTHING, 
                                           blank=True,
                                           null=True,
                                           editable=False,
                                           db_column='parameter_def_uuid',
                                           related_name='action_parameter_def')
    action_def_uuid = models.ForeignKey('ActionDef', on_delete=models.DO_NOTHING,
                                        blank=True,
                                        null=True,
                                        editable=False, db_column='action_def_uuid',)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_action_parameter_def_assign'


class ActionParameterAssign(models.Model):
    action_parameter_x_uuid = RetUUIDField(primary_key=True, db_column='action_parameter_x_uuid')
    parameter_uuid = models.ForeignKey('Parameter',
                                       on_delete=models.DO_NOTHING,
                                       blank=True,
                                       null=True,
                                       editable=False,
                                       db_column='parameter_uuid',
                                       related_name='parameter')
    action_uuid = models.ForeignKey('Action',
                                    on_delete=models.DO_NOTHING,
                                    blank=True,
                                    null=True,
                                    editable=False,
                                    db_column='action_uuid')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_action_parameter' # todo, make a complimentary assign view for ap instances


class Action(models.Model):
    action_uuid = RetUUIDField(primary_key=True,
                                   db_column='action_uuid')
    parameter = models.ManyToManyField('Parameter', through='ActionParameterAssign')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='action_description')
    action_def = models.ForeignKey('ActionDef',
                                   on_delete=models.DO_NOTHING,
                                   db_column='action_def_uuid',
                                   blank=True,
                                   null=True,)
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
                                    db_column='status_uuid',
                                    blank=True,
                                    null=True)
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

class Parameter(models.Model):
    uuid = RetUUIDField(primary_key=True,
                                     db_column='parameter_uuid')
    action_uuid = models.ForeignKey('Action',
                                    db_column='action_uuid',
                                    on_delete=models.DO_NOTHING,
                                    blank=True,
                                    null=True,
                                    editable=False,
                                    related_name='action')
    parameter_def_uuid = models.ForeignKey('ParameterDef',
                                           db_column='parameter_def_uuid',
                                           on_delete=models.DO_NOTHING,
                                           blank=True,
                                           null=True,
                                           editable=False)
    parameter_def_description = models.CharField(max_length=255,
                                                blank=True,
                                                null=True,
                                                db_column='parameter_def_description',
                                                editable=False)
    parameter_val = models.CharField(max_length=255,
                                     blank=True,
                                     null=True,
                                     db_column='parameter_val')
    # val_type_description  = models.CharField(max_length=255,
    #                                          blank=True,
    #                                          null=True,
    #                                          db_column='val_type_description',
    #                                          editable=False)
    # valunit  = models.CharField(max_length=255,
    #                             blank=True,
    #                             null=True,
    #                             db_column='valunit',
    #                             editable=False)
    actor_uuid = models.ForeignKey('Actor',
                                   on_delete=models.DO_NOTHING,
                                   db_column='parameter_actor_uuid',
                                   blank=True,
                                   null=True,
                                   editable=False)
    actor_description  = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            db_column='parameter_actor_description',
                                            editable=False)
    status_uuid = models.ForeignKey('Status',
                                   on_delete=models.DO_NOTHING,
                                   db_column='parameter_status_uuid',
                                   blank=True,
                                   null=True,
                                   editable=False)
    status_description  = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            db_column='parameter_status_description',
                                            editable=False)
    add_date = models.DateTimeField(auto_now_add=True, db_column='parameter_add_date')
    mod_date = models.DateTimeField(auto_now=True, db_column='parameter_mod_date')

    class Meta:
        managed = False
        db_table = 'vw_action_parameter' # todo: discuss the asymmetry here w/ g+s


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
    step = models.ManyToManyField('WorkflowStep', through='WorkflowStep')
    description = models.CharField(max_length=255,
                                     blank=True,
                                     null=True,
                                     db_column='description',
                                     editable=False)
    parent_uuid = models.ForeignKey('Workflow', models.DO_NOTHING,
                                    blank=True, null=True,
                                    db_column='parent_uuid')
    workflow_type = models.ForeignKey('WorkflowType', models.DO_NOTHING,
                                      blank=True, null=True,
                                      db_column='workflow_type_uuid')
    workflow_type_description = models.CharField(max_length=255,
                                     blank=True,
                                     null=True,
                                     editable=False)
    actor = models.ForeignKey('Actor',
                               on_delete=models.DO_NOTHING,
                               db_column='actor_uuid',
                               blank=True,
                               null=True,
                               editable=False)
    actor_description  = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            db_column='actor_description',
                                            editable=False)
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False)
    status_description  = models.CharField(max_length=255,
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
    workflow_uuid = models.ForeignKey('Workflow', models.DO_NOTHING,
                                      db_column='workflow_uuid',
                                      related_name='workflow_uuid')
    workflow_description = models.CharField(max_length=255,
                                             blank=True,
                                             null=True,
                                             editable=False)
    parent_uuid = models.ForeignKey('WorkflowStep', models.DO_NOTHING,
                                    blank=True, null=True, editable=False,
                                    db_column='parent_uuid')
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
    conditional_val = models.CharField(max_length=255,
                                     blank=True,
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
                               editable=False)
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True, db_column='add_date')
    mod_date = models.DateTimeField(auto_now=True, db_column='mod_date')

    workflow_object_uuid = models.ForeignKey('WorkflowObject', models.DO_NOTHING,
                                             db_column='workflow_object_uuid')
    # unclear how to make this an fk for django...
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
    # object_add_date
    # object_mod_date
    class Meta:
        managed = False
        db_table = 'vw_workflow_step'


class WorkflowObject(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='workflow_object_uuid')
    action_uuid = models.ForeignKey('Action', models.DO_NOTHING,
                                    blank=True, null=True, editable=False,
                                    related_name='wf_action_uuid',
                                    db_column='action_uuid')
    condition_uuid = models.ForeignKey('Condition', models.DO_NOTHING,
                                       blank=True, null=True, editable=False,
                                       related_name='wf_condition_uuid',
                                       db_column='condition_uuid')
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
