from django.db.models import F, Value
from django.http import HttpResponse
from django.views.generic import TemplateView
from django.forms import formset_factory, ModelChoiceField

from core.models.view_tables import WorkflowActionSet, Experiment, BomMaterial #ActionParameter
from core.models.core_tables import RetUUIDField
from core.forms.custom_types import InventoryMaterialForm, NominalActualForm

from core.forms.forms import ExperimentNameForm
from core.utilities.utils import experiment_copy
import json
from django.shortcuts import render
from core.utilities.experiment_utils import update_dispense_action_set
from core.custom_types import Val
from core.models.view_tables.organization import Actor
from django.urls import reverse, reverse_lazy

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


class ExperimentDetailEditView(TemplateView):
    '''
    Combination of Material Edit View and Parameter Edit View
    displays q1_material as well as q1-q3 and allows updating form from details page
    '''
    template_name = "core/experiment_detail_editor.html"
    NominalActualFormSet = formset_factory(NominalActualForm, extra=0)
    MaterialFormSet = formset_factory(InventoryMaterialForm, extra=0)

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        related_exp = 'workflow__experiment_workflow_workflow__experiment'
        related_exp_wf = 'workflow__experiment_workflow_workflow'
        related_exp_material = 'bom__experiment'
        org_id = self.request.session['current_org_id']
        lab = Actor.objects.get(organization=org_id, person__isnull=True)
        self.all_experiments = Experiment.objects.filter(parent__isnull=True, lab=lab)
        context['all_experiments'] = self.all_experiments
        pk = str(kwargs['pk'])

        experiment = Experiment.objects.get(pk=pk)
        q1_material = BomMaterial.objects.filter(bom__experiment=experiment).only(
                    'uuid').annotate(
                    object_description=F('description')).annotate(
                    object_uuid=F('uuid')).annotate(
                    experiment_uuid=F(f'{related_exp_material}__uuid')).annotate(
                    experiment_description=F(f'{related_exp_material}__description')).prefetch_related(f'{related_exp_material}')
            
        q1 = ActionParameter.objects.filter(workflow__experiment_workflow_workflow__experiment=pk).only('uuid').annotate(
                    object_description=F('action_description')).annotate(
                    object_uuid=F('uuid')).annotate(
                    parameter_value=F('parameter_val_nominal')).annotate(
                    experiment_uuid=F(f'{related_exp}__uuid')).annotate(
                    experiment_description=F(f'{related_exp}__description')).annotate(
                    workflow_seq=F(f'{related_exp_wf}__experiment_workflow_seq'
                    )).filter(workflow_action_set__isnull=True).prefetch_related(f'{related_exp}')
        
        q2 = WorkflowActionSet.objects.filter(parameter_val_nominal__isnull=False, workflow__experiment_workflow_workflow__experiment=pk).only(
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
        q3 = WorkflowActionSet.objects.filter(calculation__isnull=False, workflow__experiment_workflow_workflow__experiment=pk).only(
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
        
        initial_q1 = []
        initial_q2 = []
        initial_q3 = []

        #q1 material initial       
        initial_q1_material = [{'value': row.inventory_material, 'uuid': json.dumps([f'{row.object_description}'])} for row in q1_material]
        #initial_q1_material = [{'value': row.inventory_material} for row in q1_material]
        
        #q1 initial
        for row in q1:
            data = {'value': row.parameter_value, \
                'uuid': json.dumps([f'{row.object_description}', f'{row.parameter_def_description}'])}
            if 'array' in row.parameter_value.val_type.description:
                data['actual_value'] = Val.from_dict({'type':'array_num', \
                                                      'value':[0]*len(row.parameter_value.value), \
                                                      'unit':row.parameter_value.unit})
            else:
                data['actual_value'] = Val.from_dict({'type':'num', \
                                                      'value':0, \
                                                      'unit':row.parameter_value.unit})
            
            initial_q1.append(data)

        #q2 initial
        for row in q2:
            for param in row.parameter_value:
                data = {'value': param, \
                    'uuid': json.dumps([f'{row.object_description}', f'{row.parameter_def_description}'])}
                if 'array' in param.val_type.description:
                    data['actual_value'] = Val.from_dict({'type':'array_num', \
                                                          'value':[0]*len(param.value), \
                                                          'unit':param.unit})
                else:
                    data['actual_value'] = Val.from_dict({'type':'num', \
                                                          'value':0, \
                                                          'unit':param.unit})
                
                initial_q2.append(data)
            
        #q3 initial
        for row in q3:
            data = {'value': row.parameter_value, \
                'uuid': json.dumps([f'{row.object_description}', f'{row.parameter_def_description}'])}
            if 'array' in row.parameter_value.val_type.description:
                data['actual_value'] = Val.from_dict({'type':'array_num', \
                                                      'value':[0]*len(row.parameter_value.value), \
                                                      'unit':row.parameter_value.unit})
            else:
                data['actual_value'] = Val.from_dict({'type':'num', \
                                                      'value':0, \
                                                      'unit':row.parameter_value.unit})
            
            initial_q3.append(data)

        q1_material_details = [f'{row.object_description}' for row in q1_material]
        form_kwargs = {'org_uuid':self.request.session['current_org_id']}
        
        q1_details = [f'{row.object_description} : {row.parameter_def_description}' for row in q1]
        q2_details = [f'{row.object_description} : {row.parameter_def_description}' for row in q2 for param in row.parameter_value]
        q3_details = [f'{row.object_description} : {row.parameter_def_description}' for row in q3]
        
        context['q1_material_formset'] = self.MaterialFormSet(initial=initial_q1_material, prefix='q1_material', form_kwargs=form_kwargs)
        context['q1_formset'] = self.NominalActualFormSet(initial=initial_q1, prefix='q1_param')
        context['q2_formset'] = self.NominalActualFormSet(initial=initial_q2, prefix='q2_param')
        context['q3_formset'] = self.NominalActualFormSet(initial=initial_q3, prefix='q3_param')

        context['q1_material'] = q1_material
        context['q1'] = q1
        context['q2'] = q2
        context['q3'] = q3

        context['q1_material_details'] = q1_material_details
        context['q1_details'] = q1_details
        context['q2_details'] = q2_details
        context['q3_details'] = q3_details

        context['experiment'] = experiment
        return context
        
    def post(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        # get the experiment template uuid and name
        exp_template = Experiment.objects.get(pk=request.session['experiment_template_uuid'])
        #print("THIS IS THE EXPERIMENT TEMPLATE:",exp_template)
        template_name = exp_template.description
        #print("THIS IS THE EXPERIMENT DESCRIPTION:",exp_template.uuid)


        # construct all formsets
        q1_formset = self.NominalActualFormSet(request.POST, prefix='q1_param')
        q2_formset = self.NominalActualFormSet(request.POST, prefix='q2_param')
        q3_formset = self.NominalActualFormSet(request.POST, prefix='q3_param')
        q1_material_formset = self.MaterialFormSet(request.POST,
                                                   prefix='q1_material',
                                                   form_kwargs={'org_uuid': self.request.session['current_org_id']})

        if all([q1_formset.is_valid(), 
                q2_formset.is_valid(), 
                q3_formset.is_valid(), 
                q1_material_formset.is_valid()]):
            
            q1 = context['q1']
            q1_material = context['q1_material']
            q2 = context['q2']
            q3 = context['q3']

            # update values of new experiment where no special logic is required
            for query_set, query_form_set in zip([q1, q1_material, q2, q3],
                                                 [q1_formset, q1_material_formset, q2_formset, q3_formset]):
                for i, form in enumerate(query_form_set):
                    if form.has_changed() and form.is_valid():
                        data = form.cleaned_data
                        print(data.keys())
                        desc = json.loads(data['uuid'])
                        if len(desc) == 2:
                            object_desc, param_def_desc = desc
                            query = query_set.get(object_description=object_desc, parameter_def_description=param_def_desc)
                        else:
                            query = query_set.get(object_description=desc[0])

                        # need to update value for material, q1-q3 nominal
                        # need to update actual_value for q1,q3 actual and need to create new method for q2
                        if query_form_set is q2_formset:
                            update_dispense_action_set(query, data['value'])
                            update_dispense_action_set(query, data['actual_value'])
                        elif query_form_set is q1_material_formset:
                            setattr(query, 'inventory_material', data['value'])
                        else:
                            setattr(query, 'parameter_val', data['value'])
                            setattr(query, 'parameter_val_actual', data['actual_value'])
                            query.save()
                        
            context['experiment_link'] = reverse('experiment_list')
            render(request, self.template_name, context)
            #render(request, self.template_name, context)
        else:
            return render(request, self.template_name, context)
            print("q1: ",q1_formset.errors)
            print("q2: ",q2_formset.errors)
            print("q3: ",q3_formset.errors)
            print("q1_material: ",q1_material_formset.errors)
# this might not be needed       
        return render(request, self.template_name, context)
# end: self.post()
