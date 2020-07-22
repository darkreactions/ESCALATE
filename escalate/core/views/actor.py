from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import Actor,Note
from core.forms import ActorForm,NoteForm
from core.views.menu import GenericListView

#Note side
from django.forms import modelformset_factory
from django.shortcuts import get_object_or_404

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
    template_name = 'core/generic/edit_note.html'
    model = Actor
    form_class = ActorForm
    success_url = reverse_lazy('actor_list')

    #Note side
    context_object_name = 'actor'
    NoteFormSet = modelformset_factory(Note, form=NoteForm,can_delete=True)


    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        #Note side
        if 'actor' in context:
            actor = context['actor']
            context['note_forms'] = self.NoteFormSet(
                queryset=Note.objects.filter(ref_note_uuid=actor.pk))

        context['title'] = 'Actor'
        return context


    def post(self, request, *args, **kwargs):
        #Note side
        if self.NoteFormSet != None:
            formset = self.NoteFormSet(request.POST)
            actor = get_object_or_404(Actor, pk=self.kwargs['pk'])
            # Loop through every note form
            for form in formset:
                # Only if the form has changed make an update, otherwise ignore
                if form.has_changed() and form.is_valid():
                    if request.user.is_authenticated:
                        # Get the appropriate actor and then add it to the note
                        actor = Actor.objects.get(
                            person_uuid=request.user.person.pk)
                        note = form.save(commit=False)
                        note.actor_uuid = actor
                        # Get the appropriate uuid of the record being changed.
                        # Conveniently in this case its person, but we need to figure out an alternative
                        note.ref_note_uuid = actor.pk
                        note.save()
            # Delete each note we marked in the formset
            formset.save(commit=False)
            for obj in formset.deleted_objects:
                obj.delete()
            # Choose which website we are redirected to
        if request.POST.get("Submit"):
            self.success_url = reverse_lazy('actor_list')
        if request.POST.get('update'):
            self.success_url = reverse_lazy('actor_update',kwargs={'pk': actor.pk})

        return super().post(request, *args, **kwargs)


class ActorCreate(ActorEdit, CreateView):
    #Note side
    template_name = 'core/generic/edit.html'
    NoteFormSet = None


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
                'Status': obj.actor_status_description,
                'Organization': f"{obj.org_full_name} ({obj.org_short_name})",
                'Person': f"{obj.person_first_name} {obj.person_last_name}",
                'Person organization': obj.person_org,
                'Systemtool': obj.systemtool_name,
                'Systemtool description': obj.systemtool_description,
                'Systemtool type': obj.systemtool_type,
                'Systemtool vendor': obj.systemtool_vendor,
                'Systemtool model': obj.systemtool_model,
                'Systemtool serial': obj.systemtool_serial,
                'Systemtool version': obj.systemtool_version
        }
        context['update_url'] = reverse_lazy(
            'actor_update', kwargs={'pk': obj.pk})
        context['title'] = 'Actor'
        context['table_data'] = table_data
        return context
