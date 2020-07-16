from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import Actor
from core.forms import ActorForm
from core.views.menu import GenericListView


class ActorList(GenericListView):
    model = Actor
    #template_name = 'core/actor/actor_list.html'
    template_name = 'core/generic/list.html'
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

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        table_columns = ['Person', 'Organization',
                         'Systemtool', 'Status', 'Actions']
        context['table_columns'] = table_columns
        actors = context['actors']
        table_data = []
        for actor in actors:
            table_row_data = []

            # data for the object we want to display for a row
            person_full_name = f"{actor.person_first_name} {actor.person_last_name}"

            table_row_data.append(person_full_name)
            table_row_data.append(actor.org_full_name)
            table_row_data.append(actor.systemtool_name)
            table_row_data.append(actor.actor_status_description)

            # dict containing the data, view and update url, primary key and obj
            # name to use in template
            table_row_info = {
                'table_row_data': table_row_data,
                'view_url': reverse_lazy('actor_view', kwargs={'pk': actor.pk}),
                'update_url': reverse_lazy('actor_update', kwargs={'pk': actor.pk}),
                'obj_name': str(actor),
                'obj_pk': actor.pk
            }
            table_data.append(table_row_info)

        context['add_url'] = reverse_lazy('actor_add')
        context['table_data'] = table_data
        context['title'] = 'Actor'
        return context


class ActorEdit:
    template_name = 'core/generic/edit.html'
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
    template_name = 'core/generic/detail.html'
    queryset = Actor.objects.select_related()

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        obj = context['object']
        table_data = {
            'Actor description': obj.actor_description,
            'Status': obj.actor_status,
            'Organization': obj.org_full_name + f" ({obj.org_short_name})",
            'Person': f"{obj.person_first_name} {obj.person_last_name}",
            'Systemtool': obj.systemtool_name,
            'Systemtool description': obj.systemtool_description,
            'Systemtool type': obj.systemtool_type,
            'Systemtool vendor': obj.systemtool_vendor,
            'Systemtool model': obj.systemtool_model,
            'Systemtool serial': obj.systemtool_serial,
            'Systemtool_version': obj.systemtool_version
        }
        context['update_url'] = reverse_lazy(
            'actor_update', kwargs={'pk': obj.pk})
        context['title'] = 'Actor'
        context['table_data'] = table_data
        return context
