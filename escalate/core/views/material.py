from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from ..models import Material
from ..forms import MaterialForm
from .menu import GenericListView


class MaterialsList(GenericListView):
    model = Material
    template_name = 'core/material/material_list.html'
    context_object_name = 'materials'
    paginate_by = 10


class MaterialEdit:
    template_name = 'core/material/material_edit.html'
    model = Material
    fields = ['description', 'parent_material', 'status', 'note']
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
