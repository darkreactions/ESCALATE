from django.db.models import F, Value
from django.http import HttpResponse
from django.views.generic import TemplateView
from django.forms import formset_factory, ModelChoiceField
from django.http import HttpResponseRedirect
from django.shortcuts import render

from core.models.view_tables import ActionParameter, WorkflowActionSet, Experiment, BomMaterial, ParameterDef
from core.models.core_tables import RetUUIDField
from core.forms.custom_types import SingleValForm, InventoryMaterialForm
from core.utils import experiment_copy


class CreateExperimentView(TemplateView):
    template_name = "core/create_experiment.html"
    all_experiments = Experiment.objects.all()
    ParameterFormSet = formset_factory(SingleValForm, extra=0)
    MaterialFormSet = formset_factory(InventoryMaterialForm, extra=0)

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['all_experiments'] = self.all_experiments
        return context

    def get_action_parameter_querysets(self, exp_uuid):
        related_exp = 'workflow__experiment_workflow_workflow__experiment'
        related_exp_wf = 'workflow__experiment_workflow_workflow'
        q1 = ActionParameter.objects.filter(**{f'{related_exp}': exp_uuid}).only('uuid').annotate(
                    object_description=F('action_description')).annotate(
                    object_uuid=F('uuid')).annotate(
                    parameter_value=F('parameter_val')).annotate(
                    experiment_uuid=F(f'{related_exp}__uuid')).annotate(
                    experiment_description=F(f'{related_exp}__description')).annotate(
                    workflow_seq=F(f'{related_exp_wf}__experiment_workflow_seq'
                    )).filter(workflow_action_set__isnull=True).prefetch_related(f'{related_exp}')
        q2 = WorkflowActionSet.objects.filter(**{f'{related_exp}': exp_uuid, 'parameter_val__isnull': False}).only(
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
        q3 = WorkflowActionSet.objects.filter(**{f'{related_exp}': exp_uuid, 'calculation__isnull': True}).only(
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
        return q1, q2, q3

    def get_action_parameter_forms(self, exp_uuid, context):
        #workflow__experiment_workflow_workflow__experiment=exp_uuid
        q1, q2, q3 = self.get_action_parameter_querysets(exp_uuid)

        #context['q1_formset'] = self.ParameterFormSet(initial=[{'value': row.parameter_value} for row in q1])
        initial_q1 = [{'value': row.parameter_value} for row in q1]
        initial_q2 = [{'value': param} for row in q2 for param in row.parameter_value]
        initial_q3 = [{'value': row.parameter_value} for row in q3]

        q1_details = [f'{row.object_description} : {row.parameter_def_description}' for row in q1]
        q2_details = [f'{row.object_description} : {row.parameter_def_description}' for row in q2]
        q3_details = [f'{row.object_description} : {row.parameter_def_description}' for row in q3]
        context['q1_param_formset'] = self.ParameterFormSet(initial=initial_q1, prefix='q1_param')
        context['q2_param_formset'] = self.ParameterFormSet(initial=initial_q2, prefix='q2_param')
        context['q3_param_formset'] = self.ParameterFormSet(initial=initial_q3, prefix='q3_param')

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
        initial_q1 = [{'value': row.inventory_material} for row in q1]

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

            # check if the template is one that this one-time procedure supports
            # if template_name == "test_lanl_liq_sol":  # this can be a list or the key of a dict

            # make the experiment copy
            experiment_copy_uuid = experiment_copy(str(exp_template.uuid), 'test_liq_sol_copy')
            new_exp = Experiment.objects.get(pk=experiment_copy_uuid)

            # now we have to do the UPDATEs that correspond to the GETs in get_{material, action_parameter}_forms above
            # this is straightforward, expect for calculation parameters (q3). Now is the time to sort that out...

            q1, q2, q3 = self.get_action_parameter_querysets(experiment_copy_uuid)
            q1_formset = self.ParameterFormSet(request.POST, prefix='q1_param')
            q2_formset = self.ParameterFormSet(request.POST, prefix='q2_param')
            q3_formset = self.ParameterFormSet(request.POST, prefix='q3_param')

            for q, qfs in zip([q1, q2, q3], [q1_formset, q2_formset, q3_formset]):
                for i, form in enumerate(qfs):
                    if form.is_valid():
                        q[i].parameter_value = form.cleaned_data['value']
                        q[i].save()
                        



            ## end: one-time procedure
            

        
        return render(request, self.template_name, context)

