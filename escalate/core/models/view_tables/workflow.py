from django.db import models
from django.contrib.postgres.fields import ArrayField
from core.models.core_tables import RetUUIDField
from core.models.custom_types import ValField, CustomArrayField
import uuid
from core.models.base_classes import DateColumns, StatusColumn, ActorColumn, DescriptionColumn
from core.managers import ExperimentTemplateManager, BomMaterialManager, BomCompositeMaterialManager

managed_tables = True
managed_views = False


class Action(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='action_uuid')
    action_def = models.ForeignKey('ActionDef',
                                   on_delete=models.DO_NOTHING,
                                   db_column='action_def_uuid',
                                   blank=True,
                                   null=True, related_name='action_action_def')
    parameter_def = models.ManyToManyField(
        'ParameterDef', blank=True, editable=False)
    workflow = models.ForeignKey('Workflow',
                                 on_delete=models.DO_NOTHING,
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
    calculation_def = models.ForeignKey('CalculationDef', on_delete=models.DO_NOTHING,
                                        db_column='calculation_def_uuid',
                                        blank=True,
                                        null=True,
                                        related_name='action_calculation_def')

    def __str__(self):
        return "{}".format(self.description)


# Potential table to eliminate WorkflowActionSet. An action can operate on one or many
# source-destination material pairs. Both can be represented by Action

class ActionUnit(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='action_material_uuid')
    action = models.ForeignKey('Action', on_delete=models.DO_NOTHING,
                               blank=True,
                               null=True,
                               related_name='action_unit_action')
    source_material = models.ForeignKey('BaseBomMaterial',
                                        on_delete=models.DO_NOTHING,
                                        db_column='source_material_uuid',
                                        blank=True,
                                        null=True,
                                        related_name='action_unit_source_material')
    destination_material = models.ForeignKey('BaseBomMaterial',
                                             on_delete=models.DO_NOTHING,
                                             db_column='destination_material_uuid',
                                             blank=True,
                                             null=True,
                                             related_name='action_unit_destination_material')
    # parameter = models.OneToOneField('Parameter', on_delete=models.CASCADE, blank=True,
    #                           null=True,
    #                           related_name='action_unit_parameter')


class ActionDef(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):

    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='action_def_uuid')
    # , through='ActionParameterDefAssign')
    parameter_def = models.ManyToManyField('ParameterDef', blank=True)

    def __str__(self):
        return f"{self.description}"


class BillOfMaterials(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column='bom_uuid')
    experiment = models.ForeignKey('Experiment', on_delete=models.DO_NOTHING,
                                   blank=True, null=True, db_column='experiment_uuid',
                                   related_name='bom_experiment')
    # experiment_description = models.CharField(
    #    max_length=255, blank=True, null=True)

    def __str__(self):
        return f"{self.description}"

# For reference Proxy Models:  https://docs.djangoproject.com/en/3.2/topics/db/models/#proxy-models


class BaseBomMaterial(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='bom_material_uuid')
    bom = models.ForeignKey('BillOfMaterials', on_delete=models.DO_NOTHING,
                            blank=True, null=True, db_column='bom_uuid',
                            related_name='bom_material_bom')
    inventory_material = models.ForeignKey('InventoryMaterial', on_delete=models.DO_NOTHING,
                                           blank=True, null=True, db_column='inventory_material_uuid',
                                           related_name='bom_material_inventory_material')
    # material = models.ForeignKey('Material', on_delete=models.DO_NOTHING,
    #                             blank=True, null=True, db_column='material_uuid',
    #                             related_name='bom_material_material')
    # bom_description = models.CharField(max_length=255, blank=True, null=True)
    alloc_amt_val = ValField(blank=True, null=True)
    used_amt_val = ValField(blank=True, null=True)
    putback_amt_val = ValField(blank=True, null=True)
    bom_material = models.ForeignKey('BomMaterial', on_delete=models.DO_NOTHING,
                                     blank=True, null=True,  # db_column='bom_material_uuid',
                                     related_name='bom_composite_material_bom_material')
    mixture = models.ForeignKey('Mixture', on_delete=models.DO_NOTHING,
                                blank=True, null=True, db_column='material_composite_uuid',
                                related_name='bom_composite_material_composite_material')

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


