#from escalate.core.models.view_tables import ActionParameterDef
from django.db import models
from django.urls import path, include, re_path
from rest_framework.response import Response
from rest_framework.reverse import reverse
from rest_framework import viewsets
from rest_framework.authtoken import views as token_views

from rest_framework.decorators import api_view

from rest_framework_extensions.routers import ExtendedSimpleRouter, NestedRouterMixin
#from rest_framework_nested import routers
from drf_spectacular.views import SpectacularAPIView, SpectacularRedocView, SpectacularSwaggerView

from rest_api import viewsets
from .utils import camel_case, dasherize, docstring, rest_exposed_url_views, rest_nested_url_views, snake_case
from .rest_docs import rest_docs
from .serializers import expandable_fields

import core.models


@api_view(['GET'])
@docstring(rest_docs['api_root'])
def api_root(request, format=None):
    response_object = {}
    for view_name in sorted(rest_exposed_url_views):
        #name = snake_case(view_name)
        name = view_name.lower()
        response_object[name] = reverse(
            name+'-list', request=request, format=format)
    return Response(response_object)

router = ExtendedSimpleRouter()

rest_urlpatterns = [

    path('api/', api_root, name='api_root'),
    path('api/login', token_views.obtain_auth_token, name='api_login'),
    path('api/download/<uuid:uuid>/',
         viewsets.download_blob, name='edoc_download'),
]

registered = router.register('experiment-template', viewsets.ExperimentTemplateViewSet, basename='experimenttemplate')
name = 'experimenttemplate'
registered.register('notes', viewsets.NoteViewSet,
                    basename=f'{name}-note', parents_query_lookups=['ref_note_uuid'])
registered.register('tags', viewsets.TagAssignViewSet,
                    basename=f'{name}-tag', parents_query_lookups=['ref_tag'])
registered.register('edocs', viewsets.EdocumentViewSet,
                    basename=f'{name}-edoc', parents_query_lookups=['ref_edocument_uuid'])
registered.register('create', viewsets.ExperimentCreateViewSet, basename=f'{name}-create',
                    parents_query_lookups=['uuid'])

registered = router.register('experiment', viewsets.ExperimentViewSet, basename='experiment')
name = 'experiment'
registered.register('notes', viewsets.NoteViewSet,
                    basename=f'{name}-note', parents_query_lookups=['ref_note_uuid'])
registered.register('tags', viewsets.TagAssignViewSet,
                    basename=f'{name}-tag', parents_query_lookups=['ref_tag'])
registered.register('edocs', viewsets.EdocumentViewSet,
                    basename=f'{name}-edoc', parents_query_lookups=['ref_edocument_uuid'])


# The following for loop helps generate nested URLs to 1 level

for view in rest_nested_url_views:
    model = getattr(core.models, view)
    # basename of an endpoint e.g. api/person/
    #name = snake_case(view)
    name = view.lower()
    dasherized_name = dasherize(view)
    # Add to related names if a field is a foriegn key
    related_names = [f'{name}_{f.name}' for f in model._meta.get_fields(
    ) if isinstance(f, (models.ForeignKey, models.ManyToManyField))]
    many_to_one_names = [f'{f.name}' for f in model._meta.get_fields(
    ) if isinstance(f, models.ManyToOneRel)]
    many_to_one_rel_model = [model._meta.get_field(
        url).remote_field.model.__name__ for url in many_to_one_names]

    url_names = [f'{f.name}' for f in model._meta.get_fields()
                 if isinstance(f, (models.ForeignKey, models.ManyToManyField))]

    # register basename, then loop through nested foreign keys and register them
    registered = router.register(rf'{dasherized_name}', getattr(
        viewsets, view+'ViewSet'), basename=name)

    for i, url in enumerate(url_names):
        related_model_name = model._meta.get_field(url).remote_field.model
        if not isinstance(related_model_name, str):
            related_model_name = related_model_name.__name__
        registered.register(rf'{url}', getattr(viewsets, related_model_name+'ViewSet'),
                            basename=f'{name}-{url}', parents_query_lookups=[related_names[i]])

    for i, related_name in enumerate(many_to_one_names):
        model_name = many_to_one_rel_model[i]
        url = model_name.lower()
        try:
            viewset = getattr(viewsets, model_name+'ViewSet')
            registered.register(rf'{url}', viewset,
                            basename=f'{name}-{url}', parents_query_lookups=[name])
        except:
            pass

    if view in expandable_fields:
        fields = expandable_fields[view]['fields']
        for field in fields:
            serializer_name, exp_dict = fields[field]
            serializer_name = serializer_name.split('.')[1]
            related_model_name = serializer_name[:-10]
            registered.register(rf'{field}', getattr(viewsets, related_model_name+'ViewSet'),
                                basename=f'{name}-{field}', parents_query_lookups=[name])

            #registered.register(field, getattr(viewsets, related_model_name+'ViewSet'))

    # Try to register notes, tags
    registered.register('notes', viewsets.NoteViewSet,
                        basename=f'{name}-note', parents_query_lookups=['ref_note_uuid'])
    registered.register('tags', viewsets.TagAssignViewSet,
                        basename=f'{name}-tag', parents_query_lookups=['ref_tag'])
    registered.register('edocs', viewsets.EdocumentViewSet,
                        basename=f'{name}-edoc', parents_query_lookups=['ref_edocument_uuid'])
    if name == 'material' or name=='mixture':
        registered.register('property', viewsets.PropertyViewSet,
                        basename=f'{name}-property', parents_query_lookups=['property_ref'])
    if name == 'action':
        registered.register('parameter', viewsets.ParameterViewSet,
                        basename=f'{name}-parameter', parents_query_lookups=['ref_object'])

schema_patterns = [
    path('api/', include(router.urls)),
    # YOUR PATTERNS
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    # Optional UI:
    path('api/schema/swagger-ui/',
         SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/schema/redoc/',
         SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
]

urlpatterns = rest_urlpatterns + schema_patterns
#import pprint
#pprint.pprint(router.get_urls())