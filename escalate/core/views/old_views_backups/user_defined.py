from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import UdfDef
from core.forms import UdfDefForm
from core.views.menu import GenericListView

from .model_view_generic import GenericModelEdit, GenericModelList, GenericModelView


class UdfDefList(GenericModelList):
    model = UdfDef
    context_object_name = 'udf_defs'
    table_columns = ['Description', 'Value Type']
    column_necessary_fields = {
        'Description': ['description'],
        'Value Type': ['valtype']
    }
    order_field = 'description'
    field_contains = ''

    # Need this
    table_columns += ['Actions']


class UdfDefEdit(GenericModelEdit):
    model = UdfDef
    context_object_name = 'udf_def'
    form_class = UdfDefForm


class UdfDefCreate(CreateView):
    template_name = 'core/generic/edit.html'
    model = UdfDef
    form_class = UdfDefForm
    success_url = reverse_lazy('udf_def_list')


class UdfDefUpdate(UdfDefEdit, UpdateView):
    pass


class UdfDefDelete(DeleteView):
    model = UdfDef
    success_url = reverse_lazy('udf_def_list')


class UdfDefView(GenericModelView):
    model = UdfDef
    model_name = 'udf_def'
    detail_fields = ['Description', 'Value Type',
                     'Add Date', 'Last Modification Date']
    detail_fields_need_fields = {
        'Description': ['description'],
        'Value Type': ['valtype'],
        'Add Date': ['add_date'],
        'Last Modification Date': ['mod_date']
    }
