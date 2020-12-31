from django.db import models
from django.contrib.postgres.fields import ArrayField
from django.db.models.fields import CharField
from core.models.core_tables import RetUUIDField
from core.models.custom_types import ValField, CustomArrayField
#from django.db.models import Model, ForeignKey
from auto_prefetch import Model, ForeignKey

class Action(Model):
    uuid = RetUUIDField(primary_key=True,
                               db_column='action_uuid')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='action_description')
    action_def = ForeignKey('ActionDef',
                                   on_delete=models.DO_NOTHING,
                                   db_column='action_def_uuid',
                                   blank=True,
                                   null=True, related_name='action_action_def')
    workflow = ForeignKey('Workflow',
                                   on_delete=models.DO_NOTHING,
                                   db_column='workflow_uuid',
                                   blank=True,
                                   null=True, related_name='action_workflow')
    # pending exposition of workflow_action_set through api
    # workflow_action_set = ForeignKey('WorkflowActionSet',
    #                                         on_delete=models.DO_NOTHING,
    #                                         db_column='workflow_action_set_uuid',
    #                                         blank=True,
    #                                         null=True,
    #                                         )
    # workflow_action_set_description = models.CharField(max_length=255,
    #                                       blank=True,
    #                                       null=True,
    #                                       db_column='workflow_action_set_description',
    #                                       editable=False)
    source_material = ForeignKey('BomMaterial',
                               on_delete=models.DO_NOTHING,
                               db_column='source_material_uuid',
                               blank=True,
                               null=True,
                               editable=False,
                               related_name='action_source_material')
    source_material_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='source_material_description',
                                          editable=False)
    destination_material = ForeignKey('BomMaterial',
                               on_delete=models.DO_NOTHING,
                               db_column='destination_material_uuid',
                               blank=True,
                               null=True,
                               editable=False,
                               related_name='action_destination_material')
    destination_material_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='destination_material_description',
                                          editable=False)
    duration = models.FloatField(db_column='duration',
                                 blank=True,
                                 null=True)
    repeating = models.IntegerField(db_column='repeating',
                                    blank=True,
                                    null=True)
    # calculation_def and ref_parameter_uuid can be ignored in the django model
    # as they are no longer essential data model components
    # calculation_def = ForeignKey('CalculationDef',
    #                                     db_column='calculation_def_uuid',
    #                                     on_delete=models.DO_NOTHING,
    #                                     blank=True,
    #                                     null=True,
    #                                     editable=False,
    #                                     related_name='action_calculation_def'
    #                                     )
    actor = ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='action_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='actor_description',
                                         editable=False)
    status = ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True, related_name='action_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_action'

    def __str__(self):
        return "{}".format(self.description)


class ActionDef(Model):
    uuid = RetUUIDField(primary_key=True, db_column='action_def_uuid')
    parameter_def = models.ManyToManyField(
        'ParameterDef', through='ActionParameterDefAssign')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description',
                                   editable=False)
    actor = ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='action_def_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='actor_description',
                                         editable=False)
    status = ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='action_def_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.description}"

    class Meta:
        managed = False
        db_table = 'vw_action_def'


class ActionParameter(Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='parameter_uuid')
    action = ForeignKey('Action',
                               db_column='action_uuid',
                               on_delete=models.DO_NOTHING,
                               blank=True,
                               null=True,
                               editable=False,
                               related_name='parameter_action')
    parameter_def = ForeignKey('ParameterDef',
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
    parameter_val = ValField(max_length=255, blank=True,
                             null=True,
                             db_column='parameter_val')
    actor = ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='parameter_actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='action_parameter_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='parameter_actor_description',
                                         editable=False)
    status = ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='parameter_status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='action_parameter_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='parameter_status_description',
                                          editable=False)
    add_date = models.DateTimeField(
        auto_now_add=True, db_column='parameter_add_date')
    mod_date = models.DateTimeField(
        auto_now=True, db_column='parameter_mod_date')

    class Meta:
        managed = False
        db_table = 'vw_action_parameter'


