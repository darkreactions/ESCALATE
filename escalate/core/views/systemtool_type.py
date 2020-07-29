from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import SystemtoolType
from core.forms import SystemtoolTypeForm
from core.views.menu import GenericListView

from .model_view_generic import GenericModelEdit


class SystemtoolTypeList(GenericListView):
    model = SystemtoolType
    template_name = 'core/generic/list.html'
    context_object_name = 'systemtool_types'
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

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        table_columns = [ 'Description','Actions']
        context['table_columns'] = table_columns
        systemtool_types = context['systemtool_types']
        table_data = []
        for systemtool_type in systemtool_types:
            table_row_data = []

            # data for the object we want to display for a row
            table_row_data.append(systemtool_type.description)

            # dict containing the data, view and update url, primary key and obj
            # name to use in template
            table_row_info = {
                'table_row_data': table_row_data,
                'view_url': reverse_lazy('systemtool_type_view', kwargs={'pk': systemtool_type.pk}),
                'update_url': reverse_lazy('systemtool_type_update', kwargs={'pk': systemtool_type.pk}),
                'obj_name': str(systemtool_type),
                'obj_pk': systemtool_type.pk
            }
            table_data.append(table_row_info)

        context['add_url'] = reverse_lazy('systemtool_type_add')
        context['table_data'] = table_data
        context['title'] = 'systemtool_type'
        return context

# class SystemtoolTypeEdit:
#     template_name = 'core/generic/edit.html'
#     model = SystemtoolType
#     form_class = SystemtoolTypeForm
#     success_url = reverse_lazy('systemtool_type_list')
#
#     def get_context_data(self, **kwargs):
#         context = super().get_context_data(**kwargs)
#         context['title'] = 'systemtool_type'
#         return context

class SystemtoolTypeEdit(GenericModelEdit):
    model = SystemtoolType
    context_object_name = 'systemtool_type'
    form_class = SystemtoolTypeForm


class SystemtoolTypeCreate(SystemtoolTypeEdit, CreateView):
    pass


class SystemtoolTypeUpdate(SystemtoolTypeEdit, UpdateView):
    pass


class SystemtoolTypeDelete(DeleteView):
    model = SystemtoolType
    success_url = reverse_lazy('systemtool_type_list')


class SystemtoolTypeView(DetailView):
    model = SystemtoolType
    template_name = 'core/generic/detail.html'


    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        obj = context['object']
        table_data = {
                'System tool type description': obj.description,
                'Add date': obj.add_date,
                'Modified date': obj.mod_date
        }
        context['update_url'] = reverse_lazy(
            'systemtool_type_update', kwargs={'pk': obj.pk})
        context['title'] = 'systemtool_type'
        context['table_data'] = table_data
        return context
