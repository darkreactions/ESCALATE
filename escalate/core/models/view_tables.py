from django.db import models


managed_value = False


class ViewInventory(models.Model):
    # vw_inventory_uuid = models.OneToOneField(
    #    'Inventory', on_delete=models.DO_NOTHING, primary_key=True, db_column='inventory_uuid')
    vw_inventory_uuid = models.UUIDField(
        primary_key=True, db_column='inventory_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)
    material_uuid = models.ForeignKey(
        'ViewMaterial', models.DO_NOTHING, db_column='material_uuid')
    actor_uuid = models.ForeignKey(
        'ViewActor', models.DO_NOTHING, db_column='actor_uuid', blank=True, null=True)
    part_no = models.CharField(max_length=255, blank=True, null=True)
    onhand_amt = models.FloatField(blank=True, null=True)
    unit = models.CharField(max_length=255, blank=True, null=True)

    #measure_id = models.BigIntegerField(blank=True, null=True)
    create_date = models.DateTimeField(blank=True, null=True)
    expiration_date = models.DateTimeField(blank=True, null=True)
    inventory_location = models.CharField(
        max_length=255, blank=True, null=True)
    status_uuid = models.ForeignKey(
        'Status', models.DO_NOTHING, db_column='status_uuid', blank=True, null=True)
    edocument_uuid = models.ForeignKey(
        'Edocument', models.DO_NOTHING, db_column='edocument_uuid', blank=True, null=True)
    note_uuid = models.ForeignKey(
        'Note', models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'vw_inventory'


class ViewActor(models.Model):
    vw_actor_uuid = models.UUIDField(
        primary_key=True, db_column='actor_uuid')
    organization = models.ForeignKey(
        'Organization', on_delete=models.DO_NOTHING, blank=True, null=True)
    person = models.ForeignKey(
        'Person', on_delete=models.DO_NOTHING, blank=True, null=True)
    systemtool = models.ForeignKey(
        'Systemtool', on_delete=models.DO_NOTHING, blank=True, null=True)
    actor_description = models.CharField(max_length=255, blank=True, null=True)
    actor_status = models.CharField(max_length=255, blank=True, null=True)
    actor_notetext = models.CharField(max_length=255, blank=True, null=True)
    actor_document = models.BinaryField(blank=True, null=True)
    actor_doc_type = models.CharField(max_length=255, blank=True, null=True)
    org_full_name = models.CharField(max_length=255, blank=True, null=True)
    org_short_name = models.CharField(max_length=255, blank=True, null=True)
    per_lastname = models.CharField(max_length=255, blank=True, null=True)
    per_firstname = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = managed_value
        db_table = 'vw_actor'


class ViewLatestSystemtool(models.Model):
    #systemtool_id = models.BigAutoField(primary_key=True)
    vw_systemtool_uuid = models.UUIDField(
        primary_key=True, db_column='systemtool_uuid')
    systemtool_name = models.CharField(max_length=255)
    description = models.CharField(max_length=255, blank=True, null=True)
    systemtool_type = models.ForeignKey(
        'SystemtoolType', models.DO_NOTHING, blank=True, null=True)
    vendor_organization = models.ForeignKey(
        'Organization', models.DO_NOTHING, blank=True, null=True)
    model = models.CharField(max_length=255, blank=True, null=True)
    serial = models.CharField(max_length=255, blank=True, null=True)
    ver = models.CharField(max_length=255, blank=True, null=True)
    note = models.ForeignKey(
        'Note', models.DO_NOTHING, blank=True, null=True, db_column='note_uuid')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'vw_latest_systemtool'


class ViewLatestSystemtoolActor(models.Model):
    vw_actor_uuid = models.UUIDField(
        primary_key=True, db_column='actor_uuid')
    person = models.ForeignKey(
        'Person', models.DO_NOTHING, blank=True, null=True)
    organization = models.ForeignKey(
        'Organization', models.DO_NOTHING, blank=True, null=True)
    systemtool = models.ForeignKey(
        'Systemtool', models.DO_NOTHING, blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    status_uuid = models.ForeignKey(
        'Status', models.DO_NOTHING, db_column='status_uuid', blank=True, null=True)
    note_uuid = models.ForeignKey(
        'Note', models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'vw_latest_systemtool_actor'


class ViewMDescriptorDef(models.Model):
    vw_m_descriptor_def_uuid = models.UUIDField(
        primary_key=True, db_column='m_descriptor_def_uuid')
    short_name = models.CharField(max_length=255, blank=True, null=True)
    calc_definition = models.CharField(max_length=255, blank=True, null=True)
    description = models.CharField(max_length=1023, blank=True, null=True)
    in_type = models.CharField(max_length=255, blank=True, null=True)
    out_type = models.CharField(max_length=255, blank=True, null=True)
    systemtool = models.ForeignKey(
        'Systemtool', models.DO_NOTHING, blank=True, null=True)
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
        managed = managed_value
        db_table = 'vw_m_descriptor_def'


class ViewMDescriptor(models.Model):
    vw_m_descriptor_uuid = models.UUIDField(
        primary_key=True, db_column='m_descriptor_uuid')

    m_descriptor_alias_name = models.CharField(
        max_length=255, blank=True, null=True)
    in_val = models.TextField(blank=True, null=True)
    in_opt_val = models.TextField(blank=True, null=True)
    out_val = models.TextField(blank=True, null=True)
    create_date = models.DateTimeField(blank=True, null=True)
    status = models.CharField(max_length=255, blank=True, null=True)
    actor_descr = models.CharField(max_length=255, blank=True, null=True)
    note_text = models.CharField(max_length=255, blank=True, null=True)

    m_descriptor_def_uuid = models.ForeignKey(
        'ViewMDescriptorDef', models.DO_NOTHING, blank=True, null=True, db_column='m_descriptor_def_uuid')
    short_name = models.CharField(max_length=255, blank=True, null=True)
    calc_definition = models.CharField(max_length=255, blank=True, null=True)

    description = models.CharField(max_length=1023, blank=True, null=True)
    # This field type is a guess.
    in_type = models.TextField(blank=True, null=True)
    # This field type is a guess.
    out_type = models.TextField(blank=True, null=True)

    systemtool = models.ForeignKey(
        'Systemtool', models.DO_NOTHING, blank=True, null=True)
    systemtool_name = models.CharField(max_length=1023, blank=True, null=True)
    systemtool_type_description = models.CharField(
        max_length=1023, blank=True, null=True)
    systemtool_vendor_organization = models.CharField(
        max_length=1023, blank=True, null=True, db_column='systemtool_vendor_organzation')
    systemtool_version = models.CharField(
        max_length=1023, blank=True, null=True)

    actor_uuid = models.ForeignKey(
        'Actor', models.DO_NOTHING, db_column='actor_uuid', blank=True, null=True)
    actor_description = models.CharField(
        max_length=1023, blank=True, null=True)

    class Meta:
        managed = managed_value
        db_table = 'vw_m_descriptor'


class ViewMaterialRefnameType(models.Model):
    material_refname_type_uuid = models.UUIDField(primary_key=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    notetext = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = managed_value
        db_table = 'vw_material_refname_type'


class ViewMaterialRaw(models.Model):
    material_id = models.BigIntegerField(primary_key=True)
    material_uuid = models.UUIDField()
    material_description = models.CharField(
        max_length=255, blank=True, null=True)
    material_status = models.CharField(max_length=255, blank=True, null=True)
    material_refname_description = models.CharField(
        max_length=255, blank=True, null=True)
    material_refname_type_uuid = models.ForeignKey(
        'MaterialRefname', models.DO_NOTHING, blank=True, null=True, db_column='material_refname_type_uuid')
    material_refname_type = models.CharField(
        max_length=255, blank=True, null=True)
    create_date = models.DateTimeField()

    class Meta:
        managed = managed_value
        db_table = 'vw_material_raw'


class ViewMaterial(models.Model):
    material_uuid = models.UUIDField(primary_key=True)
    material_status = models.CharField(max_length=255, blank=True, null=True)
    create_date = models.DateTimeField()
    abbreviation = models.CharField(
        db_column='abbreviation', max_length=255, blank=True, null=True)
    chemical_name = models.CharField(
        db_column='chemical_name', max_length=255, blank=True, null=True)
    inchi = models.CharField(
        db_column='inchi', max_length=255, blank=True, null=True)
    inchi_key = models.CharField(
        db_column='inchikey', max_length=255, blank=True, null=True)
    molecular_formula = models.CharField(
        db_column='molecular_formula', max_length=255, blank=True, null=True)
    smiles = models.CharField(
        db_column='smiles', max_length=255, blank=True, null=True)

    class Meta:
        managed = managed_value
        db_table = 'vw_material'


class ViewMaterialDescriptorRaw(models.Model):
    material_uuid = models.UUIDField(primary_key=True)
    m_descriptor_uuid = models.UUIDField(blank=True, null=True)
    m_descriptor_alias_name = models.CharField(
        max_length=255, blank=True, null=True)
    in_val = models.TextField(blank=True, null=True)
    in_opt_val = models.TextField(blank=True, null=True)
    out_val = models.TextField(blank=True, null=True)

    class Meta:
        managed = managed_value
        db_table = 'vw_material_descriptor'


class ViewMaterialDescriptor(models.Model):
    material_uuid = models.UUIDField(primary_key=True)
    material_status = models.CharField(max_length=255, blank=True, null=True)
    create_date = models.DateTimeField()
    abbreviation = models.CharField(
        db_column='Abbreviation', max_length=255, blank=True, null=True)
    chemical_name = models.CharField(
        db_column='Chemical_Name', max_length=255, blank=True, null=True)
    inchi = models.CharField(
        db_column='InChI', max_length=255, blank=True, null=True)
    inchi_key = models.CharField(
        db_column='InChIKey', max_length=255, blank=True, null=True)
    molecular_formula = models.CharField(
        db_column='Molecular_Formula', max_length=255, blank=True, null=True)
    smiles = models.CharField(
        db_column='SMILES', max_length=255, blank=True, null=True)
    m_descriptor_uuid = models.UUIDField(blank=True, null=True)
    m_descriptor_alias_name = models.CharField(
        max_length=255, blank=True, null=True)
    in_val = models.TextField(blank=True, null=True)
    in_opt_val = models.TextField(blank=True, null=True)
    out_val = models.TextField(blank=True, null=True)

    class Meta:
        managed = managed_value
        db_table = 'vw_material_descriptor'


class ViewInventoryMaterial(models.Model):
    inventory_uuid = models.UUIDField(primary_key=True)
    inventory_description = models.CharField(
        max_length=255, blank=True, null=True)
    inventory_part_no = models.CharField(max_length=255, blank=True, null=True)
    inventory_onhand_amt = models.FloatField(blank=True, null=True)
    inventory_unit = models.CharField(max_length=255, blank=True, null=True)
    inventory_crate_date = models.DateTimeField(blank=True, null=True)
    inventory_expiration_date = models.DateTimeField(blank=True, null=True)
    inventory_location = models.CharField(
        max_length=255, blank=True, null=True)
    inventory_status = models.CharField(max_length=255, blank=True, null=True)
    actor_uuid = models.UUIDField(blank=True, null=True)
    actor_description = models.CharField(max_length=255, blank=True, null=True)
    org_full_name = models.CharField(max_length=255, blank=True, null=True)
    material_uuid = models.UUIDField(blank=True, null=True)
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


class ViewInventoryMaterialDescriptor(models.Model):
    inventory_uuid = models.OneToOneField(
        'Inventory', on_delete=models.DO_NOTHING, primary_key=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    material_uuid = models.ForeignKey(
        'Material', on_delete=models.DO_NOTHING, blank=True, null=True)
    actor_uuid = models.ForeignKey(
        'Actor', on_delete=models.DO_NOTHING, blank=True, null=True)
    part_no = models.CharField(max_length=255, blank=True, null=True)
    onhand_amt = models.FloatField(blank=True, null=True)
    unit = models.CharField(max_length=255, blank=True, null=True)
    create_date = models.DateTimeField(blank=True, null=True)
    expiration_date = models.DateTimeField(blank=True, null=True)
    inventory_location = models.CharField(
        max_length=255, blank=True, null=True)
    status_uuid = models.ForeignKey(
        'Status', on_delete=models.DO_NOTHING, blank=True, null=True)
    edocument_uuid = models.ForeignKey(
        'Edocument', on_delete=models.DO_NOTHING, blank=True, null=True)
    note_uuid = models.ForeignKey(
        'Note', on_delete=models.DO_NOTHING, blank=True, null=True)
    add_date = models.DateTimeField(blank=True, null=True)
    mod_date = models.DateTimeField(blank=True, null=True)