class ActionParameterDef(Model):
    uuid = RetUUIDField(
        primary_key=True, db_column='action_parameter_def_x_uuid')
    action_def = ForeignKey('ActionDef',
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
    actor = ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='action_parameter_def_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='actor_description',
                                         editable=False)
    status = ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='action_parameter_def_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    parameter_def = ForeignKey('ParameterDef',
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
    parameter_val_type = ForeignKey('TypeDef',
                                           db_column='parameter_val_type_uuid',
                                           on_delete=models.DO_NOTHING,
                                           blank=True,
                                           null=True, related_name='action_parameter_def_parameter_val_type')

    class Meta:
        managed = False
        db_table = 'vw_action_parameter_def'
        

class ActionParameterDefAssign(Model):
    uuid = RetUUIDField(
        primary_key=True, db_column='action_parameter_def_x_uuid')
    parameter_def = ForeignKey('ParameterDef',
                                      on_delete=models.DO_NOTHING,
                                      blank=True,
                                      null=True,
                                      editable=False,
                                      db_column='parameter_def_uuid',
                                      related_name='action_parameter_def_assign_parameter_def')
    action_def = ForeignKey('ActionDef', on_delete=models.DO_NOTHING,
                                   blank=True,
                                   null=True,
                                   editable=False, db_column='action_def_uuid', related_name='action_parameter_def_assign_action_def')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_action_parameter_def_assign'


class BillOfMaterials(Model):
    uuid = RetUUIDField(primary_key=True, db_column='bom_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)
    experiment = ForeignKey('Experiment', on_delete=models.DO_NOTHING,
                                   blank=True, null=True, db_column='experiment_uuid',
                                   related_name='bom_experiment')
    experiment_description = models.CharField(
        max_length=255, blank=True, null=True)

    actor = ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='bom_actor')
    status = ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='bom_status')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_bom'


class BomMaterial(Model):
    uuid = RetUUIDField(primary_key=True, db_column='bom_material_index_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)
    bom = ForeignKey('BillOfMaterials', on_delete=models.DO_NOTHING,
                            blank=True, null=True, db_column='bom_uuid',
                            related_name='bom_material_bom')
    
    bom_description = models.CharField(max_length=255, blank=True, null=True)
    inventory_material = ForeignKey('InventoryMaterial', on_delete=models.DO_NOTHING,
                                           blank=True, null=True, db_column='inventory_material_uuid',
                                           related_name='bom_material_inventory_material')
    material = ForeignKey('Material', on_delete=models.DO_NOTHING,
                                 blank=True, null=True, db_column='material_uuid',
                                 related_name='bom_material_material')
    alloc_amt_val = ValField(max_length=255, blank=True, null=True)
    used_amt_val = ValField(max_length=255, blank=True, null=True)
    putback_amt_val = ValField(max_length=255, blank=True, null=True)
    actor = ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='bom_material_actor')
    status = ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='bom_material_status')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)
    
    class Meta:
        managed = False
        db_table = 'vw_bom_material'


class BomCompositeMaterial(Model):
    uuid = RetUUIDField(primary_key=True, db_column='bom_material_composite_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)
    bom_material = ForeignKey('BomMaterial', on_delete=models.DO_NOTHING,
                            blank=True, null=True, db_column='bom_material_uuid',
                            related_name='bom_composite_material_bom_material')
    bom_material_description = models.CharField(max_length=255, blank=True, null=True)
    
    composite_material = ForeignKey('CompositeMaterial', on_delete=models.DO_NOTHING,
                                               blank=True, null=True, db_column='material_composite_uuid',
                                               related_name='bom_composite_material_composite_material')
    component = ForeignKey('Material', on_delete=models.DO_NOTHING,
                                               blank=True, null=True, db_column='component_uuid',
                                               related_name='bom_composite_material_component')
    material_description = models.CharField(max_length=255,
                                                          blank=True,
                                                          null=True)
    actor = ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='bom_composite_material_actor')
    status = ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='bom_composite_material_status')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_bom_material_composite'


