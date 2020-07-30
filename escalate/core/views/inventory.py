from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView
from django.forms.models import model_to_dict

from core.models import Inventory
from core.forms import InventoryForm
from core.views.menu import GenericListView

from .model_view_generic import GenericModelEdit, GenericModelList, GenericModelView

# class InventoryList(GenericListView):
#     model = Inventory
#     #template_name = 'core/inventory/inventory_list.html'
#     template_name = 'core/generic/list.html'
#     context_object_name = 'inventory'
#     paginate_by = 10
#
#     def get_queryset(self):
#
#         # added get_queryset method
#         filter_val = self.request.GET.get('filter', '')
#         ordering = self.request.GET.get('ordering', 'inventory_description')
#         # order by description
#         if filter_val != None:
#             new_queryset = self.model.objects.filter(
#                 inventory_description__icontains=filter_val).select_related().order_by(ordering)
#             # filter by decription being a empty/nonempty string
#         else:
#             new_queryset = self.model.objects.all().select_related().order_by(ordering)
#         return new_queryset
#
#     def get_context_data(self, **kwargs):
#         context = super().get_context_data(**kwargs)
#         table_columns = ['Description', 'Status',
#                          'Material', 'On Hand Amount', 'Actions']
#         context['table_columns'] = table_columns
#         inventory = context['inventory']
#         table_data = []
#         for item in inventory:
#             table_row_data = []
#
#             # data for the object we want to display for a row
#             table_row_data.append(item.inventory_description)
#             table_row_data.append(item.status_description)
#             table_row_data.append(item.material_description)
#             table_row_data.append(f"{item.onhand_amt} {item.unit}")
#
#             # dict containing the data, view and update url, primary key and obj
#             # name to use in template
#             table_row_info = {
#                 'table_row_data': table_row_data,
#                 'view_url': reverse_lazy('inventory_view', kwargs={'pk': item.pk}),
#                 'update_url': reverse_lazy('inventory_update', kwargs={'pk': item.pk}),
#                 'obj_name': str(item),
#                 'obj_pk': item.pk
#             }
#             table_data.append(table_row_info)
#
#         context['add_url'] = reverse_lazy('inventory_add')
#         context['table_data'] = table_data
#         context['title'] = 'Inventory'
#         return context

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

    #Need this
    table_columns += ['Actions']


# class InventoryEdit:
#     template_name = 'core/generic/edit.html'
#     model = Inventory
#     form_class = InventoryForm
#     success_url = reverse_lazy('inventory_list')
#
#     def get_context_data(self, **kwargs):
#         context = super().get_context_data(**kwargs)
#         context['title'] = 'Inventory'
#         return context

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


# class InventoryView(DetailView):
#     template_name = 'core/generic/detail.html'
#     model = Inventory
#     #queryset = Inventory.objects.select_related()
#
#     def get_context_data(self, **kwargs):
#         context = super().get_context_data(**kwargs)
#         obj = context['object']
#         table_data = {
#                 'Inventory description': obj.inventory_description,
#                 'Actor description': obj.actor_description,
#                 'Material description': obj.material_description,
#                 'Part Number': obj.part_no,
#                 'On Hand Amount': obj.onhand_amt,
#                 'Create Date': obj.create_date,
#                 'Expiration Date': obj.expiration_date,
#                 'Inventory location': obj.inventory_location,
#                 'Status': obj.status_description
#         }
#         context['update_url'] = reverse_lazy(
#             'inventory_update', kwargs={'pk': obj.pk})
#         context['title'] = 'Inventory'
#         context['table_data'] = table_data
#         return context

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
