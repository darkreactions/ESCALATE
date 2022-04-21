from django.db import models
from django.db.models import QuerySet, Prefetch, F
from django.contrib.postgres.fields import ArrayField, JSONField

from core.models.core_tables import RetUUIDField, SlugField
from core.models.custom_types import ValField, CustomArrayField

import uuid
from core.models.base_classes import (
    DateColumns,
    StatusColumn,
    ActorColumn,
    DescriptionColumn,
)
from core.managers import (
    ExperimentTemplateManager,
    ExperimentInstanceManager,
    BomMaterialManager,
    BomCompositeMaterialManager,
    BomVesselManager,
    ExperimentCompletedInstanceManager,
    ExperimentPendingInstanceManager,
)
from core.models.view_tables.actions import ActionTemplate, Action
from core.models.view_tables.chemistry_data import ReagentTemplate, Reagent


managed_tables = True
managed_views = False


class BillOfMaterials(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column="bom_uuid")
    experiment = models.ForeignKey(
        "ExperimentTemplate",
        on_delete=models.CASCADE,
        blank=True,
        null=True,
        db_column="experiment_uuid",
        related_name="bom_experiment",
    )
    experiment_instance = models.ForeignKey(
        "ExperimentInstance",
        on_delete=models.CASCADE,
        blank=True,
        null=True,
        related_name="bom_ei",
    )
    # experiment_description = models.CharField(
    #    max_length=255, blank=True, null=True)
    internal_slug = SlugField(
        populate_from=["description", "experiment__internal_slug"],
        overwrite=True,
        max_length=255,
    )

    def __str__(self):
        return f"{self.description}"


# For reference Proxy Models:  https://docs.djangoproject.com/en/3.2/topics/db/models/#proxy-models


class BaseBomMaterial(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column="bom_material_uuid"
    )
    bom = models.ForeignKey(
        "BillOfMaterials",
        on_delete=models.CASCADE,
        blank=True,
        null=True,
        db_column="bom_uuid",
        related_name="bom_material_bom",
    )
    inventory_material = models.ForeignKey(
        "InventoryMaterial",
        on_delete=models.CASCADE,
        blank=True,
        null=True,
        db_column="inventory_material_uuid",
        related_name="bom_material_inventory_material",
    )
    vessel = models.ForeignKey(
        "Vessel",
        on_delete=models.CASCADE,
        blank=True,
        null=True,
        db_column="vessel_uuid",
        related_name="bom_material_vessel",
    )
    reagent = models.ForeignKey(
        "ReagentTemplate",
        on_delete=models.CASCADE,
        blank=True,
        null=True,
        db_column="reagent_template_uuid",
        related_name="bom_material_reagent_template",
    )
    # material = models.ForeignKey('Material', on_delete=models.CASCADE,
    #                             blank=True, null=True, db_column='material_uuid',
    #                             related_name='bom_material_material')
    # bom_description = models.CharField(max_length=255, blank=True, null=True)
    alloc_amt_val = ValField(blank=True, null=True)
    used_amt_val = ValField(blank=True, null=True)
    putback_amt_val = ValField(blank=True, null=True)
    bom_material = models.ForeignKey(
        "BomMaterial",
        on_delete=models.CASCADE,
        blank=True,
        null=True,  # db_column='bom_material_uuid',
        related_name="bom_composite_material_bom_material",
    )
    mixture = models.ForeignKey(
        "Mixture",
        on_delete=models.CASCADE,
        blank=True,
        null=True,
        db_column="material_composite_uuid",
        related_name="bom_composite_material_composite_material",
    )
    internal_slug = SlugField(
        populate_from=[
            "description",
            "bom__internal_slug",
            "inventory_material__internal_slug",
            "vessel__internal_slug",
            "reagent__internal_slug",
        ],
        overwrite=True,
        max_length=255,
    )

    def __str__(self):
        return f"{self.description}"


class BomMaterial(BaseBomMaterial):
    objects = BomMaterialManager()

    class Meta:
        proxy = True


class BomCompositeMaterial(BaseBomMaterial):
    objects = BomCompositeMaterialManager()

    class Meta:
        proxy = True


class BomVessel(BaseBomMaterial):
    objects = BomVesselManager()

    class Meta:
        proxy = True


