from django.db import models
from django.contrib.postgres.fields import ArrayField
from core.models.core_tables import RetUUIDField
from core.models.custom_types import ValField, CustomArrayField

"""
related_exp = 'workflow__experiment_workflow_workflow__experiment'
related_exp_wf = 'workflow__experiment_workflow_workflow'
q1 = ActionParameter.objects.only('workflow').annotate(
                object_description=F('action__description')).annotate( 
                object_uuid=F('action__uuid')).annotate(
                parameter_uuid=F('parameter__uuid')).annotate(
                parameter_value=F('parameter_val')).annotate(
                experiment_uuid=F(f'{related_exp}__uuid')).annotate(
                workflow_seq=F(f'{related_exp_wf}__experiment_workflow_seq'
                )).filter(workflow_action_set__isnull=True).select_related(
                    'workflow').prefetch_related(f'{related_exp}')

q2 = WorkflowActionSet.objects.filter(parameter_val__isnull=False).only(
                    'workflow').annotate(
                    object_description=F('description')).annotate(
                    object_uuid=F('uuid')).annotate(
                    parameter_uuid=Value(None, RetUUIDField())).annotate(
                    parameter_value=F('parameter_val')).annotate(
                    experiment_uuid=F(f'{related_exp}__uuid')).annotate(
                    workflow_seq=F(f'{related_exp_wf}__experiment_workflow_seq')
                    ).prefetch_related(f'{related_exp}')


q3 = WorkflowActionSet.objects.filter(calculation__isnull=False).only(
                    'workflow').select_related(
    'calculation', 'calculation__calculation_def').annotate(
                    object_description=F('description')).annotate(
                    object_uuid=F('uuid')).annotate(
                    parameter_uuid=F('calculation__calculation_def__parameter_def__uuid')).annotate(
                    parameter_value=F('calculation__calculation_def__parameter_def__default_val')).annotate(
                    experiment_uuid=F(f'{related_exp}__uuid')).annotate(
                    workflow_seq=F(f'{related_exp_wf}__experiment_workflow_seq').prefetch_related('workflow__experiment_workflow_workflow__experiment')
"""
#q1 = ActionParameter.objects.only('action', 'parameter', 'workflow').filter(workflow_action_set__isnull=True).select_related('workflow').prefetch_related('workflow__experiment_workflow_workflow__experiment')
#q2 = WorkflowActionSet.objects.filter(parameter_val__isnull=False).prefetch_related('workflow__experiment_workflow_workflow__experiment')
#q3 = WorkflowActionSet.objects.filter(calculation__isnull=False).select_related('calculation', 'calculation__calculation_def').prefetch_related('calculation__calculation_def__calculation_parameter_def_assign_calculation_def__parameter_def').prefetch_related('workflow__experiment_workflow_workflow__experiment')

