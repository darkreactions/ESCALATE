

from core.models.view_tables.organization import Actor
import json
from django.db.models import F, Value
from django.views.generic import TemplateView
from django.forms import formset_factory, BaseFormSet, modelformset_factory, inlineformset_factory
from django.shortcuts import render
from django.contrib import messages
from django.urls import reverse, reverse_lazy
from django.views.generic.list import ListView
from django.views.generic.detail import DetailView

from core.models.view_tables import WorkflowActionSet, ExperimentTemplate, ExperimentInstance, BomMaterial, Edocument, ReagentInstanceValue
from core.models.core_tables import RetUUIDField
from core.forms.custom_types import SingleValForm, InventoryMaterialForm, NominalActualForm, ReagentValueForm
from core.forms.custom_types import ExperimentNameForm, ExperimentTemplateForm, ReagentForm, BaseReagentFormSet
from core.utilities.utils import experiment_copy
from core.utilities.randomSampling import generateExperiments
from core.utilities.experiment_utils import update_dispense_action_set, get_action_parameter_querysets, get_material_querysets, supported_wfs, get_reagent_querysets
import core.models
from core.models.view_tables import Note, TagAssign, Tag
from core.experiment_templates import liquid_solid_extraction, resin_weighing, perovskite_demo
from core.custom_types import Val
import core.experiment_templates
from core.models.view_tables import Parameter
from core.widgets import ValWidget

# from .crud_view_methods.model_view_generic import GenericModelList
# from .crud_views import LoginRequired

