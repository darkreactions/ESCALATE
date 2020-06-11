from django.urls import path, include
from .views import (LoginView, CreateUserView, MainMenuView,
                    MaterialsList, MaterialCreate, MaterialUpdate,
                    MaterialDelete, MaterialView, InventoryList,
                    InventoryCreate, InventoryDelete, InventoryUpdate,
                    InventoryView, ActorView, ActorList, ActorCreate,
                    ActorUpdate, ActorDelete, OrganizationList, OrganizationCreate,
                    OrganizationDelete, OrganizationUpdate, OrganizationView)

urlpatterns = [
    path('', LoginView.as_view(), name='login'),
    path('create_user/', CreateUserView.as_view(), name='create_user'),
    path('main_menu/', MainMenuView.as_view(), name='main_menu')
]

# Materials
urlpatterns += [
    path('material_list/', MaterialsList.as_view(), name='material_list'),
    path('material/', MaterialCreate.as_view(), name='material_add'),
    path('material/<int:pk>',
         MaterialUpdate.as_view(), name='material_update'),
    path('material/<int:pk>/delete',
         MaterialDelete.as_view(), name='material_delete'),
    path('material/<int:pk>/view',
         MaterialView.as_view(), name='material_view')
]

# Inventory
urlpatterns += [
    path('inventory_list/', InventoryList.as_view(), name='inventory_list'),
    path('inventory/', InventoryCreate.as_view(), name='inventory_add'),
    path('inventory/<int:pk>',
         InventoryUpdate.as_view(), name='inventory_update'),
    path('inventory/<int:pk>/delete',
         InventoryDelete.as_view(), name='inventory_delete'),
    path('inventory/<int:pk>/view',
         InventoryView.as_view(), name='inventory_view'),
]

# Actor
urlpatterns += [
    path('actor_list/', ActorList.as_view(), name='actor_list'),
    path('actor/', ActorCreate.as_view(), name='actor_add'),
    path('actor/<int:pk>',
         ActorUpdate.as_view(), name='actor_update'),
    path('actor/<int:pk>/delete',
         ActorDelete.as_view(), name='actor_delete'),
    path('actor/<int:pk>/view',
         ActorView.as_view(), name='actor_view'),
]


urlpatterns += [
    path('organization_list/', OrganizationList.as_view(),
         name='organization_list'),
    path('organization/', OrganizationCreate.as_view(), name='organization_add'),
    path('organization/<uuid:pk>',
         OrganizationUpdate.as_view(), name='organization_update'),
    path('organization/<uuid:organization_uuid>/delete',
         OrganizationDelete.as_view(), name='organization_delete'),
    path('organization/<uuid:pk>/view',
         OrganizationView.as_view(), name='organization_view'),
]
