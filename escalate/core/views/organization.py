from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import Organization
from core.forms import OrganizationForm
from core.views.menu import GenericListView


class OrganizationList(GenericListView):
    model = Organization
    template_name = 'core/organization/organization_list.html'
    context_object_name = 'orgs'
    paginate_by = 10

    def get_queryset(self):
        filter_val = self.request.GET.get('filter', '')
        ordering = self.request.GET.get('ordering', 'full_name')
        if filter_val != None:
            new_queryset = self.model.objects.filter(
                full_name__icontains=filter_val).select_related().order_by(ordering)
        else:
            new_queryset = self.model.objects.all().select_related().order_by(ordering)
        return new_queryset


class OrganizationEdit:
    template_name = 'core/organization/organization_edit.html'
    model = Organization
    fields = ['full_name', 'short_name', 'address1', 'address2', 'city',
              'state_province', 'zip', 'country', 'website_url', 'phone',
              'parent', 'notetext', 'edocument', 'tag']
    labels = {
        'state_province': 'State/Province',
        'website_url': 'Website URL',
        'address1': 'Address Line 1',
        'address2': 'Address Line 2',
        'notetext': 'Note Text'
    }
    success_url = reverse_lazy('organization_list')


class OrganizationCreate(OrganizationEdit, CreateView):
    pass


class OrganizationUpdate(OrganizationEdit, UpdateView):
    pass


class OrganizationDelete(DeleteView):
    model = Organization
    success_url = reverse_lazy('organization_list')


class OrganizationView(DetailView):
    model = Organization
    #queryset = Organization.objects.all()
    template_name = 'core/organization/organization_detail.html'
