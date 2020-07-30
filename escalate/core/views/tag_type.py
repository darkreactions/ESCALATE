from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import TagType
from core.forms import TagTypeForm
from core.views.menu import GenericListView

from .model_view_generic import GenericModelEdit, GenericModelList, GenericModelView
# class TagTypeList(GenericListView):
#     model = TagType
#     template_name = 'core/generic/list.html'
#     context_object_name = 'tag_types'
#     paginate_by = 10
#
#     def get_queryset(self):
#         return self.model.objects.all()
#         filter_val = self.request.GET.get('filter', '')
#         ordering = self.request.GET.get('ordering', 'short_description')
#         if filter_val != None:
#             new_queryset = self.model.objects.filter(
#                 short_description__icontains=filter_val).select_related().order_by(ordering)
#         else:
#             new_queryset = self.model.objects.all()
#         return new_queryset
#
#     def get_context_data(self, **kwargs):
#         context = super().get_context_data(**kwargs)
#         table_columns = [ 'Short Description','Description','Actions']
#         context['table_columns'] = table_columns
#         tag_types = context['tag_types']
#         table_data = []
#         for tag_type in tag_types:
#             table_row_data = []
#
#             # data for the object we want to display for a row
#             table_row_data.append(tag_type.short_description)
#             table_row_data.append(tag_type.description)
#             # dict containing the data, view and update url, primary key and obj
#             # name to use in template
#             table_row_info = {
#                 'table_row_data': table_row_data,
#                 'view_url': reverse_lazy('tag_type_view', kwargs={'pk': tag_type.pk}),
#                 'update_url': reverse_lazy('tag_type_update', kwargs={'pk': tag_type.pk}),
#                 'obj_name': str(tag_type),
#                 'obj_pk': tag_type.pk
#             }
#             table_data.append(table_row_info)
#
#         context['add_url'] = reverse_lazy('tag_type_add')
#         context['table_data'] = table_data
#         context['title'] = 'tag_type'
#         return context

class TagTypeList(GenericModelList):
    model = TagType
    context_object_name = 'tag_types'
    table_columns = ['Short Description', 'Description']
    column_necessary_fields = {
                'Short Description': ['short_description'],
                'Description': ['description']
    }
    order_field = 'short_description'
    field_contains = ''

    #Need this
    table_columns += ['Actions']


# class TagTypeEdit:
#     template_name = 'core/generic/edit.html'
#     model = TagType
#     form_class = TagTypeForm
#     success_url = reverse_lazy('tag_type_list')
#
#     def get_context_data(self, **kwargs):
#         context = super().get_context_data(**kwargs)
#         context['title'] = 'tag_type'
#         return context

class TagTypeEdit(GenericModelEdit):
    model = TagType
    context_object_name = 'tag_type'
    form_class = TagTypeForm


class TagTypeCreate(CreateView):
    template_name = 'core/generic/edit.html'
    model = TagType
    form_class = TagTypeForm
    success_url = reverse_lazy('tag_type_list')


class TagTypeUpdate(TagTypeEdit, UpdateView):
    pass


class TagTypeDelete(DeleteView):
    model = TagType
    success_url = reverse_lazy('tag_type_list')


# class TagTypeView(DetailView):
#     model = TagType
#     template_name = 'core/generic/detail.html'
#
#
#     def get_context_data(self, **kwargs):
#         context = super().get_context_data(**kwargs)
#         obj = context['object']
#         table_data = {
#                 'Short description': obj.short_description,
#                 'Long description': obj.description,
#                 'Add date': obj.add_date,
#                 'Modified date': obj.mod_date
#         }
#         context['update_url'] = reverse_lazy(
#             'tag_type_update', kwargs={'pk': obj.pk})
#         context['title'] = 'tag_type'
#         context['table_data'] = table_data
#         return context

class TagTypeView(GenericModelView):
    model = TagType
    model_name = 'tag_type'
    detail_fields = ['Short Description','Long Description','Add Date',
                     'Last Modification Date']
    detail_fields_need_fields = {
                'Short Description': ['short_description'],
                'Long Description': ['description'],
                'Add Date': ['add_date'],
                'Last Modification Date': ['mod_date']
    }
