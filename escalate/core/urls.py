from django.urls import path, include
import core.views

from .views import (
    LoginView,
    CreateUserView,
    MainMenuView,
    SelectLabView,
    ActionSequenceView,
    ModelTagCreate,
    ModelTagUpdate,
    logout_view,
    UserProfileView,
    change_password,
    UserProfileEdit,
)
from .views.experiment import (
    CreateExperimentView,
    CreateExperimentTemplate,
    CreateReagentTemplate,
    ExperimentDetailView,
    ExperimentReagentPrepView,
    ExperimentOutcomeView,
    ExperimentDetailEditView,
)
from core.utilities.utils import view_names, camel_to_snake
from django.contrib.staticfiles.storage import staticfiles_storage
from django.views.generic.base import RedirectView
from django.views.generic.detail import DetailView
from core.views.exports.file_types import file_types as export_file_types

urlpatterns = [
    path(
        "favicon.ico",
        RedirectView.as_view(url=staticfiles_storage.url("static/favicon.ico")),
    )
]


urlpatterns = [
    path('', LoginView.as_view(), name='login'),
    path('create_user/', CreateUserView.as_view(), name='create_user'),
    path('main_menu/', MainMenuView.as_view(), name='main_menu'),
    path("select_lab/", SelectLabView.as_view(), name="select_lab"),
    path('action_sequence/', ActionSequenceView.as_view(), name='action_sequence'),
    path('logout/', logout_view, name='logout'),
    path('user_profile/', UserProfileView.as_view(), name='user_profile'),
    path('change_password/', change_password, name='change_password'),
    path('user_profile_edit/', UserProfileEdit.as_view(), name='user_profile_edit'),
    #path('param_edit/<uuid:pk>', ParameterEditView.as_view(), name='parameter_edit'),
    #path('mat_edit/<uuid:pk>', MaterialEditView.as_view(), name='material_edit'),
    path('exp_template/', CreateExperimentTemplate.as_view(),
          name='experiment_template_add'),
    path('reagent_template/', CreateReagentTemplate.as_view(),
          name='reagent_template_add'),
    path('experiment/', CreateExperimentView.as_view(),
         name='experiment_instance_add'),
#     path('experiment_list/', ExperimentListView.as_view(), name='experiment_list'),
    path("http://escalation.sd2e.org/", CreateExperimentView.as_view(), name="escalation"),
    path('experiment/<uuid:pk>/view',
         ExperimentDetailView.as_view(), name='experiment_instance_view'),
    path('experiment/<uuid:pk>',
         ExperimentDetailEditView.as_view(), name='experiment_instance_update'),
     path('experiment/<uuid:pk>/reagent_prep',
         ExperimentReagentPrepView.as_view(), name='reagent_prep'),
     path('experiment/<uuid:pk>/outcome',
         ExperimentOutcomeView.as_view(), name='outcome'),
    path('favicon.ico', RedirectView.as_view(
        url=staticfiles_storage.url('static/favicon.ico'))),
]


def add_urls(model_name, pattern_list):
    lower_case_model_name = camel_to_snake(model_name)

    new_urls = []
    if (list_view_class := getattr(core.views, f"{model_name}List", None)) != None:
        new_urls.append(
            path(
                f"{lower_case_model_name}_list/",
                list_view_class.as_view(),
                name=f"{lower_case_model_name}_list",
            )
        )
    if (create_view_class := getattr(core.views, f"{model_name}Create", None)) != None:
        new_urls.append(
            path(
                f"{lower_case_model_name}/",
                create_view_class.as_view(),
                name=f"{lower_case_model_name}_add",
            )
        )
    if (update_view_class := getattr(core.views, f"{model_name}Update", None)) != None:
        new_urls.append(
            path(
                f"{lower_case_model_name}/<uuid:pk>",
                getattr(core.views, f"{model_name}Update").as_view(),
                name=f"{lower_case_model_name}_update",
            )
        )
    if (delete_view_class := getattr(core.views, f"{model_name}Delete", None)) != None:
        new_urls.append(
            path(
                f"{lower_case_model_name}/<uuid:pk>/delete",
                delete_view_class.as_view(),
                name=f"{lower_case_model_name}_delete",
            )
        )
    if (detail_view_class := getattr(core.views, f"{model_name}View", None)) != None:
        new_urls.append(
            path(
                f"{lower_case_model_name}/<uuid:pk>/view",
                detail_view_class.as_view(),
                name=f"{lower_case_model_name}_view",
            )
        )
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
        path(
            f"{lower_case_model_name}_export_{file_type}/",
            export_view_class.as_view(),
            name=f"{lower_case_model_name}_export_{file_type}",
        )
        for file_type in export_file_types
        if (
            export_view_class := getattr(
                core.views, f"{model_name}Export{file_type.capitalize()}", None
            )
        )
        != None
    ]

    return pattern_list + new_urls + export_urls


for model_name in view_names:
    urlpatterns = add_urls(model_name, urlpatterns)


urlpatterns += [
    path("new_tag/<uuid:pk>", ModelTagCreate.as_view(), name="model_tag_create"),
    path("new_tag/<uuid:pk>", ModelTagUpdate.as_view(), name="model_tag_update"),
]
