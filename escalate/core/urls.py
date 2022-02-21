from django.urls import path, include
import core.views
from core.views.function_views import (
    download_vp_spec_file,
    # save_action_sequence,
    save_experiment_action_sequence,
)

from .views import (
    LoginView,
    CreateUserView,
    MainMenuView,
    SelectLabView,
    ActionSequenceView,
    # ExperimentActionSequenceView,
    ModelTagCreate,
    ModelTagUpdate,
    logout_view,
    UserProfileView,
    change_password,
    UserProfileEdit,
)
from .views.experiment import (
    CreateExperimentView,
    SetupExperimentView,
    CreateExperimentTemplate,
    # ExperimentDetailView,
    ExperimentReagentPrepView,
    ExperimentOutcomeView,
    ExperimentDetailEditView,
    ParameterEditView,
)

from .views.experiment.create_select_template import SelectReagentsView

from core.utilities.utils import view_names, camel_to_snake
from django.contrib.staticfiles.storage import staticfiles_storage
from django.views.generic.base import RedirectView
from django.views.generic.detail import DetailView
from core.views.exports.file_types import file_types as export_file_types

urlpatterns = [
    path("", LoginView.as_view(), name="login"),
    path("create_user/", CreateUserView.as_view(), name="create_user"),
    path("main_menu/", MainMenuView.as_view(), name="main_menu"),
    path("select_lab/", SelectLabView.as_view(), name="select_lab"),
    # path("action_sequence/", ActionSequenceView.as_view(), name="action_sequence"),
    path(
        "action_sequence/<uuid:pk>",
        ActionSequenceView.as_view(),
        name="action_sequence",
    ),
    path("logout/", logout_view, name="logout"),
    path("user_profile/", UserProfileView.as_view(), name="user_profile"),
    path("change_password/", change_password, name="change_password"),
    path("user_profile_edit/", UserProfileEdit.as_view(), name="user_profile_edit"),
    path(
        "favicon.ico",
        RedirectView.as_view(url=staticfiles_storage.url("static/favicon.ico")),
    ),
]

# Experiment Instance creation patterns
urlpatterns += [
    path(
        "experiment/setup",
        SetupExperimentView.as_view(),
        name="experiment_instance_add",
    ),
    path(
        "experiment/setup/select_reagents",
        SelectReagentsView.as_view(),
        name="select_reagents",
    ),
    path(
        "experiment/setup/create",
        CreateExperimentView.as_view(),
        name="create_experiment",
    ),
    path(
        "experiment/setup/robot_file",
        download_vp_spec_file,
        name="download_vp_spec_file",
    ),
]

# Experiment template creation patterns
urlpatterns += [
    path(
        "exp_template/",
        CreateExperimentTemplate.as_view(),
        name="experiment_template_add",
    ),
    # path("save_action_sequence/", save_action_sequence, name="save_action_sequence",),
    path(
        "save_experiment_action_sequence/",
        save_experiment_action_sequence,
        name="save_experiment_action_sequence",
    ),
]

# Experiment instance edit/view patterns
urlpatterns += [
    path(
        "experiment/<uuid:pk>",
        ExperimentDetailEditView.as_view(),
        name="experiment_instance_view",
    ),
    path(
        "experiment/<uuid:pk>",
        ExperimentDetailEditView.as_view(),
        name="experiment_instance_update",
    ),
    path(
        "experiment/<uuid:pk>/reagent_prep",
        ExperimentReagentPrepView.as_view(),
        name="reagent_prep",
    ),
    path(
        "experiment/<uuid:pk>/outcome", ExperimentOutcomeView.as_view(), name="outcome"
    ),
]

# Completed experiment patterns
urlpatterns += [
    path(
        "experiment_completed_instance/",
        CreateExperimentView.as_view(),
        name="experiment_completed_instance_add",
    ),
    path("exp_template/experiment", CreateExperimentView.as_view(), name="experiment"),
    path(
        "experiment_completed_instance/<uuid:pk>",
        ExperimentDetailEditView.as_view(),
        name="experiment_completed_instance_view",
    ),
    path(
        "experiment_completed_instance/<uuid:pk>",
        ExperimentDetailEditView.as_view(),
        name="experiment_completed_instance_update",
    ),
    path(
        "experiment_completed_instance/<uuid:pk>/parameter",
        ParameterEditView.as_view(),
        name="experiment_completed_instance_parameter",
    ),
]

# Pending experiment patterns
urlpatterns += [
    path(
        "experiment_pending_instance/",
        CreateExperimentView.as_view(),
        name="experiment_pending_instance_add",
    ),
    path(
        "experiment_pending_instance/<uuid:pk>",
        ExperimentDetailEditView.as_view(),
        name="experiment_pending_instance_view",
    ),
    path(
        "experiment_pending_instance/<uuid:pk>",
        ExperimentDetailEditView.as_view(),
        name="experiment_pending_instance_update",
    ),
    path(
        "experiment_pending_instance/<uuid:pk>/reagent_prep",
        ExperimentReagentPrepView.as_view(),
        name="experiment_pending_instance_reagent_prep",
    ),
    path(
        "experiment_pending_instance/<uuid:pk>/outcome",
        ExperimentOutcomeView.as_view(),
        name="experiment_pending_instance_outcome",
    ),
    path(
        "experiment_pending_instance/<uuid:pk>/parameter",
        ParameterEditView.as_view(),
        name="experiment_pending_instance_parameter",
    ),
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

    # return pattern_list + new_urls + export_urls
    return new_urls + export_urls


for model_name in view_names:
    urlpatterns += add_urls(model_name, urlpatterns)


urlpatterns += [
    path("new_tag/<uuid:pk>", ModelTagCreate.as_view(), name="model_tag_create"),
    path("new_tag/<uuid:pk>", ModelTagUpdate.as_view(), name="model_tag_update"),
]
