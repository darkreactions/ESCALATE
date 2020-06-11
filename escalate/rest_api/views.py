# builtin imports
import types
import tempfile

# Django imports
from django.shortcuts import render, HttpResponse
from django.http import Http404, FileResponse

# Rest Imports
from rest_framework.decorators import api_view
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.reverse import reverse
from rest_framework.generics import ListAPIView, RetrieveAPIView
from django_filters import rest_framework as filters
from url_filter.integrations.drf import DjangoFilterBackend


# App imports

from .serializers import *
from .utils import camel_case_uuid, camel_case, view_names, custom_serializer_views, docstring
import core.models
import rest_api
from .rest_docs import rest_docs


view_names = view_names + custom_serializer_views


@api_view(['GET'])
@docstring(rest_docs['api_root'])
def api_root(request, format=None):

    response_object = {}

    for view_name in view_names:
        name = camel_case(view_name)
        response_object[name] = reverse(
            name+'-list', request=request, format=format)

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
                    "name": camel_case(model_name)+'-list',
                    "filter_backends": [DjangoFilterBackend],
                    "filter_fields": '__all__',
                    "__doc__": rest_docs.get(model_name, '')
                    }
    #
    #

    methods_detail = {"queryset": model.objects.all(),
                      "serializer_class": modelSerializer,
                      "name": camel_case(model_name)+'-detail'}
    globals()[model_name+'List'] = type(model_name + 'List',
                                        tuple([ListAPIView]), methods_list)
    globals()[model_name+'Detail'] = type(model_name + 'Detail',
                                          tuple([RetrieveAPIView]), methods_detail)


for view_name in view_names:
    #lookup_field = camel_case_uuid(view_name)
    #create_view(view_name, lookup_field)
    create_view(view_name)

create_view('Edocument')


# Download file view
def download_blob(request, uuid):
    edoc = core.models.Edocument.objects.get(edocument_uuid=uuid)
    contents = edoc.edocument
    filename = edoc.filename
    testfile = tempfile.TemporaryFile()
    testfile.write(contents)
    testfile.seek(0)
    response = FileResponse(testfile, as_attachment=True,
                            filename=filename)

    #response['Content-Disposition'] = 'attachment; filename=blob.pdf'
    return response
