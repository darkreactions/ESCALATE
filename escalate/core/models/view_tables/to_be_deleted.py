from django.db import models
from django.contrib.postgres.fields import ArrayField

from core.models.core_tables import RetUUIDField, SlugField
from core.models.custom_types import ValField, CustomArrayField
import uuid
from core.models.base_classes import (
    DateColumns,
    StatusColumn,
    ActorColumn,
    DescriptionColumn,
)


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


class Mixture(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column="material_composite_uuid"
    )
    composite = models.ForeignKey(
        "Material",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        db_column="composite_uuid",
        related_name="composite_material_composite",
    )
    # composite_description = models.CharField(
    #    max_length=255, blank=True, null=True, editable=False)
    # composite_class = models.CharField(max_length=64, choices=MATERIAL_CLASS_CHOICES)
    # composite_flg = models.BooleanField(blank=True, null=True)
    component = models.ForeignKey(
        "Material",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        db_column="component_uuid",
        related_name="composite_material_component",
    )
    # component_description = models.CharField(
    #    max_length=255, blank=True, null=True, editable=False)
    addressable = models.BooleanField(blank=True, null=True)
    # property = models.ManyToManyField('Property', through='CompositeMaterialProperty', related_name='composite_material_property',
    #    through_fields=('composite_material', 'property'))
    material_type = models.ManyToManyField(
        "MaterialType", blank=True, related_name="composite_material_material_type"
    )
    internal_slug = SlugField(
        populate_from=["composite__internal_slug", "component__internal_slug"],
        overwrite=True,
        max_length=255,
    )

    def __str__(self):
        return "{} - {}".format(
            self.composite.description if self.composite else "",
            self.component.description if self.component else "",
        )


class Contents(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column="contents_uuid")
    vessel_instance = models.ForeignKey(
        "VesselInstance",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="contents_vessel_instance",
    )
    base_bom_material = models.ForeignKey(
        "BaseBomMaterial",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        db_column="bom_material_uuid",
        related_name="contents_bom_material_uuid",
    )
    value = ValField(blank=True, null=True)

    def __str__(self):
        return f"{self.description}"


class Calculation(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column="calculation_uuid"
    )
    in_val = ValField(blank=True, null=True)
    in_val_edocument = models.ForeignKey(
        "Edocument",
        models.DO_NOTHING,
        db_column="in_val_edocument_uuid",
        blank=True,
        null=True,
        related_name="calculation_in_val_edocument",
        editable=False,
    )
    in_opt_val = ValField(blank=True, null=True)
    in_opt_val_edocument = models.ForeignKey(
        "Edocument",
        models.DO_NOTHING,
        blank=True,
        null=True,
        db_column="in_opt_val_edocument_uuid",
        related_name="calculation_in_opt_val_edocument",
        editable=False,
    )
    out_val = ValField(blank=True, null=True)
    out_val_edocument = models.ForeignKey(
        "Edocument",
        models.DO_NOTHING,
        blank=True,
        null=True,
        db_column="out_val_edocument_uuid",
        related_name="calculation_out_val_edocument",
        editable=False,
    )

    calculation_alias_name = models.CharField(max_length=255, blank=True, null=True)
    calculation_def = models.ForeignKey(
        "CalculationDef",
        models.DO_NOTHING,
        blank=True,
        null=True,
        db_column="calculation_def_uuid",
        related_name="calculation_calculation_def",
    )
    short_name = models.CharField(max_length=255, blank=True, null=True)
    calc_definition = models.CharField(max_length=255, blank=True, null=True)
    systemtool = models.ForeignKey(
        "Systemtool",
        models.DO_NOTHING,
        db_column="systemtool_uuid",
        related_name="calculation_systemtool",
    )


