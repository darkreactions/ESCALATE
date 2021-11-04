

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
        managed = managed_tables
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
        managed = managed_tables
        db_table = 'action_parameter_def_x'

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
        managed = managed_tables
        db_table = 'bom_material_index'


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
        managed = managed_tables
        #db_table = 'vw_condition_calculation_def_assign'
        db_table = 'condition_calculation_def_x'






class CalculationParameterDefAssign(DateColumns):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='calculation_parameter_def_x_uuid')
    parameter_def = models.ForeignKey('ParameterDef',
                                          on_delete=models.DO_NOTHING,
                                          db_column='parameter_def_uuid',
                                          blank=True,
                                          null=True,
                                          related_name='calculation_parameter_def_assign_parameter_def')
    calculation_def = models.ForeignKey('CalculationDef',
                                          on_delete=models.DO_NOTHING,
                                          db_column='calculation_def_uuid',
                                          blank=True,
                                          null=True,
                                          related_name='calculation_parameter_def_assign_calculation_def')

    class Meta:
        managed = managed_views
        db_table = 'vw_calculation_parameter_def_assign'




class ParameterX(DateColumns):
    uuid =RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='parameter_x_uuid')
    #parameter_uuid = RetUUIDField(db_column='parameter_uuid')
    parameter_ref_uuid = RetUUIDField(db_column='ref_parameter_uuid')
    parameter = models.ForeignKey('Parameter', on_delete=models.DO_NOTHING,
                                blank=True,
                                null=True,
                                related_name='parameter_x_parameter')
    
    class Meta:
        managed = managed_tables
        db_table = 'parameter_x'


"""
class PropertyX(DateColumns):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='property_x_uuid')
    material_uuid = models.ForeignKey('Property',
                                 db_column='material_uuid',
                                 on_delete=models.DO_NOTHING,
                                 blank=True,
                                 null=True, related_name='property_x_material_uuid')
    property_uuid = models.ForeignKey('Property',
                                 db_column='property_uuid',
                                 on_delete=models.DO_NOTHING,
                                 blank=True,
                                 null=True, related_name='property_x_property_uuid')
    
    class Meta:
        managed = managed_tables
        db_table = 'property_x'

    def __str__(self):
        return "{}".format(self.uuid)
"""

"""
class CompositeMaterialProperty(DateColumns):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='material_composite_uuid')
    composite_material = models.ForeignKey('CompositeMaterial',
                                           db_column='composite_uuid',
                                           on_delete=models.DO_NOTHING,
                                           blank=True, null=True,
                                           related_name='composite_material_property_composite_material')
    composite_class = models.CharField(max_length=64, choices=MATERIAL_CLASS_CHOICES, editable=False)
    composite_material_description = models.CharField(max_length=255,
                                                      blank=True,
                                                      null=True,
                                                      db_column='composite_description',
                                                      editable=False)
    component = models.ForeignKey('CompositeMaterial',
                                  db_column='component_uuid',
                                  on_delete=models.DO_NOTHING,
                                  blank=True, null=True,
                                  related_name='composite_material_property_component')
    component_class = models.CharField(max_length=64, choices=MATERIAL_CLASS_CHOICES, editable=False)
    property = models.ForeignKey('Property',
                                 on_delete=models.DO_NOTHING,
                                 db_column='property_uuid',
                                 blank=True,
                                 null=True,
                                 editable=False,
                                 related_name='composite_material_property_property')
    property_class = models.CharField(max_length=64, choices=PROPERTY_CLASS_CHOICES)
    property_def = models.ForeignKey('PropertyDef',
                                     on_delete=models.DO_NOTHING,
                                     db_column='property_def_uuid',
                                     blank=True,
                                     null=True, related_name='composite_material_property_property_def')
    property_def_class = models.CharField(max_length=64, choices=PROPERTY_DEF_CLASS_CHOICES, editable=False)
    property_description = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            db_column='property_description',
                                            editable=False)
    property_short_description = models.CharField(max_length=255,
                                                  blank=True,
                                                  null=True,
                                                  db_column='property_short_description',
                                                  editable=False)
    value = ValField(
        blank=True,
        null=True,
        db_column='property_value_val')

    class Meta:
        managed = manage_views
        db_table = 'vw_material_composite_property'
"""

