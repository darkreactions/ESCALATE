from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from ..models import Actor
from ..forms import ActorForm
from .menu import GenericListView


class ActorList(GenericListView):
    model = Actor
    template_name = 'core/actor/actor_list.html'
    context_object_name = 'actors'
    paginate_by = 10


class ActorEdit:
    template_name = 'core/actor/actor_edit.html'
    model = Actor
    fields = ['person', 'organization', 'systemtool', 'description', 'status',
              'note']
    success_url = reverse_lazy('actor_list')


class ActorCreate(ActorEdit, CreateView):
    pass


class ActorUpdate(ActorEdit, UpdateView):
    pass


class ActorDelete(DeleteView):
    model = Actor
    success_url = reverse_lazy('actor_list')


class ActorView(DetailView):
    model = Actor
    queryset = Actor.objects.select_related()
