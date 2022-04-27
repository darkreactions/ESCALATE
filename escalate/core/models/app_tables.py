import uuid
from django.db import models
from core.models.core_tables import RetUUIDField
from django.contrib.auth.models import AbstractUser
from django.contrib.postgres.fields import ArrayField, JSONField
from core.models.view_tables import Organization

from ..managers import CustomUserManager


class CustomUser(AbstractUser):

    REQUIRED_FIELDS = []
    objects = CustomUserManager()
    person = models.ForeignKey("Person", on_delete=models.DO_NOTHING, null=True)
    selected_lab = models.ForeignKey(
        "Organization",
        on_delete=models.DO_NOTHING,
        null=True,
        related_name="custom_user_o",
    )
    metadata = JSONField(null=True, blank=True)

    def __str__(self):
        return self.username


class OrganizationPassword(models.Model):
    uuid = models.AutoField(primary_key=True)
    organization = models.OneToOneField(
        Organization,
        on_delete=models.CASCADE,
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


class ActionTemplateDesign(models.Model):
    # used to save workflow designer's json output into the database
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column="uuid")
    id = models.CharField(
        max_length=255, blank=True, null=True, db_column="elsa_id"
    )  # elsa-generated ID
    description = models.CharField(
        max_length=255, blank=True, null=True, db_column="description"
    )  # type
    source = models.CharField(max_length=255, blank=True, null=True, db_column="source")
    destination = models.CharField(
        max_length=255, blank=True, null=True, db_column="destination"
    )
    top_position = models.CharField(
        max_length=255, blank=True, null=True, db_column="top"
    )
    left_position = models.CharField(
        max_length=255, blank=True, null=True, db_column="left"
    )
    action_template = models.ForeignKey(
        "ActionTemplate",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="action_template",
    )

    order = models.IntegerField(db_column="sequence_order")
