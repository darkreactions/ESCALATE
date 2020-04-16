from django.urls import path
from rest_framework.urlpatterns import format_suffix_patterns
from rest_api import views
from .utils import camel_case, camel_case_uuid, view_names, custom_serializer_views


urlpatterns = [
    path('', views.api_root),
    path('download/<uuid:uuid>/', views.download_blob, name='edoc_download')
]

for view in view_names+custom_serializer_views:
    name = camel_case(view)
    uuid = camel_case_uuid(view)

    p_list = path('{}/'.format(name), getattr(views, view +
                                              'List').as_view(), name=name+'-list')
    p_detail = path('{}/<uuid:pk>/'.format(name), getattr(views, view+'Detail').as_view(),
                    name=name+'-detail')
    urlpatterns.append(p_list)
    urlpatterns.append(p_detail)


print(urlpatterns)
urlpatterns = format_suffix_patterns(urlpatterns)
