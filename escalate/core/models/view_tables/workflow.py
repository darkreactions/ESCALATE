from django.db import models
from django.contrib.postgres.fields import ArrayField
from core.models.core_tables import RetUUIDField
from core.models.custom_types import ValField, CustomArrayField
import uuid
from core.models.abstract_base_models import DateColumns, StatusColumn, ActorColumn

manage_tables = False
manage_views = False

class Action(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                               db_column='action_uuid')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description')
    action_def = models.ForeignKey('ActionDef',
                                   on_delete=models.DO_NOTHING,
                                   db_column='action_def_uuid',
                                   blank=True,
                                   null=True, related_name='action_action_def')
    """
    action_def_description = models.CharField(max_length=255,
                                              blank=True,
                                              null=True,
                                              editable=False)
    """
    workflow = models.ForeignKey('Workflow',
                                   on_delete=models.DO_NOTHING,
                                   db_column='workflow_uuid',
                                   blank=True,
                                   null=True, related_name='action_workflow')
    source_material = models.ForeignKey('BomMaterial',
                               on_delete=models.DO_NOTHING,
                               db_column='source_material_uuid',
                               blank=True,
                               null=True,
                               editable=False,
                               related_name='action_source_material')

    destination_material = models.ForeignKey('BomMaterial',
                               on_delete=models.DO_NOTHING,
                               db_column='destination_material_uuid',
                               blank=True,
                               null=True,
                               editable=False,
                               related_name='action_destination_material')

    duration = models.FloatField(db_column='duration',
                                 blank=True,
                                 null=True)
    repeating = models.IntegerField(db_column='repeating',
                                    blank=True,
                                    null=True)
    start_date = models.DateField(db_column='start_date')
    end_date = models.DateField(db_column='end_date') 
    class Meta:
        managed = False
        db_table = 'action'

    def __str__(self):
        return "{}".format(self.description)


class ActionDef(DateColumns, StatusColumn, ActorColumn):
    # TODO: need to add through fields
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='action_def_uuid')
    parameter_def = models.ManyToManyField(
        'ParameterDef', through='ActionParameterDefAssign')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description',
                                   )

    def __str__(self):
        return f"{self.description}"

    class Meta:
        managed = False
        db_table = 'action_def'


class ActionParameter(models.Model):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='parameter_x_uuid')
    
    action = models.ForeignKey('Action',
                               db_column='action_uuid',
                               on_delete=models.DO_NOTHING,
                               blank=True,
                               null=True,
                               editable=False,
                               related_name='action_parameter_action')
    
    action_description = models.CharField(max_length=255,
                                                 blank=True,
                                                 null=True,
                                                 db_column='action_description',
                                                 editable=False)
    workflow = models.ForeignKey('Workflow',
                               db_column='workflow_uuid',
                               on_delete=models.DO_NOTHING,
                               blank=True,
                               null=True,
                               editable=False,
                               related_name='action_parameter_workflow')
    workflow_action_set = models.ForeignKey('WorkflowActionSet',
                               db_column='workflow_action_set_uuid',
                               on_delete=models.DO_NOTHING,
                               blank=True,
                               null=True,
                               editable=False,
                               related_name='action_parameter_workflow_action_set')
    
    
    parameter = models.ForeignKey('Parameter',
                                  db_column='parameter_uuid',
                                  on_delete=models.DO_NOTHING,
                                  blank=True,
                                  null=True,
                                  editable=False,
                                  related_name='action_parameter_parameter')
    
    #parameter_uuid = RetUUIDField()
    parameter_def = models.ForeignKey('ParameterDef',
                                      db_column='parameter_def_uuid',
                                      on_delete=models.DO_NOTHING,
                                      blank=True,
                                      null=True,
                                      editable=False, related_name='action_parameter_parameter_def')
    parameter_def_description = models.CharField(max_length=255,
                                                 blank=True,
                                                 null=True,
                                                 db_column='parameter_def_description',
                                                 editable=False)
    parameter_val_nominal = ValField(max_length=255, blank=True,
                             null=True,
                             db_column='parameter_val')
    parameter_val_actual = ValField(max_length=255, blank=True,
                             null=True,
                             db_column='parameter_val_actual')

    class Meta:
        managed = False
        db_table = 'vw_action_parameter'

