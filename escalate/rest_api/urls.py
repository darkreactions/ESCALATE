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


from rest_api import views, viewsets
from .utils import camel_case, docstring, rest_exposed_url_views, rest_nested_url_views
from .rest_docs import rest_docs
from .serializers import expandable_fields

import core.models


@api_view(['GET'])
@docstring(rest_docs['api_root'])
def api_root(request, format=None):
    response_object = {}
    for view_name in sorted(rest_exposed_url_views):
        name = camel_case(view_name)
        response_object[name] = reverse(
            name+'-list', request=request, format=format)
    return Response(response_object)


rest_urlpatterns = [

    path('api/', api_root, name='api_root'),
    path('api/login', token_views.obtain_auth_token, name='api_login'),
    path('api/download/<uuid:uuid>/',
         viewsets.download_blob, name='edoc_download'),
    path('api/experimentmeasurecalculation/', views.ExperimentMeasureCalculationList.as_view(),
         name='experimentmeasurecalculation-list'),
    path('api/experimentmeasurecalculation/<str:pk>/',
         views.ExperimentMeasureCalculationDetail.as_view(), name='experimentmeasurecalculation-detail'),
    #path('api/actionparameterdef/<int:pk>/',views.ActionParameterDefDetail.as_view(), name='actionparameterdef-detail')

]


router = ExtendedSimpleRouter()

# The following for loop helps generate nested URLs to 1 level

for view in rest_nested_url_views:
    model = getattr(core.models, view)
    # basename of an endpoint e.g. api/person/
    name = camel_case(view)
    # Add to related names if a field is a foriegn key
    related_names = [f'{name}_{f.name}' for f in model._meta.get_fields(
    ) if isinstance(f, models.ForeignKey)]
    many_to_one_names = [f'{f.name}' for f in model._meta.get_fields(
    ) if isinstance(f, models.ManyToOneRel)]
    many_to_one_rel_model = [model._meta.get_field(
        url).remote_field.model.__name__ for url in many_to_one_names]

    url_names = [f'{f.name}' for f in model._meta.get_fields()
                 if isinstance(f, models.ForeignKey)]

    # register basename, then loop through nested foreign keys and register them
    registered = router.register(rf'{name}', getattr(
        viewsets, view+'ViewSet'), basename=name)
    for i, url in enumerate(url_names):
        related_model_name = model._meta.get_field(url).remote_field.model
        if not isinstance(related_model_name, str):
            related_model_name = related_model_name.__name__
        registered.register(rf'{url}', getattr(viewsets, related_model_name+'ViewSet'),
                            basename=f'{name}-{url}', parents_query_lookups=[related_names[i]])

    if view in expandable_fields:
        for field in expandable_fields[view]:
            serializer_name, exp_dict = expandable_fields[view][field]
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