class ExperimentTemplate(DateColumns, StatusColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4)
    experiment_type = models.ForeignKey(
        "Type",
        on_delete=models.CASCADE,
        blank=True,
        null=True,
        related_name="experiment_template_type",
    )
    ref_uid = models.CharField(
        max_length=255, db_column="ref_uid", blank=True, null=True
    )
    description = models.CharField(max_length=255, unique=True)

    owner = models.ForeignKey(
        "Actor",
        db_column="owner_uuid",
        on_delete=models.CASCADE,
        blank=True,
        null=True,
        related_name="experiment_template_owner",
    )
    operator = models.ForeignKey(
        "Actor",
        db_column="operator_uuid",
        on_delete=models.CASCADE,
        blank=True,
        null=True,
        related_name="experiment_template_operator",
    )
    lab = models.ForeignKey(
        "Actor",
        db_column="lab_uuid",
        on_delete=models.CASCADE,
        blank=True,
        null=True,
        related_name="experiment_template_lab",
    )
    internal_slug = SlugField(
        populate_from=[
            "description",
        ],
        overwrite=True,
        max_length=255,
    )
    reagent_templates = models.ManyToManyField(
        "ReagentTemplate", blank=True, related_name="experiment_template_rt"
    )
    outcome_templates = models.ManyToManyField(
        "OutcomeTemplate", blank=True, related_name="experiment_template_ot"
    )
    vessel_templates = models.ManyToManyField(
        "VesselTemplate", blank=True, related_name="experiment_template_vt"
    )
    metadata = JSONField(blank=True, null=True)
    action_template_et: "QuerySet[ActionTemplate]"

    def __str__(self):
        return f"{self.description}"

    def get_action_templates(
        self,
        source_vessel_decomposable: "bool|None",
        dest_vessel_decomposable: "bool|None",
    ) -> "list[ActionTemplate]":
        filter = {}
        if source_vessel_decomposable is not None:
            filter["source_vessel_decomposable"] = source_vessel_decomposable
        if dest_vessel_decomposable is not None:
            filter["dest_vessel_decomposable"] = dest_vessel_decomposable

        # Sorting action templates using depth first
        # Get all action templates without parents
        filter["parent__isnull"] = True

        def visit_at(
            at: ActionTemplate, visited_ats: set, result: "list[ActionTemplate]"
        ):
            if at.uuid not in visited_ats:
                visited_ats.add(at.uuid)
                result.append(at)
                for child in at.children.all():
                    result = visit_at(child, visited_ats, result)
            return result

        visited_ats = set()
        head_ats = (
            self.action_template_et.filter(**filter)
            .prefetch_related(Prefetch("action_def__parameter_def"))
            .order_by("description")
        )
        result = []
        for head_at in head_ats:
            result = visit_at(head_at, visited_ats, result)

        # action_templates = (
        #     self.action_template_et.filter(**filter)
        #     .prefetch_related(Prefetch("action_def__parameter_def"))
        #     .order_by("description")
        # )
        return result

    def get_reagent_templates(self) -> "QuerySet[ReagentTemplate]":
        """Return the properties of reagent templates related to
           this experiment template

        Returns:
            list[QuerySet]: Returns a QuerySet of reagent templates with their properties
        """
        reagent_templates = (
            self.reagent_templates.all()
            .prefetch_related(
                Prefetch("properties__default_value"),
                Prefetch("reagent_material_template_rt__properties__default_value"),
                Prefetch("reagent_material_template_rt__material_type"),
            )
            .order_by("description")
        )
        return reagent_templates