class Condition(Model):
    # todo: link to condition calculation
    uuid = RetUUIDField(primary_key=True, db_column='condition_uuid')
    condition_calculation = ForeignKey('ConditionCalculationDefAssign', 
                                              models.DO_NOTHING, 
                                              db_column='condition_calculation_def_x_uuid',
                                              related_name='condition_condition_calculation')
    condition_description = models.CharField(max_length=255,
                                             blank=True,
                                             null=True,
                                             editable=False)
    condition_def = ForeignKey('ConditionDef', models.DO_NOTHING,
                                      db_column='condition_def_uuid', related_name='condition_condition_def')
    calculation_description = models.CharField(max_length=255,
                                               blank=True,
                                               null=True,
                                               editable=False)
    
    # TODO: Fix in_val and out_val on Postgres to return strings not JSON!
    in_val = ValField(max_length=255, blank=True, null=True)
    out_val = ValField(max_length=255, blank=True, null=True)
    actor = ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='condition_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='actor_description',
                                         editable=False)
    status = ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='condition_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_condition'


class ConditionDef(Model):
    uuid = RetUUIDField(
        primary_key=True, db_column='condition_def_uuid')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description',
                                   editable=False)
    calculation_def = models.ManyToManyField('CalculationDef', through='ConditionCalculationDefAssign')
    actor = ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='condition_def_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='actor_description',
                                         editable=False)
    status = ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='condition_def_status')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_condition_def'


class ConditionCalculationDefAssign(Model):
    uuid = RetUUIDField(
        primary_key=True, db_column='condition_calculation_def_x_uuid')
    condition_def = ForeignKey('ConditionDef',
                              on_delete=models.DO_NOTHING,
                              db_column='condition_def_uuid',
                              blank=True,
                              null=True,
                              related_name='condition_calculation_def_assign_condition_def')
    calculation_def = ForeignKey('CalculationDef',
                              on_delete=models.DO_NOTHING,
                              db_column='calculation_def_uuid',
                              blank=True,
                              null=True,
                              related_name='condition_calculation_def_assign_calculation_def')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_condition_calculation_def_assign'


class ConditionPath(Model):
    uuid = RetUUIDField(
        primary_key=True, db_column='condition_path_uuid')
    condition = ForeignKey('Condition',
                              on_delete=models.DO_NOTHING,
                              db_column='condition_uuid',
                              blank=True,
                              null=True,
                              related_name='condition_path_condition')
    condition_out_val = ValField(max_length=255, blank=True, null=True)
    workflow_step = ForeignKey('WorkflowStep',
                              on_delete=models.DO_NOTHING,
                              db_column='workflow_uuid',
                              blank=True,
                              null=True,
                              related_name='condition_path_workflow_step')
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_condition_path'


