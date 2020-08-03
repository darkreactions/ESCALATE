from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView
from django.forms.models import model_to_dict

from core.models import Inventory
from core.forms import InventoryForm
from core.views.menu import GenericListView

from .model_view_generic import GenericModelEdit, GenericModelList, GenericModelView


class InventoryList(GenericModelList):
    model = Inventory
    context_object_name = 'inventorys'
    table_columns = ['Description', 'Status', 'Material', 'On Hand Amount']
    column_necessary_fields = {
        'Description': ['inventory_description'],
        'Status': ['status_description'],
        'Material': ['material_description'],
        'On Hand Amount': ['onhand_amt']
    }
    order_field = 'inventory_description'
    field_contains = ''

    # Need this
    table_columns += ['Actions']


class InventoryEdit(GenericModelEdit):
    model = Inventory
    context_object_name = 'inventory'
    form_class = InventoryForm


class InventoryCreate(CreateView):
    template_name = 'core/generic/edit.html'
    model = Inventory
    form_class = InventoryForm
    success_url = reverse_lazy('inventory_list')


class InventoryUpdate(InventoryEdit, UpdateView):
    pass


class InventoryDelete(DeleteView):
    model = Inventory
    success_url = reverse_lazy('inventory_list')


class InventoryView(GenericModelView):
    model = Inventory
    model_name = 'inventory'
    detail_fields = ['Inventory Description', 'Actor Description', 'Material Description',
                     'Part Number', 'On Hand Amount', 'Create Date', 'Expiration Date',
                     'Inventory Location', 'Status']
    detail_fields_need_fields = {
        'Inventory Description': ['inventory_description'],
        'Actor Description': ['actor_description'],
        'Material Description': ['material_description'],
        'Part Number': ['part_no'],
        'On Hand Amount': ['onhand_amt'],
        'Create Date': ['create_date'],
        'Expiration Date': ['expiration_date'],
        'Inventory Location': ['inventory_location'],
        'Status': ['status_description']
    }
