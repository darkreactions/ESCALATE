from django.db import models
from django.contrib.postgres.fields import ArrayField

from core.models.core_tables import RetUUIDField, SlugField
import uuid
from core.models.base_classes import (
    DateColumns,
    StatusColumn,
    ActorColumn,
    DescriptionColumn,
    UniqueDescriptionColumn,
)
from core.models.view_tables.generic_data import Parameter

managed_tables = True
managed_views = False


class ActionUnit(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    """Create Action unit. NOTE: A signal in core.signals creates
    corresponding parameters when a new action unit is created
    """

    parameter_au: "models.QuerySet[Parameter]"
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column="action_material_uuid"
    )
    action = models.ForeignKey(
        "Action",
        on_delete=models.CASCADE,
        blank=True,
        null=True,
        related_name="action_unit_a",
    )
    source_material = models.ForeignKey(
        "BaseBomMaterial",
        on_delete=models.CASCADE,
        db_column="source_uuid",
        blank=True,
        null=True,
        related_name="action_unit_source_material",
    )
    destination_material = models.ForeignKey(
        "BaseBomMaterial",
        on_delete=models.CASCADE,
        db_column="destination_uuid",
        blank=True,
        null=True,
        related_name="action_unit_destination_material",
    )
    internal_slug = SlugField(
        populate_from=[
            "uuid",
            "action__description",
            "source_material__internal_slug",
            "destination_material__internal_slug",
        ],
        overwrite=True,
        max_length=255,
    )

    def __str__(self):
        return f"{self.description}"


class Action(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column="action_uuid")
    parent = models.ForeignKey(
        "Action",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="action_child",
    )
    experiment = models.ForeignKey(
        "ExperimentInstance",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="action_ei",
    )
    template = models.ForeignKey(
        "ActionTemplate",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="action_t",
    )

    start_date = models.DateField(db_column="start_date", blank=True, null=True)
    end_date = models.DateField(db_column="end_date", blank=True, null=True)
    duration = models.FloatField(db_column="duration", blank=True, null=True)
    repeating = models.IntegerField(db_column="repeating", blank=True, null=True)
    internal_slug = SlugField(
        populate_from=["description"],
        overwrite=True,
        max_length=255,
    )

    def __str__(self):
        return "{}".format(self.description)


class ActionDef(DateColumns, StatusColumn, ActorColumn, UniqueDescriptionColumn):

    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column="action_def_uuid"
    )
    parameter_def = models.ManyToManyField("ParameterDef", blank=True)
    synonym = models.CharField(
        max_length=255, db_column="synonym", blank=True, null=True
    )  # alternate name for same ActionDef, for compatibility with Autoprotocol and other systems
    internal_slug = SlugField(
        populate_from=["description"], overwrite=True, max_length=255
    )

    def __str__(self):
        return f"{self.description}"


class ActionTemplate(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):

    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4)
    experiment_template = models.ForeignKey(
        "ExperimentTemplate",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="action_template_et",
    )

    action_def = models.ForeignKey(
        ActionDef,
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="action_template_ad",
    )
    parent = models.ManyToManyField(
        "ActionTemplate", related_name="children", blank=True
    )
    source_vessel_template = models.ForeignKey(
        "VesselTemplate",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="action_template_svt",
    )
    source_vessel_decomposable = models.BooleanField(default=False)

    dest_vessel_template = models.ForeignKey(
        "VesselTemplate",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="action_template_dvt",
    )
    dest_vessel_decomposable = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.description}"


class VesselTemplate(DateColumns, StatusColumn, ActorColumn, UniqueDescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4)
    outcome_vessel = models.BooleanField(default=False)
    default_vessel = models.ForeignKey(
        "Vessel",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="vessel_template_v",
    )

    internal_slug = SlugField(
        populate_from=["description"], overwrite=True, max_length=255
    )

    def __str__(self):
        return f"{self.description}"
