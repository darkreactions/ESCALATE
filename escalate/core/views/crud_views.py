import core.forms
import core.models
from core.views.crud_view_methods import (
    create_methods,
    delete_methods,
    detail_methods,
    list_methods,
    update_methods,
)
from core.views.crud_view_methods.model_view_generic import (
    GenericDeleteView,
    GenericModelEdit,
    GenericModelList,
    GenericModelView,
)
from core.views.user_views import SelectLabMixin
from django.contrib.auth.mixins import LoginRequiredMixin
from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import CreateView, DeleteView, FormView, UpdateView


class LoginRequired(LoginRequiredMixin):
    login_url = "/"
    redirect_field_name = "redirect_to"


def create_list_view(model_name, methods):
    globals()[model_name + "List"] = type(
        model_name + "List",
        tuple([LoginRequired, SelectLabMixin, GenericModelList]),
        methods,
    )


def create_create_view(model_name, methods):
    globals()[model_name + "Create"] = type(
        model_name + "Create",
        tuple([LoginRequired, SelectLabMixin, GenericModelEdit, CreateView]),
        methods,
    )


def create_update_view(model_name, methods):
    globals()[model_name + "Update"] = type(
        model_name + "Update",
        tuple([LoginRequired, SelectLabMixin, GenericModelEdit, UpdateView]),
        methods,
    )


def create_delete_view(model_name, methods):
    globals()[model_name + "Delete"] = type(
        model_name + "Delete",
        tuple([LoginRequired, SelectLabMixin, GenericDeleteView]),
        methods,
    )


def create_detail_view(model_name, methods):
    globals()[model_name + "View"] = type(
        model_name + "View",
        tuple([LoginRequired, SelectLabMixin, GenericModelView]),
        methods,
    )


for model_name, methods_list in list_methods.methods.items():
    create_list_view(model_name, methods_list)

for model_name, methods_list in create_methods.methods.items():
    create_create_view(model_name, methods_list)

for model_name, methods_list in detail_methods.methods.items():
    create_detail_view(model_name, methods_list)

for model_name, methods_list in delete_methods.methods.items():
    create_delete_view(model_name, methods_list)

for model_name, methods_list in update_methods.methods.items():
    create_update_view(model_name, methods_list)