#TODO: possibly update this and add ActionParameterDefX Class
class ActionParameterDef(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column='action_parameter_def_x_uuid')
    action_def = models.ForeignKey('ActionDef',
                                   on_delete=models.DO_NOTHING,
                                   db_column='action_def_uuid',
                                   blank=True,
                                   null=True,
                                   editable=False, related_name='action_parameter_def_action_def')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description',
                                   editable=False)

    parameter_def = models.ForeignKey('ParameterDef',
                                      on_delete=models.DO_NOTHING,
                                      db_column='parameter_def_uuid',
                                      blank=True,
                                      null=True,
                                      editable=False, related_name='action_parameter_def_parameter_def')

    parameter_description = models.CharField(max_length=255,
                                             blank=True,
                                             null=True,
                                             db_column='parameter_description',
                                             editable=False)
    parameter_val_type = models.ForeignKey('TypeDef',
                                           db_column='parameter_val_type_uuid',
                                           on_delete=models.DO_NOTHING,
                                           blank=True,
                                           null=True, related_name='action_parameter_def_parameter_val_type')

    class Meta:
        managed = False
        db_table = 'action_parameter_def'
        

class ActionParameterDefAssign(DateColumns):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column='action_parameter_def_x_uuid')
    parameter_def = models.ForeignKey('ParameterDef',
                                      on_delete=models.DO_NOTHING,
                                      blank=True,
                                      null=True,
                                      db_column='parameter_def_uuid',
                                      related_name='action_parameter_def_assign_parameter_def')
    action_def = models.ForeignKey('ActionDef', on_delete=models.DO_NOTHING,
                                   blank=True,
                                   null=True,
                                   db_column='action_def_uuid', related_name='action_parameter_def_assign_action_def')

    class Meta:
        managed = False
        db_table = 'action_parameter_def_x'


class BillOfMaterials(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='bom_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)
    experiment = models.ForeignKey('Experiment', on_delete=models.DO_NOTHING,
                                   blank=True, null=True, db_column='experiment_uuid',
                                   related_name='bom_experiment')
    #experiment_description = models.CharField(
    #    max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'bom'


class BomMaterial(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='bom_material_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)
    bom = models.ForeignKey('BillOfMaterials', on_delete=models.DO_NOTHING,
                            blank=True, null=True, db_column='bom_uuid',
                            related_name='bom_material_bom')
    
    # bom_description = models.CharField(max_length=255, blank=True, null=True)
    inventory_material = models.ForeignKey('InventoryMaterial', on_delete=models.DO_NOTHING,
                                           blank=True, null=True, db_column='inventory_material_uuid',
                                           related_name='bom_material_inventory_material')
    #material = models.ForeignKey('Material', on_delete=models.DO_NOTHING,
    #                             blank=True, null=True, db_column='material_uuid',
    #                             related_name='bom_material_material')
    alloc_amt_val = ValField(max_length=255, blank=True, null=True)
    used_amt_val = ValField(max_length=255, blank=True, null=True)
    putback_amt_val = ValField(max_length=255, blank=True, null=True)
    
    class Meta:
        managed = False
        db_table = 'bom_material'

    def __str__(self):
        return self.description


class BomCompositeMaterial(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='bom_material_composite_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)
    bom_material = models.ForeignKey('BomMaterial', on_delete=models.DO_NOTHING,
                            blank=True, null=True, db_column='bom_material_uuid',
                            related_name='bom_composite_material_bom_material')
    # bom_material_description = models.CharField(max_length=255, blank=True, null=True)
    
    composite_material = models.ForeignKey('CompositeMaterial', on_delete=models.DO_NOTHING,
                                               blank=True, null=True, db_column='material_composite_uuid',
                                               related_name='bom_composite_material_composite_material')
    #component = models.ForeignKey('Material', on_delete=models.DO_NOTHING,
    #                                           blank=True, null=True, db_column='component_uuid',
    #                                           related_name='bom_composite_material_component')
    #material_description = models.CharField(max_length=255,
    #                                                      blank=True,
    #                                                      null=True)

    class Meta:
        managed = False
        db_table = 'bom_material_composite'
        
# bom_material_index (description, bom_material_composite_uuid)
class BomMaterialIndex(DateColumns):
    """
    This table combines bom_material and bom_composite material so that 
    the bom_material_index_uuid can be used as an identifier in source and destination
    material uuids in WorkflowActionSet
    """
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='bom_material_index_uuid')
    #description = models.ForeignKey('BomMaterialComposite', on_delete=models.DO_NOTHING,
    #                        blank=True, null=True, db_column='description',
    #                        related_name='bom_material_index_description')
    description = models.CharField(max_length=255, blank=True, null=True)
    bom_material = models.ForeignKey('BomMaterial', on_delete=models.DO_NOTHING,
                            blank=True, null=True, db_column='bom_material_uuid',
                            related_name='bom_composite_index_bom_material')
    bom_composite_material = models.ForeignKey('BomCompositeMaterial', on_delete=models.DO_NOTHING,
                            blank=True, null=True, db_column='bom_material_composite_uuid',
                            related_name='bom_composite_index_bom_composite_material')
    
    class Meta:
        managed = False
        db_table = 'bom_material_index'


class Condition(DateColumns, StatusColumn, ActorColumn):
    # todo: link to condition calculation
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='condition_uuid')
    condition_calculation = models.ForeignKey('ConditionCalculationDefAssign', 
                                              models.DO_NOTHING, 
                                              db_column='condition_calculation_def_x_uuid',
                                              related_name='condition_condition_calculation')
    condition_description = models.CharField(max_length=255,
                                             blank=True,
                                             null=True,
                                             editable=False)
    condition_def = models.ForeignKey('ConditionDef', models.DO_NOTHING,
                                      db_column='condition_def_uuid', related_name='condition_condition_def')
    calculation_description = models.CharField(max_length=255,
                                               blank=True,
                                               null=True,
                                               editable=False)
    
    # TODO: Fix in_val and out_val on Postgres to return strings not JSON!
    in_val = ValField(max_length=255, blank=True, null=True)
    out_val = ValField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'condition'


class ConditionDef(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column='condition_def_uuid')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description',
                                   editable=False)
    # TODO: need to add through fields
    calculation_def = models.ManyToManyField('CalculationDef', through='ConditionCalculationDefAssign')

    class Meta:
        managed = False
        db_table = 'condition_def'