class Condition(DateColumns, StatusColumn, ActorColumn):
    # todo: link to condition calculation
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='condition_uuid')
    """
    condition_calculation = models.ForeignKey('ConditionCalculationDefAssign', 
                                              models.DO_NOTHING, 
                                              db_column='condition_calculation_def_x_uuid',
                                              related_name='condition_condition_calculation')
    """
    condition_description = models.CharField(max_length=255,
                                             blank=True,
                                             null=True,
                                             editable=False)
    condition_def = models.ForeignKey('ConditionDef', models.DO_NOTHING,
                                      db_column='condition_def_uuid', related_name='condition_condition_def')

    # TODO: Fix in_val and out_val on Postgres to return strings not JSON!
    in_val = ValField(blank=True, null=True)
    out_val = ValField(blank=True, null=True)


class ConditionDef(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column='condition_def_uuid')

    # through='ConditionCalculationDefAssign')
    calculation_def = models.ManyToManyField('CalculationDef', blank=True),


class ConditionPath(DateColumns):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column='condition_path_uuid')
    condition = models.ForeignKey('Condition',
                                  on_delete=models.DO_NOTHING,
                                  db_column='condition_uuid',
                                  blank=True,
                                  null=True,
                                  related_name='condition_path_condition')
    condition_out_val = ValField(blank=True, null=True)
    workflow_step = models.ForeignKey('WorkflowStep',
                                      on_delete=models.DO_NOTHING,
                                      db_column='workflow_uuid',
                                      blank=True,
                                      null=True,
                                      related_name='condition_path_workflow_step')

# For reference Proxy Models: https://docs.djangoproject.com/en/3.2/topics/db/models/#proxy-models


class Experiment(DateColumns, StatusColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='experiment_uuid')
    experiment_type = models.ForeignKey('ExperimentType', db_column='experiment_type_uuid',
                                        on_delete=models.DO_NOTHING, blank=True, null=True, related_name='experiment_experiment_type')
    ref_uid = models.CharField(max_length=255, db_column='ref_uid')
    # update to point to an experiment parent. 
    parent = models.ForeignKey('Experiment', db_column='parent_uuid',
                               on_delete=models.DO_NOTHING, blank=True, null=True, related_name='experiment_parent')
    owner = models.ForeignKey('Actor', db_column='owner_uuid', on_delete=models.DO_NOTHING, blank=True, null=True,
                              related_name='experiment_owner')
    operator = models.ForeignKey('Actor', db_column='operator_uuid', on_delete=models.DO_NOTHING, blank=True, null=True,
                                 related_name='experiment_operator')
    lab = models.ForeignKey('Actor', db_column='lab_uuid', on_delete=models.DO_NOTHING, blank=True, null=True,
                            related_name='experiment_lab')
    workflow = models.ManyToManyField(
        'Workflow', through='ExperimentWorkflow', related_name='experiment_workflow')
    # owner_description = models.CharField(max_length=255, db_column='owner_description')
    # operator_description = models.CharField(max_length=255, db_column='operator_description')

    def __str__(self):
        return f'{self.description}'


class ExperimentTemplate(Experiment):
    objects = ExperimentTemplateManager()

    class Meta:
        proxy = True


class ExperimentInstance(Experiment):
    objects = ExperimentTemplateManager()

    class Meta:
        proxy = True


class ExperimentType(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='experiment_type_uuid')


class ExperimentWorkflow(DateColumns):
    # note: omitted much detail here because should be nested under
    # experiment, no need for redundancy.
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='experiment_workflow_uuid')
    experiment = models.ForeignKey('Experiment', db_column='experiment_uuid', on_delete=models.DO_NOTHING,
                                   blank=True, null=True, related_name='experiment_workflow_experiment')
    # experiment_ref_uid = models.CharField(max_length=255)
    # experiment_description = models.CharField(max_length=255)
    experiment_workflow_seq = models.IntegerField()
    workflow = models.ForeignKey('Workflow', db_column='workflow_uuid',
                                 on_delete=models.DO_NOTHING, blank=True, null=True, related_name='experiment_workflow_workflow')
    # workflow_type_uuid = models.ForeignKey('WorkflowType', db_column='workflow_type_uuid',
    #                                       on_delete=models.DO_NOTHING, blank=True, null=True)


class Outcome(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='outcome_uuid')
    experiment = models.ForeignKey('Experiment', db_column='experiment_uuid', on_delete=models.DO_NOTHING,
                                   blank=True, null=True, related_name='outcome_experiment')