class Action(models.Model):
    uuid = RetUUIDField(primary_key=True,
                               db_column='action_uuid')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='action_description')
    action_def = models.ForeignKey('ActionDef',
                                   on_delete=models.DO_NOTHING,
                                   db_column='action_def_uuid',
                                   blank=True,
                                   null=True, related_name='action_action_def')
    action_def_description = models.CharField(max_length=255,
                                              blank=True,
                                              null=True,
                                              editable=False)
    workflow = models.ForeignKey('Workflow',
                                   on_delete=models.DO_NOTHING,
                                   db_column='workflow_uuid',
                                   blank=True,
                                   null=True, related_name='action_workflow')
    # pending exposition of workflow_action_set through api
    # workflow_action_set = models.ForeignKey('WorkflowActionSet',
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
    source_material = models.ForeignKey('BomMaterial',
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
    destination_material = models.ForeignKey('BomMaterial',
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
    # calculation_def = models.ForeignKey('CalculationDef',
    #                                     db_column='calculation_def_uuid',
    #                                     on_delete=models.DO_NOTHING,
    #                                     blank=True,
    #                                     null=True,
    #                                     editable=False,
    #                                     related_name='action_calculation_def'
    #                                     )
    actor = models.ForeignKey('Actor',
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
    status = models.ForeignKey('Status',
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


class ActionDef(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='action_def_uuid')
    parameter_def = models.ManyToManyField(
        'ParameterDef', through='ActionParameterDefAssign')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description',
                                   )
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              related_name='action_def_actor')
    actor_description = models.CharField(max_length=255,
                                         blank=True,
                                         null=True,
                                         db_column='actor_description',
                                         editable=False)
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               related_name='action_def_status')
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


class ActionParameter(models.Model):
    uuid = RetUUIDField(primary_key=True,
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
    parameter_val = ValField(max_length=255, blank=True,
                             null=True,
                             db_column='parameter_val')
    actor = models.ForeignKey('Actor',
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
    status = models.ForeignKey('Status',
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


class ActionParameterDef(models.Model):
    uuid = RetUUIDField(
        primary_key=True, db_column='action_parameter_def_x_uuid')
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
    actor = models.ForeignKey('Actor',
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
    status = models.ForeignKey('Status',
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
        db_table = 'vw_action_parameter_def'
        

class ActionParameterDefAssign(models.Model):
    uuid = RetUUIDField(
        primary_key=True, db_column='action_parameter_def_x_uuid')
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
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_action_parameter_def_assign'


class BillOfMaterials(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='bom_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)
    experiment = models.ForeignKey('Experiment', on_delete=models.DO_NOTHING,
                                   blank=True, null=True, db_column='experiment_uuid',
                                   related_name='bom_experiment')
    experiment_description = models.CharField(
        max_length=255, blank=True, null=True)

    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='bom_actor')
    status = models.ForeignKey('Status',
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


class BomMaterial(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='bom_material_index_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)
    bom = models.ForeignKey('BillOfMaterials', on_delete=models.DO_NOTHING,
                            blank=True, null=True, db_column='bom_uuid',
                            related_name='bom_material_bom')
    
    bom_description = models.CharField(max_length=255, blank=True, null=True)
    inventory_material = models.ForeignKey('InventoryMaterial', on_delete=models.DO_NOTHING,
                                           blank=True, null=True, db_column='inventory_material_uuid',
                                           related_name='bom_material_inventory_material')
    material = models.ForeignKey('Material', on_delete=models.DO_NOTHING,
                                 blank=True, null=True, db_column='material_uuid',
                                 related_name='bom_material_material')
    alloc_amt_val = ValField(max_length=255, blank=True, null=True)
    used_amt_val = ValField(max_length=255, blank=True, null=True)
    putback_amt_val = ValField(max_length=255, blank=True, null=True)
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='bom_material_actor')
    status = models.ForeignKey('Status',
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

    def __str__(self):
        return self.bom_description


class BomCompositeMaterial(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='bom_material_composite_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)
    bom_material = models.ForeignKey('BomMaterial', on_delete=models.DO_NOTHING,
                            blank=True, null=True, db_column='bom_material_uuid',
                            related_name='bom_composite_material_bom_material')
    bom_material_description = models.CharField(max_length=255, blank=True, null=True)
    
    composite_material = models.ForeignKey('CompositeMaterial', on_delete=models.DO_NOTHING,
                                               blank=True, null=True, db_column='material_composite_uuid',
                                               related_name='bom_composite_material_composite_material')
    component = models.ForeignKey('Material', on_delete=models.DO_NOTHING,
                                               blank=True, null=True, db_column='component_uuid',
                                               related_name='bom_composite_material_component')
    material_description = models.CharField(max_length=255,
                                                          blank=True,
                                                          null=True)
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              editable=False, related_name='bom_composite_material_actor')
    status = models.ForeignKey('Status',
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


class Condition(models.Model):
    # todo: link to condition calculation
    uuid = RetUUIDField(primary_key=True, db_column='condition_uuid')
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
    actor = models.ForeignKey('Actor',
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
    status = models.ForeignKey('Status',
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


class ConditionDef(models.Model):
    uuid = RetUUIDField(
        primary_key=True, db_column='condition_def_uuid')
    description = models.CharField(max_length=255,
                                   blank=True,
                                   null=True,
                                   db_column='description',
                                   editable=False)
    calculation_def = models.ManyToManyField('CalculationDef', through='ConditionCalculationDefAssign')
    actor = models.ForeignKey('Actor',
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
    status = models.ForeignKey('Status',
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


class ConditionCalculationDefAssign(models.Model):
    uuid = RetUUIDField(
        primary_key=True, db_column='condition_calculation_def_x_uuid')
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
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_condition_calculation_def_assign'


class ConditionPath(models.Model):
    uuid = RetUUIDField(
        primary_key=True, db_column='condition_path_uuid')
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
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_condition_path'


class Experiment(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='experiment_uuid')
    ref_uid = models.CharField(max_length=255, db_column='ref_uid')
    description = models.CharField(max_length=255,  db_column='description')
    parent = models.ForeignKey('TypeDef', db_column='parent_uuid',
                               on_delete=models.DO_NOTHING, blank=True, null=True, related_name='experiment_parent')
    owner = models.ForeignKey('Actor', db_column='owner_uuid', on_delete=models.DO_NOTHING, blank=True, null=True,
                              related_name='experiment_owner')
    workflow = models.ManyToManyField('Workflow', through='ExperimentWorkflow', related_name='experiment_workflow')
    owner_description = models.CharField(
        max_length=255, db_column='owner_description')
    operator = models.ForeignKey('Actor', db_column='operator_uuid', on_delete=models.DO_NOTHING, blank=True, null=True,
                                 related_name='experiment_operator')
    operator_description = models.CharField(
        max_length=255, db_column='operator_description')
    lab = models.ForeignKey('Actor', db_column='lab_uuid', on_delete=models.DO_NOTHING, blank=True, null=True,
                            related_name='experiment_lab')
    lab_description = models.CharField(
        max_length=255, db_column='lab_description')
    status = models.ForeignKey(
        'Status', on_delete=models.DO_NOTHING, db_column='status_uuid', blank=True, null=True, related_name='experiment_status')
    status_description = models.CharField(
        max_length=255, blank=True, null=True, db_column='status_description', editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f'{self.description}'

    class Meta:
        managed = False
        db_table = 'vw_experiment'


class ExperimentParameter(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='parameter_uuid')
    parameter_value = CustomArrayField(ValField(), blank=True, null=True)
    parameter_def_description = models.CharField(
        max_length=255, db_column='parameter_def_description', editable=False)
    object = models.ForeignKey('WorkflowObject', on_delete=models.DO_NOTHING, 
                                db_column='object_uuid', blank=True, null=True, 
                                related_name='experiment_parameter_object',
                                editable=False)
    object_description = models.CharField(blank=True, null=True,
        max_length=255, db_column='object_description', editable=False)
    workflow_object = models.CharField(blank=True, null=True,
        max_length=255, db_column='workflow_object', editable=False)
    workflow_seq = models.IntegerField(blank=True, null=True)
    workflow_description = models.CharField(blank=True, null=True,
        max_length=255, db_column='workflow', editable=False)
    experiment_description = models.CharField(blank=True, null=True,
        max_length=255, db_column='experiment', editable=False)
    experiment = models.ForeignKey('Experiment', on_delete=models.DO_NOTHING, 
                                db_column='experiment_uuid', blank=True, null=True, 
                                related_name='experiment_parameter_experiment',
                                editable=False)
    class Meta:
        managed = False
        db_table = 'vw_experiment_parameter'


class ExperimentWorkflow(models.Model):
    # note: omitted much detail here because should be nested under
    # experiment, no need for redundancy.
    uuid = RetUUIDField(primary_key=True, db_column='experiment_workflow_uuid')
    experiment = models.ForeignKey('Experiment', db_column='experiment_uuid', on_delete=models.DO_NOTHING,
                                   blank=True, null=True, related_name='experiment_workflow_experiment')
    experiment_ref_uid = models.CharField(max_length=255)
    experiment_description = models.CharField(max_length=255)
    experiment_workflow_seq = models.IntegerField()
    workflow = models.ForeignKey('Workflow', db_column='workflow_uuid',
                                 on_delete=models.DO_NOTHING, blank=True, null=True, related_name='experiment_workflow_workflow')
    workflow_type_uuid = models.ForeignKey('WorkflowType', db_column='workflow_type_uuid',
                                           on_delete=models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_experiment_workflow'


class Outcome(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='outcome_uuid')
    description = models.CharField(max_length=255,  db_column='description')
    experiment = models.ForeignKey('Experiment', db_column='experiment_uuid', on_delete=models.DO_NOTHING,
                                   blank=True, null=True, related_name='outcome_experiment')
    actor = models.ForeignKey(
        'Actor', models.DO_NOTHING, db_column='actor_uuid', blank=True, null=True, related_name='outcome_actor')
    actor_description = models.CharField(
        max_length=255, blank=True, null=True, editable=False)
    status = models.ForeignKey(
        'Status', models.DO_NOTHING, db_column='status_uuid', blank=True, null=True, related_name='outcome_status')
    status_description = models.CharField(
        max_length=255, blank=True, null=True, editable=False)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_outcome'


class Workflow(models.Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='workflow_uuid')
    #step = models.ManyToManyField(
    #    'WorkflowStep', through='WorkflowStep', related_name='workflow_step')
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
    workflow_type_description = models.CharField(max_length=255,
                                                 blank=True,
                                                 null=True,
                                                 editable=False)
    actor = models.ForeignKey('Actor',
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
    status = models.ForeignKey('Status',
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


class WorkflowActionSet(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='workflow_action_set_uuid')
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
    # parameter_val = ArrayField(ValField(), blank=True, null=True)
    parameter_val = CustomArrayField(ValField(), blank=True, null=True)
    # parameter_val = ValField(blank=True, null=True, list=True)
    calculation = models.ForeignKey('Calculation', models.DO_NOTHING,
                               blank=True, null=True, 
                               db_column='calculation_uuid', 
                               related_name='workflow_action_set_calculation')
    source_material = ArrayField(RetUUIDField(blank=True, null=True), db_column='source_material_uuid')
    destination_material = ArrayField(RetUUIDField(blank=True, null=True), db_column='destination_material_uuid')
    actor = models.ForeignKey('Actor',
                               on_delete=models.DO_NOTHING,
                               db_column='actor_uuid',
                               blank=True,
                               null=True,
                               editable=False, related_name='workflow_action_set_actor')
    status = models.ForeignKey('Status',
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


class WorkflowType(models.Model):
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


class WorkflowStep(models.Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='workflow_step_uuid')
    workflow = models.ForeignKey('Workflow', models.DO_NOTHING,
                                 db_column='workflow_uuid',
                                 related_name='workflow_step_workflow')
    workflow_description = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            editable=False)
    parent = models.ForeignKey('WorkflowStep', models.DO_NOTHING,
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
    status = models.ForeignKey('Status',
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

    workflow_object = models.ForeignKey('WorkflowObject', models.DO_NOTHING,
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


class WorkflowObject(models.Model):
    uuid = RetUUIDField(primary_key=True, db_column='workflow_object_uuid')
    workflow = models.ForeignKey('Workflow', models.DO_NOTHING,
                               blank=True, null=True, 
                               db_column='workflow_uuid', related_name='workflow_object_workflow')
    action = models.ForeignKey('Action', models.DO_NOTHING,
                               blank=True, null=True, 
                               db_column='action_uuid', related_name='workflow_object_action')
    condition = models.ForeignKey('Condition', models.DO_NOTHING,
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

