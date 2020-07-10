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
