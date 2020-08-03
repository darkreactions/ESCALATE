from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import SystemtoolType
from core.forms import SystemtoolTypeForm
from core.views.menu import GenericListView

from .model_view_generic import GenericModelEdit, GenericModelList, GenericModelView


class SystemtoolTypeList(GenericModelList):
    model = SystemtoolType
    context_object_name = 'systemtool_types'
    table_columns = ['Description']
    column_necessary_fields = {
        'Description': ['description']
    }
    order_field = 'description'
    field_contains = ''

    # Need this
    table_columns += ['Actions']


class SystemtoolTypeEdit(GenericModelEdit):
    model = SystemtoolType
    context_object_name = 'systemtool_type'
    form_class = SystemtoolTypeForm


class SystemtoolTypeCreate(CreateView):
    template_name = 'core/generic/edit.html'
    model = SystemtoolType
    form_class = SystemtoolTypeForm
    success_url = reverse_lazy('systemtool_type_list')


class SystemtoolTypeUpdate(SystemtoolTypeEdit, UpdateView):
    pass


class SystemtoolTypeDelete(DeleteView):
    model = SystemtoolType
    success_url = reverse_lazy('systemtool_type_list')


class SystemtoolTypeView(GenericModelView):
    model = SystemtoolType
    model_name = 'systemtool_type'
    detail_fields = ['Description', 'Add Date', 'Last Modification Date']
    detail_fields_need_fields = {
        'Description': ['description'],
        'Add Date': ['add_date'],
        'Last Modification Date': ['mod_date']
    }
