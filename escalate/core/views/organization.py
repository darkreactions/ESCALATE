from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import Organization
from core.forms import OrganizationForm
from core.views.menu import GenericListView


class OrganizationList(GenericListView):
    model = Organization
    #template_name = 'core/organization/organization_list.html'
    template_name = 'core/generic/list.html'
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

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        table_columns = {
            'Full Name': 'full_name',
            'Address1': 'address1',
            'Website': 'website_url'
        }
        context['table_columns'] = table_columns
        orgs = context['orgs']
        table_data = []
        for org in orgs:
            table_row_data = []
            table_row_data.append(org.full_name)
            table_row_data.append(org.address1)
            table_row_data.append(org.website_url)
            table_row_info = []
            table_row_info.append(table_row_data)
            table_row_info.append(reverse_lazy('organization_view', kwargs={'pk': org.pk}))
            table_row_info.append(reverse_lazy('organization_update', kwargs={'pk': org.pk}))
            table_data.append(table_row_info)
        context['add_url'] = reverse_lazy('organization_add')
        context['table_data'] = table_data
        context['title'] = 'Organization'
        return context

class OrganizationEdit:
    #template_name = 'core/organization/organization_edit.html'
    template_name = 'core/generic/edit.html'
    model = Organization
    form_class = OrganizationForm
    success_url = reverse_lazy('organization_list')

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = 'Organization'
        return context


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
    #template_name = 'core/organization/organization_detail.html'
    template_name = 'core/generic/detail.html'

    def get_context_data(self, **kwargs):
        # Call the base implementation first to get a context
        context = super().get_context_data(**kwargs)
        obj = context['object']
        table_data = {
                'Full Name': obj.full_name,
                'Short Name': obj.short_name,
                'Address': f'{obj.address1}, {obj.address2}, {obj.city}, {obj.state_province}, {obj.zip}, {obj.country}',
                'Phone': obj.phone,
                'Website': obj.website_url,
                'Parent Org': obj.parent_org_full_name
        }
        context['update_url'] = reverse_lazy(
            'organization_update', kwargs={'pk': obj.pk})
        context['title'] = 'Organization'
        context['table_data'] = table_data
        return context
