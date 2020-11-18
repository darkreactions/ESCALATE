from django.urls import path, include
import core.views
from .views import (LoginView, CreateUserView, MainMenuView, WorkflowView,
                    ModelTagCreate, ModelTagUpdate, logout_view)
from core.utils import view_names, camel_to_snake
from django.contrib.staticfiles.storage import staticfiles_storage
from django.views.generic.base import RedirectView
from core.views.edocument import EdocumentList

urlpatterns = [
    path('favicon.ico', RedirectView.as_view(
        url=staticfiles_storage.url('static/favicon.ico')))
]

urlpatterns = [
    path('', LoginView.as_view(), name='login'),
    path('create_user/', CreateUserView.as_view(), name='create_user'),
    path('main_menu/', MainMenuView.as_view(), name='main_menu'),
    path('workflow/', WorkflowView.as_view(), name='workflow'),
    path('logout/', logout_view, name='logout')
]


def add_urls(model_name, pattern_list):

    lower_case_model_name = camel_to_snake(model_name)
    new_urls = [path(f'{lower_case_model_name}_list/',
                     getattr(core.views, f'{model_name}List').as_view(),
                     name=f'{lower_case_model_name}_list'),
                path(f'{lower_case_model_name}/',
                     getattr(core.views, f'{model_name}Create').as_view(),
                     name=f'{lower_case_model_name}_add'),
                path(f'{lower_case_model_name}/<uuid:pk>',
                     getattr(core.views, f'{model_name}Update').as_view(),
                     name=f'{lower_case_model_name}_update'),
                path(f'{lower_case_model_name}/<uuid:pk>/delete',
                     getattr(core.views, f'{model_name}Delete').as_view(),
                     name=f'{lower_case_model_name}_delete'),
                path(f'{lower_case_model_name}/<uuid:pk>/view',
                     getattr(core.views, f'{model_name}View').as_view(),
                     name=f'{lower_case_model_name}_view'),
                ]
    return pattern_list + new_urls


for model_name in view_names:
    urlpatterns = add_urls(model_name, urlpatterns)

urlpatterns += [
    path('edocument_list/', EdocumentList.as_view(), name='edocument_list'),
#     path('material/', MaterialCreate.as_view(), name='material_add'),
#     path('material/<uuid:pk>',
#          MaterialUpdate.as_view(), name='material_update'),
#     path('material/<uuid:pk>/delete',
#          MaterialDelete.as_view(), name='material_delete'),
#     path('material/<uuid:pk>/view',
#          MaterialView.as_view(), name='material_view')
]

