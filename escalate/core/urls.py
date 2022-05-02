from django.urls import path, include
import core.views
from core.views.function_views import (
    download_vp_spec_file,
    download_manual_spec_file,
    save_experiment_action_template,
    experiment_invalid,
)

from .views import (
    LoginView,
    CreateUserView,
    MainMenuView,
    SelectLabView,
    ActionTemplateView,
    ModelTagCreate,
    ModelTagUpdate,
    logout_view,
    UserProfileView,
    change_password,
    UserProfileEdit,
)
from .views.experiment import (
    ExperimentReagentPrepView,
    ExperimentOutcomeView,
    ExperimentDetailEditView,
    ParameterEditView,
    CreateExperimentWizard,
    CreateTemplateWizard,
)


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
    path(
        "action_template/<uuid:pk>",
        ActionTemplateView.as_view(),
        name="action_template",
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
        "experiment/setup/robot_file",
        download_vp_spec_file,
        name="download_vp_spec_file",
    ),
]

urlpatterns += [
    path(
        "experiment-instance/",
        CreateExperimentWizard.as_view(),
        name="experiment_instance_add",
    ),
    path(
        "experiment-instance/robot_file",
        download_manual_spec_file,
        name="download_manual_spec_file",
    ),
]

# Experiment template creation patterns
urlpatterns += [
    path(
        "exp_template/",
        CreateTemplateWizard.as_view(),
        name="experiment_template_add",
    ),
    # path("save_action_sequence/", save_action_sequence, name="save_action_sequence",),
    path(
        "save_experiment_action_template/",
        save_experiment_action_template,
        name="save_experiment_action_template",
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
    path(
        "experiment_completed_instance/<uuid:pk>/delete",
        experiment_invalid,
        name="experiment_completed_instance_delete",
    ),
]

# Pending experiment patterns
urlpatterns += [
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
    path(
        "experiment_pending_instance/<uuid:pk>/delete",
        experiment_invalid,
        name="experiment_pending_instance_delete",
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
        # remove ExperimentPendingInstance and ExperimentCompletedInstance
        if (
            lower_case_model_name != "experiment_pending_instance"
            and lower_case_model_name != "experiment_completed_instance"
        ):
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
