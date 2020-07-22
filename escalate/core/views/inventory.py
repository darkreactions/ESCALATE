from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView
from django.forms.models import model_to_dict

from core.models import Inventory,Actor,Note
from core.forms import InventoryForm,NoteForm
from core.views.menu import GenericListView

#Note side
from django.forms import modelformset_factory
from django.shortcuts import get_object_or_404


class InventoryList(GenericListView):
    model = Inventory
    #template_name = 'core/inventory/inventory_list.html'
    template_name = 'core/generic/list.html'
    context_object_name = 'inventory'
    paginate_by = 10

    def get_queryset(self):

        # added get_queryset method
        filter_val = self.request.GET.get('filter', '')
        ordering = self.request.GET.get('ordering', 'inventory_description')
        # order by description
        if filter_val != None:
            new_queryset = self.model.objects.filter(
                inventory_description__icontains=filter_val).select_related().order_by(ordering)
            # filter by decription being a empty/nonempty string
        else:
            new_queryset = self.model.objects.all().select_related().order_by(ordering)
        return new_queryset

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        table_columns = ['Description', 'Status',
                         'Material', 'On Hand Amount', 'Actions']
        context['table_columns'] = table_columns
        inventory = context['inventory']
        table_data = []
        for item in inventory:
            table_row_data = []

            # data for the object we want to display for a row
            table_row_data.append(item.inventory_description)
            table_row_data.append(item.status_description)
            table_row_data.append(item.material_description)
            table_row_data.append(f"{item.onhand_amt} {item.unit}")

            # dict containing the data, view and update url, primary key and obj
            # name to use in template
            table_row_info = {
                'table_row_data': table_row_data,
                'view_url': reverse_lazy('inventory_view', kwargs={'pk': item.pk}),
                'update_url': reverse_lazy('inventory_update', kwargs={'pk': item.pk}),
                'obj_name': str(item),
                'obj_pk': item.pk
            }
            table_data.append(table_row_info)

        context['add_url'] = reverse_lazy('inventory_add')
        context['table_data'] = table_data
        context['title'] = 'Inventory'
        return context


class InventoryEdit:
    template_name = 'core/generic/edit_note.html'
    model = Inventory
    form_class = InventoryForm
    success_url = reverse_lazy('inventory_list')

    #Note side
    context_object_name = 'inventory'
    NoteFormSet = modelformset_factory(Note, form=NoteForm,can_delete=True)


    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        if 'inventory' in context:
            inventory = context['inventory']
            context['note_forms'] = self.NoteFormSet(
                queryset=Note.objects.filter(ref_note_uuid=inventory.pk))

        context['title'] = 'Inventory'
        return context

    def post(self, request, *args, **kwargs):
        #Note side
        if self.NoteFormSet != None:
            formset = self.NoteFormSet(request.POST)
            inventory = get_object_or_404(Inventory, pk=self.kwargs['pk'])
            # Loop through every note form
            for form in formset:
                # Only if the form has changed make an update, otherwise ignore
                if form.has_changed() and form.is_valid():
                    if request.user.is_authenticated:
                        # Get the appropriate actor and then add it to the note
                        actor = Actor.objects.get(
                            person_uuid=request.user.person.pk)
                        note = form.save(commit=False)
                        note.actor_uuid = actor
                        # Get the appropriate uuid of the record being changed.
                        # Conveniently in this case its person, but we need to figure out an alternative
                        note.ref_note_uuid = inventory.pk
                        note.save()
            # Delete each note we marked in the formset
            formset.save(commit=False)
            for obj in formset.deleted_objects:
                obj.delete()
            # Choose which website we are redirected to
        if request.POST.get("Submit"):
            self.success_url = reverse_lazy('inventory_list')
        if request.POST.get('update'):
            self.success_url = reverse_lazy('inventory_update',kwargs={'pk': inventory.pk})

        return super().post(request, *args, **kwargs)


class InventoryCreate(InventoryEdit, CreateView):
    #Note side
    template_name = 'core/generic/edit.html'
    NoteFormSet = None

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
                'Inventory description': obj.inventory_description,
                'Actor description': obj.actor_description,
                'Material description': obj.material_description,
                'Part Number': obj.part_no,
                'On Hand Amount': obj.onhand_amt,
                'Create Date': obj.create_date,
                'Expiration Date': obj.expiration_date,
                'Inventory location': obj.inventory_location,
                'Status': obj.status_description
        }
        context['update_url'] = reverse_lazy(
            'inventory_update', kwargs={'pk': obj.pk})
        context['title'] = 'Inventory'
        context['table_data'] = table_data
        return context
