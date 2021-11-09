from collections import defaultdict
import json
from django.http.response import HttpResponse, FileResponse

import pandas as pd
import tempfile
import mimetypes

from django.views.generic import TemplateView
from django.forms import formset_factory, BaseFormSet, modelformset_factory, inlineformset_factory
from django.shortcuts import render
from django.contrib import messages
from django.urls import reverse, reverse_lazy

from django.views.generic.detail import DetailView
from django.http import HttpResponseRedirect
import pandas as pd
#from core.models.view_tables.generic_data import File

from core.models.view_tables import (ExperimentTemplate, 
                                     ExperimentInstance, Edocument, 
                                     ReagentMaterialValue, ReagentMaterial,
                                     InventoryMaterial, OutcomeInstance, OutcomeTemplate, ReactionParameter)
# from core.models.core_tables import RetUUIDField
from core.forms.custom_types import SingleValForm, InventoryMaterialForm, NominalActualForm, ReagentValueForm
from core.forms.custom_types import (ExperimentNameForm, ExperimentTemplateForm, 
                                     ReagentForm, BaseReagentFormSet, 
                                     PropertyForm, OutcomeInstanceForm, VesselForm,
                                     UploadFileForm, RobotForm, ReactionParameterForm)
from core.utilities.utils import experiment_copy
from core.utilities.experiment_utils import (update_dispense_action_set, 
                                             get_action_parameter_querysets, 
                                             get_material_querysets, 
                                             supported_wfs, get_reagent_querysets,
                                             prepare_reagents, generate_experiments_and_save, get_vessel_querysets,
                                             save_manual_volumes, save_reaction_parameters)

import core.models
from core.models.view_tables import Note, TagAssign, Tag
from core.custom_types import Val
import core.experiment_templates
from core.models.view_tables import Parameter
from core.widgets import ValWidget
from core.utilities.wf1_utils import generate_robot_file
from core.utilities.experiment_utils import get_action_parameter_querysets


