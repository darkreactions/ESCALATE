from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import Status
from core.forms import StatusForm
from core.views.menu import GenericListView


class StatusList(GenericListView):
    model = Status
    template_name = 'core/status/status_list.html'
    context_object_name = 'statuses'
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

class StatusEdit:
    template_name = 'core/status/status_edit.html'
    model = Status
    form_class = StatusForm
    success_url = reverse_lazy('status_list')


class StatusCreate(StatusEdit, CreateView):
    pass


class StatusUpdate(StatusEdit, UpdateView):
    pass


class StatusDelete(DeleteView):
    model = Status
    success_url = reverse_lazy('status_list')


class StatusView(DetailView):
    model = Status
    template_name = 'core/status/status_detail.html'
