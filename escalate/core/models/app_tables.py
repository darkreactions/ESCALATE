import uuid
from django.db import models
from core.models.core_tables import RetUUIDField
from django.contrib.auth.models import AbstractUser
from django.contrib.postgres.fields import ArrayField
from core.models.view_tables import Organization

from ..managers import CustomUserManager


class CustomUser(AbstractUser):

    REQUIRED_FIELDS = []
    objects = CustomUserManager()
    person = models.ForeignKey("Person", on_delete=models.DO_NOTHING, null=True)

    def __str__(self):
        return self.username


class OrganizationPassword(models.Model):
    uuid = models.AutoField(primary_key=True)
    organization = models.OneToOneField(
        Organization,
        on_delete=models.CASCADE,
        db_column="parent_uuid",
        related_name="organization_password_organization",
    )
    password = models.CharField(max_length=255)

    def __str__(self):
        return "{}".format(self.organization.full_name)


class UnitType(models.Model):
    uuid = models.UUIDField(primary_key=True, default=uuid.uuid4)
    description = models.CharField(
        max_length=255, blank=True, null=True, db_column="description"
    )
    standard_unit = models.CharField(
        max_length=255, blank=True, null=True, db_column="standard_unit"
    )
    allowed_units = ArrayField(models.CharField(max_length=255))
    #
    # class Meta:
    #     managed = True
    #     db_table = 'unit_type'


class ActionSequenceDesign(models.Model):
    # used to save workflow designer's json output into the database
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column="uuid")
    id = models.CharField(
        max_length=255, blank=True, null=True, db_column="elsa_id"
    )  # elsa-generated ID
    description = models.CharField(
        max_length=255, blank=True, null=True, db_column="description"
    )  # type
    properties = models.CharField(
        max_length=255, blank=True, null=True, db_column="properties"
    )  # state
    top_position = models.CharField(
        max_length=255, blank=True, null=True, db_column="top"
    )
    left_position = models.CharField(
        max_length=255, blank=True, null=True, db_column="left"
    )
    action_sequence = models.ForeignKey(
        "ActionSequence",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="action_sequence",
    )

    order = models.IntegerField(db_column="sequence_order")
