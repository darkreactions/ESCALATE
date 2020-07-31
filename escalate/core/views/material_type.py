from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import MaterialType
from core.forms import MaterialTypeForm
from core.views.menu import GenericListView

from .model_view_generic import GenericModelEdit, GenericModelList, GenericModelView


class MaterialTypeList(GenericModelList):
    model = MaterialType
    context_object_name = 'material_types'
    table_columns = ['Description']
    column_necessary_fields = {
        'Description': ['description']
    }
    order_field = 'description'
    field_contains = ''

    # Need this
    table_columns += ['Actions']


class MaterialTypeEdit(GenericModelEdit):
    model = MaterialType
    context_object_name = 'material_type'
    form_class = MaterialTypeForm


class MaterialTypeCreate(CreateView):
    template_name = 'core/generic/edit.html'
    model = MaterialType
    form_class = MaterialTypeForm
    success_url = reverse_lazy('material_type_list')


class MaterialTypeUpdate(MaterialTypeEdit, UpdateView):
    pass


class MaterialTypeDelete(DeleteView):
    model = MaterialType
    success_url = reverse_lazy('material_type_list')


class MaterialTypeView(GenericModelView):
    model = MaterialType
    model_name = 'material_type'
    detail_fields = ['Description', 'Add Date', 'Last Modification Date']
    detail_fields_need_fields = {
        'Description': ['description'],
        'Add Date': ['add_date'],
        'Last Modification Date': ['mod_date']
    }