class CalculationDef(DateColumns, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column="calculation_def_uuid"
    )
    short_name = models.CharField(max_length=255, blank=True, null=True)
    calc_definition = models.CharField(max_length=255, blank=True, null=True)
    parameter_def = models.ManyToManyField(
        "ParameterDef",
        # through='CalculationParameterDefAssign',
        related_name="calculation_def_parameter_def",
    )
    in_source = models.ForeignKey(
        "CalculationDef",
        models.DO_NOTHING,
        db_column="in_source_uuid",
        related_name="calculation_def_in_source",
        blank=True,
        null=True,
    )
    in_type = models.ForeignKey(
        "TypeDef",
        models.DO_NOTHING,
        db_column="in_type_uuid",
        related_name="calculation_def_in_type",
        blank=True,
        null=True,
    )
    in_opt_source = models.ForeignKey(
        "CalculationDef",
        models.DO_NOTHING,
        db_column="in_opt_source_uuid",
        related_name="calculation_def_in_opt_source",
        blank=True,
        null=True,
    )
    in_opt_type = models.ForeignKey(
        "TypeDef",
        models.DO_NOTHING,
        db_column="in_opt_type_uuid",
        related_name="calculation_def_in_opt_type",
        blank=True,
        null=True,
    )
    out_type = models.ForeignKey(
        "TypeDef",
        models.DO_NOTHING,
        blank=True,
        null=True,
        db_column="out_type_uuid",
        related_name="calculation_def_out_type",
    )
    systemtool = models.ForeignKey(
        "Systemtool",
        models.DO_NOTHING,
        db_column="systemtool_uuid",
        related_name="calculation_def_systemtool",
        blank=True,
        null=True,
    )
    internal_slug = SlugField(
        populate_from=["description", "short_name", "calc_definition"],
        overwrite=True,
        max_length=255,
    )

    def __str__(self):
        return "{}".format(self.description)


class EdocumentX(DateColumns):
    uuid = RetUUIDField(primary_key=True, db_column="edocument_x_uuid", editable=False)
    ref_edocument_uuid = RetUUIDField()
    edocument = models.ForeignKey(
        "Edocument",
        on_delete=models.DO_NOTHING,
        db_column="edocument_uuid",
        blank=True,
        null=True,
        related_name="edocument_x_edocument",
    )


class NoteX(DateColumns):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column="note_x_uuid")
    ref_note = RetUUIDField(db_column="ref_note_uuid")
    note = models.ForeignKey(
        "Note",
        models.DO_NOTHING,
        blank=True,
        null=True,
        editable=False,
        db_column="note_uuid",
        related_name="note_x_note",
    )

    def __str__(self):
        return "{}".format(self.note_uuid)


class Udf(DescriptionColumn):
    """
    UDF = User Defined Field
    For example, say we wanted to start tracking ‘challenge problem #’ with an experiment.
    Instead of creating a new column in experiment, we could define a udf
    (udf_def) and it’s associated value (val) type, in this case say: text.
    Then we could allow the user (API) to create a specific instance of that
    udf_def, and associate it with a specific experiment,
    where the experiment_uuid is the ref_udf_uuid.
    """

    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column="udf_uuid")
    udf_def = models.ForeignKey(
        "UdfDef",
        models.DO_NOTHING,
        blank=True,
        null=True,
        db_column="udf_def_uuid",
        related_name="udf_udf_def",
    )
    udf_value = ValField(db_column="udf_val")
    udf_val_edocument = models.ForeignKey(
        "Edocument",
        models.DO_NOTHING,
        blank=True,
        null=True,
        db_column="udf_val_edocument_uuid",
        related_name="udf_udf_val_edocument",
    )
    ref_udf = RetUUIDField(db_column="ref_udf_uuid")
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    def __str__(self):
        return "{}".format(self.description)


class UdfX(models.Model):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column="udf_x_uuid")
    ref_uuid = RetUUIDField(db_column="ref_udf_uuid")
    udf_uuid = models.ForeignKey(
        "Udf",
        models.DO_NOTHING,
        blank=True,
        null=True,
        editable=False,
        db_column="udf_uuid",
        related_name="udf_x_udf_uuid",
    )


class UdfDef(DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column="udf_def_uuid")
    val_type = models.ForeignKey(
        "TypeDef",
        db_column="val_type_uuid",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="udf_def_val_type",
    )
    # val_type_description = models.CharField(
    #    max_length=255, blank=True, null=True)
    unit = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    def __str__(self):
        return "{}".format(self.description)
