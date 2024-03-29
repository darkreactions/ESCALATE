# builtin imports
import types


# Django imports
from django.shortcuts import render, HttpResponse
from django.http import Http404, FileResponse

# Rest Imports

from rest_framework.views import APIView

from rest_framework.generics import (
    ListAPIView,
    RetrieveUpdateAPIView,
    ListCreateAPIView,
    RetrieveAPIView,
)
from rest_framework.permissions import IsAuthenticatedOrReadOnly
from rest_framework.mixins import CreateModelMixin
from django_filters import rest_framework as filters
from url_filter.integrations.drf import DjangoFilterBackend


# App imports

from .serializers import *
from .utils import (
    camel_case_uuid,
    snake_case,
    core_views,
    custom_serializer_views,
    perform_create_views,
    GET_only_views,
    docstring,
)
import core.models
import rest_api
from .rest_docs import rest_docs

view_names = core_views | custom_serializer_views


def save_actor_on_post(self, serializer):
    """Save the person POSTing as the actor associated with a resource being created

    Use this to overload perform_create on a view.
    """
    actor = Actor.objects.get(
        person_uuid=self.request.user.person, organization__isnull=True
    )
    serializer.save(actor_uuid=actor, actor_description=actor.description)


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
    modelSerializer = getattr(rest_api.serializers, model_name + "Serializer")

    methods_list = {
        "queryset": model.objects.all(),
        "serializer_class": modelSerializer,
        "permission_classes": [IsAuthenticatedOrReadOnly],
        "name": snake_case(model_name) + "-list",
        "filter_backends": [DjangoFilterBackend],
        "filter_fields": "__all__",
        "__doc__": rest_docs.get(model_name.lower(), ""),
    }
    #
    #

    methods_detail = {
        "queryset": model.objects.all(),
        "serializer_class": modelSerializer,
        "name": snake_case(model_name) + "-detail",
        "__doc__": rest_docs.get(model_name.lower() + "_detail", ""),
    }

    list_view, detail_view = (
        (ListAPIView, RetrieveAPIView)
        if model_name in GET_only_views
        else (ListCreateAPIView, RetrieveUpdateAPIView)
    )

    globals()[model_name + "List"] = type(
        model_name + "List", tuple([list_view]), methods_list
    )
    globals()[model_name + "Detail"] = type(
        model_name + "Detail", tuple([detail_view]), methods_detail
    )

    if model_name in perform_create_views:
        globals()[model_name + "List"].perform_create = save_actor_on_post
        globals()[model_name + "Detail"].perform_create = save_actor_on_post


for view_name in view_names:
    # lookup_field = camel_case_uuid(view_name)
    # create_view(view_name, lookup_field)
    create_view(view_name)

create_view("Edocument")
