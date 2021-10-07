from django.db import models
from django.contrib.postgres.fields import ArrayField

from core.models.core_tables import RetUUIDField, SlugField
from core.models.custom_types import ValField, CustomArrayField
import uuid
from core.models.base_classes import DateColumns, StatusColumn, ActorColumn, DescriptionColumn
from core.managers import (ExperimentTemplateManager, ExperimentInstanceManager,
                            BomMaterialManager, BomCompositeMaterialManager, BomVesselManager)


managed_tables = True
managed_views = False


class Action(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='action_uuid')
    action_def = models.ForeignKey('ActionDef',
                                   on_delete=models.CASCADE,
                                   db_column='action_def_uuid',
                                   blank=True,
                                   null=True, related_name='action_action_def')
    parameter_def = models.ManyToManyField(
        'ParameterDef', blank=True, editable=False)
    workflow = models.ForeignKey('Workflow',
                                 on_delete=models.CASCADE,
                                 db_column='workflow_uuid',
                                 blank=True,
                                 null=True, related_name='action_workflow')
    start_date = models.DateField(
        db_column='start_date', blank=True, null=True)
    end_date = models.DateField(db_column='end_date', blank=True, null=True)
    duration = models.FloatField(db_column='duration',
                                 blank=True,
                                 null=True)
    repeating = models.IntegerField(db_column='repeating',
                                    blank=True,
                                    null=True)
    #calculation_def = models.ForeignKey('CalculationDef', on_delete=models.CASCADE,
    #                                    db_column='calculation_def_uuid',
    #                                    blank=True,
    #                                    null=True,
    #                                    related_name='action_calculation_def')
    internal_slug = SlugField(populate_from=[
                                    'description',
                                    'workflow',
                                    'action_def__internal_slug'
                                    ],
                              overwrite=True, 
                              max_length=255)

    def __str__(self):
        return "{}".format(self.description)


# Potential table to eliminate WorkflowActionSet. An action can operate on one or many
# source-destination material pairs. Both can be represented by Action

class ActionUnit(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='action_material_uuid')
    action = models.ForeignKey('Action', on_delete=models.CASCADE,
                               blank=True,
                               null=True,
                               related_name='action_unit_action')
    source_material = models.ForeignKey('BaseBomMaterial',
                                        on_delete=models.CASCADE,
                                        db_column='source_uuid',
                                        blank=True,
                                        null=True,
                                        related_name='action_unit_source_material')
    destination_material = models.ForeignKey('BaseBomMaterial',
                                             on_delete=models.CASCADE,
                                             db_column='destination_uuid',
                                             blank=True,
                                             null=True,
                                             related_name='action_unit_destination_material')
    # parameter = models.OneToOneField('Parameter', on_delete=models.CASCADE, blank=True,
    #                           null=True,
    #                           related_name='action_unit_parameter')
    internal_slug = SlugField(populate_from=[
                                    #'source_material__internal_slug',
                                    #'action__internal_slug',
                                    'uuid',
                                    'destination_material__internal_slug'
                                    ],
                              overwrite=True, 
                              max_length=255)
    #internal_slug = CharField(max_length=255)
    
    def __str__(self):
        return f"{self.description}"


class ActionDef(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):

    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='action_def_uuid')
    # , through='ActionParameterDefAssign')
    parameter_def = models.ManyToManyField('ParameterDef', blank=True)
    internal_slug = SlugField(populate_from=[
                                    'description'
                                    ],
                              overwrite=True, 
                              max_length=255)

    def __str__(self):
        return f"{self.description}"


class BillOfMaterials(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column='bom_uuid')
    experiment = models.ForeignKey('ExperimentTemplate', on_delete=models.CASCADE,
                                   blank=True, null=True, db_column='experiment_uuid',
                                   related_name='bom_experiment')
    experiment_instance = models.ForeignKey('ExperimentInstance', on_delete=models.CASCADE,
                                   blank=True, null=True, related_name='bom_experiment_instance')
    # experiment_description = models.CharField(
    #    max_length=255, blank=True, null=True)
    internal_slug = SlugField(populate_from=[
                                    'description',
                                    'experiment__internal_slug'
                                    ],
                              overwrite=True, 
                              max_length=255)

    def __str__(self):
        return f"{self.description}"

# For reference Proxy Models:  https://docs.djangoproject.com/en/3.2/topics/db/models/#proxy-models


