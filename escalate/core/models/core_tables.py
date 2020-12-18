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
"""
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


class PersonTable(models.Model):
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
                                          related_name='person_table_organization')

    class Meta:
        managed = False
        db_table = 'person'

    def __str__(self):
        return "{} {}".format(self.first_name, self.last_name)