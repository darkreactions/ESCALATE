from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import Status
from core.forms import StatusForm
from core.views.menu import GenericListView

from .model_view_generic import GenericModelEdit, GenericModelList, GenericModelView


class StatusList(GenericModelList):
    model = Status
    context_object_name = 'statuss'
    table_columns = ['Description']
    column_necessary_fields = {
        'Description': ['description']
    }
    order_field = 'description'
    field_contains = ''

    # Need this
    table_columns += ['Actions']


class StatusEdit(GenericModelEdit):
    model = Status
    context_object_name = 'status'
    form_class = StatusForm


class StatusCreate(CreateView):
    template_name = 'core/generic/edit.html'
    model = Status
    form_class = StatusForm
    success_url = reverse_lazy('status_list')


class StatusUpdate(StatusEdit, UpdateView):
    pass


class StatusDelete(DeleteView):
    model = Status
    success_url = reverse_lazy('status_list')


class StatusView(GenericModelView):
    model = Status
    model_name = 'status'
    detail_fields = ['Description', 'Add Date', 'Last Modification Date']
    detail_fields_need_fields = {
        'Description': ['description'],
        'Add Date': ['add_date'],
        'Last Modification Date': ['mod_date']
    }
