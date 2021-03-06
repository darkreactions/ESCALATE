import json
from django.db.models import F, Value
from django.http import HttpResponse
from django.views.generic import TemplateView
from django.forms import formset_factory, BaseFormSet
from django.http import HttpResponseRedirect
from django.shortcuts import render
from django.contrib import messages
from django.urls import reverse, reverse_lazy
from django.views.generic.list import ListView
from django.views.generic.detail import DetailView

from core.models.view_tables import ActionParameter, WorkflowActionSet, Experiment, BomMaterial, ParameterDef, Edocument
from core.models.core_tables import RetUUIDField
from core.forms.custom_types import SingleValForm, InventoryMaterialForm
from core.forms.forms import ExperimentNameForm
from core.utils import experiment_copy
import core.models
from core.models.view_tables import Note, Actor, TagAssign, Tag

from copy import deepcopy
import numpy as np
from core.custom_types import Val


SUPPORTED_CREATE_WFS = ['liquid_solid_extraction', 'resin_weighing']

def hcl_mix(stock_concentration, solution_volume, target_concentrations):
    hcl_vols = (target_concentrations * solution_volume) / stock_concentration
    h2o_vols = solution_volume - hcl_vols
    return hcl_vols, h2o_vols
                
def update_dispense_action_set(dispense_action_set, volumes, unit='mL'):
    dispense_action_set_params = deepcopy(dispense_action_set.__dict__)

    # delete keys from dispense action set that are not needed for creating a new action set
    delete_keys = ['uuid', '_state', '_prefetched_objects_cache',
                   # the below keys are the annotations from q1..q3
                   'object_description', 'object_uuid', 'parameter_def_description', 'parameter_uuid',
                   'parameter_value', 'experiment_uuid', 'experiment_description', 'workflow_seq'
                   ]
    [dispense_action_set_params.pop(k, None) for k in delete_keys]

    # delete the old action set
    dispense_action_set.delete()

    if isinstance(volumes, np.ndarray):
        #recall: needs to be a list of Val
        v = [Val.from_dict({'type': 'num', 'value': vol, 'unit': unit}) for vol in volumes]
    elif isinstance(volumes, Val):
        v = [volumes]
    dispense_action_set_params['calculation_id'] = None
    dispense_action_set_params['parameter_val'] = v
    instance = WorkflowActionSet(**dispense_action_set_params)
    instance.save()

class BaseUUIDFormSet(BaseFormSet):
    """
    This formset adds a UUID as the kwarg. When the form is rendered, 
    the UUID is added as an attribute to the html field. Which when submitted 
    can be used to identify where the data goes
    """
    def get_form_kwargs(self, index):
        kwargs = super().get_form_kwargs(index)
        kwargs['uuid'] = kwargs['object_uuids'][index]
        return kwargs

