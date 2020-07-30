from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import LatestSystemtool
from core.forms import LatestSystemtoolForm
from core.views.menu import GenericListView

from .model_view_generic import GenericModelEdit, GenericModelList

# class SystemtoolList(GenericListView):
#     model = LatestSystemtool
#     template_name = 'core/generic/list.html'
#     context_object_name = 'systemtools'
#     paginate_by = 10
#
#     def get_queryset(self):
#         return self.model.objects.all()
#         filter_val = self.request.GET.get('filter', '')
#         ordering = self.request.GET.get('ordering', 'systemtool_name')
#         if filter_val != None:
#             new_queryset = self.model.objects.filter(
#                 systemtool_name__icontains=filter_val).select_related().order_by(ordering)
#         else:
#             new_queryset = self.model.objects.all()
#         return new_queryset
#
#     def get_context_data(self, **kwargs):
#         context = super().get_context_data(**kwargs)
#         table_columns = ['Name', 'Description', 'System Tool Type', 'Vendor Organization', 'Actions']
#         context['table_columns'] = table_columns
#         systemtools = context['systemtools']
#         table_data = []
#         for systemtool in systemtools:
#             table_row_data = []
#
#             # data for the object we want to display for a row
#             table_row_data.append(systemtool.systemtool_name)
#             table_row_data.append(systemtool.description)
#             table_row_data.append(systemtool.systemtool_type_uuid)
#             table_row_data.append(systemtool.vendor_organization_uuid)
#
#             # dict containing the data, view and update url, primary key and obj
#             # name to use in template
#             table_row_info = {
#                 'table_row_data': table_row_data,
#                 'view_url': reverse_lazy('systemtool_view', kwargs={'pk': systemtool.pk}),
#                 'update_url': reverse_lazy('systemtool_update', kwargs={'pk': systemtool.pk}),
#                 'obj_name': str(systemtool),
#                 'obj_pk': systemtool.pk
#             }
#             table_data.append(table_row_info)
#
#         context['add_url'] = reverse_lazy('systemtool_add')
#         context['table_data'] = table_data
#         context['title'] = 'systemtool'
#         return context

class SystemtoolList(GenericModelList):
    model = LatestSystemtool
    context_object_name = 'systemtools'
    table_columns = ['Name', 'Description', 'System Tool Type', 'Vendor Organization']
    column_necessary_fields = {
                'Name': ['systemtool_name'],
                'Description': ['description'],
                'System Tool Type': ['systemtool_type_uuid'],
                'Vendor Organization': ['vendor_organization_uuid']
    }
    order_field = 'systemtool_name'
    field_contains = ''

    #Need this
    table_columns += ['Actions']


# class SystemtoolEdit:
#     template_name = 'core/generic/edit.html'
#     model = LatestSystemtool
#     form_class = LatestSystemtoolForm
#     success_url = reverse_lazy('systemtool_list')
#
#     def get_context_data(self, **kwargs):
#         context = super().get_context_data(**kwargs)
#         context['title'] = 'SystemTool'
#         return context

class SystemtoolEdit(GenericModelEdit):
    model = LatestSystemtool
    context_object_name = 'systemtool'
    form_class = LatestSystemtoolForm


class SystemtoolCreate(CreateView):
    template_name = 'core/generic/edit.html'
    model = LatestSystemtool
    form_class = LatestSystemtoolForm
    success_url = reverse_lazy('systemtool_list')


class SystemtoolUpdate(SystemtoolEdit, UpdateView):
    pass


class SystemtoolDelete(DeleteView):
    model = LatestSystemtool
    success_url = reverse_lazy('systemtool_list')


class SystemtoolView(DetailView):
    model = LatestSystemtool
    template_name = 'core/generic/detail.html'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        obj = context['object']
        table_data = {
                'Systemtool name': obj.systemtool_name,
                'Systemtool description': obj.description,
                'Systemtool type': obj.systemtool_type_uuid,
                'Systemtool vendor': obj.vendor_organization_uuid,
                'Systemtool model': obj.model,
                'Systemtool serial': obj.serial,
                'Systemtool version': obj.ver
        }
        context['update_url'] = reverse_lazy(
            'systemtool_update', kwargs={'pk': obj.pk})
        context['title'] = 'systemtool'
        context['table_data'] = table_data
        return context
