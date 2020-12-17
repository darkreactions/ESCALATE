from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import Organization, Tag, TagAssign, Note, Actor, CustomUser
from core.forms import OrganizationForm, NoteForm, TagSelectForm
from core.views.menu import GenericListView
from django.forms import modelformset_factory
from django.shortcuts import get_object_or_404
from .model_view_generic import GenericModelEdit, GenericModelList, GenericModelView


class OrganizationList(GenericModelList):
    model = Organization
    context_object_name = 'organizations'
    table_columns = ['Full Name', 'Address', 'Website']
    column_necessary_fields = {
        'Full Name': ['full_name'],
        'Address': ['address1', 'address2', 'zip', 'city', 'state_province', 'country'],
        'Website': ['website_url']
    }
    order_field = 'full_name'
    field_contains = ''

    # Need this
    table_columns += ['Actions']


class OrganizationEdit(GenericModelEdit):
    model = Organization
    context_object_name = 'organization'
    form_class = OrganizationForm


class OrganizationCreate(CreateView):
    template_name = 'core/generic/edit.html'
    model = Organization
    form_class = OrganizationForm
    success_url = reverse_lazy('organization_list')


class OrganizationUpdate(OrganizationEdit, UpdateView):
    pass


class OrganizationDelete(DeleteView):
    model = Organization
    success_url = reverse_lazy('organization_list')


class OrganizationView(GenericModelView):
    model = Organization
    model_name = 'organization'
    detail_fields = ['Full Name', 'Short Name', 'Description', 'Address', 'Website',
                     'Phone', 'Parent Organization', 'Add Date', 'Last Modification Date']
    detail_fields_need_fields = {
        'Full Name': ['full_name'],
        'Short Name': ['short_name'],
        'Description': ['description'],
        'Address': ['address1', 'address2', 'zip', 'city', 'state_province', 'country'],
        'Website': ['website_url'],
        'Phone': ['phone'],
        'Parent Organization': ['parent_org_full_name'],
        'Add Date': ['add_date'],
        'Last Modification Date': ['mod_date']
    }
