from django.db import models

# from django.contrib.contenttypes.fields import GenericForeignKey
# from django.contrib.contenttypes.models import ContentType
from django.db.models.fields import BooleanField
from core.models.core_tables import RetUUIDField, SlugField
from core.models.custom_types import (
    ValField,
    PROPERTY_CLASS_CHOICES,
    PROPERTY_DEF_CLASS_CHOICES,
    MATERIAL_CLASS_CHOICES,
)
from django.contrib.postgres.fields import ArrayField
import uuid
from core.models.base_classes import (
    DateColumns,
    StatusColumn,
    ActorColumn,
    DescriptionColumn,
    UniqueDescriptionColumn,
)
from core.managers import OutcomeValueManager


managed_tables = True
managed_views = False


class Edocument(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column="edocument_uuid", editable=False
    )
    title = models.CharField(max_length=255, blank=True, null=True, db_column="title")
    filename = models.CharField(
        max_length=255, blank=True, null=True, db_column="filename"
    )
    source = models.CharField(max_length=255, blank=True, null=True, db_column="source")
    edoc_type = models.CharField(
        max_length=255, blank=True, null=True, db_column="doc_type_description"
    )
    edocument = models.BinaryField(blank=True, null=True, editable=False)
    edoc_ver = models.CharField(
        max_length=255, blank=True, null=True, db_column="doc_ver"
    )
    edoc_type_uuid = models.ForeignKey(
        "TypeDef",
        db_column="doc_type_uuid",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        editable=False,
    )
    # edocument_x_uuid = RetUUIDField(editable=False)
    ref_edocument_uuid = RetUUIDField()
    internal_slug = SlugField(
        populate_from=["filename", "edoc_ver"], overwrite=True, max_length=255
    )

    def __str__(self):
        return "{}".format(self.title)


class Note(DateColumns, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column="note_uuid")
    notetext = models.TextField(blank=True, null=True, verbose_name="Note Text")
    ref_note_uuid = RetUUIDField(blank=True, null=True)
    internal_slug = SlugField(
        populate_from=["notetext"], overwrite=True, max_length=255
    )

    def __str__(self):
        return "{}".format(self.notetext)


class Parameter(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column="parameter_uuid"
    )
    parameter_def = models.ForeignKey(
        "ParameterDef",
        db_column="parameter_def_uuid",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="parameter_parameter_def",
    )
    parameter_val_nominal = ValField(blank=True, null=True, db_column="parameter_val")
    parameter_val_actual = ValField(
        blank=True, null=True, db_column="parameter_val_actual"
    )
    # ref_object = RetUUIDField(blank=True, null=True)
    action_unit = models.ForeignKey(
        "ActionUnit",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="parameter_au",
    )
    """
    # Parameter should be related to only 1 action unlike parameter_def to action_def
    # Therefore, we don't need a cross table like parameter_x but a direct foreign key
    # This should hold true even if parameter is related to other entities besides
    # action. 
    action = models.ForeignKey('Action',
                                on_delete=models.DO_NOTHING,
                                blank=True,
                                null=True,
                                related_name='parameter_action')
    """


class ParameterDef(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column="parameter_def_uuid"
    )
    # TODO: Created relation with DefaultValues table
    default_val = ValField(db_column="default_val", blank=True, null=True)
    required = BooleanField(blank=True, null=True)
    unit_type = models.CharField(
        max_length=255, blank=True, null=True, db_column="parameter_def_unit_type"
    )
    internal_slug = SlugField(
        populate_from=["description"], overwrite=True, max_length=255
    )

    def __str__(self):
        return "{}".format(self.description)

class ReactionParameter(StatusColumn, DescriptionColumn, DateColumns):
    uuid = RetUUIDField(
        primary_key=True,
        default=uuid.uuid4,
        db_column="reaction_parameter_profile_uuid",
    )
    experiment_template = models.ForeignKey(
        "ExperimentTemplate",
        models.CASCADE,
        blank=True,
        null=True,
        related_name="reaction_parameter_profile_workflow",
    )
    organization = models.ForeignKey(
        "Organization",
        models.CASCADE,
        blank=True,
        null=True,
        related_name="reaction_parameter_profile_organization",
    )
    value = models.CharField(
        max_length=255,
        blank=True,
        null=True,
        db_column="reaction_parameter_profile_parameter_value",
    )
    unit = models.CharField(
        max_length=255,
        blank=True,
        null=True,
        db_column="reaction_parameter_profile_parameter_unit",
    )
    type = models.CharField(
        max_length=255,
        blank=True,
        null=True,
        db_column="reaction_parameter_profile_parameter_type",
    )
    experiment_uuid = models.CharField(
        max_length=255,
        blank=True,
        null=True,
        db_column="reaction_parameter_profile_experiment_uuid",
    )