#SUPPORTED_CREATE_WFS = ['liquid_solid_extraction', 'resin_weighing']
#SUPPORTED_CREATE_WFS = supported_wfs() 
SUPPORTED_CREATE_WFS = [mod for mod in dir(core.experiment_templates) if '__' not in mod]


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
    form_class = ExperimentTemplateForm
    MaterialFormSet = formset_factory(InventoryMaterialForm, extra=0)
    NominalActualFormSet = formset_factory(NominalActualForm, extra=0)
    ReagentFormSet = formset_factory(ReagentForm, extra=0, formset=BaseReagentFormSet)

    def get_context_data(self, **kwargs):    
        # Select templates that belong to the current lab
        context = super().get_context_data(**kwargs)
        
        #lab = Actor.objects.get(organization=org_id, person__isnull=True)
        #self.all_experiments = Experiment.objects.filter(parent__isnull=True, lab=lab)
        #context['all_experiments'] = self.all_experiments
        return context
        

    def get_action_parameter_forms(self, exp_uuid, context):
        # workflow__experiment_workflow_workflow__experiment=exp_uuid
        #q1, q2, q3 = get_action_parameter_querysets(exp_uuid)
        q1 = get_action_parameter_querysets(exp_uuid)
        """
        This happens before copy, in the template. The only way to identify a parameter is 
        through a combination of object_description and parameter_def_description.

        When the form is submitted, a copy is created of the template and we have to search
        for the correct parameters using descriptions because UUIDS are new!

        The reason for making a copy after editing parameters is because we cannot update
        a WorkflowActionSet as of Jan 2021. We can only create a new one
        """

        #create empty lists for initial q1-q3
        initial_q1 = []
        '''
        using for loop instead of list comprehension to account for arrays
        this will be basis for implementing new array ui
        '''
        #q1 initial
        for row in q1:
            data = {'value': row.parameter_value, \
                'uuid': json.dumps([f'{row.object_description}', f'{row.parameter_def_description}'])}
            if not row.parameter_value.null:
                if 'array' in row.parameter_value.val_type.description:
                    data['actual_value'] = Val.from_dict({'type':'array_num', \
                                                          'value':[0]*len(row.parameter_value.value), \
                                                          'unit':row.parameter_value.unit})
                else:
                    data['actual_value'] = Val.from_dict({'type':'num', \
                                                          'value':0, \
                                                          'unit':row.parameter_value.unit})
            
            initial_q1.append(data)
        
        q1_details = [f'{row.object_description} : {row.parameter_def_description}' for row in q1]
        context['q1_param_formset'] = self.NominalActualFormSet(initial=initial_q1, 
                                                            prefix='q1_param',)
        context['q1_param_details'] = q1_details
        
        return context

    def get_material_forms(self, exp_uuid, context):
        
        q1 = get_material_querysets(exp_uuid)
        initial_q1 = [{'value': row.inventory_material, 'uuid': json.dumps([f'{row.object_description}'])} for row in q1]
        q1_details = [f'{row.object_description}' for row in q1]
        
        form_kwargs = {'org_uuid':self.request.session['current_org_id']}
        context['q1_material_formset'] = self.MaterialFormSet(initial=initial_q1, 
                                                        prefix='q1_material', 
                                                        form_kwargs=form_kwargs)
        context['q1_material_details'] = q1_details

        return context

    def get_reagent_forms(self, exp_template, context):
        if 'current_org_id' in self.request.session:
            org_id = self.request.session['current_org_id']
        else:
            org_id = None
        formsets = []
        reagent_template_names = []
        for index, reagent_template in enumerate(exp_template.reagent_templates.all()):
            reagent_template_names.append(reagent_template.description)
            mat_types_list = []
            initial = []
            for material_type in reagent_template.material_type.all():
                mat_types_list.append(material_type)
                initial.append({})

            formsets.append(self.ReagentFormSet(prefix=f'reagent_{index}', 
                                                initial=initial,
                                                form_kwargs={'lab_uuid': org_id, 
                                                'mat_types_list':mat_types_list,
                                                'reagent_index':index}))
        #for form in formset:
        #    form.fields[]
        context['reagent_formset'] = formsets
        context['reagent_template_names'] = reagent_template_names
        return context

    def get(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        if 'current_org_id' in self.request.session:
            org_id = self.request.session['current_org_id']
        else:
            org_id = None
        context['experiment_template_select_form'] = ExperimentTemplateForm(org_id=org_id)

        return render(request, self.template_name, context)


    def post(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        if 'select_experiment_template' in request.POST:
            exp_uuid = request.POST['select_experiment_template']
            if exp_uuid:
                request.session['experiment_template_uuid'] = exp_uuid
                context['selected_exp_template'] = ExperimentTemplate.objects.get(uuid=exp_uuid)
                context['manual'] = int(request.POST['manual'])
                context['automated'] = int(request.POST['automated'])
                context['experiment_name_form'] = ExperimentNameForm()
                context = self.get_action_parameter_forms(exp_uuid, context)

                if context['manual']:
                    context = self.get_material_forms(exp_uuid, context)
                
                if context['automated']:
                    context = self.get_reagent_forms(context['selected_exp_template'], context)
            else:
                request.session['experiment_template_uuid'] = None
        # begin: create experiment
        elif 'create_exp' in request.POST:
            #TODO: this needs to be something less ad-hoc. add an automated flag instead of looking for the first reagent chemical
            if request.POST['reagent_1-0-chemical']:
                context = self.process_automated_formsets(request, context)#need to create new process function
            else:
                context = self.process_formsets(request, context)
            # end: create experiment
        return render(request, self.template_name, context)
    # end: self.post()

    def save_forms_q1(self, queries, formset, fields):
        """Saves custom formset into queries

        Args:
            queries ([Queryset]): List of queries into which the forms values are saved
            formset ([Formset]): Formset
            fields (dict): Dictionary to map the column in queryset with field in formset
        """
        for form in formset:
            if form.has_changed():
                data = form.cleaned_data
                desc = json.loads(data['uuid'])
                if len(desc) == 2:
                    object_desc, param_def_desc = desc
                    query = queries.get(object_description=object_desc, parameter_def_description=param_def_desc)
                else:
                    query = queries.get(object_description=desc[0])
                parameter = Parameter.objects.get(uuid=query.parameter_uuid)
                for db_field, form_field in fields.items():
                    setattr(parameter, db_field, data[form_field])
                parameter.save(update_fields=list(fields.keys()))
        #queries.save()

    def save_forms_q_material(self, queries, formset, fields):
        """
        Saves custom formset into queries
        Args:
            queries ([Queryset]): List of queries into which the forms values are saved
            formset ([Formset]): Formset
            fields (dict): Dictionary to map the column in queryset with field in formset
        """
        for form in formset:
            if form.has_changed():
                data = form.cleaned_data
                desc = json.loads(data['uuid'])
                if len(desc) == 2:
                    object_desc, param_def_desc = desc
                    query = queries.get(object_description=object_desc, parameter_def_description=param_def_desc)
                else:
                    query = queries.get(object_description=desc[0])

                for db_field, form_field in fields.items():
                    setattr(query, db_field, data[form_field])

                query.save(update_fields=list(fields.keys()))

    def process_formsets(self, request, context):
        """Creates formsets and gets data from the post request.

        Args:
            request ([Django Request]): Should be the POST request
            context (dict): Context dictionary

        Returns:
            context [dict]: Context dict, returned to the page
        """
        # get the experiment template uuid and name
        exp_template = ExperimentTemplate.objects.get(pk=request.session['experiment_template_uuid'])
        template_name = exp_template.description
        # construct all formsets
        exp_name_form = ExperimentNameForm(request.POST)
        q1_formset = self.NominalActualFormSet(request.POST, prefix='q1_param')
        q1_material_formset = self.MaterialFormSet(request.POST,
                                                    prefix='q1_material',
                                                    form_kwargs={'org_uuid': self.request.session['current_org_id']})
        if all([exp_name_form.is_valid(),
                q1_formset.is_valid(), 
                q1_material_formset.is_valid()]):
            
            exp_name = exp_name_form.cleaned_data['exp_name']
            # make the experiment copy: this will be our new experiment
            experiment_copy_uuid = experiment_copy(str(exp_template.uuid), exp_name)
            # get the elements of the new experiment that we need to update with the form values
            q1 = get_action_parameter_querysets(experiment_copy_uuid, template=False)
            q1_material = get_material_querysets(experiment_copy_uuid, template=False)
            
            self.save_forms_q1(q1, q1_formset, {'parameter_val_nominal': 'value', 'parameter_val_actual': 'actual_value'})
            self.save_forms_q_material(q1_material, q1_material_formset, {'inventory_material': 'value'})
            
            # begin: template-specific logic
            if template_name in SUPPORTED_CREATE_WFS:
                data = {}  # Stick form data into this dict
                for i, form in enumerate(q1_formset):
                    if form.is_valid():
                        query = q1[i]
                        data[query.parameter_def_description] = form.cleaned_data['value'].value
                
                # Scans experiment_templates and picks up functions that have the same name as template_name
                template_function = getattr(core.experiment_templates, template_name)
                new_lsr_pk, lsr_msg = template_function(data, q1, experiment_copy_uuid, exp_name, exp_template)
               
                if new_lsr_pk is not None:
                    context['xls_download_link'] = reverse('edoc_download', args=[new_lsr_pk])
                if str(self.request.session['current_org_name']) != "TestCo":
                    context['lsr_download_link'] = None
                elif new_lsr_pk is not None:
                    context['lsr_download_link'] = reverse('edoc_download', args=[new_lsr_pk])
                else:
                    messages.error(request, f'LSRGenerator failed with message: "{lsr_msg}"')
                context['experiment_link'] = reverse('experiment_instance_view', args=[experiment_copy_uuid])
                context['reagent_prep_link'] = reverse('reagent_prep', args=[experiment_copy_uuid])
                context['new_exp_name'] = exp_name
        return context

    '''
        this function should only save the data to the db tables. refactor all other logic
    '''
    def process_automated_formsets(self, request, context):
        """Creates formsets and gets data from the post request.

        Args:
            request ([Django Request]): Should be the POST request
            context (dict): Context dictionary

        Returns:
            context [dict]: Context dict, returned to the page
        """
        # get the experiment template uuid and name
        exp_template = Experiment.objects.get(pk=request.session['experiment_template_uuid'])
        template_name = exp_template.description
        # construct all formsets
        exp_name_form = ExperimentNameForm(request.POST)
        
        if 'current_org_id' in self.request.session:
            org_id = self.request.session['current_org_id']
        else:
            org_id = None
        formsets = []
        reagent_template_names = []
        for index, form in enumerate(exp_template.reagent_templates.all()):
            reagent_template_names.append(form.description)
            mat_types_list = []
            initial = []
            for material_type in form.material_type.all():
                mat_types_list.append(material_type)
                initial.append({})
            formsets.append(self.ReagentFormSet(request.POST, prefix=f'reagent_{index}',
                                                initial=initial,
                                                form_kwargs={'lab_uuid': org_id, 
                                                'mat_types_list':mat_types_list,
                                                'reagent_index':index}))
        
        
        if exp_name_form.is_valid():
            this_material = {}
            #experiment name
            exp_name = exp_name_form.cleaned_data['exp_name']
            # make the experiment copy: this will be our new experiment
            experiment_copy_uuid = experiment_copy(str(exp_template.uuid), exp_name)
            for reagent_formset in formsets:            
                if reagent_formset.is_valid():    
                    # get the elements of the new experiment that we need to update with the form values
                    '''
                    verify this works. I think it does
                    '''
                    #q1 = get_reagent_querysets(experiment_copy_uuid)
                    
                    #get current index of reagent_formset, current material, current material type, and desired concentration for that reagent
                    current_reagent_index = reagent_formset.form_kwargs['reagent_index']
                    current_material_type = reagent_formset.form_kwargs['mat_types_list'][0] 
                    current_desired_concentration = reagent_formset[0].cleaned_data['desired_concentration'].value
                    #looks into the chemical field in the curren reagent index. Once there looks into field.choices.
                    #choices has 2 objects. [0] is [UUID, Chemical Name], [1] is [UUID, Material Type].
                    #we select choices[0] and then select the element [1] for Chemical Name
                    current_material = reagent_formset[0]['chemical'].field.choices[0][1]
                    
                    if "acid" in current_material_type.description.lower():
                        this_material[current_material]=[0,0,current_desired_concentration,0]
                    elif "solvent" in current_material_type.description.lower():
                        this_material[current_material]=[0,current_desired_concentration,0,0]
                    elif "amine" in current_material_type.description.lower():
                        this_material[current_material]=[current_desired_concentration,0,0,0]
                    #else inorganic/iodide/lead
                    else: 
                        this_material[current_material]=[0,0,0,current_desired_concentration]
                        
                    '''
                    pass to sampler. desired_concentration needs to default to NUM
                    sampler input is as followed:
                    'Reagent': [amine desired concentration, solvent desired concentrtion, acid desired concentration, iodide desired concentration]
                    possibly run generateExperiments when all the materials are finished
                    '''
            #generate desired volume for current reagent
            desired_volume = generateExperiments(this_material)
                        
            '''
            doesn't work.
            will need to make reagent version of save forms
            '''
            #self.save_forms_q1(q1, reagent_formset, {'parameter_val_nominal': 'value', 'parameter_val_actual': 'actual_value'})
            '''
            data = {}  # Stick form data into this dict
            for i, form in enumerate(reagent_formset):
                if form.is_valid():
                    query = q1[i]
                    data[query.parameter_def_description] = form.cleaned_data['value'].value
            
            # Scans experiment_templates and picks up functions that have the same name as template_name
            template_function = getattr(core.experiment_templates, template_name)
            new_lsr_pk, lsr_msg = template_function(data, q1, experiment_copy_uuid, exp_name, exp_template)
           
            if new_lsr_pk is not None:
                context['xls_download_link'] = reverse('edoc_download', args=[new_lsr_pk])
            if str(self.request.session['current_org_name']) != "TestCo":
                context['lsr_download_link'] = None
            elif new_lsr_pk is not None:
                context['lsr_download_link'] = reverse('edoc_download', args=[new_lsr_pk])
            else:
                messages.error(request, f'LSRGenerator failed with message: "{lsr_msg}"')
            context['experiment_link'] = reverse('experiment_view', args=[experiment_copy_uuid])
            context['new_exp_name'] = exp_name
            '''
        return context

    '''
    this function should retrieve data from copied experiment and send to sampler. all logic to save data should be handled in process_automated_formset
    '''
    #def save_automated_formsets(self, exp_uuid):
# end: class CreateExperimentView()

'''
Made experiment list view to be auto generated like the other models because it doesn't seem to have any 
different functionality and the code for it below is old and doesn't work
Below is what gets autogenerated for reference
'''
# class ExperimentListView(LoginRequired, GenericModelList):
#     model = core.models.view_tables.Experiment
#     table_columns = ['Description']
#     column_necessary_fields = {
#         'Description': ['description']
#     }
#     ordering = ['description']
#     field_contains = ''
#     org_related_path = 'lab__organization'
#     default_filter_kwarg= {
#         'parent__isnull': False
#     }



class ExperimentDetailView(DetailView):
    model = ExperimentInstance
    model_name = 'experiment'  # lowercase, snake case. Ex:tag_type or inventory

    template_name = 'core/experiment/detail.html'

    detail_fields = None
    detail_fields_need_fields = None
    

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        exp = context['object']

        # dict of detail field names to their value
        detail_data = {}

        #q1, q2, q3 = get_action_parameter_querysets(exp.uuid)
        q1 = get_action_parameter_querysets(exp.uuid)
        mat_q = get_material_querysets(exp.uuid)
        edocs = Edocument.objects.filter(ref_edocument_uuid=exp.uuid)
        detail_data = {row.object_description : row.inventory_material for row in mat_q}
        detail_data.update({f'{row.object_description} {row.parameter_def_description}': f'{row.parameter_value}' for row in q1})
        #detail_data.update({f'{row.object_description} {row.parameter_def_description}': f'{row.parameter_value}' for row in q2})
        #detail_data.update({f'{row.object_description} {row.parameter_def_description}': f'{row.parameter_value}' for row in q3})
        link_data = {f'{lsr_edoc.title}' : self.request.build_absolute_uri(reverse('edoc_download', args=[lsr_edoc.pk])) for lsr_edoc in edocs}
        

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
        context['tags'] = ', '.join(tags)

        context['title'] = self.model_name.replace('_', " ").capitalize()
        context['update_url'] = reverse_lazy(
            f'{self.model_name}_update', kwargs={'pk': exp.pk})
        context['detail_data'] = detail_data
        context['file_download_links'] = link_data

        return context


class ExperimentReagentPrepView(TemplateView):
    template_name = "core/experiment_reagent_prep.html"
    #form_class = ExperimentTemplateForm
    #ReagentFormSet = formset_factory(ReagentForm, extra=0, formset=BaseReagentFormSet)
    ReagentFormSet = modelformset_factory(ReagentInstanceValue, extra=0, form=ReagentValueForm,
                                            formset=BaseReagentFormSet,
                                          fields=('material', 'material_type', 'nominal_value','actual_value'),
                                          widgets={'nominal_value': ValWidget(),
                                                    'actual_value':ValWidget})

    def get(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        pk = kwargs['pk']
        experiment = ExperimentInstance.objects.get(pk=pk)
        context = self.get_reagent_forms(experiment, context)
        return render(request, self.template_name, context)
    

    def get_reagent_forms(self, experiment, context):
        reagent_instances = experiment.reagent_instance_experiment_instance.all()

        if 'current_org_id' in self.request.session:
            org_id = self.request.session['current_org_id']
        else:
            org_id = None
        formsets = []
        reagent_names = []

        form_kwargs = {
                'disabled_fields': ['material', 'material_type', 'nominal_value'],
                'lab_uuid': org_id,
            }
        
        context['helper'] = ReagentValueForm.get_helper()
        for index, reagent_instance in enumerate(reagent_instances):
            reagent_names.append(reagent_instance.description)
            
            qset = reagent_instance.reagent_instance_value_reagent_instance.all().filter(description='amount')
            material_types = [q.material_type for q in qset]
            #material_types = reagent_instance.reagent_template.material_type.all()
            form_kwargs['material_types'] = material_types
            fset = self.ReagentFormSet(prefix=f'reagent_{index}', queryset=qset, form_kwargs=form_kwargs)
            formsets.append(fset)
        #for form in formset:
        #    form.fields[]
        context['reagent_formsets'] = formsets
        context['reagent_template_names'] = reagent_names
        return context