from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import Actor
from core.forms import ActorForm
from core.views.menu import GenericListView


class ActorList(GenericListView):
    model = Actor
    template_name = 'core/actor/actor_list.html'
    context_object_name = 'actors'
    paginate_by = 10

    def get_queryset(self):
    # added get_queryset method
        filter_val = self.request.GET.get('filter', '')
        ordering = self.request.GET.get('ordering', 'actor_uuid')
        # order by actor_uuid because it not be null, a different field would be better
        if filter_val != None:
            new_queryset = self.model.objects.filter(
                actor_uuid__icontains=filter_val).select_related().order_by(ordering)
                #not sure what column to filter by so I put actor_uuid
        else:
            new_queryset = self.model.objects.all().select_related().order_by(ordering)
        return new_queryset


class ActorEdit:
    template_name = 'core/actor/actor_edit.html'
    model = Actor
    form_class = ActorForm
    # fields = ['person', 'organization', 'systemtool', 'description', 'status',
    #           'note']
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
