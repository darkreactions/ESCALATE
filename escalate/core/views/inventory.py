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
    template_name = 'core/inventory/inventory_edit.html'
    model = Inventory

    form_class = InventoryForm
    # fields = ['description', 'material', 'actor', 'part_no', 'onhand_amt',
    #           'unit', 'measure_id', 'create_date', 'expiration_dt',
    #           'inventory_location', 'status', 'document_id', 'note']

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