class CreateExperimentView(TemplateView):
    template_name = "core/create_experiment.html"
    ParameterFormSet = formset_factory(SingleValForm, extra=0)
    MaterialFormSet = formset_factory(InventoryMaterialForm, extra=0)

    def __init__(self, *args, **kwargs):
        self.all_experiments = Experiment.objects.filter(parent__isnull=True)
        super().__init__(*args, **kwargs)

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['all_experiments'] = self.all_experiments
        return context

    def get_action_parameter_querysets(self, exp_uuid):
        related_exp = 'workflow__experiment_workflow_workflow__experiment'
        related_exp_wf = 'workflow__experiment_workflow_workflow'
        q1 = ActionParameter.objects.filter(**{f'{related_exp}': exp_uuid}).annotate(
                    object_description=F('action_description')).annotate(
                    object_uuid=F('uuid')).annotate(
                    parameter_value=F('parameter_val')).annotate(
                    experiment_uuid=F(f'{related_exp}__uuid')).annotate(
                    experiment_description=F(f'{related_exp}__description')).annotate(
                    workflow_seq=F(f'{related_exp_wf}__experiment_workflow_seq'
                    )).filter(workflow_action_set__isnull=True).prefetch_related(f'{related_exp}')
        q2 = WorkflowActionSet.objects.filter(**{f'{related_exp}': exp_uuid, 'parameter_val__isnull': False}).annotate(
                        object_description=F('description')).annotate(
                        object_uuid=F('uuid')).annotate(
                        parameter_def_description=F('parameter_def__description')).annotate(
                        parameter_uuid=Value(None, RetUUIDField())).annotate(
                        parameter_value=F('parameter_val')).annotate(
                        experiment_uuid=F(f'{related_exp}__uuid')).annotate(
                        experiment_description=F(f'{related_exp}__description')).annotate(
                        workflow_seq=F(f'{related_exp_wf}__experiment_workflow_seq')
                        ).prefetch_related(f'{related_exp}')
        q3 = WorkflowActionSet.objects.filter(calculation__isnull=False,
                                              workflow__experiment_workflow_workflow__experiment=exp_uuid).annotate(
                        object_description=F('description')).annotate(
                        object_uuid=F('uuid')).annotate(
                        parameter_def_description=F('calculation__calculation_def__parameter_def__description')).annotate(
                        parameter_uuid=F('calculation__calculation_def__parameter_def__uuid')).annotate(
                        parameter_value=F('calculation__calculation_def__parameter_def__default_val')).annotate(
                        experiment_uuid=F(f'{related_exp}__uuid')).annotate(
                        experiment_description=F(f'{related_exp}__description')).annotate(
                        workflow_seq=F(f'{related_exp_wf}__experiment_workflow_seq')).prefetch_related(
                        'workflow__experiment_workflow_workflow__experiment').distinct('parameter_uuid')
        return q1, q2, q3

    def get_action_parameter_forms(self, exp_uuid, context):
        #workflow__experiment_workflow_workflow__experiment=exp_uuid
        q1, q2, q3 = self.get_action_parameter_querysets(exp_uuid)
        """
        This happens before copy, in the template. The only way to identify a parameter is 
        through a combination of object_description and parameter_def_description.

        When the form is submitted, a copy is created of the template and we have to search
        for the correct parameters using descriptions because UUIDS are new!

        The reason for making a copy after editing parameters is because we cannot update
        a WorkflowActionSet as of Jan 2021. We can only create a new one
        """
        initial_q1 = [{'value': row.parameter_value, 'uuid': json.dumps([f'{row.object_description}', f'{row.parameter_def_description}'])} for row in q1]
        initial_q2 = [{'value': param, 'uuid': json.dumps([f'{row.object_description}', f'{row.parameter_def_description}'])} for row in q2 for param in row.parameter_value]
        initial_q3 = [{'value': row.parameter_value, 'uuid': json.dumps([f'{row.object_description}', f'{row.parameter_def_description}'])} for row in q3]

        q1_details = [f'{row.object_description} : {row.parameter_def_description}' for row in q1]
        q2_details = [f'{row.object_description} : {row.parameter_def_description}' for row in q2]
        q3_details = [f'{row.object_description} : {row.parameter_def_description}' for row in q3]

        context['q1_param_formset'] = self.ParameterFormSet(initial=initial_q1, 
                                                            prefix='q1_param',)
        context['q2_param_formset'] = self.ParameterFormSet(initial=initial_q2, 
                                                            prefix='q2_param',)
        context['q3_param_formset'] = self.ParameterFormSet(initial=initial_q3, 
                                                            prefix='q3_param',)

        context['q1_param_details'] = q1_details
        context['q2_param_details'] = q2_details
        context['q3_param_details'] = q3_details
    
        return context

    def get_material_forms(self, exp_uuid, context):
        related_exp = 'bom__experiment'
        experiment = Experiment.objects.get(pk=exp_uuid)
        q1 = BomMaterial.objects.filter(bom__experiment=experiment).only(
                'uuid').annotate(
                object_description=F('description')).annotate(
                object_uuid=F('uuid')).annotate(
                experiment_uuid=F(f'{related_exp}__uuid')).annotate(
                experiment_description=F(f'{related_exp}__description')).prefetch_related(f'{related_exp}')

        # context['q1_formset'] = self.ParameterFormSet(initial=[{'value': row.parameter_value} for row in q1])
        initial_q1 = [{'value': row.inventory_material, 'uuid': json.dumps([f'{row.object_description}'])} for row in q1]
        q1_details = [f'{row.object_description}' for row in q1]
        
        form_kwargs = {'org_uuid':self.request.session['current_org_id']}
        context['q1_material_formset'] = self.MaterialFormSet(initial=initial_q1, 
                                                        prefix='q1_material', 
                                                        form_kwargs=form_kwargs)
        context['q1_material_details'] = q1_details

        return context

    def post(self, request, *args, **kwargs):
        context = {}
        context['all_experiments'] = self.all_experiments
        if 'select_exp_template' in request.POST:
            exp_uuid = request.POST['select_exp_template']
            if exp_uuid:
                request.session['experiment_template_uuid'] = exp_uuid
                context['selected_exp_template'] = Experiment.objects.get(uuid=exp_uuid)
                context['experiment_name_form'] = ExperimentNameForm()
                context = self.get_action_parameter_forms(exp_uuid, context)
                context = self.get_material_forms(exp_uuid, context)
            else:
                request.session['experiment_template_uuid'] = None
        elif 'create_exp' in request.POST:
            #context['selected_exp_template'] = {'description': "Dummy function to create an experiment" }

            ## begin: one-time procedure -- this will be refactored into a more general soln

            # get the name of the experiment template
            exp_template = Experiment.objects.get(pk=request.session['experiment_template_uuid'])
            template_name = exp_template.description

            exp_name_form = ExperimentNameForm(request.POST)
            q1_formset = self.ParameterFormSet(request.POST, prefix='q1_param')
            q2_formset = self.ParameterFormSet(request.POST, prefix='q2_param')
            q3_formset = self.ParameterFormSet(request.POST, prefix='q3_param')

            q1_material_formset = self.MaterialFormSet(request.POST,
                                                       prefix='q1_material',
                                                       form_kwargs={'org_uuid':self.request.session['current_org_id']})

            if all([exp_name_form.is_valid(),
                    q1_formset.is_valid(), 
                    q2_formset.is_valid(), 
                    q3_formset.is_valid(), 
                    q1_material_formset.is_valid()]):
                
                exp_name = exp_name_form.cleaned_data['exp_name']

                # make the experiment copy
                experiment_copy_uuid = experiment_copy(str(exp_template.uuid), exp_name)
                q1, q2, q3 = self.get_action_parameter_querysets(experiment_copy_uuid)
                
                q1_material = BomMaterial.objects.filter(bom__experiment=experiment_copy_uuid).only(
                        'uuid').annotate(
                        object_description=F('description')).annotate(
                        object_uuid=F('uuid')).annotate(
                        experiment_uuid=F('bom__experiment__uuid')).annotate(
                        experiment_description=F('bom__experiment__description')).prefetch_related('bom__experiment')
                

                # parameter_val and material_uuid require no special logic
                for query_set, query_form_set, field in zip([q1,               q1_material,         q2],
                                                            [q1_formset,       q1_material_formset, q2_formset],
                                                            ['parameter_val', 'inventory_material', None]):
                    for i, form in enumerate(query_form_set):
                        if form.has_changed() and form.is_valid():
                            data = form.cleaned_data
                            print(data['uuid'])
                            desc = json.loads(data['uuid'])
                            if len(desc) == 2:
                                object_desc, param_def_desc = desc
                                query = query_set.get(object_description=object_desc, parameter_def_description=param_def_desc)
                            else:
                                query = query_set.get(object_description=desc[0])

                            # q2 gets handled differently because its a workflow action set
                            if query_set is q2:
                                update_dispense_action_set(query, data['value'])
                            else:
                                setattr(query, field, data['value'])
                                query.save()

                if template_name in SUPPORTED_CREATE_WFS:
                    lsr_edoc = Edocument.objects.get(ref_edocument_uuid=exp_template.uuid, title='LSR file')
                    if template_name == 'liquid_solid_extraction':
                        # q3 contains concentraiton logic
                        if any([f.has_changed() for f in q3_formset]):
                            data = {}  # Stick form data into this dict
                            for i, form in enumerate(q3_formset):
                                if form.is_valid():
                                    query = q3[i]
                                    data[query.parameter_def_description] = form.cleaned_data['value'].value

                            hcl_vols, h2o_vols = hcl_mix(data['stock_concentration'],
                                                         data['total_vol'],
                                                         np.fromstring(data['hcl_concentrations'].strip(']['), sep=',')
                                                         )
                            related_exp = 'workflow__experiment_workflow_workflow__experiment'
                            h2o_dispense_action_set = WorkflowActionSet.objects.get(**{f'{related_exp}': experiment_copy_uuid,
                                                                                       'description__contains': 'H2O'})
                            hcl_dispense_action_set = WorkflowActionSet.objects.get(**{f'{related_exp}': experiment_copy_uuid,
                                                                                       'description__contains': 'HCl'})
                            update_dispense_action_set(h2o_dispense_action_set, h2o_vols)
                            update_dispense_action_set(hcl_dispense_action_set, hcl_vols)
                            new_lsr_pk, lsr_msg = update_lsr_edoc(lsr_edoc,
                                                                  experiment_copy_uuid,
                                                                  exp_name,
                                                                  vol_hcl=list(hcl_vols*1000),
                                                                  vol_h2o=list(h2o_vols*1000))
                    elif template_name == 'resin_weighing':
                        related_exp = 'workflow__experiment_workflow_workflow__experiment'
                        resin_dispense_action_set = WorkflowActionSet.objects.get(**{f'{related_exp}': experiment_copy_uuid,
                                                                                     'description__contains': 'Dispense Resin'})
                        new_lsr_pk, lsr_msg = update_lsr_edoc(lsr_edoc,
                                                              experiment_copy_uuid,
                                                              exp_name,
                                                              resin_amt=resin_dispense_action_set.parameter_val[0].value)

                    if new_lsr_pk is not None:
                        context['lsr_download_link'] = reverse('edoc_download', args=[new_lsr_pk])
                    else:
                        messages.error(request, f'LSRGenerator failed with message: "{lsr_msg}"')
                    context['experiment_link'] = reverse('experiment_view', args=[experiment_copy_uuid])
                    context['new_exp_name'] = exp_name
                    render(request, self.template_name, context)
            else:
                return render(request, self.template_name, context)
                
            ## end: one-time procedure
        return render(request, self.template_name, context)


