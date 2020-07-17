from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import SystemtoolType
from core.forms import SystemtoolTypeForm
from core.views.menu import GenericListView


class SystemtoolTypeList(GenericListView):
    model = SystemtoolType
    template_name = 'core/systemtool_type/systemtool_type_list.html'
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


class SystemtoolTypeEdit:
    template_name = 'core/systemtool_type/systemtool_type_edit.html'
    model = SystemtoolType
    form_class = SystemtoolTypeForm
    success_url = reverse_lazy('systemtool_type_list')


class SystemtoolTypeCreate(SystemtoolTypeEdit, CreateView):
    pass


class SystemtoolTypeUpdate(SystemtoolTypeEdit, UpdateView):
    pass


class SystemtoolTypeDelete(DeleteView):
    model = SystemtoolType
    success_url = reverse_lazy('systemtool_type_list')


class SystemtoolTypeView(DetailView):
    model = SystemtoolType
    template_name = 'core/systemtool_type/systemtool_type_detail.html'