class Property(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column="property_uuid")

    # property_template = models.ForeignKey(
    template = models.ForeignKey(
        "PropertyTemplate",
        db_column="property_def_uuid",
        on_delete=models.DO_NOTHING,
        blank=True,
        # null=True,
        related_name="property_pt",
    )
    nominal_value = ValField(blank=True, null=True)
    value = ValField(blank=True, null=True)
    material = models.ForeignKey(
        "Material",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="property_m",
    )
    reagent = models.ForeignKey(
        "Reagent",
        blank=True,
        null=True,
        on_delete=models.DO_NOTHING,
        editable=False,
        related_name="property_r",
    )
    reagent_material = models.ForeignKey(
        "ReagentMaterial",
        blank=True,
        null=True,
        on_delete=models.DO_NOTHING,
        # editable=False,
        related_name="property_rm",
    )

    internal_slug = SlugField(
        populate_from=["template__description"], overwrite=True, max_length=255
    )

    def __str__(self):
        return "{} : {}".format(self.template.description, self.value)  # type: ignore


class PropertyTemplate(DateColumns, StatusColumn, ActorColumn, UniqueDescriptionColumn):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column="property_def_uuid"
    )
    property_def_class = models.CharField(
        max_length=64, choices=PROPERTY_DEF_CLASS_CHOICES
    )
    short_description = models.CharField(
        max_length=255, blank=True, null=True, db_column="short_description"
    )
    default_value = models.ForeignKey(
        "DefaultValues",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="property_template_dv",
    )

    def __str__(self):
        return "{}".format(self.description)


class Status(DateColumns, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column="status_uuid")

    def __str__(self):
        return "{}".format(self.description)


class Tag(DateColumns, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column="tag_uuid", editable=False
    )
    display_text = models.CharField(max_length=255, null=True)

    tag_type = models.ForeignKey(
        "TagType",
        models.DO_NOTHING,
        db_column="tag_type_uuid",
        blank=True,
        null=True,
        related_name="tag_tag_type",
    )

    def __str__(self):
        return "{}".format(self.display_text)


class TagAssign(DateColumns):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column="tag_x_uuid")
    ref_tag = RetUUIDField(db_column="ref_tag_uuid")
    tag = models.ForeignKey(
        "Tag",
        models.DO_NOTHING,
        blank=True,
        null=True,
        db_column="tag_uuid",
        related_name="tag_assign_tag",
    )

    def __str__(self):
        return "{}".format(self.uuid)


class TagType(DateColumns, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column="tag_type_uuid")
    type = models.CharField(max_length=255, null=True)

    def __str__(self):
        return "{}".format(self.type)


class DefaultValues(DateColumns, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(
        primary_key=True,
        default=uuid.uuid4,
    )
    nominal_value = ValField(blank=True, null=True)
    actual_value = ValField(blank=True, null=True)

    def __str__(self):
        return f"{self.description}"


class ValueInstance(DateColumns, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(
        primary_key=True,
        default=uuid.uuid4,
    )
    value_template = models.ForeignKey(
        "DefaultValues",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="value_instance_value_template",
    )
    nominal_value = ValField(blank=True, null=True)
    actual_value = ValField(blank=True, null=True)
    # Foreignkey to specific tables that need values.
    # Avoiding GenericForeignKey due to performance and complexity
    outcome_instance = models.ForeignKey(
        "Outcome",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="value_instance_outcome",
    )
    # reagent_instance = models.ForeignKey('ReagentInstance', on_delete=models.DO_NOTHING,
    #                      related_name='reagent_instance_value_reagent_instance')

    def save(self, *args, **kwargs):
        if self.value_template is not None:
            self.nominal_value = self.value_template.default_nominal_value
            self.actual_value = self.value_template.default_actual_value
        super().save(*args, **kwargs)


class OutcomeValue(ValueInstance):
    objects = OutcomeValueManager()

    class Meta:
        proxy = True
