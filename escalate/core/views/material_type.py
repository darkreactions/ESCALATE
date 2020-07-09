from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import MaterialType
from core.forms import MaterialTypeForm
from core.views.menu import GenericListView


class MaterialTypeList(GenericListView):
    model = MaterialType
    template_name = 'core/material_type/material_type_list.html'
    context_object_name = 'material_types'
    paginate_by = 10

    def get_queryset(self):
        return self.model.objects.all()
        filter_val = self.request.GET.get('filter', '')
        ordering = self.request.GET.get('ordering', 'description')
        if filter_val != None:
            new_queryset = self.model.objects.filter(
                description__icontains=filter_val).select_related().order_by(ordering)
        else:
            new_queryset = self.model.objects.all()
        return new_queryset


class MaterialTypeEdit:
    template_name = 'core/material_type/material_type_edit.html'
    model = MaterialType
    form_class = MaterialTypeForm
    success_url = reverse_lazy('material_type_list')


class MaterialTypeCreate(MaterialTypeEdit, CreateView):
    pass


class MaterialTypeUpdate(MaterialTypeEdit, UpdateView):
    pass


class MaterialTypeDelete(DeleteView):
    model = MaterialType
    success_url = reverse_lazy('material_type_list')


class MaterialTypeView(DetailView):
    model = MaterialType
    template_name = 'core/material_type/material_type_detail.html'