class BaseBomMaterial(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='bom_material_uuid')
    bom = models.ForeignKey('BillOfMaterials', on_delete=models.CASCADE,
                            blank=True, null=True, db_column='bom_uuid',
                            related_name='bom_material_bom')
    inventory_material = models.ForeignKey('InventoryMaterial', on_delete=models.CASCADE,
                                           blank=True, null=True, db_column='inventory_material_uuid',
                                           related_name='bom_material_inventory_material')
    vessel = models.ForeignKey('Vessel', on_delete=models.CASCADE,
                                       blank=True, null=True, db_column='vessel_uuid',
                                       related_name='bom_material_vessel')
    # material = models.ForeignKey('Material', on_delete=models.CASCADE,
    #                             blank=True, null=True, db_column='material_uuid',
    #                             related_name='bom_material_material')
    # bom_description = models.CharField(max_length=255, blank=True, null=True)
    alloc_amt_val = ValField(blank=True, null=True)
    used_amt_val = ValField(blank=True, null=True)
    putback_amt_val = ValField(blank=True, null=True)
    bom_material = models.ForeignKey('BomMaterial', on_delete=models.CASCADE,
                                     blank=True, null=True,  # db_column='bom_material_uuid',
                                     related_name='bom_composite_material_bom_material')
    mixture = models.ForeignKey('Mixture', on_delete=models.CASCADE,
                                blank=True, null=True, db_column='material_composite_uuid',
                                related_name='bom_composite_material_composite_material')
    internal_slug = SlugField(populate_from=[
                                    'description',
                                    'bom__internal_slug',
                                    'inventory_material__internal_slug'
                                    ],
                              overwrite=True, 
                              max_length=255)

    def __str__(self):
        return self.description


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

class ExperimentTemplate(DateColumns, StatusColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4)
    experiment_type = models.ForeignKey('ExperimentType', on_delete=models.CASCADE, 
                                        blank=True, null=True, 
                                        related_name='experiment_template_experiment_type')
    ref_uid = models.CharField(max_length=255,
                               db_column='ref_uid',
                               blank=True,
                               null=True)
    owner = models.ForeignKey('Actor', db_column='owner_uuid', on_delete=models.CASCADE, blank=True, null=True,
                              related_name='experiment_template_owner')
    operator = models.ForeignKey('Actor', db_column='operator_uuid', on_delete=models.CASCADE, blank=True, null=True,
                                 related_name='experiment_template_operator')
    lab = models.ForeignKey('Actor', db_column='lab_uuid', on_delete=models.CASCADE, blank=True, null=True,
                            related_name='experiment_template_lab')
    workflow = models.ManyToManyField(
        'Workflow', through='ExperimentWorkflow', related_name='experiment_template_workflow')
    internal_slug = SlugField(populate_from=[
                                    'description',
                                    ],
                              overwrite=True, 
                              max_length=255)
    reagent_templates = models.ManyToManyField('ReagentTemplate', 
                                                blank=True, 
                                                related_name='experiment_template_reagent_template')
    outcome_templates = models.ManyToManyField('OutcomeTemplate',
                                                blank=True, 
                                                related_name='experiment_template_outcome_template')

    def __str__(self):
        return f'{self.description}'
    #objects = ExperimentTemplateManager()

    #class Meta:
    #    proxy = True


class ExperimentInstance(DateColumns, StatusColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='experiment_uuid')
    #experiment_type = models.ForeignKey('ExperimentType', db_column='experiment_type_uuid',
    #                                    on_delete=models.CASCADE, blank=True, null=True, related_name='experiment_experiment_type')
    ref_uid = models.CharField(max_length=255,
                               db_column='ref_uid',
                               blank=True,
                               null=True)
    # update to point to an experiment parent. 
    parent = models.ForeignKey('ExperimentTemplate', db_column='parent_uuid',
                               on_delete=models.CASCADE, blank=True, null=True, related_name='experiment_instance_parent')
    owner = models.ForeignKey('Actor', db_column='owner_uuid', on_delete=models.CASCADE, blank=True, null=True,
                              related_name='experiment_instance_owner')
    operator = models.ForeignKey('Actor', db_column='operator_uuid', on_delete=models.CASCADE, blank=True, null=True,
                                 related_name='experiment_instance_operator')
    lab = models.ForeignKey('Actor', db_column='lab_uuid', on_delete=models.CASCADE, blank=True, null=True,
                            related_name='experiment_instance_lab')
    workflow = models.ManyToManyField(
        'Workflow', through='ExperimentWorkflow', related_name='experiment_instance_workflow')
    # owner_description = models.CharField(max_length=255, db_column='owner_description')
    # operator_description = models.CharField(max_length=255, db_column='operator_description')
    internal_slug = SlugField(populate_from=[
                                    'description',
                                    ],
                              overwrite=True, 
                              max_length=255)
    completion_status = models.CharField(db_column='completion_status',
                                  max_length=255, 
                                  default="Pending")
    priority = models.CharField(db_column='priority',
                                  max_length=255, 
                                  default="1")
    #reagents = models.ManyToManyField('ReagentInstance', 
    #                                  blank=True, 
    #                                  related_name='experiment_instance_reagent_instance')
    

    def __str__(self):
        return f'{self.description}'
    #objects = ExperimentInstanceManager()

    #class Meta:
    #    proxy = True


