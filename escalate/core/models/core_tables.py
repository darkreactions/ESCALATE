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
import uuid

#managed_value = False
managed_tables = True
managed_views = False


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

    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
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
        managed = managed_tables
        db_table = 'type_def'

    def __str__(self):
        return self.description
