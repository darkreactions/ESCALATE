from django.db import models
from django.db import models
from core.models.core_tables import RetUUIDField, SlugField

import uuid
from core.models.base_classes import (
    DateColumns,
    StatusColumn,
    ActorColumn,
    DescriptionColumn,
)
from core.models.custom_types import ValField


class DescriptorTemplate(DescriptionColumn, DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4)
    command = models.TextField(blank=True, null=True)
    human_description = models.TextField(blank=True, null=True)
    material_type = models.ForeignKey(
        "MaterialType",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="descriptor_template_mt",
    )
    systemtool = models.ForeignKey(
        "Systemtool",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="descriptor_template_st",
    )


class MolecularDescriptor(DescriptionColumn, DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4)
    material = models.ForeignKey(
        "Material",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="molecular_descriptor_m",
    )
    template = models.ForeignKey(
        "DescriptorTemplate",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="molecular_descriptor_dt",
    )
    value = ValField(null=True, blank=True)


class ExperimentDescriptor(DescriptionColumn, DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4)