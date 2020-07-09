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
    form_class = ActorForm
    success_url = reverse_lazy('actor_list')

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = 'Actor'
        return context


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

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        obj = context['object']
        table_data = {
                'Organization': obj.org_full_name + f" ({obj.org_short_name})",
                'Person': f"{obj.person_first_name} {obj.person_last_name}",
                'Systemtool': obj.systemtool_name,
                'Description': obj.actor_description,
                'Status': obj.actor_status,
                'Note': obj.actor_notetext
        }
        context['update_url'] = reverse_lazy(
            'actor_update', kwargs={'pk': obj.pk})
        context['title'] = 'Actor'
        context['table_data'] = table_data
        return context