class ExperimentType(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='experiment_type_uuid')
    internal_slug = SlugField(populate_from=[
                                    'description'
                                    ],
                              overwrite=True, 
                              max_length=255)


class ExperimentWorkflow(DateColumns):
    # note: omitted much detail here because should be nested under
    # experiment, no need for redundancy.
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='experiment_workflow_uuid')
    experiment_template = models.ForeignKey('ExperimentTemplate', on_delete=models.CASCADE,
                                   blank=True, null=True, related_name='experiment_template_workflow_experiment')
    experiment_instance = models.ForeignKey('ExperimentInstance', on_delete=models.CASCADE,
                                   blank=True, null=True, related_name='experiment_instance_workflow_experiment')
    # experiment_ref_uid = models.CharField(max_length=255)
    # experiment_description = models.CharField(max_length=255)
    experiment_workflow_seq = models.IntegerField()
    workflow = models.ForeignKey('Workflow', db_column='workflow_uuid',
                                 on_delete=models.CASCADE, blank=True, null=True, related_name='experiment_workflow_workflow')
    # workflow_type_uuid = models.ForeignKey('WorkflowType', db_column='workflow_type_uuid',
    #                                       on_delete=models.CASCADE, blank=True, null=True)
    internal_slug = SlugField(populate_from=[
                                    'experiment__internal_slug',
                                    'workflow__internal_slug',
                                    'experiment_workflow_seq'
                                    ],
                              overwrite=True, 
                              max_length=255)


class OutcomeTemplate(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='outcome_uuid')
    experiment = models.ForeignKey('ExperimentTemplate', db_column='experiment_uuid', on_delete=models.CASCADE,
                                   blank=True, null=True, related_name='outcome_template_experiment_template')
    instance_labels = ArrayField(models.CharField(null=True, blank=True, max_length=255), null=True, blank=True)
    default_value = models.ForeignKey('DefaultValues', on_delete=models.DO_NOTHING, 
                                      blank=True, null=True, related_name='outcome_template_default_value')
    internal_slug = SlugField(populate_from=[
                                    'experiment__internal_slug',
                                    'description'
                                    ],
                              overwrite=True, 
                              max_length=255)
    


class OutcomeInstance(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='outcome_uuid')
    outcome_template = models.ForeignKey('OutcomeTemplate', on_delete=models.CASCADE,
                                   blank=True, null=True, related_name='outcome_instance_outcome_template')
    experiment_instance = models.ForeignKey('ExperimentInstance', on_delete=models.CASCADE,
                                   blank=True, null=True, related_name='outcome_instance_experiment_instance')
    internal_slug = SlugField(populate_from=[
                                    'experiment_instance__internal_slug',
                                    'description'
                                    ],
                              overwrite=True, 
                              max_length=255)
    nominal_value = ValField(blank=True, null=True)
    actual_value = ValField(blank=True, null=True)
    file = models.FileField()

    def save(self, *args, **kwargs):
        if self.outcome_template.default_value is not None:
            self.nominal_value = self.outcome_template.default_value.default_nominal_value
            self.actual_value = self.outcome_template.default_value.default_actual_value
        super().save(*args, **kwargs)


