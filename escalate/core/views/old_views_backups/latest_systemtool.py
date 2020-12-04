from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import LatestSystemtool
from core.forms import LatestSystemtoolForm
from core.views.menu import GenericListView

from .model_view_generic import GenericModelEdit, GenericModelList, GenericModelView


class SystemtoolList(GenericModelList):
    model = LatestSystemtool
    context_object_name = 'systemtools'
    table_columns = ['Name', 'Description',
                     'System Tool Type', 'Vendor Organization']
    column_necessary_fields = {
        'Name': ['systemtool_name'],
        'Description': ['description'],
        'System Tool Type': ['systemtool_type'],
        'Vendor Organization': ['vendor_organization']
    }
    order_field = 'systemtool_name'
    field_contains = ''

    # Need this
    table_columns += ['Actions']


class SystemtoolEdit(GenericModelEdit):
    model = LatestSystemtool
    context_object_name = 'systemtool'
    form_class = LatestSystemtoolForm


class SystemtoolCreate(CreateView):
    template_name = 'core/generic/edit.html'
    model = LatestSystemtool
    form_class = LatestSystemtoolForm
    success_url = reverse_lazy('systemtool_list')


class SystemtoolUpdate(SystemtoolEdit, UpdateView):
    pass


class SystemtoolDelete(DeleteView):
    model = LatestSystemtool
    success_url = reverse_lazy('systemtool_list')


class SystemtoolView(GenericModelView):
    model = LatestSystemtool
    model_name = 'systemtool'
    detail_fields = ['Systemtool Name', 'Systemtool Description', 'Systemtool Type',
                     'Systemtool Vendor', 'Systemtool Model', 'Systemtool Serial',
                     'Systemtool Version']
    detail_fields_need_fields = {
        'Systemtool Name': ['systemtool_name'],
        'Systemtool Description': ['description'],
        'Systemtool Type': ['systemtool_type_description'],
        'Systemtool Vendor': ['organization_fullname'],
        'Systemtool Model': ['model'],
        'Systemtool Serial': ['serial'],
        'Systemtool Version': ['ver']
    }
