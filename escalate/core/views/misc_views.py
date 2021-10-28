from django.db.models import F, Value
from django.views.generic import TemplateView
from django.forms import formset_factory, ModelChoiceField
from django.urls import reverse
from django.forms import modelformset_factory
from django.shortcuts import render
from django import forms

from crispy_forms.helper import FormHelper
from crispy_forms.layout import Layout, Submit, Row, Column, Hidden, Field

from core.forms.forms import UploadEdocForm
from core.models.view_tables import WorkflowActionSet, ExperimentInstance, ExperimentTemplate, BomMaterial, Edocument #ActionParameter
from core.forms.custom_types import InventoryMaterialForm, NominalActualForm, QueueStatusForm
from core.utilities.experiment_utils import get_material_querysets, get_action_parameter_querysets

import json
from core.models.view_tables.organization import Actor
from core.views.experiment import save_forms_q_material, save_forms_q1, CreateExperimentView


class ExperimentDetailEditView(TemplateView):
    '''
    Combination of Material Edit View and Parameter Edit View
    displays q1_material as well as q1-q3 and allows updating form from details page
    '''
    template_name = "core/experiment_detail_editor.html"
    list_template = "core/experiment/list.html"
    NominalActualFormSet = formset_factory(NominalActualForm, extra=0)
    MaterialFormSet = formset_factory(InventoryMaterialForm, extra=0)
    # this is inheritance, right?
    get_action_parameter_forms = CreateExperimentView().get_action_parameter_forms
    def get_context_data(self, **kwargs):

        # Setup
        context = super().get_context_data(**kwargs)
        related_exp_material = 'bom__experiment'
        org_id = self.request.session['current_org_id']
        lab = Actor.objects.get(organization=org_id, person__isnull=True)
        self.all_experiments = ExperimentTemplate.objects.filter(lab=lab)
        context['all_experiments'] = self.all_experiments
        pk = str(kwargs['pk'])
        experiment = ExperimentInstance.objects.get(pk=pk)
        experiment_field = f'bom__{"experiment_instance" if isinstance(experiment, ExperimentInstance) else "experiment"}'
        context['experiment'] = experiment

        # Queue Status/Priority
        overview_info = [('Queued by', experiment.operator),
                         ('Queued on', experiment.add_date),
                         ('Template', experiment.parent.description)]
        context['overview_info'] = overview_info
        qs = QueueStatusForm(experiment)
        context['queue_status_form'] = qs
        context['helper'] = qs.get_helper()
        context['helper'].form_tag = False

        # Edocs
        edocs = Edocument.objects.filter(ref_edocument_uuid=experiment.uuid)
        edocs = {edoc.title:
                 self.request.build_absolute_uri(reverse('edoc_download',
                                                         args=[edoc.pk]))
                 for edoc in edocs}

        context['edocs'] = edocs
        uf = UploadFileForm()
        context['edoc_upload_form'] = uf
        context['edoc_helper'] = uf.get_helper()

        # Materials
        q1_material = BomMaterial.objects.filter(**{experiment_field: experiment}).only(
                    'uuid').annotate(
                    object_description=F('description')).annotate(
                    object_uuid=F('uuid')).annotate(
                    experiment_uuid=F(f'{related_exp_material}__uuid')).annotate(
                    experiment_description=F(f'{related_exp_material}__description')).prefetch_related(f'{related_exp_material}')

        initial_q1_material = [{'value': row.inventory_material, 'uuid': json.dumps([f'{row.object_description}'])} for row in q1_material]
        q1_material_details = [f'{row.object_description}' for row in q1_material]
        form_kwargs = {'org_uuid':self.request.session['current_org_id']}
        context['q1_material_formset'] = self.MaterialFormSet(initial=initial_q1_material, prefix='q1_material', form_kwargs=form_kwargs)
        context['q1_material'] = q1_material
        context['q1_material_details'] = q1_material_details

        # Parameters (Nominal/Actual form)
        self.get_action_parameter_forms(experiment.uuid, context, template=False)

        return context

    def get(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        return render(request, self.template_name, context)

    def post(self, request, *args, **kwargs):
        context = self.get_context_data(*args, **kwargs)
        exp = context['experiment']

        # save queue status and priority
        qs = QueueStatusForm(exp, request.POST)

        f = request.FILES.get('file')
        if f is not None:
            e = Edocument.objects.create(description=f.name,
                                         ref_edocument_uuid=exp.uuid,
                                         edocument=f.file.read(),
                                         filename=f.name)
        if qs.has_changed():
            if qs.is_valid():
                exp.priorty = qs.cleaned_data['select_queue_priority']
                exp.completion_status = qs.cleaned_data['select_queue_status']
                exp.save()
        material_qs = get_material_querysets(exp, template=False)
        material_fs = self.MaterialFormSet(request.POST,
                                           prefix='q1_material',
                                           form_kwargs={'org_uuid':
                                                        self.request.session['current_org_id']})
        save_forms_q_material(material_qs, material_fs, {'inventory_material': 'value'})

        q1 = get_action_parameter_querysets(context['experiment'].uuid, template=False)
        q1_formset = self.NominalActualFormSet(request.POST, prefix='q1_param')
        save_forms_q1(q1, q1_formset, {'parameter_val_nominal': 'value', 'parameter_val_actual': 'actual_value'})
        return render(request, self.template_name, context)


class UploadFileForm(forms.Form):
    file = forms.FileField(label='Upload completed outcome file',
                           required=False)
    @staticmethod
    def get_helper():
        helper = FormHelper()
        helper.form_class = 'form-horizontal'
        helper.label_class = 'col-lg-2'
        helper.field_class = 'col-lg-8'
        helper.layout = Layout(
            Row(Column(Field('file'))),
            #Row(Column(Submit('outcome_upload', 'Submit'))),
        )
        return helper
