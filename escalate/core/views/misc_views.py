from django.db.models import F, Value
from django.views.generic import TemplateView
from django.forms import formset_factory, ModelChoiceField
from django.urls import reverse
from django.forms import modelformset_factory

from core.forms.forms import UploadEdocForm
from core.models.view_tables import WorkflowActionSet, ExperimentInstance, ExperimentTemplate, BomMaterial, Edocument #ActionParameter
from core.forms.custom_types import InventoryMaterialForm, NominalActualForm, QueueStatusForm

import json
from core.models.view_tables.organization import Actor


class ExperimentDetailEditView(TemplateView):
    '''
    Combination of Material Edit View and Parameter Edit View
    displays q1_material as well as q1-q3 and allows updating form from details page
    '''
    template_name = "core/experiment_detail_editor.html"
    NominalActualFormSet = formset_factory(NominalActualForm, extra=0)
    MaterialFormSet = formset_factory(InventoryMaterialForm, extra=0)
    post_response_template = None  # todo: draft one of these

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        related_exp_material = 'bom__experiment'
        org_id = self.request.session['current_org_id']
        lab = Actor.objects.get(organization=org_id, person__isnull=True)
        self.all_experiments = ExperimentTemplate.objects.filter(lab=lab)
        context['all_experiments'] = self.all_experiments
        pk = str(kwargs['pk'])

        experiment = ExperimentInstance.objects.get(pk=pk)
        experiment_field = f'bom__{"experiment_instance" if isinstance(experiment, ExperimentInstance) else "experiment"}'
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
        context['experiment'] = experiment

        # def hyperlinked_description(obj):
        #     d = obj.description
        #     url = obj.url
        #     return f'<a, href={url}>{d}</a>'

        overview_info = [('Queued by', experiment.operator),
                         ('Queued on', experiment.add_date),
                         ('Template', experiment.parent.description)]
        context['overview_info'] = overview_info
        qs = QueueStatusForm(experiment)
        context['queue_status_form'] = qs
        context['helper'] = qs.get_helper()


        edocs = Edocument.objects.filter(ref_edocument_uuid=experiment.uuid)
        edocs = {edoc.title:
                 self.request.build_absolute_uri(reverse('edoc_download',
                                                         args=[edoc.pk]))
                 for edoc in edocs}

        context['edocs'] = edocs
        context['edoc_upload_form'] = UploadEdocForm()


        # todo [x]: use django crispy and helper like in reagent
        # todo [x]: build edoc form with Edocument.objects.filter(ref_edocument_uuid=experiment.uuid)
        # todo [x]: plugin file form field: check user profile forms for profile upload
        # todo [x]: mimic download from detailview (not detaileditview)
        # todo []: add post functionailty
        return context
        
    def post(self, request, *args, **kwargs):
        if 'update_exp' in request.POST:
            pass
        pass
        # return render(request, self.template_name, context)