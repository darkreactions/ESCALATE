# builtin imports
import types

# Django imports
from django.shortcuts import render
from django.http import Http404

# Rest Imports
from rest_framework.decorators import api_view
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.reverse import reverse
from rest_framework.generics import ListAPIView, RetrieveAPIView


# App imports
from core.models import (Actor, Person, Organization, Material, Inventory,
                         MDescriptor, MDescriptorClass, MDescriptorDef,
                         MaterialType,
                         Measure, MeasureType, Status, Systemtool,
                         SystemtoolType, Tag, TagType)

from .serializers import (ActorSerializer, PersonSerializer,
                          OrganizationSerializer, MaterialSerializer,
                          InventorySerializer,
                          MDescriptorSerializer, MDescriptorClassSerializer, MDescriptorDefSerializer,
                          MaterialTypeSerializer,
                          MeasureSerializer, MeasureTypeSerializer, StatusSerializer, SystemtoolSerializer,
                          SystemtoolTypeSerializer, TagSerializer, TagTypeSerializer)
import rest_api.serializers
import core.models

model_names = ['Actor', 'Person', 'Organization', 'Material', 'Inventory',
               'MDescriptor', 'MDescriptorClass', 'MDescriptorDef',
               'MaterialType',
               'Measure', 'MeasureType', 'Status', 'Systemtool',
               'SystemtoolType', 'Tag', 'TagType', 'ViewInventory']


@api_view(['GET'])
def api_root(request, format=None):
    response_object = {}
    for model_name in model_names:
        response_object[model_name.lower()] = reverse(
            model_name.lower()+'-list', request=request, format=format)

    return Response(response_object)
    """
    return Response({
        'organization': reverse('organization-list', request=request, format=format),
        'actor': reverse('actor-list', request=request, format=format),
        'person': reverse('person-list', request=request, format=format),
        'material': reverse('material-list', request=request, format=format),
        'inventory': reverse('inventory-list', request=request, format=format),
        'mdescriptor': reverse('mdescriptor-list', request=request, format=format),

    })
    """


"""
Hopefully DRY way to generate classes for table lists and details

Generates classes of the form:

class <model>List(ListAPIView):
    queryset = <model>.objects.all()
    serializer_class = <model>Serializer


class <model>Detail(RetrieveAPIView):
    queryset = <model>.objects.all()
    serializer_class = <model>Serializer
"""

for model_name in model_names:
    model = getattr(core.models, model_name)
    modelSerializer = getattr(rest_api.serializers, model_name+'Serializer')

    methods_list = {"queryset": model.objects.all(),
                    "serializer_class": modelSerializer}

    methods_detail = {"queryset": model.objects.all(),
                      "serializer_class": modelSerializer, }
    # "lookup_field": model_name + '_uuid'}

    globals()[model_name+'List'] = type(model_name + 'List',
                                        tuple([ListAPIView]), methods_list)
    globals()[model_name+'Detail'] = type(model_name + 'Detail',
                                          tuple([RetrieveAPIView]), methods_detail)
