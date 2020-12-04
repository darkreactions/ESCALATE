#from escalate.core.models.view_tables import ActionParameterDef
from django.db import models
from django.urls import path, include, re_path
from django.views.generic import TemplateView
from rest_framework.response import Response
from rest_framework.reverse import reverse
from rest_framework import viewsets
from rest_framework.urlpatterns import format_suffix_patterns
from rest_framework.schemas import get_schema_view
from rest_framework.routers import DefaultRouter
from rest_framework import generics
from rest_framework.authtoken import views as token_views
from rest_framework_swagger.views import get_swagger_view
from rest_framework.decorators import api_view
from rest_framework_extensions.routers import ExtendedSimpleRouter, NestedRouterMixin

from rest_api import views, viewsets
from .utils import camel_case, camel_case_uuid, snake_case, view_names, custom_serializer_views, docstring
from .rest_docs import rest_docs

import core.models

@api_view(['GET'])
@docstring(rest_docs['api_root'])
def api_root(request, format=None):
    response_object = {}
    for view_name in view_names+custom_serializer_views:
        name = camel_case(view_name)
        response_object[name] = reverse(
            name+'-list', request=request, format=format)
    return Response(response_object)

rest_urlpatterns = [

    path('api/', api_root, name='api_root'),
    path('api/login', token_views.obtain_auth_token, name='api_login'),
    path('api/download/<uuid:uuid>/', views.download_blob, name='edoc_download'),
    path('api/experimentmeasurecalculation/', views.ExperimentMeasureCalculationList.as_view(),
         name='experimentmeasurecalculation-list'),
    path('api/experimentmeasurecalculation/<str:pk>/',
         views.ExperimentMeasureCalculationDetail.as_view(), name='experimentmeasurecalculation-detail'),
    #path('api/actionparameterdef/<int:pk>/',views.ActionParameterDefDetail.as_view(), name='actionparameterdef-detail')

]


router = ExtendedSimpleRouter()
for view in view_names+custom_serializer_views:
    model = getattr(core.models, view)
    name = camel_case(view)
    related_names = [f'{name}_{f.name}' for f in model._meta.get_fields() if isinstance(f, models.ForeignKey)]
    url_names = [f'{f.name}' for f in model._meta.get_fields() if isinstance(f, models.ForeignKey)]
    print(f'{view} : {url_names}')
    registered = router.register(rf'{name}', getattr(viewsets, view+'ViewSet'), basename=name)
    for i, url in enumerate(url_names):
        related_model_name = model._meta.get_field(url).remote_field.model
        if not isinstance(related_model_name, str):
            related_model_name = related_model_name.__name__
        registered.register(rf'{url}', getattr(viewsets, related_model_name+'ViewSet'), 
                            basename=f'{name}-{url}', parents_query_lookups=[related_names[i]])

schema_patterns = [
    path('api/docs/', get_swagger_view(patterns=rest_urlpatterns), name='swagger-ui'), 
    path('api/', include(router.urls))]

urlpatterns = rest_urlpatterns + schema_patterns 