def update_lsr_edoc(template_edoc,  experiment_copy_uuid, experiment_copy_name, **kwargs):
    """Copy LSR file from the experiment template, update tagged maps with kwargs, save to experiment copy
    Returns the uuid if completed successfully, else none
    """
    from LSRGenerator.generate import generate_lsr_design
    import xml.etree.ElementTree as ET

    # copy the template edoc
    template_edoc.pk = None # this effectively creates a copy of the original edoc

    # convert to format LSRGenerator understands
    lsr_template = template_edoc.edocument.tobytes().decode('utf-16')
    lsr_template = ET.ElementTree(ET.fromstring(lsr_template))

    # populate LSR design with kwargs, handling failure
    new_lsr_uuid = None
    message = None
    try:
        lsr_design = generate_lsr_design(lsr_template, **kwargs)
    except Exception as e:
        message = str(e)
    else:
        lsr_design = ET.tostring(lsr_design.getroot(), encoding='utf-16')
        # associate with the experiment copy and save
        template_edoc.ref_edocument_uuid = experiment_copy_uuid
        template_edoc.edocument = lsr_design
        template_edoc.filename = experiment_copy_name + '.lsr'
        template_edoc.save()
        new_lsr_uuid = template_edoc.pk

    return new_lsr_uuid, message