#from escalate.core.widgets import ValFormField

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
    ReactionParameterFormset = formset_factory(ReactionParameterForm, extra=0)

    def get_context_data(self, **kwargs):    
        # Select templates that belong to the current lab
        context = super().get_context_data(**kwargs)
        
        #lab = Actor.objects.get(organization=org_id, person__isnull=True)
        #self.all_experiments = Experiment.objects.filter(parent__isnull=True, lab=lab)
        #context['all_experiments'] = self.all_experiments
        return context
        

    def get_action_parameter_forms(self, exp_uuid, context, template=True):
        # workflow__experiment_workflow_workflow__experiment=exp_uuid
        #q1, q2, q3 = get_action_parameter_querysets(exp_uuid)
        q1 = get_action_parameter_querysets(exp_uuid, template)
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
    
    def get_colors(self, number_of_colors, colors=['deeppink', 'blueviolet', 'blue', 'coral', 'lightseagreen', 'orange', 'crimson']):
      factor = int(number_of_colors/len(colors))    
      remainder = number_of_colors % len(colors)
      total_colors = colors*factor + colors[:remainder]         
      return total_colors
    
    def get_reagent_forms(self, exp_template, context):
        if 'current_org_id' in self.request.session:
            org_id = self.request.session['current_org_id']
        else:
            org_id = None
        formsets = []
        reagent_template_names = []
        for index, reagent_template in enumerate(exp_template.reagent_templates.all().order_by('description')):
            reagent_template_names.append(reagent_template.description)
            mat_types_list = []
            initial = []
            #for material_type in reagent_template.material_type.all():
            for reagent_material_template in reagent_template.reagent_material_template_rt.all().order_by('description'):
                for reagent_material_value_template in reagent_material_template.reagent_material_value_template_rmt.filter(description='concentration'):
                    material_type = reagent_material_template.material_type
                    mat_types_list.append(material_type)
                    initial.append({'reagent_template_uuid': reagent_material_template.uuid, 
                                'material_type':material_type.uuid,
                                'desired_concentration':reagent_material_value_template.default_value.nominal_value})
            
            if mat_types_list:
                fset = self.ReagentFormSet(prefix=f'reagent_{index}', 
                                                        initial=initial,
                                                        form_kwargs={'lab_uuid': org_id, 
                                                        'mat_types_list':mat_types_list,
                                                        'reagent_index':index})
                formsets.append(fset)
        #for form in formset:
        #    form.fields[]
        context['reagent_formset_helper'] = ReagentForm.get_helper()
        context['reagent_formset_helper'].form_tag = False
        context['reagent_formset'] = formsets
        context['reagent_template_names'] = reagent_template_names

        #get vessel data for selection
        v_query = core.models.view_tables.Vessel.objects.all()
        initial_vessel = VesselForm(initial={'value': v_query[0]})
        context['vessel_form'] = initial_vessel

        # Dead volume form
        initial = {'value':Val.from_dict({'value':4000, 'unit': 'uL', 'type':'num'})}
        dead_volume_form = SingleValForm(prefix='dead_volume', initial=initial)
        context['dead_volume_form'] = dead_volume_form
        
        #reaction parameter form
        rp_wfs = get_action_parameter_querysets(exp_template.uuid)
        rp_labels = []
        index = 0
        for rp in rp_wfs:
            rp_label = str(rp.object_description)
            if "Dispense" in rp_label:
                continue
            else:
                try:
                    rp_object = ReactionParameter.objects.filter(description=rp_label).order_by('add_date').first()
                    initial= {'value':Val.from_dict({'value':rp_object.value, 'unit': rp_object.unit, 'type':'num'}), 'uuid':rp.parameter_uuid}
                except:
                    initial= {'value':Val.from_dict({'value':0, 'unit': '', 'type':'num'}), 'uuid':rp.parameter_uuid}

                rp_form = ReactionParameterForm(prefix=f'reaction_parameter_{index}',initial=initial)
                rp_labels.append((rp_label,rp_form))
                index += 1
        context['reaction_parameter_labels'] = rp_labels
        
        context['colors'] = self.get_colors(len(formsets))

        return context


    def get(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        if 'current_org_id' in self.request.session:
            org_id = self.request.session['current_org_id']
        else:
            org_id = None
        context['experiment_template_select_form'] = ExperimentTemplateForm(org_id=org_id)
        #context['robot_file_upload_form'] = UploadFileForm()
        #context['robot_file_upload_form_helper'] = UploadFileForm.get_helper()
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
                    context['robot_file_upload_form'] = RobotForm()
                    context['robot_file_upload_form_helper'] = RobotForm.get_helper()
                if context['automated']:
                    context = self.get_reagent_forms(context['selected_exp_template'], context)
            else:
                request.session['experiment_template_uuid'] = None
        # begin: create experiment
        elif 'create_exp' in request.POST:
            if "automated" in request.POST:
                context = self.process_automated_formsets(request, context)
            #elif "manual" in request.POST:
                #context=self.process_robot_formsets(request.session['experiment_template_uuid'], request, context)
        elif "robot_download" in request.POST:
            return self.download_robot_file(request.session['experiment_template_uuid'])
        elif "robot_upload" in request.POST:
            #return self.process_robot_formsets(request.session['experiment_template_uuid'], request, context)
            context=self.process_robot_formsets(request.session['experiment_template_uuid'], request, context)
        return render(request, self.template_name, context)
    
    #def process_robot_file(self, df):
        #data= df.to_html()
        #data.save()
        #return HttpResponse(data)

    def download_robot_file(self, exp_uuid):
        q1=get_action_parameter_querysets(exp_uuid) #volumes
        f=generate_robot_file(q1, {}, 'Symyx_96_well_0003', 96)
        response = FileResponse(f, as_attachment=True,
                        filename=f'robot_{exp_uuid}.xls')
        return response
        
    def process_robot_formsets(self, exp_uuid, request, context):
        context['robot_file_upload_form'] = UploadFileForm()
        context['robot_file_upload_form_helper'] = UploadFileForm.get_helper()

        exp_name_form = ExperimentNameForm(request.POST)
        if exp_name_form.is_valid():
            #experiment name
            exp_name = exp_name_form.cleaned_data['exp_name']
            
            # make the experiment copy: this will be our new experiment
            experiment_copy_uuid = experiment_copy(str(exp_uuid), exp_name)
        
        df = pd.read_excel(request.FILES['file'])
        #self.process_robot_file(df)
        save_manual_volumes(df, experiment_copy_uuid)
        
        context['experiment_link'] = reverse('experiment_instance_view', args=[experiment_copy_uuid])
        #context['reagent_prep_link'] = reverse('reagent_prep', args=[experiment_copy_uuid])
        context['outcome_link'] = reverse('outcome', args=[experiment_copy_uuid])
        context['new_exp_name'] = exp_name
        
        return context
    
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

    def save_forms_reagent(self, formset, exp_uuid, exp_concentrations):
        
        '''
        need a way to query the db table rows. in material and q1 we query 
        based on description however we only have the chemical uuid and 
        desired concentration 
        in the form. we can pass the copy experiment uuid and call that p
        otentially to get the reagentinstance/reagentinstancevalue uuid
        once this is finished test to make sure the data is saved correctly in the db.
        '''
        positions = {
            'organic': 0,
            'solvent': 1,
            'acid': 2,
            'inorganic': 3
        }
        vector = [0,0,0,0]
        for form in formset:
            if form.has_changed():
                data = form.cleaned_data 
                reagent_template_uuid = data['reagent_template_uuid']
                reagent_instance = ReagentMaterial.objects.get(template=reagent_template_uuid, 
                                                               reagent__experiment=exp_uuid,
                                                               )
                reagent_instance.material = InventoryMaterial.objects.get(uuid=data['chemical']) if data['chemical'] else None
                reagent_instance.save()
                reagent_material_value = reagent_instance.reagent_material_value_rmi.get(template__description='concentration')
                reagent_material_value.nominal_value = data['desired_concentration']
                reagent_material_value.save()
                mat_type = reagent_instance.template.material_type
                vector[positions[mat_type.description]] = data['desired_concentration']
        return vector

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
        # ref_uid will be used to identify python functions specifically for this 
        # ref_uid should follow function naming rules for Python
        template_ref_uid = exp_template.ref_uid
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
            
            save_forms_q1(q1, q1_formset, {'parameter_val_nominal': 'value', 'parameter_val_actual': 'actual_value'})
            save_forms_q_material(q1_material, q1_material_formset, {'inventory_material': 'value'})
            
            # begin: template-specific logic
            if template_ref_uid in SUPPORTED_CREATE_WFS:
                data = {}  # Stick form data into this dict
                for i, form in enumerate(q1_formset):
                    if form.is_valid():
                        query = q1[i]
                        data[query.parameter_def_description] = form.cleaned_data['value'].value
                
                # Scans experiment_templates and picks up functions that have the same name as template_name
                template_function = getattr(core.experiment_templates, template_ref_uid)
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
                context['outcome_link'] = reverse('outcome', args=[experiment_copy_uuid])
                context['new_exp_name'] = exp_name
        return context

    '''
        this function should only save the data to the db tables. refactor all other logic
    '''
    def process_automated_formsets(self, request, context):
        # get the experiment template uuid and name
        exp_template = ExperimentTemplate.objects.get(pk=request.session['experiment_template_uuid'])
        # template_name = exp_template.description
        # construct all formsets
        exp_name_form = ExperimentNameForm(request.POST)
        
        if 'current_org_id' in self.request.session:
            org_id = self.request.session['current_org_id']
        else:
            org_id = None
        formsets = []
        reagent_template_names = []
        for index, form in enumerate(exp_template.reagent_templates.all().order_by('description')):
            reagent_template_names.append(form.description)
            mat_types_list = []
            for reagent_material_template in form.reagent_material_template_rt.all().order_by('description'):
                for reagent_material_value_template in reagent_material_template.reagent_material_value_template_rmt.filter(description='concentration'):
                    mat_types_list.append(reagent_material_template.material_type)
                    formsets.append(self.ReagentFormSet(request.POST, prefix=f'reagent_{index}',
                                                form_kwargs={'lab_uuid': org_id, 
                                                'mat_types_list':mat_types_list,
                                                'reagent_index':index}))
        if exp_name_form.is_valid():
            #experiment name
            exp_name = exp_name_form.cleaned_data['exp_name']
            
            # make the experiment copy: this will be our new experiment
            experiment_copy_uuid = experiment_copy(str(exp_template.uuid), exp_name)
            exp_concentrations = {}
            for reagent_formset in formsets:            
                if reagent_formset.is_valid():
                    vector = self.save_forms_reagent(reagent_formset, experiment_copy_uuid, exp_concentrations)
                    exp_concentrations = prepare_reagents(reagent_formset, exp_concentrations)
            
            # Save dead volumes should probably be in a separate function
            dead_volume_form = SingleValForm(request.POST, prefix='dead_volume')
            if dead_volume_form.is_valid():
                dead_volume = dead_volume_form.value
            else:
                dead_volume = None
            
            #post reaction parameter form
            #get label here and get form out of label, use label for description
            rp_wfs = get_action_parameter_querysets(exp_template.uuid)
            index = 0
            for rp in rp_wfs:
                rp_label = str(rp.object_description)
                if "Dispense" in rp_label:
                    continue
                else:
                    rp_form = ReactionParameterForm(request.POST, prefix=f'reaction_parameter_{index}')
                    if rp_form.is_valid:
                        rp_value = rp_form.data[f'reaction_parameter_{index}-value_0']
                        rp_unit = rp_form.data[f'reaction_parameter_{index}-value_1']
                        rp_type = rp_form.data[f'reaction_parameter_{index}-value_2']
                        rp_uuid = rp_form.data[f'reaction_parameter_{index}-uuid']
                        save_reaction_parameters(exp_template,rp_value,rp_unit,rp_type,rp_label,experiment_copy_uuid)
                        #The rp_uuid is not being generated from the loadscript for some parameters
                        #This issue stems from the data being loaded in. This function will work once we fix loading issues
                        #if rp_uuid != "" or rp_uuid is not None:
                        #    save_parameter(rp_uuid,rp_value,rp_unit)
                    index += 1
            
            
            #retrieve # of experiments to be generated (# of vial locations)
            exp_number = int(request.POST['automated'])
            #generate desired volume for current reagent
            generate_experiments_and_save(experiment_copy_uuid, exp_concentrations, exp_number, dead_volume)
            q1 = get_action_parameter_querysets(experiment_copy_uuid, template=False)
            
            #robotfile generation
            if exp_template.ref_uid in SUPPORTED_CREATE_WFS:
                template_function = getattr(core.experiment_templates, exp_template.ref_uid)
                new_lsr_pk, lsr_msg = template_function(None, q1, experiment_copy_uuid, exp_name, exp_template)
                
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
                context['outcome_link'] = reverse('outcome', args=[experiment_copy_uuid])
                context['new_exp_name'] = exp_name                     
        return context
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
    ReagentFormSet = formset_factory(ReagentValueForm, extra=0, formset=BaseReagentFormSet,)

    def get(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        pk = kwargs['pk']
        experiment = ExperimentInstance.objects.get(pk=pk)
        context = self.get_reagent_forms(experiment, context)
        return render(request, self.template_name, context)
    
    def get_colors(self, number_of_colors, colors=['deeppink', 'blueviolet', 'blue', 'coral', 'lightseagreen', 'orange', 'crimson']):
      factor = int(number_of_colors/len(colors))    
      remainder = number_of_colors % len(colors)
      total_colors = colors*factor + colors[:remainder]         
      return total_colors
    
    def get_reagent_forms(self, experiment, context):
        formsets = []
        reagent_names = []
        reagent_template_names = []
        reagent_total_volume_forms = []
        form_kwargs = {
                'disabled_fields': ['material', 'material_type', 'nominal_value'],
            }
        
        context['helper'] = ReagentValueForm.get_helper(readonly_fields=['material', 'material_type', 'nominal_value'])
        context['helper'].form_tag = False

        context['volume_form_helper'] = PropertyForm.get_helper()
        context['volume_form_helper'].form_tag = False

        
        #for index, reagent_template in enumerate(reagent_templates):
        for index, reagent in enumerate(experiment.reagent_ei.all()):
            reagent_template_names.append(reagent.template.description)
            reagent_materials = reagent.reagent_material_r.filter(reagent_material_value_rmi__description='amount')
                                                                  #  template__reagent_template=)
            property = reagent.property_r.get(property_template__description__iexact='total volume')
            reagent_total_volume_forms.append(PropertyForm(instance=property, 
                                                           nominal_value_label = 'Calculated Volume',
                                                           value_label = 'Measured Volume',
                                                           disabled_fields=['nominal_value'])) 
            initial = []
            for reagent_material in reagent_materials:
                
                reagent_names.append(reagent_material.description)
                rmvi = reagent_material.reagent_material_value_rmi.all().get(template__description='amount')
                initial.append({'material_type':reagent_material.template.material_type.description,  
                                'material' : reagent_material.material,
                                'nominal_value' : rmvi.nominal_value,
                                'actual_value': rmvi.actual_value,
                                'uuid': rmvi.uuid})
                
            fset = self.ReagentFormSet(prefix=f'reagent_{index}', initial=initial, form_kwargs=form_kwargs)
            formsets.append(fset)

        context['reagent_formsets'] = zip(formsets, reagent_total_volume_forms)
        context['reagent_template_names']=reagent_template_names
        context['colors'] = self.get_colors(len(formsets))
        
        return context
      
    def post(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        experiment_instance_uuid = request.resolver_match.kwargs['pk']
        experiment = ExperimentInstance.objects.get(uuid=experiment_instance_uuid)
        reagent_templates = experiment.parent.reagent_templates.all()
        formsets = []
        valid_forms = True
        for index in range(len(reagent_templates)):
            property_form = PropertyForm(request.POST)
            if property_form.is_valid():
                property_form.save()
            else:
                valid_forms = False
            fset = self.ReagentFormSet(request.POST, prefix=f'reagent_{index}')
            formsets.append(fset)
            if fset.is_valid():
                for form in fset:
                    rmvi = ReagentMaterialValue.objects.get(uuid=form.cleaned_data['uuid'])
                    rmvi.actual_value = form.cleaned_data['actual_value']
                    rmvi.save()
            else:
                valid_forms = False
        
        
        if valid_forms:
            return HttpResponseRedirect(reverse('experiment_instance_list'))
        else:
            return render(request, self.template_name, context)
          
          
class ExperimentOutcomeView(TemplateView):
    template_name = "core/experiment_outcome.html"
    OutcomeFormSet = modelformset_factory(OutcomeInstance, 
                                          form=OutcomeInstanceForm, 
                                          extra=0, 
                                          widgets={'actual_value': ValWidget()})

    def get(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        pk = kwargs['pk']
        # experiment = ExperimentInstance.objects.get(pk=pk)
        # context = self.get_outcome_forms(experiment, context)
        # context['outcome_file_url'] = reverse('outcome_file', kwargs={'pk':pk})
        context['outcome_file_upload_form'] = UploadFileForm()
        context['outcome_file_upload_form_helper'] = UploadFileForm.get_helper()
        context['outcome_file_upload_form_helper'].form_tag = False
        return render(request, self.template_name, context)
    
    def get_outcome_forms(self, experiment, context):
        outcome_instances = experiment.outcome_instance_experiment_instance.all().order_by('description')

        outcome_formset = self.OutcomeFormSet(queryset=outcome_instances)
        context['outcome_formset'] = outcome_formset
        context['helper'] = OutcomeInstanceForm.get_helper()
        context['helper'].form_tag = False
        return context

    def post(self, request, *args, **kwargs):
        #context = self.get_context_data(**kwargs)
        #experiment_instance_uuid = request.resolver_match.kwargs['pk']
        # outcome_formset = self.OutcomeFormSet(request.POST)
        # if outcome_formset.is_valid():
        #   outcome_formset.save()
        if 'outcome_download' in request.POST:
            return self.download_outcome_file(kwargs['pk'])
        if 'outcome_upload' in request.POST:
            df = pd.read_csv(request.FILES['file'])
            self.process_outcome_csv(df, kwargs['pk'])
        
        if 'outcome_formset' in request.POST:
            outcome_formset = self.OutcomeFormSet(request.POST)
            if outcome_formset.is_valid():
                outcome_formset.save()
        return HttpResponseRedirect(reverse('experiment_instance_list'))

    def process_outcome_csv(self, df, exp_uuid):
        outcomes = OutcomeInstance.objects.filter(experiment_instance__uuid=exp_uuid)
        # outcome_templates = OutcomeTemplate.objects.filter(outcome_instance_ot__experiment_instance__uuid=exp_uuid).distinct()
        outcome_templates = ExperimentInstance.objects.get(uuid=exp_uuid).parent.outcome_templates.all()
        df.fillna('', inplace=True)
        for ot in outcome_templates:
            # Check if the outcome column exists in dataframe
            if ot.description in df.columns:
                # Loop through each location
                for i, row in df.iterrows():
                    o = outcomes.get(description=row[ot.description + ' location'])
                    o.actual_value.value = row[ot.description]
                    # o.actual_value.unit = 'test'
                    o.actual_value.unit = row[ot.description + ' unit']
                    # Placeholder for when all files are uploaded
                    # o.file = file in post data
                    Note.objects.create(notetext=row[ot.description + ' notes'], ref_note_uuid=o.uuid)
                    o.save()

    def download_outcome_file(self, exp_uuid):
        # Getting outcomes and its templates
        outcomes = OutcomeInstance.objects.filter(experiment_instance__uuid=exp_uuid)
        outcome_templates = OutcomeTemplate.objects.filter(outcome_instance_ot__experiment_instance__uuid=exp_uuid).distinct()

        # Constructing a dictionary for pandas table
        data = defaultdict(list)
        # Loop through each outcome type (for eg. Crystal scores, temperatures, etc)
        for ot in outcome_templates:
            # Loop through each outcome for that type (eg. Crystal score for A1, A2, ...)
            for o in outcomes.filter(outcome_template=ot):
                # Outcome description
                data[ot.description + ' location'].append(o.description)
                # Add value of outcome
                data[ot.description].append(o.actual_value.value)
                # Add unit of outcome
                data[ot.description + ' unit'].append(o.actual_value.unit)
                # Add filename of outcome (This can be used to associate any file uploaded with the well)
                data[ot.description + ' filename'].append('')
                # Extra notes the user may wish to add
                data[ot.description + ' notes'].append('')
        df = pd.DataFrame.from_dict(data)
        temp = tempfile.NamedTemporaryFile()
        df.to_csv(temp, index=False)
        temp.seek(0)
        response = FileResponse(temp, as_attachment=True,
                                filename=f'outcomes_{exp_uuid}.csv')
        return response


def save_forms_q_material(queries, formset, fields):
    """
    Saves custom formset into queries
    Args:
        queries ([Queryset]): List of queries into which the forms values are saved
        formset ([Formset]): Formset
        fields (dict): Dictionary to map the column in queryset with field in formset
    """
    for form in formset:
        if form.has_changed() and form.is_valid():
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


def save_forms_q1(queries, formset, fields):
    """Saves custom formset into queries

    Args:
        queries ([Queryset]): List of queries into which the forms values are saved
        formset ([Formset]): Formset
        fields (dict): Dictionary to map the column in queryset with field in formset
    """
    for form in formset:
        if form.has_changed() and form.is_valid():
            data = form.cleaned_data
            desc = json.loads(data['uuid'])
            if len(desc) == 2:
                object_desc, param_def_desc = desc
                query = queries.get(object_description=object_desc,
                                    parameter_def_description=param_def_desc)
            else:
                query = queries.get(object_description=desc[0])
            parameter = Parameter.objects.get(uuid=query.parameter_uuid)
            for db_field, form_field in fields.items():
                setattr(parameter, db_field, data[form_field])
            parameter.save(update_fields=list(fields.keys()))
