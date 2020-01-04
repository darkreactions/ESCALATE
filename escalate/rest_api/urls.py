from django.urls import path
from rest_framework.urlpatterns import format_suffix_patterns
from rest_api import views


urlpatterns = [
    path('', views.api_root),
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
]

urlpatterns = format_suffix_patterns(urlpatterns)