class ExperimentInstance(DateColumns, StatusColumn, DescriptionColumn):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column="experiment_uuid"
    )
    ref_uid = models.CharField(
        max_length=255, db_column="ref_uid", blank=True, null=True
    )
    # update to point to an experiment parent.
    template = models.ForeignKey(
        "ExperimentTemplate",
        db_column="parent_uuid",
        on_delete=models.CASCADE,
        blank=True,
        null=True,
        related_name="experiment_instance_template",
    )
    owner = models.ForeignKey(
        "Actor",
        db_column="owner_uuid",
        on_delete=models.CASCADE,
        blank=True,
        null=True,
        related_name="experiment_instance_owner",
    )
    operator = models.ForeignKey(
        "Actor",
        db_column="operator_uuid",
        on_delete=models.CASCADE,
        blank=True,
        null=True,
        related_name="experiment_instance_operator",
    )
    lab = models.ForeignKey(
        "Actor",
        db_column="lab_uuid",
        on_delete=models.CASCADE,
        blank=True,
        null=True,
        related_name="experiment_instance_lab",
    )
    internal_slug = SlugField(
        populate_from=[
            "description",
        ],
        overwrite=True,
        max_length=255,
    )
    completion_status = models.CharField(
        db_column="completion_status", max_length=255, default="Pending"
    )
    priority = models.CharField(db_column="priority", max_length=255, default="1")
    metadata = JSONField(blank=True, null=True)
    action_ei: "QuerySet[Action]"
    reagent_ei: "QuerySet[Reagent]"

    def __str__(self):
        return f"{self.description}"

    def get_action_parameters(
        self, decomposable: "bool|None" = None
    ) -> "QuerySet[Action]":
        """
        ## Gets the action parameters related to the experiment
        decomposable = True -> Only parameters that have decomposable destination
        decomposable = False -> Only parameters that DON'T have decomposable destination
        decomposable = None -> All parameters
        """
        if decomposable is None:
            filter = {}
        else:
            filter = {"template__dest_vessel_decomposable": decomposable}
        actions = (
            self.action_ei.filter(**filter)
            .prefetch_related("action_unit_a__parameter_au")
            .annotate(action_unit_uuid=F("action_unit_a"))
            .annotate(
                action_unit_dest=F(
                    "action_unit_a__destination_material__vessel__description"
                )
            )
            .annotate(
                action_unit_source=F(
                    "action_unit_a__source_material__vessel__description"
                )
            )
            .annotate(parameter_uuid=F("action_unit_a__parameter_au"))
            .annotate(
                parameter_nominal=F(
                    "action_unit_a__parameter_au__parameter_val_nominal"
                )
            )
            .annotate(
                parameter_actual=F("action_unit_a__parameter_au__parameter_val_actual")
            )
        )

        return actions


class ExperimentCompletedInstance(ExperimentInstance):
    objects = ExperimentCompletedInstanceManager()

    class Meta:
        proxy = True


class ExperimentPendingInstance(ExperimentInstance):
    objects = ExperimentPendingInstanceManager()

    class Meta:
        proxy = True


class OutcomeTemplate(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column="outcome_uuid")
    experiment = models.ForeignKey(
        "ExperimentTemplate",
        db_column="experiment_uuid",
        on_delete=models.CASCADE,
        blank=True,
        null=True,
        related_name="outcome_template_experiment_template",
    )
    # instance_labels = ArrayField(
    # models.CharField(null=True, blank=True, max_length=255), null=True, blank=True
    # )
    default_value = models.ForeignKey(
        "DefaultValues",
        on_delete=models.DO_NOTHING,
        blank=True,
        null=True,
        related_name="outcome_template_default_value",
    )
    internal_slug = SlugField(
        populate_from=["experiment__internal_slug", "description"],
        overwrite=True,
        max_length=255,
    )

    def __str__(self):
        return f"{self.description}"


class Outcome(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column="outcome_uuid")
    outcome_template = models.ForeignKey(
        "OutcomeTemplate",
        on_delete=models.CASCADE,
        blank=True,
        null=True,
        related_name="outcome_instance_ot",
    )
    experiment_instance = models.ForeignKey(
        "ExperimentInstance",
        on_delete=models.CASCADE,
        blank=True,
        null=True,
        related_name="outcome_instance_experiment_instance",
    )
    # instance_labels = ArrayField(
    # models.CharField(null=True, blank=True, max_length=255), null=True, blank=True
    # )
    internal_slug = SlugField(
        populate_from=["experiment_instance__internal_slug", "description"],
        overwrite=True,
        max_length=255,
    )
    nominal_value = ValField(blank=True, null=True)
    actual_value = ValField(blank=True, null=True)
    # file = models.FileField()

    def save(self, *args, **kwargs):
        if self.outcome_template.default_value is not None:
            if not self.nominal_value:
                self.nominal_value = self.outcome_template.default_value.nominal_value
            if not self.actual_value:
                self.actual_value = self.outcome_template.default_value.actual_value
        super().save(*args, **kwargs)


class Type(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    """Specifies the type of object, Currently used to define the type of an
    actionsequence and experimenttemplate

    Args:
        DateColumns (Model): Contains Datecolumns
        StatusColumn (Model): Contains Status column
        ActorColumn (Model): Contains Actor column
        DescriptionColumn (Model): Contains description column
    """

    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column="experiment_type_uuid"
    )
    internal_slug = SlugField(
        populate_from=["description"], overwrite=True, max_length=255
    )