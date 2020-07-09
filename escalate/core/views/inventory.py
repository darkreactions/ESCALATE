from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView
from django.forms.models import model_to_dict

from core.models import Inventory
from core.forms import InventoryForm
from core.views.menu import GenericListView


class InventoryList(GenericListView):
    model = Inventory
    template_name = 'core/inventory/inventory_list.html'
    context_object_name = 'inventory'
    paginate_by = 10

    def get_queryset(self):

    # added get_queryset method
        filter_val = self.request.GET.get('filter', '')
        ordering = self.request.GET.get('ordering', 'description')
        # order by description
        if filter_val != None:
            new_queryset = self.model.objects.filter(
                description__icontains=filter_val).select_related().order_by(ordering)
            # filter by decription being a empty/nonempty string
        else:
            new_queryset = self.model.objects.all().select_related().order_by(ordering)
        return new_queryset


class InventoryEdit:
    template_name = 'core/generic/edit.html'
    model = Inventory
    form_class = InventoryForm
    success_url = reverse_lazy('inventory_list')

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = 'Edit Inventory'
        return context


class InventoryCreate(InventoryEdit, CreateView):
    pass


class InventoryUpdate(InventoryEdit, UpdateView):
    pass


class InventoryDelete(DeleteView):
    model = Inventory
    success_url = reverse_lazy('inventory_list')


class InventoryView(DetailView):
    template_name = 'core/generic/detail.html'
    model = Inventory
    #queryset = Inventory.objects.select_related()

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        obj = context['object']
        table_data = {
                'Actor description': obj.description,
                'Material description': obj.material_description,
                'Part Number': obj.part_no,
                'On Hand Amount': obj.onhand_amt,
                'Create Date': obj.create_date,
                'Expiration Date': obj.expiration_date,
                'Inventory location': obj.inventory_location,
                'Status': obj.status,
                'Note text': obj.notetext
        }
        context['update_url'] = reverse_lazy(
            'inventory_update', kwargs={'pk': obj.pk})
        context['title'] = 'Inventory'
        context['table_data'] = table_data
        return context
