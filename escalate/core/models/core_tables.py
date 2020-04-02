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

managed_value = True


class Actor(models.Model):
    actor_uuid = models.UUIDField(primary_key=True)
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
        db_table = 'actor'
        #unique_together = (('person', 'organization', 'systemtool'),)

    def __str__(self):
        return self.description


class ActorPref(models.Model):
    actor_pref_uuid = models.UUIDField(primary_key=True)
    actor_uuid = models.ForeignKey(
        Actor, models.DO_NOTHING, db_column='actor_uuid', blank=True, null=True)
    pkey = models.CharField(max_length=255, blank=True, null=True)
    pvalue = models.CharField(max_length=255, blank=True, null=True)
    note_uuid = models.ForeignKey(
        'Note', models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'actor_pref'


class Edocument(models.Model):
    edocument_uuid = models.UUIDField(primary_key=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    edocument = models.BinaryField(blank=True, null=True)
    edoc_type = models.CharField(max_length=255, blank=True, null=True)
    ver = models.CharField(max_length=255, blank=True, null=True)
    actor_uuid = models.ForeignKey(
        Actor, models.DO_NOTHING, db_column='actor_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'edocument'

    def __str__(self):
        return self.description


class EdocumentX(models.Model):
    edocument_x_uuid = models.UUIDField(primary_key=True)
    ref_edocument_uuid = models.UUIDField(blank=True, null=True)
    edocument_uuid = models.ForeignKey(
        Edocument, models.DO_NOTHING, db_column='edocument_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'edocument_x'
        unique_together = (('ref_edocument_uuid', 'edocument_uuid'),)


class Files(models.Model):
    filename = models.TextField(blank=True, null=True)

    class Meta:
        managed = managed_value
        db_table = 'files'

    def __str__(self):
        return self.filename


class Inventory(models.Model):
    #inventory_id = models.BigAutoField(primary_key=True)
    inventory_uuid = models.UUIDField(primary_key=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    material_uuid = models.ForeignKey(
        'Material', models.DO_NOTHING, db_column='material_uuid')
    actor_uuid = models.ForeignKey(
        Actor, models.DO_NOTHING, db_column='actor_uuid', blank=True, null=True)
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
        Edocument, models.DO_NOTHING, db_column='edocument_uuid', blank=True, null=True)
    note_uuid = models.ForeignKey(
        'Note', models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'inventory'
        unique_together = (('material_uuid', 'actor_uuid', 'create_date'),)

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
    updated_by = models.CharField(max_length=255, blank=True, null=True)
    in_stock = models.FloatField(blank=True, null=True)
    remaining_stock = models.FloatField(blank=True, null=True)

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
    field_raw_molweight = models.FloatField(
        db_column='_raw_molweight', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_raw_smiles_standard = models.CharField(
        db_column='_raw_smiles_standard', max_length=255, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_raw_standard_molweight = models.FloatField(
        db_column='_raw_standard_molweight', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_prototype_ecpf4_256_6 = models.CharField(
        db_column='_prototype_ecpf4_256_6', max_length=-1, blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_atomcount_c = models.SmallIntegerField(
        db_column='_feat_atomcount_c', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_atomcount_n = models.SmallIntegerField(
        db_column='_feat_atomcount_n', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_avgpol = models.FloatField(
        db_column='_feat_avgpol', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_molpol = models.FloatField(
        db_column='_feat_molpol', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_refractivity = models.FloatField(
        db_column='_feat_refractivity', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_aliphaticringcount = models.SmallIntegerField(
        db_column='_feat_aliphaticringcount', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_aromaticringcount = models.SmallIntegerField(
        db_column='_feat_aromaticringcount', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_aliphaticatomcount = models.SmallIntegerField(
        db_column='_feat_aliphaticatomcount', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_aromaticatomcount = models.SmallIntegerField(
        db_column='_feat_aromaticatomcount', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_bondcount = models.SmallIntegerField(
        db_column='_feat_bondcount', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_carboaliphaticringcount = models.SmallIntegerField(
        db_column='_feat_carboaliphaticringcount', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_carboaromaticringcount = models.SmallIntegerField(
        db_column='_feat_carboaromaticringcount', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_carboringcount = models.SmallIntegerField(
        db_column='_feat_carboringcount', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_chainatomcount = models.SmallIntegerField(
        db_column='_feat_chainatomcount', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_chiralcentercount = models.SmallIntegerField(
        db_column='_feat_chiralcentercount', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_ringatomcount = models.SmallIntegerField(
        db_column='_feat_ringatomcount', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_smallestringsize = models.SmallIntegerField(
        db_column='_feat_smallestringsize', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_largestringsize = models.SmallIntegerField(
        db_column='_feat_largestringsize', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_heteroaliphaticringcount = models.SmallIntegerField(
        db_column='_feat_heteroaliphaticringcount', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_heteroaromaticringcount = models.SmallIntegerField(
        db_column='_feat_heteroaromaticringcount', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_rotatablebondcount = models.SmallIntegerField(
        db_column='_feat_rotatablebondcount', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_balabanindex = models.FloatField(
        db_column='_feat_balabanindex', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_cyclomaticnumber = models.SmallIntegerField(
        db_column='_feat_cyclomaticnumber', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_hyperwienerindex = models.SmallIntegerField(
        db_column='_feat_hyperwienerindex', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_wienerindex = models.SmallIntegerField(
        db_column='_feat_wienerindex', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_wienerpolarity = models.SmallIntegerField(
        db_column='_feat_wienerpolarity', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_minimalprojectionarea = models.FloatField(
        db_column='_feat_minimalprojectionarea', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_maximalprojectionarea = models.FloatField(
        db_column='_feat_maximalprojectionarea', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_minimalprojectionradius = models.FloatField(
        db_column='_feat_minimalprojectionradius', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_maximalprojectionradius = models.FloatField(
        db_column='_feat_maximalprojectionradius', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_lengthperpendiculartotheminarea = models.FloatField(
        db_column='_feat_lengthperpendiculartotheminarea', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_lengthperpendiculartothemaxarea = models.FloatField(
        db_column='_feat_lengthperpendiculartothemaxarea', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_vanderwaalsvolume = models.FloatField(
        db_column='_feat_vanderwaalsvolume', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_vanderwaalssurfacearea = models.FloatField(
        db_column='_feat_vanderwaalssurfacearea', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_asa = models.FloatField(
        db_column='_feat_asa', blank=True, null=True)
    # Field renamed to remove unsuitable characters. Field renamed because it started with '_'. Field renamed because it ended with '_'.
    field_feat_asa_field = models.FloatField(
        db_column='_feat_asa+', blank=True, null=True)
    # Field renamed to remove unsuitable characters. Field renamed because it started with '_'. Field renamed because it ended with '_'. Field renamed because of name conflict.
    field_feat_asa_field_0 = models.FloatField(
        db_column='_feat_asa-', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_asa_h = models.FloatField(
        db_column='_feat_asa_h', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_asa_p = models.FloatField(
        db_column='_feat_asa_p', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_polarsurfacearea = models.FloatField(
        db_column='_feat_polarsurfacearea', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_acceptorcount = models.SmallIntegerField(
        db_column='_feat_acceptorcount', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_accsitecount = models.SmallIntegerField(
        db_column='_feat_accsitecount', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_donorcount = models.SmallIntegerField(
        db_column='_feat_donorcount', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_donsitecount = models.SmallIntegerField(
        db_column='_feat_donsitecount', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_nh2 = models.SmallIntegerField(
        db_column='_feat_fr_nh2', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_nh1 = models.SmallIntegerField(
        db_column='_feat_fr_nh1', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_nh0 = models.SmallIntegerField(
        db_column='_feat_fr_nh0', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_quatn = models.SmallIntegerField(
        db_column='_feat_fr_quatn', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_arn = models.SmallIntegerField(
        db_column='_feat_fr_arn', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_ar_nh = models.SmallIntegerField(
        db_column='_feat_fr_ar_nh', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_imine = models.SmallIntegerField(
        db_column='_feat_fr_imine', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_amidine = models.SmallIntegerField(
        db_column='_feat_fr_amidine', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_dihydropyridine = models.SmallIntegerField(
        db_column='_feat_fr_dihydropyridine', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_guanido = models.SmallIntegerField(
        db_column='_feat_fr_guanido', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_piperdine = models.SmallIntegerField(
        db_column='_feat_fr_piperdine', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_piperzine = models.SmallIntegerField(
        db_column='_feat_fr_piperzine', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_fr_pyridine = models.SmallIntegerField(
        db_column='_feat_fr_pyridine', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_maximalprojectionsize = models.FloatField(
        db_column='_feat_maximalprojectionsize', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_minimalprojectionsize = models.FloatField(
        db_column='_feat_minimalprojectionsize', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_molsurfaceareavdwp = models.FloatField(
        db_column='_feat_molsurfaceareavdwp', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_msareavdwp = models.FloatField(
        db_column='_feat_msareavdwp', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_molsurfaceareaasap = models.FloatField(
        db_column='_feat_molsurfaceareaasap', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_msareaasap = models.FloatField(
        db_column='_feat_msareaasap', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_protpolarsurfacearea = models.FloatField(
        db_column='_feat_protpolarsurfacearea', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_protpsa = models.FloatField(
        db_column='_feat_protpsa', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_hacceptorcount = models.SmallIntegerField(
        db_column='_feat_hacceptorcount', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_hdonorcount = models.SmallIntegerField(
        db_column='_feat_hdonorcount', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_feat_charge_cnt = models.SmallIntegerField(
        db_column='_feat_charge_cnt', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_calc_chrg_per_vol = models.FloatField(
        db_column='_calc_chrg_per_vol', blank=True, null=True)
    # Field renamed because it started with '_'.
    field_calc_chrg_per_asa = models.FloatField(
        db_column='_calc_chrg_per_asa', blank=True, null=True)

    class Meta:
        managed = managed_value
        db_table = 'load_perov_desc'


class LoadPerovDescDef(models.Model):
    short_name = models.CharField(max_length=255, blank=True, null=True)
    calc_definition = models.CharField(max_length=255, blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    systemtool_name = models.CharField(max_length=255, blank=True, null=True)
    systemtool_ver = models.CharField(max_length=255, blank=True, null=True)
    in_type = models.CharField(max_length=255, blank=True, null=True)
    out_type = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = managed_value
        db_table = 'load_perov_desc_def'

    def __str__(self):
        return self.description


class LoadPerovMolImage(models.Model):
    filename = models.CharField(max_length=-1, blank=True, null=True)
    fileno = models.IntegerField(blank=True, null=True)
    # Field renamed because it started with '_'.
    field_image = models.BinaryField(db_column='_image', blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'load_perov_mol_image'


class MDescriptor(models.Model):
    #m_descriptor_id = models.BigAutoField(primary_key=True)
    m_descriptor_uuid = models.UUIDField(primary_key=True)
    m_descriptor_def_uuid = models.UUIDField(blank=True, null=True)
    # This field type is a guess.
    in_val = models.TextField(blank=True, null=True)
    # This field type is a guess.
    in_opt_val = models.TextField(blank=True, null=True)
    # This field type is a guess.
    out_val = models.TextField(blank=True, null=True)
    create_date = models.DateTimeField(blank=True, null=True)
    status_uuid = models.ForeignKey(
        'Status', models.DO_NOTHING, db_column='status_uuid', blank=True, null=True)
    actor_uuid = models.ForeignKey(
        Actor, models.DO_NOTHING, db_column='actor_uuid', blank=True, null=True)
    note_uuid = models.ForeignKey(
        'Note', models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    """
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
    """
    class Meta:
        managed = managed_value
        db_table = 'm_descriptor'
        unique_together = (('m_descriptor_def_uuid', 'in_val', 'in_opt_val'),)


class MDescriptorClass(models.Model):
    #m_descriptor_class_id = models.BigAutoField(primary_key=True)
    m_descriptor_class_uuid = models.UUIDField(primary_key=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    note_uuid = models.ForeignKey(
        'Note', models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'm_descriptor_class'

    def __str__(self):
        return self.description


class MDescriptorDef(models.Model):
    #m_descriptor_def_id = models.BigAutoField(primary_key=True)
    m_descriptor_def_uuid = models.UUIDField(primary_key=True)
    short_name = models.CharField(max_length=255, blank=True, null=True)
    calc_definition = models.CharField(max_length=255, blank=True, null=True)
    systemtool = models.ForeignKey(
        'Systemtool', models.DO_NOTHING, blank=True, null=True)
    description = models.CharField(max_length=1023, blank=True, null=True)
    # This field type is a guess.
    in_type = models.TextField(blank=True, null=True)
    # This field type is a guess.
    out_type = models.TextField(blank=True, null=True)
    m_descriptor_class_uuid = models.ForeignKey(
        MDescriptorClass, models.DO_NOTHING, db_column='m_descriptor_class_uuid', blank=True, null=True)
    actor_uuid = models.ForeignKey(
        Actor, models.DO_NOTHING, db_column='actor_uuid', blank=True, null=True)
    note_uuid = models.ForeignKey(
        'Note', models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'm_descriptor_def'
        unique_together = (('actor_uuid', 'calc_definition'),)

    def __str__(self):
        return self.description


class MDescriptorEval(models.Model):
    eval_id = models.BigAutoField(primary_key=True)
    m_descriptor_def_uuid = models.UUIDField(blank=True, null=True)
    # This field type is a guess.
    in_val = models.TextField(blank=True, null=True)
    # This field type is a guess.
    in_opt_val = models.TextField(blank=True, null=True)
    # This field type is a guess.
    out_val = models.TextField(blank=True, null=True)
    m_descriptor_alias_name = models.CharField(
        max_length=255, blank=True, null=True)
    actor_uuid = models.UUIDField(blank=True, null=True)
    create_date = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'm_descriptor_eval'


class Material(models.Model):
    material_id = models.BigAutoField(primary_key=True)
    material_uuid = models.UUIDField(blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    parent_uuid = models.ForeignKey(
        'self', models.DO_NOTHING, db_column='parent_uuid', blank=True, null=True)
    # This field type is a guess.
    parent_path = models.TextField(blank=True, null=True)
    status_uuid = models.ForeignKey(
        'Status', models.DO_NOTHING, db_column='status_uuid', blank=True, null=True)
    note_uuid = models.ForeignKey(
        'Note', models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'material'

    def __str__(self):
        return self.description


class MaterialRefname(models.Model):
    material_refname_uuid = models.UUIDField(primary_key=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    blob_value = models.BinaryField(blank=True, null=True)
    blob_type = models.CharField(max_length=255, blank=True, null=True)
    material_refname_type_uuid = models.ForeignKey(
        'MaterialRefnameType', models.DO_NOTHING, db_column='material_refname_type_uuid', blank=True, null=True)
    reference = models.CharField(max_length=255, blank=True, null=True)
    status_uuid = models.ForeignKey(
        'Status', models.DO_NOTHING, db_column='status_uuid', blank=True, null=True)
    note_uuid = models.ForeignKey(
        'Note', models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'material_refname'
        unique_together = (('description', 'material_refname_type_uuid'),)

    def __str__(self):
        return self.description


class MaterialRefnameType(models.Model):
    material_refname_type_uuid = models.UUIDField(primary_key=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    note_uuid = models.ForeignKey(
        'Note', models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'material_refname_type'


class MaterialRefnameX(models.Model):
    material_refname_x_uuid = models.UUIDField(primary_key=True)
    material_uuid = models.ForeignKey(
        Material, models.DO_NOTHING, db_column='material_uuid', blank=True, null=True)
    material_refname_uuid = models.ForeignKey(
        MaterialRefname, models.DO_NOTHING, db_column='material_refname_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'material_refname_x'
        unique_together = (('material_uuid', 'material_refname_uuid'),)


class MaterialType(models.Model):
    material_type_uuid = models.UUIDField(primary_key=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    note_uuid = models.ForeignKey(
        'Note', models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'material_type'

    def __str__(self):
        return self.description


class MaterialTypeX(models.Model):
    #material_type_x_id = models.BigAutoField()
    material_type_x_uuid = models.UUIDField(primary_key=True)
    ref_material_uuid = models.ForeignKey(
        Material, models.DO_NOTHING, db_column='ref_material_uuid', blank=True, null=True)
    material_type_uuid = models.ForeignKey(
        MaterialType, models.DO_NOTHING, db_column='material_type_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'material_type_x'
        unique_together = (('ref_material_uuid', 'material_type_uuid'),)

    def __str__(self):
        return self.material_type


class Measure(models.Model):
    measure_uuid = models.UUIDField(primary_key=True)
    measure_type_uuid = models.ForeignKey(
        'MeasureType', models.DO_NOTHING, db_column='measure_type_uuid', blank=True, null=True)
    amount = models.FloatField(blank=True, null=True)
    unit = models.CharField(max_length=255, blank=True, null=True)
    blob_amount = models.BinaryField(blank=True, null=True)
    blob_type = models.CharField(max_length=255, blank=True, null=True)
    actor_uuid = models.UUIDField(blank=True, null=True)
    edocument_uuid = models.ForeignKey(
        Edocument, models.DO_NOTHING, db_column='edocument_uuid', blank=True, null=True)
    note_uuid = models.ForeignKey(
        'Note', models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'measure'

    def __str__(self):
        return "{} {}".format(self.amount, self.unit)


class MeasureType(models.Model):
    measure_type_uuid = models.UUIDField(primary_key=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    note_uuid = models.ForeignKey(
        'Note', models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'measure_type'

    def __str__(self):
        return self.description


class MeasureX(models.Model):
    measure_x_uuid = models.UUIDField(primary_key=True)
    ref_measure_uuid = models.ForeignKey(
        Measure, models.DO_NOTHING, db_column='ref_measure_uuid', blank=True, null=True)
    measure_uuid = models.UUIDField(blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'measure_x'
        unique_together = (('ref_measure_uuid', 'measure_uuid'),)


class Note(models.Model):
    #note_id = models.BigAutoField(primary_key=True)
    note_uuid = models.UUIDField(primary_key=True)
    notetext = models.CharField(max_length=255, blank=True, null=True)
    edocument_uuid = models.ForeignKey(
        Edocument, models.DO_NOTHING, db_column='edocument_uuid', blank=True, null=True)
    actor_uuid = models.ForeignKey(
        Actor, models.DO_NOTHING, db_column='actor_uuid', blank=True, null=True)
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
    parent = models.ForeignKey(
        'self', models.DO_NOTHING, blank=True, null=True)
    # This field type is a guess.
    parent_path = models.TextField(blank=True, null=True)

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
    note_uuid = models.ForeignKey(
        Note, models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
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
    note_uuid = models.ForeignKey(
        Note, models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'person'

    def __str__(self):
        return "{} {}".format(self.firstname, self.lastname)


class Status(models.Model):
    status_uuid = models.UUIDField(primary_key=True)
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
    vendor_organization = models.ForeignKey(
        Organization, models.DO_NOTHING, blank=True, null=True)
    model = models.CharField(max_length=255, blank=True, null=True)
    serial = models.CharField(max_length=255, blank=True, null=True)
    ver = models.CharField(max_length=255, blank=True, null=True)
    note_uuid = models.ForeignKey(
        Note, models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'systemtool'
        unique_together = (
            ('systemtool_name', 'systemtool_type', 'vendor_organization', 'ver'),)

    def __str__(self):
        return "{} {}".format(self.systemtool_name, self.model)


class SystemtoolType(models.Model):
    systemtool_type_id = models.BigAutoField(primary_key=True)
    systemtool_type_uuid = models.UUIDField(blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    note_uuid = models.ForeignKey(
        Note, models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'systemtool_type'

    def __str__(self):
        return self.description


class Tag(models.Model):
    tag_uuid = models.UUIDField(primary_key=True)
    tag_type_uuid = models.ForeignKey(
        'TagType', models.DO_NOTHING, db_column='tag_type_uuid', blank=True, null=True)
    short_description = models.CharField(max_length=16, blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    actor_uuid = models.ForeignKey(
        Actor, models.DO_NOTHING, db_column='actor_uuid', blank=True, null=True)
    note_uuid = models.ForeignKey(
        Note, models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'tag'

    def __str__(self):
        return self.description


class TagType(models.Model):
    tag_type_uuid = models.UUIDField(primary_key=True)
    short_desscription = models.CharField(max_length=32, blank=True, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = managed_value
        db_table = 'tag_type'

    def __str__(self):
        return self.description


class TagX(models.Model):
    tag_x_uuid = models.UUIDField(primary_key=True)
    ref_tag_uuid = models.UUIDField(blank=True, null=True)
    tag_uuid = models.ForeignKey(
        Tag, models.DO_NOTHING, db_column='tag_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'tag_x'
        unique_together = (('ref_tag_uuid', 'tag_uuid'),)


class TriggerTest(models.Model):
    tt_id = models.AutoField(primary_key=True)
    smiles = models.TextField(blank=True, null=True)
    val = models.TextField(blank=True, null=True)

    class Meta:
        managed = managed_value
        db_table = 'trigger_test'


class VTypeOut(models.Model):

    class Meta:
        managed = False
        db_table = 'v_type_out'
