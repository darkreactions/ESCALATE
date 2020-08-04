from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import Actor
from core.forms import ActorForm
from core.views.menu import GenericListView

from .model_view_generic import GenericModelEdit, GenericModelList, GenericModelView

"""
class ActorList(GenericModelList):
    model = Actor
    context_object_name = 'actors'
    table_columns = ['Name', 'Organization', 'Systemtool', 'Status']
    column_necessary_fields = {
        'Name': ['person_first_name', 'person_last_name'],
        'Organization': ['org_full_name'],
        'Systemtool': ['systemtool_name'],
        'Status': ['actor_status_description']
    }
    order_field = 'actor_description'
    field_contains = ''

    # Need this
    table_columns += ['Actions']





class ActorEdit(GenericModelEdit):
    model = Actor
    context_object_name = 'actor'
    form_class = ActorForm


class ActorCreate(CreateView):
    template_name = 'core/generic/edit.html'
    model = Actor
    form_class = ActorForm
    success_url = reverse_lazy('actor_list')


class ActorUpdate(ActorEdit, UpdateView):
    pass


class ActorDelete(DeleteView):
    model = Actor
    success_url = reverse_lazy('actor_list')




class ActorView(GenericModelView):
    model = Actor
    model_name = 'actor'
    detail_fields = ['Actor Description', 'Status', 'Organization', 'Person', 'Person Organization',
                     'Systemtool', 'Systemtool description', 'Systemtool type', 'Systemtool vendor',
                     'Systemtool model', 'Systemtool serial', 'Systemtool version']
    detail_fields_need_fields = {
        'Actor Description': ['actor_description'],
        'Status': ['actor_status_description'],
        'Organization': ['org_full_name'],
        'Person': ['person_first_name', 'person_last_name'],
        'Person Organization': ['person_org'],
        'Systemtool': ['systemtool_name'],
        'Systemtool description': ['systemtool_description'],
        'Systemtool type': ['systemtool_type'],
        'Systemtool vendor': ['systemtool_vendor'],
        'Systemtool model': ['systemtool_model'],
        'Systemtool serial': ['systemtool_serial'],
        'Systemtool version': ['systemtool_version']
    }
"""
