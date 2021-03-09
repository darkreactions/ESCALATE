from django.db.models import F, Value
from django.http import HttpResponse
from django.views.generic import TemplateView
from django.forms import formset_factory, ModelChoiceField

from core.models.view_tables import ActionParameter, WorkflowActionSet, Experiment, BomMaterial
from core.models.core_tables import RetUUIDField
from core.forms.custom_types import SingleValForm, InventoryMaterialForm

class ParameterEditView(TemplateView):
    template_name = "core/parameter_editor.html"
    ParameterFormSet = formset_factory(SingleValForm, extra=0)
    
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
                        parameter_value=F('parameter_val')).annotate(
                        experiment_uuid=F(f'{related_exp}__uuid')).annotate(
                        experiment_description=F(f'{related_exp}__description')).annotate(
                        workflow_seq=F(f'{related_exp_wf}__experiment_workflow_seq'
                        )).filter(workflow_action_set__isnull=True).prefetch_related(f'{related_exp}')
            
            q2 = WorkflowActionSet.objects.filter(parameter_val__isnull=False, workflow__experiment_workflow_workflow__experiment=kwargs['pk']).only(
                            'workflow').annotate(
                            object_description=F('description')).annotate(
                            object_uuid=F('uuid')).annotate(
                            parameter_def_description=F('parameter_def__description')).annotate(
                            parameter_uuid=Value(None, RetUUIDField())).annotate(
                            parameter_value=F('parameter_val')).annotate(
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


