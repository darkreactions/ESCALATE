from django.db import models


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
                                        blank=True, null=True, db_column='systemtool_uuid')
    actor_description = models.CharField(max_length=255, blank=True, null=True)
    actor_status = models.CharField(max_length=255, blank=True, null=True)
    actor_notetext = models.CharField(max_length=255, blank=True, null=True)
    org_full_name = models.CharField(max_length=255, blank=True, null=True)
    org_short_name = models.CharField(max_length=255, blank=True, null=True)
    per_lastname = models.CharField(max_length=255, blank=True, null=True)
    per_firstname = models.CharField(max_length=255, blank=True, null=True)
    person_lastfirst = models.CharField(max_length=255, blank=True, null=True)
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
    description = models.CharField(max_length=255,
                                   blank=True, null=True)

    edocument_uuid = models.ForeignKey('Edocument', models.DO_NOTHING,
                                       db_column='edocument_uuid',
                                       blank=True, null=True)
    edocument_description = models.CharField(max_length=255,
                                             blank=True, null=True)
    note_uuid = models.ForeignKey('Note', models.DO_NOTHING,
                                  db_column='note_uuid',
                                  blank=True, null=True)
    notetext = models.CharField(max_length=255,
                                blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_inventory'


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


class LatestSystemtool(models.Model):

    systemtool_uuid = models.UUIDField(primary_key=True,
                                       db_column='systemtool_uuid')
    systemtool_name = models.CharField(max_length=255, blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    vendor_organization = models.ForeignKey('Organization',
                                            models.DO_NOTHING,
                                            db_column='vendor_organization_uuid')
    organization_fullname = models.CharField(
        max_length=255, blank=True, null=True)
    systemtool_type = models.ForeignKey('SystemtoolType',
                                        models.DO_NOTHING,
                                        db_column='systemtool_type_uuid')
    systemtool_type_description = models.CharField(
        max_length=255, blank=True, null=True)
    model = models.CharField(max_length=255, blank=True, null=True)
    serial = models.CharField(max_length=255, blank=True, null=True)
    ver = models.CharField(max_length=255, blank=True, null=True)
    actor = models.ForeignKey('Actor', models.DO_NOTHING,
                              db_column='actor_uuid')
    actor_description = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_latest_systemtool'


class MDescriptor(models.Model):
    m_descriptor_uuid = models.UUIDField(primary_key=True,
                                         db_column='m_descriptor_uuid')
    in_val = models.TextField(blank=True, null=True)
    in_opt_val = models.TextField(blank=True, null=True)
    out_val = models.TextField(blank=True, null=True)
    m_descriptor_alias_name = models.CharField(
        max_length=255, blank=True, null=True)
    create_date = models.DateTimeField(blank=True, null=True)
    status = models.CharField(max_length=255, blank=True, null=True)
    actor_descr = models.CharField(max_length=255, blank=True, null=True)
    notetext = models.CharField(max_length=255, blank=True, null=True)

    m_descriptor_def = models.ForeignKey('MDescriptorDef',
                                         models.DO_NOTHING,
                                         blank=True, null=True,
                                         db_column='m_descriptor_def_uuid')
    short_name = models.CharField(max_length=255, blank=True, null=True)
    calc_definition = models.CharField(max_length=255, blank=True, null=True)

    description = models.CharField(max_length=1023, blank=True, null=True)
    in_type = models.CharField(max_length=255, blank=True, null=True)
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
        db_table = 'vw_m_descriptor'


class MDescriptorDef(models.Model):
    m_descriptor_def_uuid = models.UUIDField(
        primary_key=True, db_column='m_descriptor_def_uuid')
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
        max_length=255, blank=True, null=True, db_column='systemtool_vendor_organzation')
    systemtool_version = models.CharField(
        max_length=255, blank=True, null=True)
    actor = models.ForeignKey(
        'Actor', models.DO_NOTHING, blank=True, null=True, db_column='actor_uuid')
    actor_description = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_m_descriptor_def'


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


class MaterialDescriptor(models.Model):
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
    m_descriptor_uuid = models.ForeignKey('MDescriptor',
                                          models.DO_NOTHING,
                                          db_column='m_descriptor_uuid')
    m_descriptor_alias_name = models.CharField(
        max_length=255, blank=True, null=True)
    in_val = models.TextField(blank=True, null=True)
    in_opt_val = models.TextField(blank=True, null=True)
    out_val = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_material_descriptor'


class MaterialRefnameType(models.Model):
    material_refname_type_uuid = models.UUIDField(primary_key=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    notetext = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_material_refname_type'


class MaterialType(models.Model):
    material_type_uuid = models.UUIDField(primary_key=True)
    description = models.TextField(blank=True, null=True)
    notetext = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_material_type'


class Note(models.Model):
    note_uuid = models.UUIDField(primary_key=True)
    notetext = models.TextField(blank=True, null=True)
    add_date = models.DateTimeField()
    mod_date = models.DateTimeField()
    edocument_uuid = models.ForeignKey('Edocument',
                                       models.DO_NOTHING,
                                       db_column='edocument_uuid')
    edocument_type = models.CharField(max_length=255, blank=True, null=True)
    actor = models.ForeignKey('Actor', models.DO_NOTHING,
                              db_column='actor_uuid')
    actor_description = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_note'


class Organization(models.Model):
    organization_uuid = models.UUIDField(primary_key=True)
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
                               blank=True, null=True, db_column='parent_uuid')
    parent_org_full_name = models.CharField(max_length=255)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)
    note = models.ForeignKey('Note', models.DO_NOTHING,
                             db_column='note_uuid',
                             blank=True, null=True)
    notetext = models.TextField(blank=True, null=True)
    edocument = models.ForeignKey('Edocument',
                                  models.DO_NOTHING,
                                  db_column='edocument_uuid')
    edocument_descr = models.CharField(max_length=255, blank=True, null=True)
    tag = models.ForeignKey('Tag', models.DO_NOTHING,
                            db_column='tag_uuid')
    tag_short_descr = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_organization'


