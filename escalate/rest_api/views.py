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

from .serializers import *
from .utils import camel_case_uuid, camel_case, model_names, view_names
import core.models
import rest_api


@api_view(['GET'])
def api_root(request, format=None):
    response_object = {}
    for model_name in model_names:
        name = camel_case(model_name)
        response_object[name] = reverse(
            name+'_list', request=request, format=format)

    for view_name in view_names:
        name = camel_case(view_name)
        response_object[name] = reverse(
            name+'_list', request=request, format=format)

    return Response(response_object)


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


def create_view(model_name, lookup_field=None):
    model = getattr(core.models, model_name)
    modelSerializer = getattr(rest_api.serializers, model_name+'Serializer')

    methods_list = {"queryset": model.objects.all(),
                    "serializer_class": modelSerializer,
                    "name": camel_case(model_name)+'_list'}

    methods_detail = {"queryset": model.objects.all(),
                      "serializer_class": modelSerializer,
                      "name": camel_case(model_name)+'_detail'}
    # if lookup_field:
    #    methods_detail["lookup_field"] = lookup_field

    # "lookup_field": model_name + '_uuid'}
    globals()[model_name+'List'] = type(model_name + 'List',
                                        tuple([ListAPIView]), methods_list)
    globals()[model_name+'Detail'] = type(model_name + 'Detail',
                                          tuple([RetrieveAPIView]), methods_detail)


for model_name in model_names:
    create_view(model_name)

for view_name in view_names:
    lookup_field = camel_case_uuid(view_name)
    create_view(view_name, lookup_field)
