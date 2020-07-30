from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import MaterialType
from core.forms import MaterialTypeForm
from core.views.menu import GenericListView

from .model_view_generic import GenericModelEdit, GenericModelList


# class MaterialTypeList(GenericListView):
#     model = MaterialType
#     #template_name = 'core/material_type/material_type_list.html'
#     template_name = 'core/generic/list.html'
#     context_object_name = 'material_types'
#     paginate_by = 10
#
#     def get_queryset(self):
#         return self.model.objects.all()
#         filter_val = self.request.GET.get('filter', '')
#         ordering = self.request.GET.get('ordering', 'description')
#         if filter_val != None:
#             new_queryset = self.model.objects.filter(
#                 description__icontains=filter_val).select_related().order_by(ordering)
#         else:
#             new_queryset = self.model.objects.all()
#         return new_queryset
#
#     def get_context_data(self, **kwargs):
#         context = super().get_context_data(**kwargs)
#         table_columns = ['Description', 'Actions']
#         context['table_columns'] = table_columns
#         material_types = context['material_types']
#         table_data = []
#         for material_type in material_types:
#             table_row_data = []
#
#             # data for the object we want to display for a row
#             table_row_data.append(material_type.description)
#
#             # dict containing the data, view and update url, primary key and obj
#             # name to use in template
#             table_row_info = {
#                     'table_row_data' : table_row_data,
#                     'view_url' : reverse_lazy('material_type_view', kwargs={'pk': material_type.pk}),
#                     'update_url' : reverse_lazy('material_type_update', kwargs={'pk': material_type.pk}),
#                     'obj_name' : str(material_type),
#                     'obj_pk' : material_type.pk
#                     }
#             table_data.append(table_row_info)
#
#         context['add_url'] = reverse_lazy('material_type_add')
#         context['table_data'] = table_data
#         context['title'] = 'material_type'
#         return context

class MaterialTypeList(GenericModelList):
    model = MaterialType
    context_object_name = 'material_types'
    table_columns = ['Description']
    column_necessary_fields = {
                'Description': ['description']
    }
    order_field = 'description'
    field_contains = ''

    #Need this
    table_columns += ['Actions']

# class MaterialTypeEdit:
#     template_name = 'core/generic/edit.html'
#     model = MaterialType
#     form_class = MaterialTypeForm
#     success_url = reverse_lazy('material_type_list')
#
#     def get_context_data(self, **kwargs):
#         context = super().get_context_data(**kwargs)
#         context['title'] = 'Material Type'
#         return context

class MaterialTypeEdit(GenericModelEdit):
    model = MaterialType
    context_object_name = 'material_type'
    form_class = MaterialTypeForm


class MaterialTypeCreate(CreateView):
    template_name = 'core/generic/edit.html'
    model = MaterialType
    form_class = MaterialTypeForm
    success_url = reverse_lazy('material_type_list')


class MaterialTypeUpdate(MaterialTypeEdit, UpdateView):
    pass


class MaterialTypeDelete(DeleteView):
    model = MaterialType
    success_url = reverse_lazy('material_type_list')


class MaterialTypeView(DetailView):
    model = MaterialType
    template_name = 'core/generic/detail.html'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        obj = context['object']
        table_data = {
                'Description': obj.description,
                'Add Date': obj.add_date,
                'Last Modification Date': obj.mod_date
        }
        context['update_url'] = reverse_lazy('material_type_update', kwargs={'pk':obj.pk})
        context['title'] = 'Material Type'
        context['table_data'] = table_data
        return context
