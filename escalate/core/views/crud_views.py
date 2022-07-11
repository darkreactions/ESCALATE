from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView
from django.contrib.auth.mixins import LoginRequiredMixin

import core.models
import core.forms
from core.views.crud_view_methods.model_view_generic import (
    GenericModelEdit,
    GenericModelList,
    GenericModelView,
    GenericDeleteView,
)
from core.views.crud_view_methods import (
    create_methods,
    detail_methods,
    update_methods,
    delete_methods,
    list_methods,
)


class LoginRequired(LoginRequiredMixin):
    login_url = "/"
    redirect_field_name = "redirect_to"


def create_list_view(model_name, methods):
    globals()[model_name + "List"] = type(
        model_name + "List", tuple([LoginRequired, GenericModelList]), methods
    )


def create_create_view(model_name, methods):
    globals()[model_name + "Create"] = type(
        model_name + "Create",
        tuple([LoginRequired, GenericModelEdit, CreateView]),
        methods,
    )


def create_update_view(model_name, methods):
    globals()[model_name + "Update"] = type(
        model_name + "Update",
        tuple([LoginRequired, GenericModelEdit, UpdateView]),
        methods,
    )


def create_delete_view(model_name, methods):
    globals()[model_name + "Delete"] = type(
        model_name + "Delete", tuple([LoginRequired, GenericDeleteView]), methods
    )


def create_detail_view(model_name, methods):
    globals()[model_name + "View"] = type(
        model_name + "View", tuple([LoginRequired, GenericModelView]), methods
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