class ExperimentListView(ListView):
    template_name = 'core/experiment/list.html'
    model = core.models.view_tables.Experiment
    field_contains = ''
    order_field = 'description'
    org_related_path = 'lab__organization'
    table_columns = ['Description', 'Actions']
    column_necessary_fields = {'Description': ['description'], 
                               }
    context_object_name= 'experiments'

    def get_context_data(self, **kwargs):
        context = super(ExperimentListView, self).get_context_data(**kwargs)
        context['filter'] = self.request.GET.get('filter', '')
        return context
    
    def get_queryset(self):
        filter_val = self.request.GET.get('filter', self.field_contains)
        order = "".join(self.request.session.get(f'experiments_order',self.order_field).split('-'))
        ordering = self.request.GET.get('ordering', order)

        #order = "".join(order_field)
        filter_kwargs = {f'{order}__icontains': filter_val}

        # Filter by organization if it exists in the model
        if 'current_org_id' in self.request.session:
            org_filter_kwargs = {self.org_related_path : self.request.session['current_org_id'],
                                 'parent__isnull':False}
            base_query = self.model.objects.filter(**org_filter_kwargs)
        else:
            base_query = self.model.objects.none()
        
        
        if filter_val != None:
            new_queryset = base_query.filter(
                **filter_kwargs).select_related().order_by(ordering)
        else:
            new_queryset = base_query
        
        new_queryset = base_query
        return new_queryset
    

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['table_columns'] = self.table_columns
        models = context[self.context_object_name]
        model_name = self.context_object_name[:-1]  # Ex: tag_types -> tag_type
        table_data = []
        for model in models:
            table_row_data = []

            # loop to get each column data for one row. [:-1] because table_columns has 'Actions'
            header_names = self.table_columns[:-1]
            for field_name in header_names:
                # get list of fields used to fill out one cell
                necessary_fields = self.column_necessary_fields[field_name]
                # get actual field value from the model
                fields_for_col = [getattr(model, field)
                                  for field in necessary_fields]
                # loop to change None to '' or non-string to string because join needs strings
                for k in range(0, len(fields_for_col)):
                    if fields_for_col[k] == None:
                        fields_for_col[k] = ''
                    if not isinstance(fields_for_col[k], str):
                        fields_for_col[k] = str(fields_for_col[k])
                col_data = " ".join(fields_for_col)
                # take away any leading and trailing whitespace
                col_data = col_data.strip()
                # change the cell data to be N/A if it is empty string at this point
                if len(col_data) == 0:
                    col_data = 'N/A'
                table_row_data.append(col_data)

            # dict containing the data, view and update url, primary key and obj
            # name to use in template
            table_row_info = {
                'table_row_data': table_row_data,
                'view_url': reverse_lazy(f'{model_name}_view', kwargs={'pk': model.pk}),
                'update_url': reverse_lazy(f'{model_name}_update', kwargs={'pk': model.pk}),
                'obj_name': str(model),
                'obj_pk': model.pk
            }
            table_data.append(table_row_info)

        context['add_url'] = reverse_lazy(f'{model_name}_add')
        context['table_data'] = table_data
        # get rid of underscores with spaces and capitalize
        context['title'] = model_name.replace('_', ' ').capitalize()
        return context

