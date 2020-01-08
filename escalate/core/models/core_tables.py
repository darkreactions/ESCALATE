# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey has `on_delete` set to the desired behavior.
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models
from datetime import datetime
from django.utils.timezone import now

managed_value = False


class Actor(models.Model):
    actor_id = models.BigAutoField(primary_key=True)
    actor_uuid = models.UUIDField(blank=True, null=True)
    person = models.ForeignKey(
        'Person', models.DO_NOTHING, blank=True, null=True)
    organization = models.ForeignKey(
        'Organization', models.DO_NOTHING, blank=True, null=True)
    systemtool = models.ForeignKey(
        'Systemtool', models.DO_NOTHING, blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    status = models.ForeignKey(
        'Status', models.DO_NOTHING, blank=True, null=True)
    note = models.ForeignKey('Note', models.DO_NOTHING, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'actor'
        unique_together = (('person', 'organization', 'systemtool'),)

    def __str__(self):
        return self.description


class Edocument(models.Model):
    edocument_id = models.BigAutoField(primary_key=True)
    edocument_uuid = models.UUIDField(blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    edocument = models.BinaryField(blank=True, null=True)
    edoc_type = models.CharField(max_length=255, blank=True, null=True)
    ver = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'edocument'

    def __str__(self):
        return self.description


class Files(models.Model):
    filename = models.TextField(blank=True, null=True)

    class Meta:
        managed = managed_value
        db_table = 'files'

    def __str__(self):
        return self.filename


class Inventory(models.Model):
    inventory_id = models.BigAutoField(primary_key=True)
    inventory_uuid = models.UUIDField(blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    material = models.ForeignKey('Material', models.DO_NOTHING)
    actor = models.ForeignKey(Actor, models.DO_NOTHING, blank=True, null=True)
    part_no = models.CharField(max_length=255, blank=True, null=True)
    onhand_amt = models.FloatField(blank=True, null=True)
    unit = models.CharField(max_length=255, blank=True, null=True)
    measure_id = models.BigIntegerField(blank=True, null=True)
    create_date = models.DateTimeField(blank=True, null=True)
    expiration_dt = models.DateTimeField(blank=True, null=True)
    inventory_location = models.CharField(
        max_length=255, blank=True, null=True)
    status = models.ForeignKey(
        'Status', models.DO_NOTHING, blank=True, null=True)
    document_id = models.BigIntegerField(blank=True, null=True)
    note = models.ForeignKey('Note', models.DO_NOTHING, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'inventory'
        unique_together = (('material', 'actor', 'create_date'),)

    def __str__(self):
        return self.description


class LoadExpdataJson(models.Model):
    uid = models.CharField(primary_key=True, max_length=255)
    # This field type is a guess.
    exp_json = models.TextField(blank=True, null=True)
    add_dt = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = managed_value
        db_table = 'load_EXPDATA_JSON'


class LoadChemInventory(models.Model):
    # Field name made lowercase.
    chemicalname = models.CharField(
        db_column='ChemicalName', max_length=255, blank=True, null=True)
    # Field name made lowercase.
    chemicalabbreviation = models.CharField(
        db_column='ChemicalAbbreviation', max_length=255, blank=True, null=True)
    # Field name made lowercase.
    molecularweight = models.CharField(
        db_column='MolecularWeight', max_length=255, blank=True, null=True)
    # Field name made lowercase.
    density = models.CharField(
        db_column='Density', max_length=255, blank=True, null=True)
    # Field name made lowercase.
    inchi = models.CharField(
        db_column='InChI', max_length=255, blank=True, null=True)
    # Field name made lowercase.
    inchikey = models.CharField(
        db_column='InChIKey', max_length=255, blank=True, null=True)
    # Field name made lowercase.
    chemicalcategory = models.CharField(
        db_column='ChemicalCategory', max_length=255, blank=True, null=True)
    # Field name made lowercase.
    canonicalsmiles = models.CharField(
        db_column='CanonicalSMILES', max_length=255, blank=True, null=True)
    # Field name made lowercase.
    molecularformula = models.CharField(
        db_column='MolecularFormula', max_length=255, blank=True, null=True)
    # Field name made lowercase.
    pubchemid = models.CharField(
        db_column='PubChemID', max_length=255, blank=True, null=True)
    # Field name made lowercase.
    catalogdescr = models.CharField(
        db_column='CatalogDescr', max_length=255, blank=True, null=True)
    # Field name made lowercase.
    synonyms = models.CharField(
        db_column='Synonyms', max_length=255, blank=True, null=True)
    # Field name made lowercase.
    catalogno = models.CharField(
        db_column='CatalogNo', max_length=255, blank=True, null=True)
    # Field name made lowercase. Field renamed to remove unsuitable characters.
    sigma_aldrich_url = models.CharField(
        db_column='Sigma-Aldrich URL', max_length=255, blank=True, null=True)
    # Field name made lowercase.
    primaryinformationsource = models.CharField(
        db_column='PrimaryInformationSource', max_length=255, blank=True, null=True)
    # Field name made lowercase.
    standardizedsmiles = models.CharField(
        db_column='StandardizedSMILES', max_length=255, blank=True, null=True)

    class Meta:
        managed = managed_value
        db_table = 'load_chem_inventory'

    def __str__(self):
        return self.chemicalname


class LoadDirfiles(models.Model):
    filename = models.TextField(blank=True, null=True)

    class Meta:
        managed = managed_value
        db_table = 'load_dirfiles'

    def __str__(self):
        return self.filename


class LoadHcInventory(models.Model):
    reagent = models.CharField(max_length=255)
    part_no = models.CharField(max_length=255, blank=True, null=True)
    amount = models.FloatField(blank=True, null=True)
    units = models.CharField(max_length=255, blank=True, null=True)
    update_date = models.DateTimeField(auto_now=True)
    create_date = models.DateTimeField(auto_now_add=True)

    class Meta:
        managed = managed_value
        db_table = 'load_hc_inventory'


class LoadLblInventory(models.Model):
    reagent = models.CharField(max_length=255)
    part_no = models.CharField(max_length=255, blank=True, null=True)
    amount = models.FloatField(blank=True, null=True)
    units = models.CharField(max_length=255, blank=True, null=True)
    update_date = models.DateTimeField(auto_now=True)
    create_date = models.DateTimeField(auto_now_add=True)

    class Meta:
        managed = managed_value
        db_table = 'load_lbl_inventory'


class LoadPerovDesc(models.Model):
    # Field renamed because it started with '_'.
    field_raw_inchikey = models.CharField(
        db_column='_raw_inchikey', max_length=255, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_raw_smiles = models.CharField(
        db_column='_raw_smiles', max_length=255, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_raw_molweight = models.DecimalField(
        db_column='_raw_molweight', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_raw_smiles_standard = models.CharField(
        db_column='_raw_smiles_standard', max_length=255, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_raw_standard_molweight = models.DecimalField(
        db_column='_raw_standard_molweight', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_prototype_ecpf4_256_6 = models.CharField(
        db_column='_prototype_ecpf4_256_6', max_length=256, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_atomcount_c = models.DecimalField(
        db_column='_feat_atomcount_c', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_atomcount_n = models.DecimalField(
        db_column='_feat_atomcount_n', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_avgpol = models.DecimalField(
        db_column='_feat_avgpol', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_molpol = models.DecimalField(
        db_column='_feat_molpol', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_refractivity = models.DecimalField(
        db_column='_feat_refractivity', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_aliphaticringcount = models.DecimalField(
        db_column='_feat_aliphaticringcount', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_aromaticringcount = models.DecimalField(
        db_column='_feat_aromaticringcount', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_aliphaticatomcount = models.DecimalField(
        db_column='_feat_aliphaticatomcount', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_aromaticatomcount = models.DecimalField(
        db_column='_feat_aromaticatomcount', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_bondcount = models.DecimalField(
        db_column='_feat_bondcount', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_carboaliphaticringcount = models.DecimalField(
        db_column='_feat_carboaliphaticringcount', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_carboaromaticringcount = models.DecimalField(
        db_column='_feat_carboaromaticringcount', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_carboringcount = models.DecimalField(
        db_column='_feat_carboringcount', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_chainatomcount = models.DecimalField(
        db_column='_feat_chainatomcount', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_chiralcentercount = models.DecimalField(
        db_column='_feat_chiralcentercount', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_ringatomcount = models.DecimalField(
        db_column='_feat_ringatomcount', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_smallestringsize = models.DecimalField(
        db_column='_feat_smallestringsize', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_largestringsize = models.DecimalField(
        db_column='_feat_largestringsize', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_heteroaliphaticringcount = models.DecimalField(
        db_column='_feat_heteroaliphaticringcount', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_heteroaromaticringcount = models.DecimalField(
        db_column='_feat_heteroaromaticringcount', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_rotatablebondcount = models.DecimalField(
        db_column='_feat_rotatablebondcount', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_balabanindex = models.DecimalField(
        db_column='_feat_balabanindex', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_cyclomaticnumber = models.DecimalField(
        db_column='_feat_cyclomaticnumber', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_hyperwienerindex = models.DecimalField(
        db_column='_feat_hyperwienerindex', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_wienerindex = models.DecimalField(
        db_column='_feat_wienerindex', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_wienerpolarity = models.DecimalField(
        db_column='_feat_wienerpolarity', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_minimalprojectionarea = models.DecimalField(
        db_column='_feat_minimalprojectionarea', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_maximalprojectionarea = models.DecimalField(
        db_column='_feat_maximalprojectionarea', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_minimalprojectionradius = models.DecimalField(
        db_column='_feat_minimalprojectionradius', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_maximalprojectionradius = models.DecimalField(
        db_column='_feat_maximalprojectionradius', max_digits=255, decimal_places=0, blank=True, null=True)
    field_feat_lengthperpendiculartotheminarea = models.DecimalField(
        db_column='_feat_lengthperpendiculartotheminarea', max_digits=255, decimal_places=0, blank=True, null=True)  # Field renamed because it started with '_'.
    field_feat_lengthperpendiculartothemaxarea = models.DecimalField(
        db_column='_feat_lengthperpendiculartothemaxarea', max_digits=255, decimal_places=0, blank=True, null=True)  # Field renamed because it started with '_'.
    # Field renamed because it started with '_'.
    field_feat_vanderwaalsvolume = models.DecimalField(
        db_column='_feat_vanderwaalsvolume', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_vanderwaalssurfacearea = models.DecimalField(
        db_column='_feat_vanderwaalssurfacearea', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_asa = models.DecimalField(
        db_column='_feat_asa', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed to remove unsuitable characters. Field renamed because it started with '_'. Field renamed because it ended with '_'.
    field_feat_asa_field = models.DecimalField(
        db_column='_feat_asa+', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed to remove unsuitable characters. Field renamed because it started with '_'. Field renamed because it ended with '_'. Field renamed because of name conflict.
    field_feat_asa_field_0 = models.DecimalField(
        db_column='_feat_asa-', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_asa_h = models.DecimalField(
        db_column='_feat_asa_h', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_asa_p = models.DecimalField(
        db_column='_feat_asa_p', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_polarsurfacearea = models.DecimalField(
        db_column='_feat_polarsurfacearea', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_acceptorcount = models.DecimalField(
        db_column='_feat_acceptorcount', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_accsitecount = models.DecimalField(
        db_column='_feat_accsitecount', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_donorcount = models.DecimalField(
        db_column='_feat_donorcount', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_donsitecount = models.DecimalField(
        db_column='_feat_donsitecount', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_nh2 = models.DecimalField(
        db_column='_feat_fr_nh2', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_nh1 = models.DecimalField(
        db_column='_feat_fr_nh1', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_nh0 = models.DecimalField(
        db_column='_feat_fr_nh0', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_quatn = models.DecimalField(
        db_column='_feat_fr_quatn', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_arn = models.DecimalField(
        db_column='_feat_fr_arn', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_ar_nh = models.DecimalField(
        db_column='_feat_fr_ar_nh', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_imine = models.DecimalField(
        db_column='_feat_fr_imine', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_amidine = models.DecimalField(
        db_column='_feat_fr_amidine', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_dihydropyridine = models.DecimalField(
        db_column='_feat_fr_dihydropyridine', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_guanido = models.DecimalField(
        db_column='_feat_fr_guanido', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_piperdine = models.DecimalField(
        db_column='_feat_fr_piperdine', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_piperzine = models.DecimalField(
        db_column='_feat_fr_piperzine', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_pyridine = models.DecimalField(
        db_column='_feat_fr_pyridine', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_maximalprojectionsize = models.DecimalField(
        db_column='_feat_maximalprojectionsize', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_minimalprojectionsize = models.DecimalField(
        db_column='_feat_minimalprojectionsize', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_molsurfaceareavdwp = models.DecimalField(
        db_column='_feat_molsurfaceareavdwp', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_msareavdwp = models.DecimalField(
        db_column='_feat_msareavdwp', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_molsurfaceareaasap = models.DecimalField(
        db_column='_feat_molsurfaceareaasap', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_msareaasap = models.DecimalField(
        db_column='_feat_msareaasap', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_protpolarsurfacearea = models.DecimalField(
        db_column='_feat_protpolarsurfacearea', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_protpsa = models.DecimalField(
        db_column='_feat_protpsa', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_hacceptorcount = models.DecimalField(
        db_column='_feat_hacceptorcount', max_digits=255, decimal_places=0, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_hdonorcount = models.DecimalField(
        db_column='_feat_hdonorcount', max_digits=255, decimal_places=0, blank=True, null=True)

    class Meta:
        managed = managed_value
        db_table = 'load_perov_desc'


class LoadPerovDescDef(models.Model):
    short_name = models.CharField(max_length=255, blank=True, null=True)
    calc_definition = models.CharField(max_length=255, blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    systemtool_name = models.CharField(max_length=255, blank=True, null=True)
    systemtool_ver = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = managed_value
        db_table = 'load_perov_desc_def'

    def __str__(self):
        return self.description


class MDescriptor(models.Model):
    m_descriptor_id = models.BigAutoField(primary_key=True)
    m_descriptor_uuid = models.UUIDField(blank=True, null=True)
    material_name_description = models.ForeignKey(
        'MaterialName', models.DO_NOTHING, db_column='material_name_description', blank=True, null=True)
    material_name_type = models.CharField(
        max_length=255, blank=True, null=True)
    m_descriptor_def_id = models.BigIntegerField(blank=True, null=True)
    create_date = models.DateTimeField(blank=True, null=True)
    # This field type is a guess.
    num_value = models.TextField(blank=True, null=True)
    blob_value = models.BinaryField(blank=True, null=True)
    status = models.ForeignKey(
        'Status', models.DO_NOTHING, blank=True, null=True)
    note = models.ForeignKey('Note', models.DO_NOTHING, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'm_descriptor'
        unique_together = (
            ('material_name_description', 'm_descriptor_def_id'),)


class MDescriptorClass(models.Model):
    m_descriptor_class_id = models.BigAutoField(primary_key=True)
    m_descriptor_class_uuid = models.UUIDField(blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    note = models.ForeignKey('Note', models.DO_NOTHING, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'm_descriptor_class'

    def __str__(self):
        return self.description


class MDescriptorDef(models.Model):
    m_descriptor_def_id = models.BigAutoField(primary_key=True)
    m_descriptor_def_uuid = models.UUIDField(blank=True, null=True)
    short_name = models.CharField(max_length=255, blank=True, null=True)
    calc_definition = models.CharField(max_length=255, blank=True, null=True)
    description = models.CharField(max_length=1023, blank=True, null=True)
    m_descriptor_class = models.ForeignKey(
        MDescriptorClass, models.DO_NOTHING, blank=True, null=True)
    actor = models.ForeignKey(Actor, models.DO_NOTHING, blank=True, null=True)
    note = models.ForeignKey('Note', models.DO_NOTHING, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'm_descriptor_def'
        unique_together = (('actor', 'calc_definition'),)

    def __str__(self):
        return self.description


class MDescriptorValue(models.Model):
    m_descriptor_value_id = models.BigAutoField(primary_key=True)
    m_descriptor_value_uuid = models.UUIDField(blank=True, null=True)
    num_value = models.FloatField(blank=True, null=True)
    blob_value = models.BinaryField(blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'm_descriptor_value'


class Material(models.Model):
    material_id = models.BigAutoField(primary_key=True)
    material_uuid = models.UUIDField(blank=True, null=True)
    description = models.CharField(max_length=255)
    parent_material = models.ForeignKey(
        'self', models.DO_NOTHING, blank=True, null=True)
    status = models.ForeignKey(
        'Status', models.DO_NOTHING, blank=True, null=True)
    note = models.ForeignKey('Note', models.DO_NOTHING, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'material'

    def __str__(self):
        return self.description


class MaterialName(models.Model):
    material_name_id = models.BigAutoField(primary_key=True)
    material_name_uuid = models.UUIDField(blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    material = models.ForeignKey(
        Material, models.DO_NOTHING, blank=True, null=True)
    material_name_type = models.CharField(
        max_length=255, blank=True, null=True)
    reference = models.CharField(max_length=255, blank=True, null=True)
    status = models.ForeignKey(
        'Status', models.DO_NOTHING, blank=True, null=True)
    note = models.ForeignKey('Note', models.DO_NOTHING, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'material_name'
        unique_together = (('description', 'material_name_type'),)

    def __str__(self):
        return self.description


class MaterialNameX(models.Model):
    material_name_x_id = models.BigAutoField(primary_key=True)
    material_name_x_uuid = models.UUIDField(blank=True, null=True)
    material = models.ForeignKey(
        Material, models.DO_NOTHING, blank=True, null=True)
    material_name = models.ForeignKey(
        MaterialName, models.DO_NOTHING, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'material_name_x'
        unique_together = (('material', 'material_name'),)

    def __str__(self):
        return self.material_name


class MaterialType(models.Model):
    material_type_id = models.BigAutoField(primary_key=True)
    material_type_uuid = models.UUIDField(blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    note = models.ForeignKey('Note', models.DO_NOTHING, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'material_type'

    def __str__(self):
        return self.description


class MaterialTypeX(models.Model):
    material_type_x_id = models.BigAutoField(primary_key=True)
    material_type_x_uuid = models.UUIDField(blank=True, null=True)
    material = models.ForeignKey(
        Material, models.DO_NOTHING, blank=True, null=True)
    material_type = models.ForeignKey(
        MaterialType, models.DO_NOTHING, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'material_type_x'
        unique_together = (('material', 'material_type'),)

    def __str__(self):
        return self.material_type


class Measure(models.Model):
    measure_id = models.BigAutoField(primary_key=True)
    measure_uuid = models.UUIDField(blank=True, null=True)
    measure_type_id = models.BigIntegerField(blank=True, null=True)
    amount = models.FloatField(blank=True, null=True)
    unit = models.CharField(max_length=255, blank=True, null=True)
    blob_amount = models.BinaryField(blank=True, null=True)
    document_id = models.BigIntegerField(blank=True, null=True)
    note_id = models.BigIntegerField(blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'measure'

    def __str__(self):
        return "{} {}".format(amount, unit)


class MeasureType(models.Model):
    measure_type_id = models.BigAutoField(primary_key=True)
    measure_type_uuid = models.UUIDField(blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    note = models.ForeignKey('Note', models.DO_NOTHING, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'measure_type'

    def __str__(self):
        return self.description


class Note(models.Model):
    note_id = models.BigAutoField(primary_key=True)
    note_uuid = models.UUIDField(blank=True, null=True)
    notetext = models.CharField(max_length=255, blank=True, null=True)
    edocument = models.ForeignKey(
        Edocument, models.DO_NOTHING, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'note'

    def __str__(self):
        return self.notetext


class Organization(models.Model):
    organization_id = models.BigAutoField(primary_key=True)
    organization_uuid = models.UUIDField(blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
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
    note = models.ForeignKey(Note, models.DO_NOTHING, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'organization'

    def __str__(self):
        return self.full_name


class Person(models.Model):
    person_id = models.BigAutoField(primary_key=True)
    person_uuid = models.UUIDField(blank=True, null=True)
    firstname = models.CharField(max_length=255, blank=True, null=True)
    lastname = models.CharField(max_length=255)
    middlename = models.CharField(max_length=255, blank=True, null=True)
    address1 = models.CharField(max_length=255, blank=True, null=True)
    address2 = models.CharField(max_length=255, blank=True, null=True)
    city = models.CharField(max_length=255, blank=True, null=True)
    stateprovince = models.CharField(max_length=3, blank=True, null=True)
    phone = models.CharField(max_length=255, blank=True, null=True)
    email = models.CharField(max_length=255, blank=True, null=True)
    title = models.CharField(max_length=255, blank=True, null=True)
    suffix = models.CharField(max_length=255, blank=True, null=True)
    organization = models.ForeignKey(
        Organization, models.DO_NOTHING, blank=True, null=True)
    note = models.ForeignKey(Note, models.DO_NOTHING, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'person'

    def __str__(self):
        return "{} {}".format(self.firstname, self.lastname)


class Status(models.Model):
    status_id = models.BigAutoField(primary_key=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'status'

    def __str__(self):
        return self.description


class Systemtool(models.Model):
    systemtool_id = models.BigAutoField(primary_key=True)
    systemtool_uuid = models.UUIDField(blank=True, null=True)
    systemtool_name = models.CharField(max_length=255)
    description = models.CharField(max_length=255, blank=True, null=True)
    systemtool_type = models.ForeignKey(
        'SystemtoolType', models.DO_NOTHING, blank=True, null=True)
    vendor = models.CharField(max_length=255, blank=True, null=True)
    model = models.CharField(max_length=255, blank=True, null=True)
    serial = models.CharField(max_length=255, blank=True, null=True)
    ver = models.CharField(max_length=255, blank=True, null=True)
    organization = models.ForeignKey(
        Organization, models.DO_NOTHING, blank=True, null=True)
    note = models.ForeignKey(Note, models.DO_NOTHING, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'systemtool'

    def __str__(self):
        return "{} {}".format(self.systemtool_name, self.model)


class SystemtoolType(models.Model):
    systemtool_type_id = models.BigAutoField(primary_key=True)
    systemtool_type_uuid = models.UUIDField(blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    note = models.ForeignKey(Note, models.DO_NOTHING, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'systemtool_type'

    def __str__(self):
        return self.description


class Tag(models.Model):
    tag_id = models.BigAutoField(primary_key=True)
    tag_uuid = models.UUIDField(blank=True, null=True)
    tag_type = models.ForeignKey(
        'TagType', models.DO_NOTHING, blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    note = models.ForeignKey(Note, models.DO_NOTHING, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'tag'

    def __str__(self):
        return self.description


class TagType(models.Model):
    tag_type_id = models.BigAutoField(primary_key=True)
    tag_type_uuid = models.UUIDField(blank=True, null=True)
    short_desscription = models.CharField(max_length=32, blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'tag_type'

    def __str__(self):
        return self.description


class TriggerTest(models.Model):
    tt_id = models.AutoField(primary_key=True)
    smiles = models.TextField(blank=True, null=True)
    val = models.TextField(blank=True, null=True)

    class Meta:
        managed = managed_value
        db_table = 'trigger_test'
