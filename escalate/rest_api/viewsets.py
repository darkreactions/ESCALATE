import tempfile

from django.http import Http404, FileResponse
from rest_framework import viewsets
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
from .utils import perform_create_views, view_names, custom_serializer_views
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
    print(type(contents))
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



for view_name in view_names+custom_serializer_views:
    create_viewset(view_name)

create_viewset('Edocument')