class Experiment(Model):
    uuid = RetUUIDField(primary_key=True, db_column='experiment_uuid')
    ref_uid = models.CharField(max_length=255, db_column='ref_uid')
    description = models.CharField(max_length=255,  db_column='description')
    parent = ForeignKey('TypeDef', db_column='parent_uuid',
                               on_delete=models.DO_NOTHING, blank=True, null=True, related_name='experiment_parent')
    owner = ForeignKey('Actor', db_column='owner_uuid', on_delete=models.DO_NOTHING, blank=True, null=True,
                              related_name='experiment_owner')
    workflow = models.ManyToManyField('Workflow', through='ExperimentWorkflow', related_name='experiment_workflow')
    owner_description = models.CharField(
        max_length=255, db_column='owner_description')
    operator = ForeignKey('Actor', db_column='operator_uuid', on_delete=models.DO_NOTHING, blank=True, null=True,
                                 related_name='experiment_operator')
    operator_description = models.CharField(
        max_length=255, db_column='operator_description')
    lab = ForeignKey('Actor', db_column='lab_uuid', on_delete=models.DO_NOTHING, blank=True, null=True,
                            related_name='experiment_lab')
    lab_description = models.CharField(
        max_length=255, db_column='lab_description')
    status = ForeignKey(
        'Status', on_delete=models.DO_NOTHING, db_column='status_uuid', blank=True, null=True, related_name='experiment_status')
    status_description = models.CharField(
        max_length=255, blank=True, null=True, db_column='status_description', editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_experiment'





class ExperimentWorkflow(Model):
    # note: omitted much detail here because should be nested under
    # experiment, no need for redundancy.
    uuid = RetUUIDField(primary_key=True, db_column='experiment_workflow_uuid')
    experiment = ForeignKey('Experiment', db_column='experiment_uuid', on_delete=models.DO_NOTHING,
                                   blank=True, null=True, related_name='experiment_workflow_experiment')
    experiment_ref_uid = models.CharField(max_length=255)
    experiment_description = models.CharField(max_length=255)
    experiment_workflow_seq = models.IntegerField()
    workflow = ForeignKey('Workflow', db_column='workflow_uuid',
                                 on_delete=models.DO_NOTHING, blank=True, null=True, related_name='experiment_workflow_workflow')
    workflow_type_uuid = ForeignKey('WorkflowType', db_column='workflow_type_uuid',
                                           on_delete=models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_experiment_workflow'


class Outcome(Model):
    uuid = RetUUIDField(primary_key=True, db_column='outcome_uuid')
    description = models.CharField(max_length=255,  db_column='description')
    experiment = ForeignKey('Experiment', db_column='experiment_uuid', on_delete=models.DO_NOTHING,
                                   blank=True, null=True, related_name='outcome_experiment')
    actor = ForeignKey(
        'Actor', models.DO_NOTHING, db_column='actor_uuid', blank=True, null=True, related_name='outcome_actor')
    actor_description = models.CharField(
        max_length=255, blank=True, null=True, editable=False)
    status = ForeignKey(
        'Status', models.DO_NOTHING, db_column='status_uuid', blank=True, null=True, related_name='outcome_status')
    status_description = models.CharField(
        max_length=255, blank=True, null=True, editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_outcome'


class Workflow(Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='workflow_uuid')
    #step = models.ManyToManyField(
    #    'WorkflowStep', through='WorkflowStep', related_name='workflow_step')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description')
    parent = ForeignKey('Workflow', models.DO_NOTHING,
                               blank=True, null=True,
                               db_column='parent_uuid', related_name='workflow_parent')
    workflow_type = ForeignKey('WorkflowType', models.DO_NOTHING,
                                      blank=True, null=True,
                                      db_column='workflow_type_uuid', related_name='workflow_workflow_type')
    workflow_type_description = models.CharField(max_length=255,
                                                 blank=True,
                                                 null=True,
                                                 editable=False)
    actor = ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              related_name='workflow_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='actor_description',
                                         editable=False)
    status = ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               related_name='workflow_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True, db_column='add_date')
    mod_date = models.DateTimeField(auto_now=True, db_column='mod_date')

    class Meta:
        managed = False
        db_table = 'vw_workflow'


class WorkflowActionSet(Model):
    uuid = RetUUIDField(primary_key=True, db_column='workflow_action_set_uuid')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True)
    workflow = ForeignKey('Workflow', models.DO_NOTHING,
                               blank=True, null=True, 
                               db_column='workflow_uuid', 
                               related_name='workflow_action_set_workflow')
    action_def = ForeignKey('ActionDef', models.DO_NOTHING,
                               blank=True, null=True, 
                               db_column='action_def_uuid', 
                               related_name='workflow_action_set_action_def')
    start_date = models.DateTimeField()
    end_date = models.DateTimeField()
    duration = models.FloatField()
    repeating = models.BigIntegerField()
    parameter_def = ForeignKey('ParameterDef', models.DO_NOTHING,
                               blank=True, null=True,
                               db_column='parameter_def_uuid',
                               related_name='workflow_action_set_parameter_def')
    # parameter_val = ArrayField(ValField(), blank=True, null=True)
    parameter_val = CustomArrayField(ValField(), blank=True, null=True)
    # parameter_val = ValField(blank=True, null=True, list=True)
    calculation = ForeignKey('Calculation', models.DO_NOTHING,
                               blank=True, null=True, 
                               db_column='calculation_uuid', 
                               related_name='workflow_action_set_calculation')
    source_material = ArrayField(RetUUIDField(blank=True, null=True), db_column='source_material_uuid')
    destination_material = ArrayField(RetUUIDField(blank=True, null=True), db_column='destination_material_uuid')
    actor = ForeignKey('Actor',
                               on_delete=models.DO_NOTHING,
                               db_column='actor_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='workflow_action_set_actor')
    status = ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='workflow_action_set_status')
    add_date = models.DateTimeField(auto_now_add=True, db_column='add_date')
    mod_date = models.DateTimeField(auto_now=True, db_column='mod_date')

    class Meta:
        managed = False
        db_table = 'vw_workflow_action_set'


class WorkflowType(Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='workflow_type_uuid')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description',
                                   editable=False)
    add_date = models.DateTimeField(auto_now_add=True, db_column='add_date')
    mod_date = models.DateTimeField(auto_now=True, db_column='mod_date')

    class Meta:
        managed = False
        db_table = 'vw_workflow_type'