class Workflow(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='workflow_uuid')
    parent = models.ForeignKey('Workflow', models.DO_NOTHING,
                               blank=True, null=True,
                               db_column='parent_uuid', related_name='workflow_parent')
    workflow_type = models.ForeignKey('WorkflowType', models.DO_NOTHING,
                                      blank=True, null=True,
                                      db_column='workflow_type_uuid', related_name='workflow_workflow_type')
    experiment = models.ManyToManyField(
        'Experiment', through='ExperimentWorkflow', related_name='workflow_experiment')

    def __str__(self):
        return f'{self.description}'


class WorkflowActionSet(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='workflow_action_set_uuid')
    workflow = models.ForeignKey('Workflow', models.DO_NOTHING,
                                 blank=True, null=True,
                                 db_column='workflow_uuid',
                                 related_name='workflow_action_set_workflow')
    action_def = models.ForeignKey('ActionDef', models.DO_NOTHING,
                                   blank=True, null=True,
                                   db_column='action_def_uuid',
                                   related_name='workflow_action_set_action_def')
    start_date = models.DateTimeField()
    end_date = models.DateTimeField()
    duration = models.FloatField()
    repeating = models.BigIntegerField()
    parameter_def = models.ForeignKey('ParameterDef', models.DO_NOTHING,
                                      blank=True, null=True,
                                      db_column='parameter_def_uuid',
                                      related_name='workflow_action_set_parameter_def')
    parameter_val_nominal = CustomArrayField(ValField(),
                                             blank=True, null=True,
                                             db_column='parameter_val')
    parameter_val_actual = CustomArrayField(ValField(),
                                            blank=True, null=True,
                                            db_column='parameter_val_actual')
    calculation = models.ForeignKey('Calculation', models.DO_NOTHING,
                                    blank=True, null=True,
                                    db_column='calculation_uuid',
                                    related_name='workflow_action_set_calculation')
    source_material = ArrayField(RetUUIDField(
        blank=True, null=True), db_column='source_material_uuid')
    destination_material = ArrayField(RetUUIDField(
        blank=True, null=True), db_column='destination_material_uuid')


class WorkflowType(DateColumns, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='workflow_type_uuid')

    def __str__(self):
        return f'{self.description}'


class WorkflowStep(DateColumns, StatusColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='workflow_step_uuid')
    workflow = models.ForeignKey('Workflow', models.DO_NOTHING,
                                 db_column='workflow_uuid',
                                 related_name='workflow_step_workflow')
    '''
    workflow_action_set = models.ForeignKey('WorkflowActionSet', models.DO_NOTHING,
                                 db_column='workflow_action_set_uuid',
                                 related_name='workflow_step_workflow_action_set', 
                                 null=True, blank=True)
    '''
    action = models.ForeignKey('Action', models.DO_NOTHING,
                           blank=True, null=True, 
                           db_column='action_uuid', related_name='workflow_step_action') 
    parent = models.ForeignKey('Workflow', models.DO_NOTHING,
                               blank=True, null=True,
                               db_column='parent_uuid', related_name='workflow_step_parent')

    parent_path = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   editable=False)
    workflow_object = models.ForeignKey('WorkflowObject', models.DO_NOTHING,
                                        db_column='workflow_object_uuid', related_name='workflow_step_workflow_object')
    action = models.ForeignKey('Action', models.DO_NOTHING,
                               blank=True, null=True,
                               db_column='action_uuid', related_name='workflow_step_action')


class WorkflowObject(DateColumns, StatusColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='workflow_object_uuid')
    workflow = models.ForeignKey('Workflow', models.DO_NOTHING,
                                 blank=True, null=True,
                                 db_column='workflow_uuid', related_name='workflow_object_workflow')
    action = models.ForeignKey('Action', models.DO_NOTHING,
                               blank=True, null=True,
                               db_column='action_uuid', related_name='workflow_object_action')
    condition = models.ForeignKey('Condition', models.DO_NOTHING,
                                  blank=True, null=True,
                                  db_column='condition_uuid', related_name='workflow_object_condition')
    workflow_action_set = models.ForeignKey('WorkflowActionSet', models.DO_NOTHING,
                                            blank=True, null=True,
                                            db_column='workflow_action_set_uuid',
                                            related_name='workflow_object_workflow_action_set')