class Workflow(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='workflow_uuid')
    parent = models.ForeignKey('Workflow', models.CASCADE,
                               blank=True, null=True,
                               db_column='parent_uuid', related_name='workflow_parent')
    workflow_type = models.ForeignKey('WorkflowType', models.CASCADE,
                                      blank=True, null=True,
                                      db_column='workflow_type_uuid', related_name='workflow_workflow_type')
    experiment = models.ManyToManyField(
        'ExperimentTemplate', through='ExperimentWorkflow', related_name='workflow_experiment')
    internal_slug = SlugField(populate_from=[
                                    'description',
                                    ],
                              overwrite=True, 
                              max_length=255)

    def __str__(self):
        return f'{self.description}'


class WorkflowActionSet(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='workflow_action_set_uuid')
    workflow = models.ForeignKey('Workflow', models.CASCADE,
                                 blank=True, null=True,
                                 db_column='workflow_uuid',
                                 related_name='workflow_action_set_workflow')
    action_def = models.ForeignKey('ActionDef', models.CASCADE,
                                   blank=True, null=True,
                                   db_column='action_def_uuid',
                                   related_name='workflow_action_set_action_def')
    start_date = models.DateTimeField()
    end_date = models.DateTimeField()
    duration = models.FloatField()
    repeating = models.BigIntegerField()
    parameter_def = models.ForeignKey('ParameterDef', models.CASCADE,
                                      blank=True, null=True,
                                      db_column='parameter_def_uuid',
                                      related_name='workflow_action_set_parameter_def')
    parameter_val_nominal = CustomArrayField(ValField(),
                                             blank=True, null=True,
                                             db_column='parameter_val')
    parameter_val_actual = CustomArrayField(ValField(),
                                            blank=True, null=True,
                                            db_column='parameter_val_actual')
    #calculation = models.ForeignKey('Calculation', models.CASCADE,
    #                                blank=True, null=True,
    #                                db_column='calculation_uuid',
    #                                related_name='workflow_action_set_calculation')
    source_material = ArrayField(RetUUIDField(
        blank=True, null=True), db_column='source_uuid')
    destination_material = ArrayField(RetUUIDField(
        blank=True, null=True), db_column='destination_uuid')


class WorkflowType(DateColumns, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='workflow_type_uuid')
    internal_slug = SlugField(populate_from=[
                                    'description'
                                    ],
                              overwrite=True, 
                              max_length=255)

    def __str__(self):
        return f'{self.description}'


class WorkflowStep(DateColumns, StatusColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='workflow_step_uuid')
    workflow = models.ForeignKey('Workflow', models.CASCADE,
                                 db_column='workflow_uuid',
                                 related_name='workflow_step_workflow')
    '''
    workflow_action_set = models.ForeignKey('WorkflowActionSet', models.CASCADE,
                                 db_column='workflow_action_set_uuid',
                                 related_name='workflow_step_workflow_action_set', 
                                 null=True, blank=True)
    '''
    action = models.ForeignKey('Action', models.CASCADE,
                           blank=True, null=True, 
                           db_column='action_uuid', related_name='workflow_step_action') 
    parent = models.ForeignKey('Workflow', models.CASCADE,
                               blank=True, null=True,
                               db_column='parent_uuid', related_name='workflow_step_parent')

    parent_path = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   editable=False)
    workflow_object = models.ForeignKey('WorkflowObject', models.CASCADE,
                                        db_column='workflow_object_uuid', related_name='workflow_step_workflow_object')
    internal_slug = SlugField(populate_from=[
                                    'workflow__internal_slug',
                                    'action__internal_slug'
                                    ],
                              overwrite=True, 
                              max_length=255)


class WorkflowObject(DateColumns, StatusColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='workflow_object_uuid')
    workflow = models.ForeignKey('Workflow', models.CASCADE,
                                 blank=True, null=True,
                                 db_column='workflow_uuid', related_name='workflow_object_workflow')
    action = models.ForeignKey('Action', models.CASCADE,
                               blank=True, null=True,
                               db_column='action_uuid', related_name='workflow_object_action')
    #condition = models.ForeignKey('Condition', models.CASCADE,
    #                              blank=True, null=True,
    #                              db_column='condition_uuid', related_name='workflow_object_condition')
    workflow_action_set = models.ForeignKey('WorkflowActionSet', models.CASCADE,
                                            blank=True, null=True,
                                            db_column='workflow_action_set_uuid',
                                            related_name='workflow_object_workflow_action_set')
    internal_slug = SlugField(populate_from=[
                                    'workflow__internal_slug',
                                    'action__internal_slug',
                                    'condition__internal_slug'
                                    ],
                              overwrite=True, 
                              max_length=255)
