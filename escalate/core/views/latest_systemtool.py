from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import LatestSystemtool
from core.forms import LatestSystemtoolForm
from core.views.menu import GenericListView


class SystemtoolList(GenericListView):
    model = LatestSystemtool
    template_name = 'core/systemtool/systemtool_list.html'
    context_object_name = 'systemtools'
    paginate_by = 10

    def get_queryset(self):
        return self.model.objects.all()
        filter_val = self.request.GET.get('filter', '')
        ordering = self.request.GET.get('ordering', 'systemtool_name')
        if filter_val != None:
            new_queryset = self.model.objects.filter(
                systemtool_name__icontains=filter_val).select_related().order_by(ordering)
        else:
            new_queryset = self.model.objects.all()
        return new_queryset

class SystemtoolEdit:
    template_name = 'core/systemtool/systemtool_edit.html'
    model = LatestSystemtool
    form_class = LatestSystemtoolForm
    success_url = reverse_lazy('systemtool_list')


class SystemtoolCreate(SystemtoolEdit, CreateView):
    pass


class SystemtoolUpdate(SystemtoolEdit, UpdateView):
    pass


class SystemtoolDelete(DeleteView):
    model = LatestSystemtool
    success_url = reverse_lazy('systemtool_list')


class SystemtoolView(DetailView):
    model = LatestSystemtool
    template_name = 'core/systemtool/systemtool_detail.html'
