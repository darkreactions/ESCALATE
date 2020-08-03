from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView
from django import forms

from ..models import Material
from ..forms import MaterialForm
from .menu import GenericListView

from .model_view_generic import GenericModelEdit, GenericModelList, GenericModelView


class MaterialList(GenericModelList):
    model = Material
    context_object_name = 'materials'
    table_columns = ['Chemical Name', 'Abbreviation', 'Status']
    column_necessary_fields = {
        'Chemical Name': ['chemical_name'],
        'Abbreviation': ['abbreviation'],
        'Status': ['material_status_description']
    }
    order_field = 'chemical_name'
    field_contains = ''

    # Need this
    table_columns += ['Actions']


class MaterialEdit(GenericModelEdit):
    model = Material
    context_object_name = 'material'
    form_class = MaterialForm


class MaterialCreate(CreateView):
    template_name = 'core/generic/edit.html'
    model = Material
    form_class = MaterialForm
    success_url = reverse_lazy('material_list')


class MaterialUpdate(MaterialEdit, UpdateView):
    pass


class MaterialDelete(DeleteView):
    model = Material
    success_url = reverse_lazy('material_list')


class MaterialView(GenericModelView):
    model = Material
    model_name = 'material'
    detail_fields = ['Chemical Name', 'Abbreviation', 'Molecular Formula', 'InChI',
                     'InChI Key', 'Smiles', 'Create Date', 'Status']
    detail_fields_need_fields = {
        'Chemical Name': ['chemical_name'],
        'Abbreviation': ['abbreviation'],
        'Molecular Formula': ['molecular_formula'],
        'InChI': ['inchi'],
        'InChI Key': ['inchikey'],
        'Smiles': ['smiles'],
        'Create Date': ['create_date'],
        'Status': ['material_status_description']
    }
