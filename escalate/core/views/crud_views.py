from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

import core.models
import core.forms
from core.views.model_view_generic import GenericModelEdit, GenericModelList, GenericModelView
from core.utils import view_names, camel_to_snake
from core.views import create_methods, detail_methods, update_methods, delete_methods, list_methods


def create_list_view(model_name, methods):
    globals()[model_name+'List'] = type(model_name + 'List',
                                        tuple([GenericModelList]), methods)


def create_create_view(model_name, methods):
    globals()[model_name+'Create'] = type(model_name + 'Create',
                                          tuple([GenericModelEdit, CreateView]), methods)


def create_update_view(model_name, methods):
    globals()[model_name+'Update'] = type(model_name + 'Update',
                                          tuple([GenericModelEdit, UpdateView]), methods)


def create_delete_view(model_name, methods):
    globals()[model_name+'Delete'] = type(model_name + 'Delete',
                                          tuple([DeleteView]), methods)


def create_detail_view(model_name, methods):
    globals()[model_name+'View'] = type(model_name + 'View',
                                        tuple([GenericModelView]), methods)


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