"""
# Materials
urlpatterns += [
    path('material_list/', MaterialsList.as_view(), name='material_list'),
    path('material/', MaterialCreate.as_view(), name='material_add'),
    path('material/<uuid:pk>',
         MaterialUpdate.as_view(), name='material_update'),
    path('material/<uuid:pk>/delete',
         MaterialDelete.as_view(), name='material_delete'),
    path('material/<uuid:pk>/view',
         MaterialView.as_view(), name='material_view')
]

# Inventory
urlpatterns += [
    path('inventory_list/', InventoryList.as_view(), name='inventory_list'),
    path('inventory/', InventoryCreate.as_view(), name='inventory_add'),
    path('inventory/<uuid:pk>',
         InventoryUpdate.as_view(), name='inventory_update'),
    path('inventory/<uuid:pk>/delete',
         InventoryDelete.as_view(), name='inventory_delete'),
    path('inventory/<uuid:pk>/view',
         InventoryView.as_view(), name='inventory_view'),
]

# Actor
urlpatterns += [
    path('actor_list/', ActorList.as_view(), name='actor_list'),
    path('actor/', ActorCreate.as_view(), name='actor_add'),
    path('actor/<uuid:pk>',
         ActorUpdate.as_view(), name='actor_update'),
    path('actor/<uuid:pk>/delete',
         ActorDelete.as_view(), name='actor_delete'),
    path('actor/<uuid:pk>/view',
         ActorView.as_view(), name='actor_view'),
]

# Organization
urlpatterns += [
    path('organization_list/', OrganizationList.as_view(),
         name='organization_list'),
    path('organization/', OrganizationCreate.as_view(), name='organization_add'),
    path('organization/<uuid:pk>',
         OrganizationUpdate.as_view(), name='organization_update'),
    path('organization/<uuid:pk>/delete',
         OrganizationDelete.as_view(), name='organization_delete'),
    path('organization/<uuid:pk>/view',
         OrganizationView.as_view(), name='organization_view'),
]

# Person
urlpatterns += [
    path('person_list/', PersonList.as_view(), name='person_list'),
    path('person/', PersonCreate.as_view(), name='person_add'),
    path('person/<uuid:pk>',
         PersonUpdate.as_view(), name='person_update'),
    path('person/<uuid:pk>/delete',
         PersonDelete.as_view(), name='person_delete'),
    path('person/<uuid:pk>/view',
         PersonView.as_view(), name='person_view'),
]

# Latest_SystemTool_Version
urlpatterns += [
    path('systemtool_list/', SystemtoolList.as_view(), name='systemtool_list'),
    path('systemtool/', SystemtoolCreate.as_view(), name='systemtool_add'),
    path('systemtool/<uuid:pk>',
         SystemtoolUpdate.as_view(), name='systemtool_update'),
    path('systemtool/<uuid:pk>/delete',
         SystemtoolDelete.as_view(), name='systemtool_delete'),
    path('systemtool/<uuid:pk>/view',
         SystemtoolView.as_view(), name='systemtool_view'),
]

# System Type
urlpatterns += [
    path('systemtool_type_list/', SystemtoolTypeList.as_view(), name='systemtool_type_list'),
    path('systemtool_type/', SystemtoolTypeCreate.as_view(), name='systemtool_type_add'),
    path('systemtool_type/<uuid:pk>',
         SystemtoolTypeUpdate.as_view(), name='systemtool_type_update'),
    path('systemtool_type/<uuid:pk>/delete',
         SystemtoolTypeDelete.as_view(), name='systemtool_type_delete'),
    path('systemtool_type/<uuid:pk>/view',
         SystemtoolTypeView.as_view(), name='systemtool_type_view'),
]

# User Defined Fields
urlpatterns += [
    path('udf_def_list/', UdfDefList.as_view(), name='udf_def_list'),
    path('udf_def/', UdfDefCreate.as_view(), name='udf_def_add'),
    path('udf_def/<uuid:pk>',
         UdfDefUpdate.as_view(), name='udf_def_update'),
    path('udf_def/<uuid:pk>/delete',
         UdfDefDelete.as_view(), name='udf_def_delete'),
    path('udf_def/<uuid:pk>/view',
         UdfDefView.as_view(), name='udf_def_view'),
]


# Status
urlpatterns += [
    path('status_list/', StatusList.as_view(), name='status_list'),
    path('status/', StatusCreate.as_view(), name='status_add'),
    path('status/<uuid:pk>',
         StatusUpdate.as_view(), name='status_update'),
    path('status/<uuid:pk>/delete',
         StatusDelete.as_view(), name='status_delete'),
    path('status/<uuid:pk>/view',
         StatusView.as_view(), name='status_view'),
]


# Tag
urlpatterns += [
    path('tag_list/', TagList.as_view(), name='tag_list'),
    path('tag/', TagCreate.as_view(), name='tag_add'),
    path('tag/<uuid:pk>',
         TagUpdate.as_view(), name='tag_update'),
    path('tag/<uuid:pk>/delete',
         TagDelete.as_view(), name='tag_delete'),
    path('tag/<uuid:pk>/view',
         TagView.as_view(), name='tag_view'),
]


# Tag Type
urlpatterns += [
    path('tag_type_list/', TagTypeList.as_view(), name='tag_type_list'),
    path('tag_type/', TagTypeCreate.as_view(), name='tag_type_add'),
    path('tag_type/<uuid:pk>',
         TagTypeUpdate.as_view(), name='tag_type_update'),
    path('tag_type/<uuid:pk>/delete',
         TagTypeDelete.as_view(), name='tag_type_delete'),
    path('tag_type/<uuid:pk>/view',
         TagTypeView.as_view(), name='tag_type_view'),
]


# Material Type
urlpatterns += [
    path('material_type_list/', MaterialTypeList.as_view(), name='material_type_list'),
    path('material_type/', MaterialTypeCreate.as_view(), name='material_type_add'),
    path('material_type/<uuid:pk>',
         MaterialTypeUpdate.as_view(), name='material_type_update'),
    path('material_type/<uuid:pk>/delete',
         MaterialTypeDelete.as_view(), name='material_type_delete'),
    path('material_type/<uuid:pk>/view',
         MaterialTypeView.as_view(), name='material_type_view'),
]
"""

urlpatterns += [
    path('new_tag/<uuid:pk>', ModelTagCreate.as_view(), name='model_tag_create'),
    path('new_tag/<uuid:pk>', ModelTagUpdate.as_view(), name='model_tag_update'),
]