class ConditionCalculationDefAssign(DateColumns):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column='condition_calculation_def_x_uuid')
    condition_def = models.ForeignKey('ConditionDef',
                              on_delete=models.DO_NOTHING,
                              db_column='condition_def_uuid',
                              blank=True,
                              null=True,
                              related_name='condition_calculation_def_assign_condition_def')
    calculation_def = models.ForeignKey('CalculationDef',
                              on_delete=models.DO_NOTHING,
                              db_column='calculation_def_uuid',
                              blank=True,
                              null=True,
                              related_name='condition_calculation_def_assign_calculation_def')
    class Meta:
        managed = False
        #db_table = 'vw_condition_calculation_def_assign'
        db_table = 'condition_calculation_def_x'


class ConditionPath(DateColumns):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column='condition_path_uuid')
    condition = models.ForeignKey('Condition',
                              on_delete=models.DO_NOTHING,
                              db_column='condition_uuid',
                              blank=True,
                              null=True,
                              related_name='condition_path_condition')
    condition_out_val = ValField(max_length=255, blank=True, null=True)
    workflow_step = models.ForeignKey('WorkflowStep',
                              on_delete=models.DO_NOTHING,
                              db_column='workflow_uuid',
                              blank=True,
                              null=True,
                              related_name='condition_path_workflow_step')

    class Meta:
        managed = False
        db_table = 'condition_path'


class Experiment(DateColumns, StatusColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='experiment_uuid')
    experiment_type = models.ForeignKey('ExperimentType', db_column='experiment_type_uuid',
                               on_delete=models.DO_NOTHING, blank=True, null=True, related_name='experiment_experiment_type')
    ref_uid = models.CharField(max_length=255, db_column='ref_uid')
    description = models.CharField(max_length=255,  db_column='description')
    parent = models.ForeignKey('TypeDef', db_column='parent_uuid',
                               on_delete=models.DO_NOTHING, blank=True, null=True, related_name='experiment_parent')
    owner = models.ForeignKey('Actor', db_column='owner_uuid', on_delete=models.DO_NOTHING, blank=True, null=True,
                              related_name='experiment_owner')
    operator = models.ForeignKey('Actor', db_column='operator_uuid', on_delete=models.DO_NOTHING, blank=True, null=True,
                                 related_name='experiment_operator')
    lab = models.ForeignKey('Actor', db_column='lab_uuid', on_delete=models.DO_NOTHING, blank=True, null=True,
                            related_name='experiment_lab')
    # TODO: need to add through fields
    workflow = models.ManyToManyField('Workflow', through='ExperimentWorkflow', related_name='experiment_workflow')
    # owner_description = models.CharField(max_length=255, db_column='owner_description')
    
    # operator_description = models.CharField(max_length=255, db_column='operator_description')
    

    def __str__(self):
        return f'{self.description}'

    class Meta:
        managed = False
        db_table = 'experiment'


