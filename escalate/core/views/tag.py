from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import Tag,Note,Actor
from core.forms import TagForm,NoteForm
from core.views.menu import GenericListView

#Note side
from django.forms import modelformset_factory
from django.shortcuts import get_object_or_404

class TagList(GenericListView):
    model = Tag
    template_name = 'core/generic/list.html'
    context_object_name = 'tags'
    paginate_by = 10

    def get_queryset(self):
        return self.model.objects.all()
        filter_val = self.request.GET.get('filter', '')
        ordering = self.request.GET.get('ordering', 'display_text')
        if filter_val != None:
            new_queryset = self.model.objects.filter(
                display_text__icontains=filter_val).select_related().order_by(ordering)
        else:
            new_queryset = self.model.objects.all()
        return new_queryset

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        table_columns = [ 'Name','Description','Actor','Tag Type','Actions']
        context['table_columns'] = table_columns
        tags = context['tags']
        table_data = []
        for tag in tags:
            table_row_data = []

            # data for the object we want to display for a row
            table_row_data.append(tag.display_text)
            table_row_data.append(tag.description)
            table_row_data.append(tag.actor_description)
            table_row_data.append(tag.tag_type_uuid)
            # dict containing the data, view and update url, primary key and obj
            # name to use in template
            table_row_info = {
                'table_row_data': table_row_data,
                'view_url': reverse_lazy('tag_view', kwargs={'pk': tag.pk}),
                'update_url': reverse_lazy('tag_update', kwargs={'pk': tag.pk}),
                'obj_name': str(tag),
                'obj_pk': tag.pk
            }
            table_data.append(table_row_info)

        context['add_url'] = reverse_lazy('tag_add')
        context['table_data'] = table_data
        context['title'] = 'tag'
        return context


class TagEdit:
    template_name = 'core/generic/edit_note.html'
    model = Tag
    form_class = TagForm
    success_url = reverse_lazy('tag_list')

    #Note side
    context_object_name = 'tag'
    NoteFormSet = modelformset_factory(Note, form=NoteForm,can_delete=True)

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        if 'tag' in context:
            tag = context['tag']
            context['note_forms'] = self.NoteFormSet(
                queryset=Note.objects.filter(ref_note_uuid=tag.pk))
        context['title'] = 'tag'
        return context

    def post(self, request, *args, **kwargs):
        # Note side
        if self.NoteFormSet != None:
            formset = self.NoteFormSet(request.POST)
            tag = get_object_or_404(Tag, pk=self.kwargs['pk'])
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
                        # Conveniently in this case its tag, but we need to figure out an alternative
                        note.ref_note_uuid = tag.pk
                        note.save()
            # Delete each note we marked in the formset
            formset.save(commit=False)
            for obj in formset.deleted_objects:
                obj.delete()
            # Choose which website we are redirected to
        if request.POST.get("Submit"):
            self.success_url = reverse_lazy('tag_list')
        if request.POST.get('update'):
            self.success_url = reverse_lazy('tag_update', kwargs={'pk': tag.pk})

        return super().post(request, *args, **kwargs)

class TagCreate(TagEdit, CreateView):
        # Note side
        template_name = 'core/generic/edit.html'
        NoteFormSet = None

class TagUpdate(TagEdit, UpdateView):
    pass


class TagDelete(DeleteView):
    model = Tag
    success_url = reverse_lazy('tag_list')


class TagView(DetailView):
    model = Tag
    template_name = 'core/generic/detail.html'


    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        obj = context['object']
        table_data = {
                'Tag name': obj.display_text,
                'Tag description': obj.description,
                'Actor':obj.actor_uuid,
                'Add date': obj.add_date,
                'Modified date': obj.mod_date,
                'Tag type name':obj.tag_type_uuid,
                'Tag type description':obj.tag_type_description
        }
        context['update_url'] = reverse_lazy(
            'tag_update', kwargs={'pk': obj.pk})
        context['title'] = 'tag'
        context['table_data'] = table_data
        return context