class WorkflowStep(Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='workflow_step_uuid')
    workflow = ForeignKey('Workflow', models.DO_NOTHING,
                                 db_column='workflow_uuid',
                                 related_name='workflow_step_workflow')
    workflow_description = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            editable=False)
    parent = ForeignKey('WorkflowStep', models.DO_NOTHING,
                               blank=True, null=True, 
                               db_column='parent_uuid', related_name='workflow_step_parent')
    parent_object_type = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          editable=False)
    parent_object_description = models.CharField(max_length=255,
                                                 blank=True,
                                                 null=True,
                                                 editable=False)
    parent_path = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   editable=False)
    conditional_val = ValField(max_length=255, blank=True,
                               null=True)
    conditional_value = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         editable=False)
    status = ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               related_name='workflow_step_status')
    status_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='status_description',
                                          editable=False)
    add_date = models.DateTimeField(auto_now_add=True, db_column='add_date')
    mod_date = models.DateTimeField(auto_now=True, db_column='mod_date')

    workflow_object = ForeignKey('WorkflowObject', models.DO_NOTHING,
                                        db_column='workflow_object_uuid', related_name='workflow_step_workflow_object')
    # unclear how to make this an fk for django...
    """
    object_uuid = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='object_uuid',
                                   editable=False)
    object_type = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='object_type',
                                   editable=False)
    object_description = models.CharField(max_length=255,
                                          blank=True,
                                          null=True,
                                          db_column='object_description',
                                          editable=False)
    object_def_description = models.CharField(max_length=255,
                                              blank=True,
                                              null=True,
                                              db_column='object_def_description',
                                              editable=False)
    """

    class Meta:
        managed = False
        db_table = 'vw_workflow_step'


class WorkflowObject(Model):
    uuid = RetUUIDField(primary_key=True, db_column='workflow_object_uuid')
    workflow = ForeignKey('Workflow', models.DO_NOTHING,
                               blank=True, null=True, 
                               db_column='workflow_uuid', related_name='workflow_object_workflow')
    action = ForeignKey('Action', models.DO_NOTHING,
                               blank=True, null=True, 
                               db_column='action_uuid', related_name='workflow_object_action')
    condition = ForeignKey('Condition', models.DO_NOTHING,
                                  blank=True, null=True, 
                                  db_column='condition_uuid', related_name='workflow_object_condition')
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
    add_date = models.DateTimeField(auto_now_add=True, db_column='add_date')
    mod_date = models.DateTimeField(auto_now=True, db_column='mod_date')

    class Meta:
        managed = False
        db_table = 'vw_workflow_object'

