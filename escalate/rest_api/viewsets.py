
import tempfile
from uuid import UUID
import uuid

from django.http import Http404, FileResponse
from rest_framework import viewsets
from rest_framework.generics import get_object_or_404
from rest_framework.permissions import IsAuthenticatedOrReadOnly
from rest_framework_extensions.mixins import NestedViewSetMixin
from rest_framework.exceptions import ParseError
from rest_framework.parsers import FileUploadParser
from rest_framework.response import Response
from rest_framework import status

from django_filters import rest_framework as filters
from url_filter.integrations.drf import DjangoFilterBackend


from .serializers import *
import core.models
import rest_api
from .utils import rest_viewset_views, perform_create_views
from .rest_docs import rest_docs


def save_actor_on_post(self, serializer):
    """Save the person POSTing as the actor associated with a resource being created

    Use this to overload perform_create on a view.
    """
    actor = core.models.Actor.objects.get(person=self.request.user.person)
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