class ExperimentType(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='experiment_type_uuid')
    description = models.CharField(max_length=255,  db_column='description')

    class Meta:
        managed = False
        db_table = 'experiment_type'


class ExperimentWorkflow(DateColumns):
    # note: omitted much detail here because should be nested under
    # experiment, no need for redundancy.
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='experiment_workflow_uuid')
    experiment = models.ForeignKey('Experiment', db_column='experiment_uuid', on_delete=models.DO_NOTHING,
                                   blank=True, null=True, related_name='experiment_workflow_experiment')
    # experiment_ref_uid = models.CharField(max_length=255)
    # experiment_description = models.CharField(max_length=255)
    experiment_workflow_seq = models.IntegerField()
    workflow = models.ForeignKey('Workflow', db_column='workflow_uuid',
                                 on_delete=models.DO_NOTHING, blank=True, null=True, related_name='experiment_workflow_workflow')
    #workflow_type_uuid = models.ForeignKey('WorkflowType', db_column='workflow_type_uuid',
    #                                       on_delete=models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'experiment_workflow'


class Outcome(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='outcome_uuid')
    description = models.CharField(max_length=255,  db_column='description')
    experiment = models.ForeignKey('Experiment', db_column='experiment_uuid', on_delete=models.DO_NOTHING,
                                   blank=True, null=True, related_name='outcome_experiment')

    class Meta:
        managed = False
        db_table = 'outcome'


class Workflow(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='workflow_uuid')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description')
    parent = models.ForeignKey('Workflow', models.DO_NOTHING,
                               blank=True, null=True,
                               db_column='parent_uuid', related_name='workflow_parent')
    workflow_type = models.ForeignKey('WorkflowType', models.DO_NOTHING,
                                      blank=True, null=True,
                                      db_column='workflow_type_uuid', related_name='workflow_workflow_type')

    class Meta:
        managed = False
        db_table = 'workflow'

class WorkflowActionSet(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='workflow_action_set_uuid')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True)
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
    calculation = models.ForeignKey('Calculation', models.DO_NOTHING,
                               blank=True, null=True, 
                               db_column='calculation_uuid', 
                               related_name='workflow_action_set_calculation')
    source_material = ArrayField(RetUUIDField(blank=True, null=True), db_column='source_material_uuid')
    destination_material = ArrayField(RetUUIDField(blank=True, null=True), db_column='destination_material_uuid')

    class Meta:
        managed = False
        db_table = 'workflow_action_set'


class WorkflowType(DateColumns):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='workflow_type_uuid')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description')

    class Meta:
        managed = False
        db_table = 'workflow_type'


class WorkflowStep(DateColumns, StatusColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='workflow_step_uuid')
    workflow = models.ForeignKey('Workflow', models.DO_NOTHING,
                                 db_column='workflow_uuid',
                                 related_name='workflow_step_workflow')
    workflow_action_set = models.ForeignKey('WorkflowActionSet', models.DO_NOTHING,
                                 db_column='workflow_action_set_uuid',
                                 related_name='workflow_step_workflow_action_set')
    parent = models.ForeignKey('WorkflowStep', models.DO_NOTHING,
                               blank=True, null=True, 
                               db_column='parent_uuid', related_name='workflow_step_parent')
    parent_path = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   editable=False)
    workflow_object = models.ForeignKey('WorkflowObject', models.DO_NOTHING,
                                        db_column='workflow_object_uuid', related_name='workflow_step_workflow_object')

    class Meta:
        managed = False
        db_table = 'workflow_step'


class WorkflowObject(DateColumns, StatusColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='workflow_object_uuid')
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
    """
    object_uuid = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   editable=False)

    object_type = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   editable=False)
    object_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          editable=False)
    object_def_description = models.CharField(max_length=255,
                                              blank=True,
                                              null=True,
                                              editable=False)
    """
    class Meta:
        managed = False
        db_table = 'workflow_object'

