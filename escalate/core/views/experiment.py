from django.db.models import F, Value
from django.http import HttpResponse
from django.views.generic import TemplateView
from django.forms import formset_factory, ModelChoiceField
from django.http import HttpResponseRedirect
from django.shortcuts import render

from core.models.view_tables import ActionParameter, WorkflowActionSet, Experiment, BomMaterial, ParameterDef
from core.models.core_tables import RetUUIDField
from core.forms.custom_types import SingleValForm, InventoryMaterialForm
from core.forms.forms import ExperimentNameForm
from core.utils import experiment_copy

from copy import deepcopy
import numpy as np
from core.custom_types import Val


def hcl_mix(stock_concentration, solution_volume, target_concentrations):
    hcl_vols = (target_concentrations * solution_volume) / stock_concentration
    h2o_vols = solution_volume - hcl_vols
    return hcl_vols, h2o_vols
                
def update_dispense_action_set(dispense_action_set, volumes, unit='mL'):
    dispense_action_set_params = deepcopy(dispense_action_set.__dict__)
    del dispense_action_set_params['_state']
    del dispense_action_set_params['uuid']
    dispense_action_set.delete()
    v = [Val.from_dict({'type': 'num', 'value': vol, 'unit': unit}) for vol in volumes]
    dispense_action_set_params['calculation_id'] = None
    dispense_action_set_params['parameter_val'] = v
    instance = WorkflowActionSet(**dispense_action_set_params)
    instance.save()


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
        q3 = WorkflowActionSet.objects.filter(calculation__isnull=False,
                                              workflow__experiment_workflow_workflow__experiment=exp_uuid).only(
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
                for query_set, query_form_set, field in zip([q1, q1_material],
                                                    [q1_formset, q1_material_formset],
                                                    ['parameter_val', 'material_uuid']):
                    for i, form in enumerate(query_form_set):
                        if form.has_changed() and form.is_valid():
                            data = form.cleaned_data
                            query = query_set[i]
                            setattr(query, field, data['value'])
                            query.save()
                
                # check if the template is one that this one-time procedure supports
                if template_name == 'test_lanl_liq_sol':  # this can be a list or the key of a dict
                    # now we have to do the UPDATEs that correspond to the GETs in get_{material, action_parameter}_forms above
                    # this is straightforward, expect for calculation parameters (q3). Now is the time to sort that out...
                    data = {} # Stick form data into this dict
                    for query_set, query_form_set, field in zip([q2, q3],
                                                        [q2_formset, q3_formset],
                                                        ['parameter_val', 'parameter_val']):
                        for i, form in enumerate(query_form_set):
                            if form.has_changed():
                                query = query_set[i]
                                data[query.parameter_def_description] = form.cleaned_data['value'].value

                    hcl_vols, h2o_vols = hcl_mix(data['stock_concentration'],
                                                 data['volume'],
                                                 np.fromstring(data['hcl_concentrations'].strip(']['), sep=',')
                                                 )
                    related_exp = 'workflow__experiment_workflow_workflow__experiment'
                    h2o_dispense_action_set = WorkflowActionSet.objects.get(**{f'{related_exp}': experiment_copy_uuid, 'description__contains': 'H2O'})
                    hcl_dispense_action_set = WorkflowActionSet.objects.get(**{f'{related_exp}': experiment_copy_uuid, 'description__contains': 'HCl'})
                    update_dispense_action_set(h2o_dispense_action_set, h2o_vols)
                    update_dispense_action_set(hcl_dispense_action_set, hcl_vols)    
            else:
                return render(request, self.template_name, context)
                
            ## end: one-time procedure
        return render(request, self.template_name, context)

