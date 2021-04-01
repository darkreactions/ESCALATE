
import tempfile
from uuid import UUID
import uuid

from django.http import Http404, FileResponse
from django.db.models import F, Value
from django.urls import reverse_lazy
from rest_framework import viewsets
from rest_framework.generics import get_object_or_404
from rest_framework.permissions import IsAuthenticatedOrReadOnly
from rest_framework.views import APIView
from rest_framework_extensions.mixins import NestedViewSetMixin
from rest_framework.exceptions import ParseError
from rest_framework.parsers import FileUploadParser
from rest_framework.response import Response
from rest_framework import status

from django_filters import rest_framework as filters
from url_filter.integrations.drf import DjangoFilterBackend

from core.models.core_tables import RetUUIDField
from core.utils import experiment_copy
from .serializers import *
import core.models
from core.models.view_tables import (ActionParameter, WorkflowActionSet, 
                                     Experiment, BomMaterial, 
                                     ParameterDef, Edocument)
import rest_api
from .utils import rest_viewset_views, perform_create_views
from .rest_docs import rest_docs


def save_actor_on_post(self, serializer):
    """Save the person POSTing as the actor associated with a resource being created

    Use this to overload perform_create on a view.
    """
    p = core.models.Person.objects.get(pk=self.request.user.person.uuid)
    actor = core.models.Actor.objects.get(person=p)
    serializer.save(actor=actor, actor_description=actor.description)

# Download file view


def download_blob(request, uuid):
    edoc = core.models.Edocument.objects.get(uuid=uuid)
    contents = edoc.edocument
    filename = edoc.filename
    testfile = tempfile.TemporaryFile()
    testfile.write(contents)
    testfile.seek(0)
    response = FileResponse(testfile, as_attachment=True,
                            filename=filename)

    #response['Content-Disposition'] = 'attachment; filename=blob.pdf'
    return response


def create_viewset(model_name):
    model = getattr(core.models, model_name)
    modelSerializer = getattr(rest_api.serializers, model_name+'Serializer')

    methods_list = {"queryset": model.objects.all(),
                    "serializer_class": modelSerializer,
                    "permission_classes": [IsAuthenticatedOrReadOnly],
                    "filter_backends": [DjangoFilterBackend],
                    "filter_fields": '__all__',
                    "__doc__": rest_docs.get(model_name.lower(), '')
                    }
    viewset_classes = [NestedViewSetMixin, viewsets.ModelViewSet]
    globals()[model_name+'ViewSet'] = type(model_name + 'ViewSet',
                                           tuple(viewset_classes), methods_list)

    if model_name in perform_create_views:
        globals()[model_name+'ViewSet'].perform_create = save_actor_on_post


for view_name in rest_viewset_views:
    create_viewset(view_name)

create_viewset('Edocument')

class ExperimentCreateViewSet(NestedViewSetMixin, viewsets.ViewSet):
    permission_classes = [IsAuthenticatedOrReadOnly]
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

    def get_material_queryset(self, exp_uuid):
        related_exp = 'bom__experiment'
        experiment = Experiment.objects.get(pk=exp_uuid)
        q1 = BomMaterial.objects.filter(bom__experiment=experiment).only(
                'uuid').annotate(
                object_description=F('description')).annotate(
                object_uuid=F('uuid')).annotate(
                experiment_uuid=F(f'{related_exp}__uuid')).annotate(
                experiment_description=F(f'{related_exp}__description')).prefetch_related(f'{related_exp}')

        return q1

    def list(self, request, *args, **kwargs):
        q1, q2, q3 = self.get_action_parameter_querysets(kwargs['parent_lookup_uuid'])
        q1_mat = self.get_material_queryset(kwargs['parent_lookup_uuid'])
        
        exp_params1 = [{'parameter_value': row.parameter_value, 'object_description': f'{row.object_description}', 'parameter_def_description': f'{row.parameter_def_description}'} for row in q1]
        exp_params1 += [{'parameter_value': param, 'object_description': f'{row.object_description}', 'parameter_def_description': f'{row.parameter_def_description}'} for row in q2 for param in row.parameter_value]
        exp_params1 += [{'parameter_value': row.parameter_value, 'object_description': f'{row.object_description}', 'parameter_def_description': f'{row.parameter_def_description}'} for row in q3]
        results = {'experiment_parameters': exp_params1}

        mat_params = [{'material_name': row.object_description , 'value': request.build_absolute_uri(reverse_lazy('bommaterial-detail', args=[row.object_uuid]))} for row in q1_mat]
        
        results.update({'material_parameters': mat_params, 'experiment_name': ''})
        serializer = ExperimentDetailSerializer(results)
        
        return Response(serializer.data)
    
    def create(self, request, *args, **kwargs):
        template_uuid = kwargs['parent_lookup_uuid']
        experiment_copy_uuid = experiment_copy(template_uuid, request.data['experiment_name'])
        q1, q2, q3 = self.get_action_parameter_querysets(experiment_copy_uuid)
        q1_mat = self.get_material_queryset(experiment_copy_uuid)
        
        return Response({})



class ExperimentTemplateViewSet(NestedViewSetMixin, viewsets.ReadOnlyModelViewSet):
    queryset = Experiment.objects.filter(parent__isnull=True)
    serializer_class = ExperimentTemplateSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    filter_backends = [DjangoFilterBackend]
    filter_fields =  '__all__'

class ExperimentViewSet(NestedViewSetMixin, viewsets.ReadOnlyModelViewSet):
    queryset = Experiment.objects.filter(parent__isnull=False)
    serializer_class = ExperimentSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    filter_backends = [DjangoFilterBackend]
    filter_fields =  '__all__'


class SaveViewSet(NestedViewSetMixin, viewsets.ModelViewSet):
    # Override these two variables!
    parent_lookup = None
    ref_uuid = None

    def perform_create(self, serializer, **kwargs):
        serializer.save(**kwargs)

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        create_args = {self.ref_uuid: kwargs[self.parent_lookup]}
        self.perform_create(serializer, **create_args)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

save_viewsets = {
    'TagAssignViewSet':  {'parent_lookup': 'parent_lookup_ref_tag', 
                          'ref_uuid': 'ref_tag'},
    'NoteViewSet' : {'parent_lookup': 'parent_lookup_ref_note_uuid', 
                     'ref_uuid': 'ref_note_uuid'},
    'EdocumentViewSet' : {'parent_lookup': 'parent_lookup_ref_edocument_uuid', 
                          'ref_uuid': 'ref_edocument_uuid'}
}

for viewset_name, kwargs in save_viewsets.items():
    viewset = globals()[viewset_name]
    globals()[viewset_name] = type(viewset_name, 
                                   (viewset, SaveViewSet), 
                                   kwargs)

