from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView
from django.forms.models import model_to_dict

from ..models import Inventory
from ..forms import InventoryForm
from .menu import GenericListView


class InventoryList(GenericListView):
    model = Inventory
    template_name = 'core/inventory/inventory_list.html'
    context_object_name = 'inventory'
    paginate_by = 10

    def get_queryset(self):
        filter_val = self.request.GET.get('filter', '')
        ordering = self.request.GET.get('ordering', 'inventory_description')
        if filter_val != None:
            new_queryset = self.model.objects.filter(
                inventory_description__icontains=filter_val).select_related().order_by(ordering)
        else:
            new_queryset = self.model.objects.all().select_related().order_by(ordering)
        return new_queryset


class InventoryEdit:
    template_name = 'core/inventory/inventory_edit.html'
    model = Inventory
    fields = ['description', 'material_uuid', 'actor_uuid', 'part_no', 'onhand_amt',
              'unit', 'create_date', 'expiration_date',
              'inventory_location', 'status', 'edocument_uuid', 'notetext']
    success_url = reverse_lazy('inventory_list')


class InventoryCreate(InventoryEdit, CreateView):
    pass


class InventoryUpdate(InventoryEdit, UpdateView):
    pass


class InventoryDelete(DeleteView):
    model = Inventory
    success_url = reverse_lazy('inventory_list')


class InventoryView(DetailView):
    template_name = 'core/inventory/inventory_detail.html'
    model = Inventory
    queryset = Inventory.objects.select_related()

    """
    def get_context_data(self, **kwargs):
        context = super(InventoryView, self).get_context_data(**kwargs)
        context['thing'] = model_to_dict(Inventory.objects.select_related()[0])

        return context
    """
