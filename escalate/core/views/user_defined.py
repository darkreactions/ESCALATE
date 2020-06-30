from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import UdfDef
from core.forms import UdfDefForm
from core.views.menu import GenericListView


class UdfDefList(GenericListView):
    model = UdfDef
    template_name = 'core/udf_def/udf_def_list.html'
    context_object_name = 'udf_defs'
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

class UdfDefEdit:
    template_name = 'core/udf_def/udf_def_edit.html'
    model = UdfDef
    form_class = UdfDefForm
    success_url = reverse_lazy('udf_def_list')


class UdfDefCreate(UdfDefEdit, CreateView):
    pass


class UdfDefUpdate(UdfDefEdit, UpdateView):
    pass


class UdfDefDelete(DeleteView):
    model = UdfDef
    success_url = reverse_lazy('udf_def_list')


class UdfDefView(DetailView):
    model = UdfDef
    template_name = 'core/udf_def/udf_def_detail.html'
