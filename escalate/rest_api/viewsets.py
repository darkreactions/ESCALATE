
import tempfile
from uuid import UUID
import uuid

from django.http import Http404, FileResponse
from django.db.models import F, Value
from django.urls import reverse_lazy, reverse
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
from core.utilities.utils import experiment_copy
from core.utilities.experiment_utils import update_dispense_action_set, get_action_parameter_querysets, get_material_querysets
from .serializers import *
import core.models
from core.models.view_tables import (WorkflowActionSet, #ActionParameter
                                     Experiment, BomMaterial, InventoryMaterial,
                                     ParameterDef, Edocument, ExperimentTemplate, ExperimentInstance)
import rest_api
from core.custom_types import Val
from core.experiment_templates import liquid_solid_extraction, resin_weighing, perovskite_demo
from .utils import rest_viewset_views, perform_create_views
from .rest_docs import rest_docs

SUPPORTED_CREATE_WFS = [mod for mod in dir(core.experiment_templates) if '__' not in mod]


def save_actor_on_post(self, serializer):
    """Save the person POSTing as the actor associated with a resource being created

    Use this to overload perform_create on a view.
    """
    p = core.models.Person.objects.get(pk=self.request.user.person.uuid)
    actor = core.models.Actor.objects.get(person=p, organization__isnull=True)
    #serializer.save(actor=actor, actor_description=actor.description)
    serializer.save(actor=actor)

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
    
    def list(self, request, *args, **kwargs):
        q1, q2, q3 = get_action_parameter_querysets(kwargs['parent_lookup_uuid'])
        q1_mat = get_material_querysets(kwargs['parent_lookup_uuid'])
        
        exp_params1 = [{'nominal_value': row.parameter_value, 'actual_value': row.parameter_value,'object_description': f'{row.object_description}', 'parameter_def_description': f'{row.parameter_def_description}'} for row in q1]
        exp_params2 = [{'nominal_value': param, 'actual_value': param, 'object_description': f'{row.object_description}', 'parameter_def_description': f'{row.parameter_def_description}'} for row in q2 for param in row.parameter_value]
        exp_params3 = [{'nominal_value': row.parameter_value, 'actual_value': row.parameter_value, 'object_description': f'{row.object_description}', 'parameter_def_description': f'{row.parameter_def_description}'} for row in q3]
        
        results = {'experiment_parameters_1': exp_params1, 'experiment_parameters_2': exp_params2, 'experiment_parameters_3': exp_params3}
        mat_params = [{'material_name': row.object_description , 'value': request.build_absolute_uri(reverse('inventorymaterial-detail', args=[row.inventory_material.uuid]))} for row in q1_mat]
        #mat_params = [{'material_name': row.object_description , 'value': row.object_uuid} for row in q1_mat]
        #mat_params = {row.object_description:row.object_uuid for row in q1_mat}
        
        results.update({'material_parameters': mat_params, 'experiment_name': ''})
        serializer = ExperimentDetailSerializer(results)
        
        return Response(serializer.data)

    def save_material_params(self, queryset, data):
        for entry in data:
            object_desc = entry['material_name']
            query = queryset.get(object_description=object_desc)
            uuid = entry['value'].split('/')[-2]
            print(uuid)

            query.inventory_material = InventoryMaterial.objects.get(pk=uuid)
            query.save()

    def save_params(self, queryset, data, fields):
        for entry in data:
            object_desc = entry['object_description']
            param_def_desc = entry['parameter_def_description']
            query = queryset.get(object_description=object_desc, parameter_def_description=param_def_desc)
            
            if fields is None:
                update_dispense_action_set(query, entry['value'])
            else:
                for db_field, form_field in fields.items():
                    setattr(query, db_field, entry[form_field])
                    query.save()

    
    def create(self, request, *args, **kwargs):
        template_uuid = kwargs['parent_lookup_uuid']

        exp_template = Experiment.objects.get(pk=template_uuid)
        template_name = exp_template.description

        exp_name = request.data['experiment_name']

        experiment_copy_uuid = experiment_copy(template_uuid, exp_name)
        q1, q2, q3 = get_action_parameter_querysets(experiment_copy_uuid)
        q1_mat = get_material_querysets(experiment_copy_uuid)

        self.save_material_params(q1_mat, request.data['material_parameters'])
        self.save_params(q1, request.data['experiment_parameters_1'], {'parameter_val_actual': 'actual_value', 'parameter_val_nominal': 'nominal_value'})
        self.save_params(q2, request.data['experiment_parameters_2'], None)

        if template_name in SUPPORTED_CREATE_WFS:
            if template_name == 'liquid_solid_extraction':
                lsr_edoc = Edocument.objects.get(ref_edocument_uuid=exp_template.uuid, title='LSR file')
                new_lsr_pk, lsr_msg = liquid_solid_extraction(data, q3, experiment_copy_uuid, lsr_edoc, exp_name)
            elif template_name == 'resin_weighing':
                lsr_edoc = Edocument.objects.get(ref_edocument_uuid=exp_template.uuid, title='LSR file')
                new_lsr_pk, lsr_msg = resin_weighing(experiment_copy_uuid, lsr_edoc, exp_name)
            elif template_name == 'perovskite_demo':
                new_lsr_pk, lsr_msg = perovskite_demo(data, q3, experiment_copy_uuid, exp_name)

        return Response({'experiment_detail': request.build_absolute_uri(reverse('experiment-detail', args=[experiment_copy_uuid])),
                        'generated_file': request.build_absolute_uri(reverse('edoc_download', args=[new_lsr_pk]))})



class ExperimentTemplateViewSet(NestedViewSetMixin, viewsets.ModelViewSet):
    #queryset = Experiment.objects.filter(parent__isnull=True)
    queryset = ExperimentTemplate.objects.all()
    serializer_class = ExperimentTemplateSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    filter_backends = [DjangoFilterBackend]
    filter_fields =  '__all__'

class ExperimentInstanceViewSet(NestedViewSetMixin, viewsets.ModelViewSet):
    #queryset = Experiment.objects.filter(parent__isnull=True)
    queryset = ExperimentInstance.objects.all()
    serializer_class = ExperimentInstanceSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    filter_backends = [DjangoFilterBackend]
    filter_fields =  '__all__'

class ExperimentViewSet(NestedViewSetMixin, viewsets.ModelViewSet):
    #queryset = Experiment.objects.filter(parent__isnull=False)
    queryset = Experiment.objects.all()
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
                          'ref_uuid': 'ref_edocument_uuid'},
    'PropertyViewSet': {'parent_lookup': 'parent_lookup_property_ref',
                        'ref_uuid': 'property_ref'},
    'ParameterViewSet': {'parent_lookup': 'parent_lookup_ref_object',
                        'ref_uuid': 'ref_object'}
}

for viewset_name, kwargs in save_viewsets.items():
    viewset = globals()[viewset_name]
    globals()[viewset_name] = type(viewset_name, 
                                   (viewset, SaveViewSet), 
                                   kwargs)

