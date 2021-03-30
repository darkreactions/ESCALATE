from django.urls import path, include
import core.views
from .views import (LoginView, CreateUserView, MainMenuView, WorkflowView,
                    ModelTagCreate, ModelTagUpdate, logout_view, UserProfileView, 
                    change_password, UserProfileEdit)
from .views.misc_views import ParameterEditView, MaterialEditView
from .views.experiment import CreateExperimentView, ExperimentDetailView, ExperimentListView
from core.utilities.utils import view_names, camel_to_snake
from django.contrib.staticfiles.storage import staticfiles_storage
from django.views.generic.base import RedirectView


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
    path('param_edit/<uuid:pk>', ParameterEditView.as_view(), name='parameter_edit'),
    path('mat_edit/<uuid:pk>', MaterialEditView.as_view(), name='material_edit'),
    path('create_experiment/', CreateExperimentView.as_view(), name='create_experiment'),
    path('experiment_list/', ExperimentListView.as_view(), name='experiment_list'),
    path('experiment_view/<uuid:pk>', ExperimentDetailView.as_view(), name='experiment_view'),
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
    path('new_tag/<uuid:pk>', ModelTagCreate.as_view(), name='model_tag_create'),
    path('new_tag/<uuid:pk>', ModelTagUpdate.as_view(), name='model_tag_update'),
]
