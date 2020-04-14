from django.urls import path
from rest_framework.urlpatterns import format_suffix_patterns
from rest_api import views
from .utils import camel_case, camel_case_uuid, model_names, view_names


urlpatterns = [
    path('', views.api_root),
]

for model in model_names:
    name = camel_case(model)
    p_list = path(name+'/', getattr(views, model+'List').as_view(),
                  name=name+'-list')
    p_detail = path(name+'/<int:pk>/', getattr(views, model+'Detail').as_view(),
                    name=name+'-detail')
    urlpatterns.append(p_list)
    urlpatterns.append(p_detail)

for view in view_names:
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
