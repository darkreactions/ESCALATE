#from escalate.core.models.view_tables import ActionParameterDef
from django.urls import path, include, re_path
from django.views.generic import TemplateView
from rest_framework.urlpatterns import format_suffix_patterns
from rest_api import views
from .utils import camel_case, camel_case_uuid, view_names, custom_serializer_views
from rest_framework.schemas import get_schema_view
from rest_framework.routers import DefaultRouter
from rest_framework import generics
from rest_framework.authtoken import views as token_views
from rest_framework_swagger.views import get_swagger_view


rest_urlpatterns = [

    path('api/', views.api_root, name='api_root'),
    path('api/login', token_views.obtain_auth_token, name='api_login'),
    path('api/download/<uuid:uuid>/', views.download_blob, name='edoc_download'),
    path('api/experimentmeasurecalculation/', views.ExperimentMeasureCalculationList.as_view(),
         name='experimentmeasurecalculation-list'),
    path('api/experimentmeasurecalculation/<str:pk>/',
         views.ExperimentMeasureCalculationDetail.as_view(), name='experimentmeasurecalculation-detail'),
    #path('api/actionparameterdef/<int:pk>/',views.ActionParameterDefDetail.as_view(), name='actionparameterdef-detail')

]

for view in view_names+custom_serializer_views:
    name = camel_case(view)
    #uuid = camel_case_uuid(view)

    p_list = path('api/{}/'.format(name), getattr(views, view +
                                                  'List').as_view(), name=name+'-list')
    p_detail = path('api/{}/<uuid:pk>/'.format(name), getattr(views, view+'Detail').as_view(),
                    name=name+'-detail')
    rest_urlpatterns.append(p_list)
    rest_urlpatterns.append(p_detail)


#urlpatterns.append(r'', include(router.urls))
#urlpatterns = format_suffix_patterns(urlpatterns)

schema_patterns = [
    path('api/docs/', get_swagger_view(patterns=rest_urlpatterns), name='swagger-ui'), ]

urlpatterns = rest_urlpatterns + schema_patterns
