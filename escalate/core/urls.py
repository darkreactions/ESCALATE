from django.urls import path, include
import core.views
from .views import (LoginView, CreateUserView, MainMenuView, WorkflowView,
                    ModelTagCreate, ModelTagUpdate, logout_view, UserProfileView,
                    change_password, UserProfileEdit)
# ParameterEditView, MaterialEditView,
from .views.misc_views import ExperimentDetailEditView
from .views.experiment import (CreateExperimentView, ExperimentDetailView,
# ExperimentListView
)
from core.utilities.utils import view_names, camel_to_snake
from core.utilities.view_utils import getattr_or_none
from django.contrib.staticfiles.storage import staticfiles_storage
from django.views.generic.base import RedirectView
from django.views.generic.detail import DetailView
from core.views.edocument import EdocumentList, EdocumentDetailView
import core.views.exports.file_types as export_file_types

urlpatterns = [
    path('favicon.ico', RedirectView.as_view(
        url=staticfiles_storage.url('static/favicon.ico')))
]


urlpatterns = [
    path('', LoginView.as_view(), name='login'),
    path('create_user/', CreateUserView.as_view(), name='create_user'),
    path('main_menu/', MainMenuView.as_view(), name='main_menu'),
    path('workflow/', WorkflowView.as_view(), name='workflow'),
    path('logout/', logout_view, name='logout'),
    path('user_profile/', UserProfileView.as_view(), name='user_profile'),
    path('change_password/', change_password, name='change_password'),
    path('user_profile_edit/', UserProfileEdit.as_view(), name='user_profile_edit'),
    #path('param_edit/<uuid:pk>', ParameterEditView.as_view(), name='parameter_edit'),
    #path('mat_edit/<uuid:pk>', MaterialEditView.as_view(), name='material_edit'),
    path('edocument_list/', EdocumentList.as_view(), name='edocument_list'),
    path('edocument_list/', EdocumentDetailView.as_view(), name='edocument_view'),
    path('create_experiment/', CreateExperimentView.as_view(),
         name='create_experiment'),
#     path('experiment_list/', ExperimentListView.as_view(), name='experiment_list'),
    path('experiment_view/<uuid:pk>',
         ExperimentDetailView.as_view(), name='experiment_view'),
    path('experiment_update/<uuid:pk>',
         ExperimentDetailEditView.as_view(), name='experiment_update'),
    path('favicon.ico', RedirectView.as_view(
        url=staticfiles_storage.url('static/favicon.ico'))),
]


def add_urls(model_name, pattern_list):
     lower_case_model_name = camel_to_snake(model_name)

     new_urls = []
     if getattr_or_none(core.views, f'{model_name}List') != None:
          new_urls.append(path(f'{lower_case_model_name}_list/',
                     getattr(core.views, f'{model_name}List').as_view(),
                     name=f'{lower_case_model_name}_list'))
     if getattr_or_none(core.views, f'{model_name}Create') != None:
          new_urls.append(path(f'{lower_case_model_name}/',
                         getattr(core.views, f'{model_name}Create').as_view(),
                         name=f'{lower_case_model_name}_add'))
     if getattr_or_none(core.views, f'{model_name}Update') != None:
          new_urls.append(path(f'{lower_case_model_name}/<uuid:pk>',
                         getattr(core.views, f'{model_name}Update').as_view(),
                         name=f'{lower_case_model_name}_update'))
     if getattr_or_none(core.views, f'{model_name}Delete') != None:
          new_urls.append(path(f'{lower_case_model_name}/<uuid:pk>/delete',
                         getattr(core.views, f'{model_name}Delete').as_view(),
                         name=f'{lower_case_model_name}_delete'))
     if getattr_or_none(core.views, f'{model_name}View') != None:
          new_urls.append(path(f'{lower_case_model_name}/<uuid:pk>/view',
                         getattr(core.views, f'{model_name}View').as_view(),
                         name=f'{lower_case_model_name}_view'))
     # new_urls = [path(f'{lower_case_model_name}_list/',
     #                     getattr(core.views, f'{model_name}List').as_view(),
     #                     name=f'{lower_case_model_name}_list'),
     #                path(f'{lower_case_model_name}/',
     #                     getattr(core.views, f'{model_name}Create').as_view(),
     #                     name=f'{lower_case_model_name}_add'),
     #                path(f'{lower_case_model_name}/<uuid:pk>',
     #                     getattr(core.views, f'{model_name}Update').as_view(),
     #                     name=f'{lower_case_model_name}_update'),
     #                path(f'{lower_case_model_name}/<uuid:pk>/delete',
     #                     getattr(core.views, f'{model_name}Delete').as_view(),
     #                     name=f'{lower_case_model_name}_delete'),
     #                path(f'{lower_case_model_name}/<uuid:pk>/view',
     #                     getattr(core.views, f'{model_name}View').as_view(),
     #                     name=f'{lower_case_model_name}_view'),
     #                ]

     export_urls = [
          path(f'{lower_case_model_name}_export_{file_type}/',
               getattr(
                    core.views, f'{model_name}Export{file_type.capitalize()}').as_view(),
               name=f'{lower_case_model_name}_export_{file_type}')
          for file_type in export_file_types.file_types if getattr_or_none(
                    core.views, f'{model_name}Export{file_type.capitalize()}') != None
     ]

     return pattern_list + new_urls + export_urls


for model_name in view_names:
    urlpatterns = add_urls(model_name, urlpatterns)


urlpatterns += [
    path('new_tag/<uuid:pk>', ModelTagCreate.as_view(), name='model_tag_create'),
    path('new_tag/<uuid:pk>', ModelTagUpdate.as_view(), name='model_tag_update'),
]