"""
class InventoryMaterialMaterial(models.Model):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='inventory_material_uuid')
    inventory = models.ForeignKey('Inventory',
                                    db_column='inventory_uuid',
                                    on_delete=models.DO_NOTHING,
                                    blank=True, null=True,
                                    related_name='inventory_material_material_inventory')
    actor = models.ForeignKey('Actor',
                                    db_column='actor_uuid',
                                    on_delete=models.DO_NOTHING,
                                    blank=True, null=True,
                                    related_name='inventory_material_material_actor')
    material =  models.ForeignKey('Material',
                                    db_column='material_uuid',
                                    on_delete=models.DO_NOTHING,
                                    blank=True, null=True,
                                    related_name='inventory_material_material_material')
    
    class Meta:
        managed = False
        db_table = 'vw_inventory_material_material'
"""

"""
class PropertyX(DateColumns):
    property = RetUUIDField(primary_key=True,
                        db_column='property_x_uuid')
    material = models.ForeignKey('Material',
                                 db_column='material_uuid',
                                 on_delete=models.DO_NOTHING,
                                 blank=True,
                                 null=True, related_name='property_x_material')
    property = models.ForeignKey('Property',
                                 on_delete=models.DO_NOTHING,
                                 db_column='property_uuid',
                                 blank=True,
                                 null=True,
                                 editable=False,
                                 related_name='property_x_property')

    class Meta:
        managed = manage_tables
        db_table = 'property_x'


class MaterialProperty(models.Model):
    # TODO: Material property may need fixing. Endpoint displays all tags for all rows
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='property_x_uuid')
    material = models.ForeignKey('Material',
                                 db_column='material_uuid',
                                 on_delete=models.DO_NOTHING,
                                 blank=True,
                                 null=True, related_name='material_property_material')
    material_class = models.CharField(max_length=64, choices=MATERIAL_CLASS_CHOICES, editable=False)
    description = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            db_column='description',
                                            editable=False)
    property = models.ForeignKey('Property',
                                 on_delete=models.DO_NOTHING,
                                 db_column='property_uuid',
                                 blank=True,
                                 null=True,
                                 editable=False,
                                 related_name='material_property_property')
    property_def = models.ForeignKey('PropertyDef',
                                     on_delete=models.DO_NOTHING,
                                     db_column='property_def_uuid',
                                     blank=True,
                                     null=True, related_name='material_property_property_def')
    property_description = models.CharField(max_length=255,
                                            blank=True,
                                            null=True,
                                            db_column='property_description',
                                            editable=False)
    property_short_description = models.CharField(max_length=255,
                                                  blank=True,
                                                  null=True,
                                                  db_column='property_short_description',
                                                  editable=False)
    value = ValField( blank=True, null=True, db_column='property_value_val')

    class Meta:
        managed = manage_views
        db_table = 'vw_material_property'


class MaterialIdentifierX(models.Model):
    uuid = RetUUIDField(
        primary_key=True, db_column='material_refname_x_uuid')
    material = models.ForeignKey('Material',
                               on_delete=models.DO_NOTHING,
                               blank=True,
                               null=True,
                               db_column='material_uuid',
                               related_name='material_refname_x_material')
    identifier = models.ForeignKey('MaterialIdentifier',
                               on_delete=models.DO_NOTHING,
                               blank=True,
                               null=True,
                               db_column='material_refname_uuid',
                               related_name='material_identifier_x_material')
    class Meta:
        managed = manage_tables
        db_table = 'material_refname_x'
"""

    #abbreviation = models.CharField(max_length=255, blank=True, null=True)
    #chemical_name = models.CharField(max_length=255, blank=True, null=True)
    #inchi = models.CharField(max_length=255, blank=True, null=True)
    #inchikey = models.CharField(max_length=255, blank=True, null=True)
    #molecular_formula = models.CharField(max_length=255, blank=True, null=True)
    #smiles = models.CharField(max_length=255, blank=True, null=True)

"""
class MaterialTypeX(DateColumns):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='material_type_x_uuid')
    material = models.ForeignKey('Material',
                               on_delete=models.DO_NOTHING,
                               blank=True,
                               null=True,
                               db_column='material_uuid',
                               related_name='material_type_x_material')
    material_type = models.ForeignKey('MaterialType',
                               on_delete=models.DO_NOTHING,
                               blank=True,
                               null=True,
                               db_column='material_type_uuid',
                               related_name='material_type_x_material_type')

    class Meta:
        managed = manage_tables
        db_table = 'material_type_x'
"""

