from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import CreateView, DeleteView, UpdateView
from django.http import HttpResponse
from core.models import Person
from core.forms import PersonForm

from .model_view_generic import GenericModelEdit, GenericModelList, GenericModelView


class PersonList(GenericModelList):
    model = Person
    context_object_name = 'persons'
    table_columns = ['Name', 'Address', 'Title', 'Email']
    column_necessary_fields = {
        'Name': ['first_name', 'middle_name', 'last_name'],
        'Address': ['address1', 'address2', 'zip', 'city', 'state_province', 'country'],
        'Title': ['title'],
        'Email': ['email']
    }
    order_field = 'first_name'
    field_contains = ''

    # Need this
    table_columns += ['Actions']


class PersonEdit(GenericModelEdit):
    model = Person
    context_object_name = 'person'
    form_class = PersonForm


class PersonCreate(CreateView):
    template_name = 'core/generic/edit.html'
    model = Person
    context_object_name = 'person'
    form_class = PersonForm
    success_url = reverse_lazy('person_list')


class PersonUpdate(PersonEdit, UpdateView):
    pass


class PersonDelete(DeleteView):
    model = Person
    success_url = reverse_lazy('person_list')


class PersonView(GenericModelView):
    model = Person
    model_name = 'person'
    detail_fields = ['Full Name', 'Address', 'Phone', 'Email', 'Title',
                     'Suffix', 'Organization', 'Add Date', 'Last Modification Date']
    detail_fields_need_fields = {
        'Full Name': ['first_name', 'middle_name', 'last_name'],
        'Address': ['address1', 'address2', 'zip', 'city', 'state_province', 'country'],
        'Phone': ['phone'],
        'Email': ['email'],
        'Title': ['title'],
        'Suffix': ['suffix'],
        'Organization': ['organization_full_name'],
        'Add Date': ['add_date'],
        'Last Modification Date': ['mod_date']
    }
