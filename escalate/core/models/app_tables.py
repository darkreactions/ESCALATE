import uuid
from django.db import models
from django.contrib.auth.models import AbstractUser
from django.contrib.postgres.fields import ArrayField
from core.models.view_tables import Organization

from ..managers import CustomUserManager


class CustomUser(AbstractUser):

    REQUIRED_FIELDS = []
    objects = CustomUserManager()
    person = models.ForeignKey(
        'Person', on_delete=models.DO_NOTHING, null=True)

    def __str__(self):
        return self.username

class OrganizationPassword(models.Model):
    uuid = models.AutoField(primary_key=True)
    organization = models.OneToOneField(Organization, models.DO_NOTHING,
                                    db_column='parent_uuid',
                                    related_name='organization_password_organization')
    password = models.CharField(max_length=255, blank=True)

    def __str__(self):
        return "{}".format(self.organization.full_name)


class UnitType(models.Model):
    uuid = models.UUIDField(primary_key=True)
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description')
    standard_unit = models.CharField(max_length=255,
                                     blank=True,
                                     null=True,
                                     db_column='standard_unit')
    allowed_units = ArrayField(models.CharField(max_length=255))
    #
    # class Meta:
    #     managed = True
    #     db_table = 'unit_type'
