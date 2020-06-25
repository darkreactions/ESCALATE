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

    def get_queryset(self):
        filter_val = self.request.GET.get('filter', '')
        ordering = self.request.GET.get('ordering', 'actor_description')
        if filter_val != None:
            new_queryset = self.model.objects.filter(
                actor_description__icontains=filter_val).select_related().order_by(ordering)
        else:
            new_queryset = self.model.objects.all().select_related().order_by(ordering)
        return new_queryset



class ActorEdit:
    template_name = 'core/actor/actor_edit.html'
    model = Actor
    fields = ['person_uuid', 'organization_uuid', 'systemtool_uuid', 'actor_description', 'actor_status',
              'actor_notetext']
    success_url = reverse_lazy('actor_list')


class ActorCreate(ActorEdit, CreateView):
    pass


class ActorUpdate(ActorEdit, UpdateView):
    pass


class ActorDelete(DeleteView):
    model = Actor
    success_url = reverse_lazy('actor_list')


class ActorView(DetailView):
    template_name='core/actor/actor_detail.html'
    queryset = Actor.objects.select_related()
