from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import TagType,Note,Actor
from core.forms import TagTypeForm,NoteForm
from core.views.menu import GenericListView

#Note side
from django.forms import modelformset_factory
from django.shortcuts import get_object_or_404

class TagTypeList(GenericListView):
    model = TagType
    template_name = 'core/generic/list.html'
    context_object_name = 'tag_types'
    paginate_by = 10

    def get_queryset(self):
        return self.model.objects.all()
        filter_val = self.request.GET.get('filter', '')
        ordering = self.request.GET.get('ordering', 'short_description')
        if filter_val != None:
            new_queryset = self.model.objects.filter(
                short_description__icontains=filter_val).select_related().order_by(ordering)
        else:
            new_queryset = self.model.objects.all()
        return new_queryset

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        table_columns = [ 'Short Description','Description','Actions']
        context['table_columns'] = table_columns
        tag_types = context['tag_types']
        table_data = []
        for tag_type in tag_types:
            table_row_data = []

            # data for the object we want to display for a row
            table_row_data.append(tag_type.short_description)
            table_row_data.append(tag_type.description)
            # dict containing the data, view and update url, primary key and obj
            # name to use in template
            table_row_info = {
                'table_row_data': table_row_data,
                'view_url': reverse_lazy('tag_type_view', kwargs={'pk': tag_type.pk}),
                'update_url': reverse_lazy('tag_type_update', kwargs={'pk': tag_type.pk}),
                'obj_name': str(tag_type),
                'obj_pk': tag_type.pk
            }
            table_data.append(table_row_info)

        context['add_url'] = reverse_lazy('tag_type_add')
        context['table_data'] = table_data
        context['title'] = 'tag_type'
        return context


class TagTypeEdit:
    template_name = 'core/generic/edit_note.html'
    model = TagType
    form_class = TagTypeForm
    success_url = reverse_lazy('tag_type_list')
    #Note side
    context_object_name = 'tag_type'
    NoteFormSet = modelformset_factory(Note, form=NoteForm,can_delete=True)


    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        if 'tag_type' in context:
            tag_type = context['tag_type']
            context['note_forms'] = self.NoteFormSet(
                queryset=Note.objects.filter(ref_note_uuid=tag_type.pk))
        context['title'] = 'tag_type'
        return context

    def post(self, request, *args, **kwargs):
        # Note side
        if self.NoteFormSet != None:
            formset = self.NoteFormSet(request.POST)
            tag_type = get_object_or_404(TagType, pk=self.kwargs['pk'])
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
                        # Conveniently in this case its tag_type, but we need to figure out an alternative
                        note.ref_note_uuid = tag_type.pk
                        note.save()
            # Delete each note we marked in the formset
            formset.save(commit=False)
            for obj in formset.deleted_objects:
                obj.delete()
            # Choose which website we are redirected to
        if request.POST.get("Submit"):
            self.success_url = reverse_lazy('tag_type_list')
        if request.POST.get('update'):
            self.success_url = reverse_lazy('tag_type_update', kwargs={'pk': tag_type.pk})

        return super().post(request, *args, **kwargs)

class TagTypeCreate(TagTypeEdit, CreateView):
    #Note side
    template_name = 'core/generic/edit.html'
    NoteFormSet = None


class TagTypeUpdate(TagTypeEdit, UpdateView):
    pass


class TagTypeDelete(DeleteView):
    model = TagType
    success_url = reverse_lazy('tag_type_list')


class TagTypeView(DetailView):
    model = TagType
    template_name = 'core/generic/detail.html'


    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        obj = context['object']
        table_data = {
                'Short description': obj.short_description,
                'Long description': obj.description,
                'Add date': obj.add_date,
                'Modified date': obj.mod_date
        }
        context['update_url'] = reverse_lazy(
            'tag_type_update', kwargs={'pk': obj.pk})
        context['title'] = 'tag_type'
        context['table_data'] = table_data
        return context