class MaterialTypeAssign(DateColumns):
    uuid = RetUUIDField(
        primary_key=True, db_column='material_type_x_uuid')
    material = models.ForeignKey('Material',
                               on_delete=models.DO_NOTHING,
                               blank=True,
                               null=True,
                               db_column='material_uuid',
                               related_name='material_type_assign_material')
    material_type = models.ForeignKey('MaterialType',
                               on_delete=models.DO_NOTHING,
                               blank=True,
                               null=True,
                               db_column='material_type_uuid',
                               related_name='material_type_assign')

    class Meta:
        managed = manage_views
        db_table = 'vw_material_type_assign'

class BomCompositeMaterial(DateColumns, StatusColumn, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='bom_material_composite_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)
    # bom_material_description = models.CharField(max_length=255, blank=True, null=True)
    #component = models.ForeignKey('Material', on_delete=models.DO_NOTHING,
    #                                           blank=True, null=True, db_column='component_uuid',
    #                                           related_name='bom_composite_material_component')
    #material_description = models.CharField(max_length=255,
    #                                                      blank=True,
    #                                                      null=True)

    class Meta:
        managed = managed_tables
        db_table = 'bom_material_composite'


class Condition(DateColumns, StatusColumn, ActorColumn):
    # todo: link to condition calculation
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='condition_uuid')
    """
    condition_calculation = models.ForeignKey('ConditionCalculationDefAssign', 
                                              models.CASCADE, 
                                              db_column='condition_calculation_def_x_uuid',
                                              related_name='condition_condition_calculation')
    """
    condition_description = models.CharField(max_length=255,
                                             blank=True,
                                             null=True,
                                             editable=False)
    condition_def = models.ForeignKey('ConditionDef', models.CASCADE,
                                      db_column='condition_def_uuid', related_name='condition_condition_def')
    # TODO: Fix in_val and out_val on Postgres to return strings not JSON!
    in_val = ValField(blank=True, null=True)
    out_val = ValField(blank=True, null=True)
    internal_slug = SlugField(populate_from=[
                                    'condition_description',
                                    ],
                              overwrite=True, 
                              max_length=255)



class ConditionDef(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):

    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='condition_def_uuid')
    calculation_def = models.ManyToManyField('CalculationDef', blank=True), #through='ConditionCalculationDefAssign')
    internal_slug = SlugField(populate_from=[
                                    'description'
                                    ],
                              overwrite=True, 
                              max_length=255)
    def __str__(self):
        return f"{self.description}"


class ConditionPath(DateColumns):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column='condition_path_uuid')
    condition = models.ForeignKey('Condition',
                                  on_delete=models.CASCADE,
                                  db_column='condition_uuid',
                                  blank=True,
                                  null=True,
                                  related_name='condition_path_condition')
    condition_out_val = ValField(blank=True, null=True)
    workflow_step = models.ForeignKey('WorkflowStep',
                                      on_delete=models.CASCADE,
                                      db_column='workflow_uuid',
                                      blank=True,
                                      null=True,
                                      related_name='condition_path_workflow_step')
    internal_slug = SlugField(populate_from=[
                                    'condition__internal_slug',
                                    'workflow_step__internal_slug'
                                    ],
                              overwrite=True, 
                              max_length=255)


