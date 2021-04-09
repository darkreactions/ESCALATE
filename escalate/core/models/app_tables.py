import uuid
from django.db import models
from django.contrib.auth.models import AbstractUser
from .core_tables import OrganizationTable

from ..managers import CustomUserManager


class CustomUser(AbstractUser):

    REQUIRED_FIELDS = []
    objects = CustomUserManager()
    person = models.ForeignKey(
        'PersonTable', on_delete=models.DO_NOTHING, null=True)

    def __str__(self):
        return self.username

class OrganizationPassword(models.Model):
    uuid = models.AutoField(primary_key=True)
    organization = models.OneToOneField(OrganizationTable, models.DO_NOTHING,
                                    db_column='parent_uuid',
                                    related_name='organization_password_organization')
    password = models.CharField(max_length=255, blank=True)

    def __str__(self):
        return "{}".format(self.organization.full_name)