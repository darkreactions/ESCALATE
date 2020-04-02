from django.urls import path
from rest_framework.urlpatterns import format_suffix_patterns
from rest_api import views

url_prefixes = ['Actor', 'Person', 'Organization', 'Material', 'Inventory',
                'MDescriptor', 'MDescriptorClass', 'MDescriptorDef',
                'MaterialType',
                'Measure', 'MeasureType', 'Status', 'Systemtool',
                'SystemtoolType', 'Tag', 'TagType', 'ViewInventory']

urlpatterns = [
    path('', views.api_root),
]

for model in url_prefixes:
    p_list = path(model.lower()+'/', getattr(views, model+'List').as_view(),
                  name=model.lower()+'-list')
    p_detail = path(model.lower()+'/<int:pk>/', getattr(views, model+'Detail').as_view(),
                    name=model.lower()+'-detail')
    urlpatterns.append(p_list)
    urlpatterns.append(p_detail)

"""
    path('organization/', views.OrganizationList.as_view(),
         name='organization-list'),
    path('organization/<int:pk>/', views.OrganizationDetail.as_view(),
         name='organization-detail'),
    path('actor/', views.ActorList.as_view(), name='actor-list'),
    path('actor/<int:pk>/', views.ActorDetail.as_view(), name='actor-detail'),
    path('person', views.PersonList.as_view(), name='person-list'),
    path('person/<int:pk>/', views.PersonDetail.as_view(), name='person-detail'),
    path('material', views.MaterialList.as_view(), name='material-list'),
    path('material/<int:pk>/', views.MaterialDetail.as_view(),
         name='material-detail'),
    path('inventory', views.InventoryList.as_view(), name='inventory-list'),
    path('inventory/<int:pk>/', views.InventoryDetail.as_view(),
         name='inventory-detail'),
    path('mdescriptor', views.MDescriptorList.as_view(), name='mdescriptor-list'),
    path('mdescriptor/<int:pk>/', views.MDescriptorDetail.as_view(),
         name='mdescriptor-detail'),
]
"""
urlpatterns = format_suffix_patterns(urlpatterns)
