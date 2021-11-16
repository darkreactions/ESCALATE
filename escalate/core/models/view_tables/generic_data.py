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
)
from core.managers import OutcomeInstanceValueManager


managed_tables = True
managed_views = False
# TODO: REMOVE THIS ENTIRE MODEL AND BREAK IT INTO SEPERATE MODELS WITH BASE CLASSES
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


class Measure(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column="measure_uuid")
    measure_type = models.ForeignKey(
        "MeasureType",
        on_delete=models.DO_NOTHING,
        db_column="measure_type_uuid",
        blank=True,
        null=True,
        related_name="measure_measure_type",
    )
    ref_measure = models.ForeignKey(
        "Measure",
        on_delete=models.DO_NOTHING,
        db_column="ref_measure_uuid",
        blank=True,
        null=True,
        related_name="measure_ref_measure",
    )
    measure_def = models.ForeignKey(
        "MeasureDef", db_column="measure_def_uuid", on_delete=models.DO_NOTHING
    )
    measure_value = ValField()
    internal_slug = SlugField(
        populate_from=["description"], overwrite=True, max_length=255
    )


class MeasureType(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column="measure_type_uuid"
    )

    def __str__(self):
        return f"{self.description}"


class MeasureX(DateColumns):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column="measure_x_uuid"
    )
    ref_measure = RetUUIDField(db_column="ref_measure_uuid")
    measure = models.ForeignKey(
        "Measure",
        models.DO_NOTHING,
        blank=True,
        null=True,
        editable=False,
        db_column="measure_uuid",
        related_name="measure_x_measure",
    )

    def __str__(self):
        return "{}".format(self.measure_uuid)


class MeasureDef(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column="measure_def_uuid"
    )
    default_measure_type = models.ForeignKey(
        "MeasureType",
        models.DO_NOTHING,
        blank=True,
        null=True,
        db_column="default_measure_type_uuid",
        related_name="measure_def_default_measure_type",
    )
    default_measure_value = ValField()
    property_def = models.ForeignKey(
        "PropertyTemplate",
        models.DO_NOTHING,
        blank=True,
        null=True,
        db_column="property_def_uuid",
        related_name="measure_def_default_measure_type",
    )

    def __str__(self):
        return f"{self.description}"


class Note(DateColumns, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column="note_uuid")
    notetext = models.TextField(blank=True, null=True, verbose_name="Note Text")
    ref_note_uuid = RetUUIDField(blank=True, null=True)
    internal_slug = SlugField(
        populate_from=["notetext"], overwrite=True, max_length=255
    )

    def __str__(self):
        return "{}".format(self.notetext)


# TODO: Test this removal
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
        related_name="parameter_action_unit",
    )
    """
    # Parameter should be related to only 1 action unlike parameter_def to action_def
    # Therefore, we don't need a cross table like parameter_x but a direct foreign key
    # This should hold true even if parameter is related to other entities besides
    # action. Currently, also associated with calculation 
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


class Property(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column="property_uuid")

    property_template = models.ForeignKey(
        "PropertyTemplate",
        db_column="property_def_uuid",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="property_pt",
    )
    nominal_value = ValField(blank=True, null=True)
    value = ValField(blank=True, null=True)
    # property_class = models.CharField(max_length=64, choices=PROPERTY_CLASS_CHOICES)
    # property_ref = RetUUIDField(blank=True, null=True)
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
        related_name="property_r",
    )

    def __str__(self):
        return "{} : {}".format(self.property_def, self.property_val)


class PropertyTemplate(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
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

    """
    val_type = models.ForeignKey('TypeDef',
                                 db_column='val_type_uuid',
                                 on_delete=models.DO_NOTHING,
                                 blank=True,
                                 null=True, related_name='property_def_val_type')
    val_unit = models.CharField(max_length=255,
                                blank=True,
                                null=True,
                                db_column='valunit')
    unit_type = models.CharField(max_length=255,
                                blank=True,
                                null=True,
                                db_column='property_def_unit_type')
    """

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
    type = models.CharField(max_length=255, blank=True, null=True, editable=False)
    type_description = models.CharField(
        max_length=255, blank=True, null=True, editable=False
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


class DefaultValues(DateColumns, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,)
    nominal_value = ValField(blank=True, null=True)
    actual_value = ValField(blank=True, null=True)

    def __str__(self):
        return self.description


class ValueInstance(DateColumns, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,)
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
        "OutcomeInstance",
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


class OutcomeInstanceValue(ValueInstance):
    objects = OutcomeInstanceValueManager()

    class Meta:
        proxy = True