class Person(models.Model):
    person_uuid = models.UUIDField(primary_key=True)
    firstname = models.CharField(max_length=255, blank=True, null=True)
    lastname = models.CharField(max_length=255)
    middlename = models.CharField(max_length=255, blank=True, null=True)
    address1 = models.CharField(max_length=255, blank=True, null=True)
    address2 = models.CharField(max_length=255, blank=True, null=True)
    city = models.CharField(max_length=255, blank=True, null=True)
    stateprovince = models.CharField(max_length=3, blank=True, null=True)
    zip = models.CharField(max_length=255, blank=True, null=True)
    country = models.CharField(max_length=255, blank=True, null=True)

    phone = models.CharField(max_length=255, blank=True, null=True)
    email = models.CharField(max_length=255, blank=True, null=True)
    title = models.CharField(max_length=255, blank=True, null=True)
    suffix = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    organization = models.ForeignKey('Organization', models.DO_NOTHING,
                                     blank=True, null=True,
                                     db_column='organization_uuid')
    full_name = models.CharField(max_length=255)
    note_uuid = models.ForeignKey('Note', models.DO_NOTHING,
                                  db_column='note_uuid', blank=True, null=True)
    notetext = models.TextField(blank=True, null=True)
    edocument = models.ForeignKey('Edocument',
                                  models.DO_NOTHING,
                                  db_column='edocument_uuid')
    edocument_descr = models.CharField(max_length=255, blank=True, null=True)
    tag = models.ForeignKey('Tag', models.DO_NOTHING,
                            db_column='tag_uuid')
    tag_short_descr = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_person'


class Status(models.Model):
    status_uuid = models.UUIDField(primary_key=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_status'


class Tag(models.Model):
    tag_uuid = models.UUIDField(primary_key=True)
    tag_short_descr = models.CharField(max_length=255, blank=True, null=True)
    tag_description = models.CharField(max_length=255, blank=True, null=True)
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


class TagType(models.Model):
    tag_type_uuid = models.UUIDField(primary_key=True)
    short_description = models.CharField(max_length=255, blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    actor_uuid = models.ForeignKey(
        'Actor', models.DO_NOTHING, db_column='actor_uuid', blank=True, null=True)
    actor_description = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_tag_type'