class ParameterEditView(TemplateView):
    template_name = "core/parameter_editor.html"
    ParameterFormSet = formset_factory(NominalActualForm, extra=0)
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        related_exp = 'workflow__experiment_workflow_workflow__experiment'
        related_exp_wf = 'workflow__experiment_workflow_workflow'
        #print(kwargs['pk'])

        if 'pk' in kwargs:
            experiment = Experiment.objects.get(pk=kwargs['pk'])
            # Can't use q1 because it doesn't have a unique uuid!
            q1 = ActionParameter.objects.filter(workflow__experiment_workflow_workflow__experiment=kwargs['pk']).only('uuid').annotate(
                        object_description=F('action_description')).annotate(
                        object_uuid=F('uuid')).annotate(
                        parameter_value=F('parameter_val_nominal')).annotate(
                        experiment_uuid=F(f'{related_exp}__uuid')).annotate(
                        experiment_description=F(f'{related_exp}__description')).annotate(
                        workflow_seq=F(f'{related_exp_wf}__experiment_workflow_seq'
                        )).filter(workflow_action_set__isnull=True).prefetch_related(f'{related_exp}')
            
            q2 = WorkflowActionSet.objects.filter(parameter_val_nominal__isnull=False, workflow__experiment_workflow_workflow__experiment=kwargs['pk']).only(
                            'workflow').annotate(
                            object_description=F('description')).annotate(
                            object_uuid=F('uuid')).annotate(
                            parameter_def_description=F('parameter_def__description')).annotate(
                            parameter_uuid=Value(None, RetUUIDField())).annotate(
                            parameter_value=F('parameter_val_nominal')).annotate(
                            experiment_uuid=F(f'{related_exp}__uuid')).annotate(
                            experiment_description=F(f'{related_exp}__description')).annotate(
                            workflow_seq=F(f'{related_exp_wf}__experiment_workflow_seq')
                            ).prefetch_related(f'{related_exp}')
            q3 = WorkflowActionSet.objects.filter(calculation__isnull=False, workflow__experiment_workflow_workflow__experiment=kwargs['pk']).only(
                                'workflow').annotate(
                                object_description=F('description')).annotate(
                                object_uuid=F('uuid')).annotate(
                                parameter_def_description=F('calculation__calculation_def__parameter_def__description')).annotate(
                                parameter_uuid=F('calculation__calculation_def__parameter_def__uuid')).annotate(
                                parameter_value=F('calculation__calculation_def__parameter_def__default_val')).annotate(
                                experiment_uuid=F(f'{related_exp}__uuid')).annotate(
                                experiment_description=F(f'{related_exp}__description')).annotate(
                                workflow_seq=F(f'{related_exp_wf}__experiment_workflow_seq')).prefetch_related(
                                    'workflow__experiment_workflow_workflow__experiment').distinct('parameter_uuid')  
                    
            #context['q1_formset'] = self.ParameterFormSet(initial=[{'value': row.parameter_value} for row in q1])
            initial_q1 = [{'value': row.parameter_value} for row in q1]
            initial_q2 = [{'value': param} for row in q2 for param in row.parameter_value]
            initial_q3 = [{'value': row.parameter_value} for row in q3]

            q1_details = [f'{row.object_description} : {row.parameter_def_description}' for row in q1]
            q2_details = [f'{row.object_description} : {row.parameter_def_description}' for row in q2]
            q3_details = [f'{row.object_description} : {row.parameter_def_description}' for row in q3]
            context['q1_formset'] = self.ParameterFormSet(initial=initial_q1, prefix='q1')
            context['q2_formset'] = self.ParameterFormSet(initial=initial_q2, prefix='q2')
            context['q3_formset'] = self.ParameterFormSet(initial=initial_q3, prefix='q3')

            context['q1_details'] = q1_details
            context['q2_details'] = q2_details
            context['q3_details'] = q3_details

            context['experiment'] = experiment
        return context


class MaterialEditView(TemplateView):
    template_name = "core/material_editor.html"
    MaterialFormSet = formset_factory(InventoryMaterialForm, extra=0)
    # todo: we likely want to filter this down to only appropriate material

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        related_exp = 'bom__experiment'
        # print(kwargs['pk'])

        if 'pk' in kwargs:
            experiment = Experiment.objects.get(pk=kwargs['pk'])
            q1 = BomMaterial.objects.filter(bom__experiment=experiment).only(
                'uuid').annotate(
                object_description=F('description')).annotate(
                object_uuid=F('uuid')).annotate(
                experiment_uuid=F(f'{related_exp}__uuid')).annotate(
                experiment_description=F(f'{related_exp}__description')).prefetch_related(f'{related_exp}')

            # context['q1_formset'] = self.ParameterFormSet(initial=[{'value': row.parameter_value} for row in q1])
            initial_q1 = [{'value': row.inventory_material} for row in q1]

            q1_details = [f'{row.object_description}' for row in q1]
            form_kwargs = {'org_uuid':self.request.session['current_org_id']}
            context['q1_formset'] = self.MaterialFormSet(initial=initial_q1, 
                                                         prefix='q1', 
                                                         form_kwargs=form_kwargs)
            context['q1_details'] = q1_details

            context['experiment'] = experiment
        return context

class WorkflowActionSet(DateColumns, StatusColumn, ActorColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='workflow_action_set_uuid')
    action_sequence = models.ForeignKey('ActionSequence', models.CASCADE,
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


class WorkflowStep(DateColumns, StatusColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='workflow_step_uuid')
    action_sequence = models.ForeignKey('ActionSequence', models.CASCADE,
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
    parent = models.ForeignKey('ActionSequence', models.CASCADE,
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
    action_sequence = models.ForeignKey('ActionSequence', models.CASCADE,
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
