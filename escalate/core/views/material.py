from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView
from django import forms

from core.models import Material
from core.forms import MaterialForm
from core.views.menu import GenericListView


class MaterialsList(GenericListView):
    model = Material
    template_name = 'core/material/material_list.html'
    context_object_name = 'materials'
    paginate_by = 10

    def get_queryset(self):
    # added get_queryset method
        filter_val = self.request.GET.get('filter', '')
        ordering = self.request.GET.get('ordering', 'abbreviation')
        # order by abbreviation
        if filter_val != None:
            new_queryset = self.model.objects.filter(
                abbreviation__icontains=filter_val).select_related().order_by(ordering)
        # filter by abbrev being empty/nonempty string
        else:
            new_queryset = self.model.objects.all().select_related().order_by(ordering)
        return new_queryset


class MaterialEdit:
    template_name = 'core/material/material_edit.html'
    model = Material
    form_class = MaterialForm
    #fields = ['description', 'parent_material', 'status', 'note']
    success_url = reverse_lazy('material_list')


class MaterialCreate(MaterialEdit, CreateView):
    pass


class MaterialUpdate(MaterialEdit, UpdateView):
    pass


class MaterialDelete(DeleteView):
    model = Material
    success_url = reverse_lazy('material_list')


class MaterialView(DetailView):
    template_name = 'core/material/material_detail.html'
    model = Material
    queryset = Material.objects.select_related()