class ExperimentDetailView(DetailView):
    model = Experiment
    model_name = 'experiment'  # lowercase, snake case. Ex:tag_type or inventory

    template_name = 'core/experiment/detail.html'

    
    detail_fields = None
    detail_fields_need_fields = None

    def get_action_parameter_querysets(self, exp_uuid):
        related_exp = 'workflow__experiment_workflow_workflow__experiment'
        related_exp_wf = 'workflow__experiment_workflow_workflow'
        q1 = ActionParameter.objects.filter(**{f'{related_exp}': exp_uuid}).annotate(
                    object_description=F('action_description')).annotate(
                    object_uuid=F('uuid')).annotate(
                    parameter_value=F('parameter_val')).annotate(
                    experiment_uuid=F(f'{related_exp}__uuid')).annotate(
                    experiment_description=F(f'{related_exp}__description')).annotate(
                    workflow_seq=F(f'{related_exp_wf}__experiment_workflow_seq'
                    )).filter(workflow_action_set__isnull=True).prefetch_related(f'{related_exp}')
        q2 = WorkflowActionSet.objects.filter(**{f'{related_exp}': exp_uuid, 'parameter_val__isnull': False}).annotate(
                        object_description=F('description')).annotate(
                        object_uuid=F('uuid')).annotate(
                        parameter_def_description=F('parameter_def__description')).annotate(
                        parameter_uuid=Value(None, RetUUIDField())).annotate(
                        parameter_value=F('parameter_val')).annotate(
                        experiment_uuid=F(f'{related_exp}__uuid')).annotate(
                        experiment_description=F(f'{related_exp}__description')).annotate(
                        workflow_seq=F(f'{related_exp_wf}__experiment_workflow_seq')
                        ).prefetch_related(f'{related_exp}')
        q3 = WorkflowActionSet.objects.filter(calculation__isnull=False,
                                              workflow__experiment_workflow_workflow__experiment=exp_uuid).annotate(
                        object_description=F('description')).annotate(
                        object_uuid=F('uuid')).annotate(
                        parameter_def_description=F('calculation__calculation_def__parameter_def__description')).annotate(
                        parameter_uuid=F('calculation__calculation_def__parameter_def__uuid')).annotate(
                        parameter_value=F('calculation__calculation_def__parameter_def__default_val')).annotate(
                        experiment_uuid=F(f'{related_exp}__uuid')).annotate(
                        experiment_description=F(f'{related_exp}__description')).annotate(
                        workflow_seq=F(f'{related_exp_wf}__experiment_workflow_seq')).prefetch_related(
                        'workflow__experiment_workflow_workflow__experiment').distinct('parameter_uuid')
        mat_q = BomMaterial.objects.filter(bom__experiment=exp_uuid).only(
                        'uuid').annotate(
                        object_description=F('description')).annotate(
                        object_uuid=F('uuid')).annotate(
                        experiment_uuid=F('bom__experiment__uuid')).annotate(
                        experiment_description=F('bom__experiment__description')).prefetch_related('bom__experiment')
        return q1, q2, q3, mat_q
    

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        exp = context['object']

        # dict of detail field names to their value
        detail_data = {}

        q1, q2, q3, mat_q = self.get_action_parameter_querysets(exp.uuid)
        edocs = Edocument.objects.filter(ref_edocument_uuid=exp.uuid)

        detail_data = {row.inventory_material : row.object_description for row in mat_q}
        detail_data.update({f'{row.object_description} {row.parameter_def_description}': f'{row.parameter_value}' for row in q1})
        detail_data.update({f'{row.object_description} {row.parameter_def_description}': f'{row.parameter_value}' for row in q2})
        detail_data.update({f'{row.object_description} {row.parameter_def_description}': f'{row.parameter_value}' for row in q3})
        detail_data.update({f'{lsr_edoc.title} download link' : reverse('edoc_download', args=[lsr_edoc.pk]) for lsr_edoc in edocs})
        

        # get notes
        notes_raw = Note.objects.filter(note_x_note__ref_note=exp.pk)
        notes = []
        for note in notes_raw:
            notes.append('-' + note.notetext)
        context['Notes'] = notes

        # get tags
        tags_raw = Tag.objects.filter(pk__in=TagAssign.objects.filter(
            ref_tag=exp.pk).values_list('tag', flat=True))
        tags = []
        for tag in tags_raw:
            tags.append(tag.display_text.strip())
        detail_data['Tags'] = ', '.join(tags)

        context['title'] = self.model_name.replace('_', " ").capitalize()
        context['update_url'] = reverse_lazy(
            f'{self.model_name}_update', kwargs={'pk': exp.pk})
        context['detail_data'] = detail_data
        
        

        return context