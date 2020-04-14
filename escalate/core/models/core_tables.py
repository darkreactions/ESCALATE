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

"""
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
        managed = False
        db_table = 'actor'
        #unique_together = (('person', 'organization', 'systemtool'),)

    def __str__(self):
        return self.description


class Note(models.Model):
    #note_id = models.BigAutoField(primary_key=True)
    note_uuid = models.UUIDField(primary_key=True)
    notetext = models.CharField(max_length=255, blank=True, null=True)
    edocument_uuid = models.ForeignKey(
        'Edocument', models.DO_NOTHING, db_column='edocument_uuid', blank=True, null=True)
    actor_uuid = models.ForeignKey(
        Actor, models.DO_NOTHING, db_column='actor_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'note'

    def __str__(self):
        return self.notetext


class Status(models.Model):
    status_uuid = models.UUIDField(primary_key=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'status'

    def __str__(self):
        return self.description


class Person(models.Model):
    person_uuid = models.UUIDField(primary_key=True)
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
        'Organization', models.DO_NOTHING, blank=True, null=True)
    note_uuid = models.ForeignKey(
        Note, models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'person'

    def __str__(self):
        return "{} {}".format(self.firstname, self.lastname)
"""


class Edocument(models.Model):
    edocument_uuid = models.UUIDField(primary_key=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    edocument = models.BinaryField(blank=True, null=True)
    edoc_type = models.CharField(max_length=255, blank=True, null=True)
    ver = models.CharField(max_length=255, blank=True, null=True)
    actor_uuid = models.ForeignKey(
        'Actor', models.DO_NOTHING, db_column='actor_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'edocument'

    def __str__(self):
        return self.description


class Systemtool(models.Model):
    systemtool_uuid = models.UUIDField(primary_key=True)
    systemtool_name = models.CharField(max_length=255)
    description = models.CharField(max_length=255, blank=True, null=True)
    systemtool_type = models.ForeignKey(
        'SystemtoolType', models.DO_NOTHING, blank=True, null=True, db_column='systemtool_type_uuid')
    vendor_organization = models.ForeignKey(
        'Organization', models.DO_NOTHING, blank=True, null=True, db_column='vendor_organization_uuid')
    model = models.CharField(max_length=255, blank=True, null=True)
    serial = models.CharField(max_length=255, blank=True, null=True)
    ver = models.CharField(max_length=255, blank=True, null=True)
    note_uuid = models.ForeignKey(
        'Note', models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'systemtool'
        unique_together = (
            ('systemtool_name', 'systemtool_type', 'vendor_organization', 'ver'),)

    def __str__(self):
        return "{} {}".format(self.systemtool_name, self.model)


class SystemtoolType(models.Model):
    #systemtool_type_id = models.BigAutoField()
    systemtool_type_uuid = models.UUIDField(primary_key=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    note_uuid = models.ForeignKey(
        'Note', models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'systemtool_type'

    def __str__(self):
        return self.description


"""
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
        'Note', models.DO_NOTHING, db_column='note_uuid', blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'organization'

    def __str__(self):
        return self.full_name


class Material(models.Model):
    #material_id = models.BigAutoField(primary_key=True)
    material_uuid = models.UUIDField(primary_key=True)
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
        managed = False
        db_table = 'material'

    def __str__(self):
        return self.description


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
        managed = False
        db_table = 'inventory'
        unique_together = (('material_uuid', 'actor_uuid', 'create_date'),)

    def __str__(self):
        return self.description
"""
