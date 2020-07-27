from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView
from django.http import HttpResponse
from core.models import Person, Note, Actor, CustomUser,Tag_x,Tag
from core.forms import PersonForm, NoteForm,TagXForm
from core.views.menu import GenericListView

#Note side
from django.forms import modelformset_factory
from django.shortcuts import get_object_or_404


class PersonList(GenericListView):
    model = Person
    template_name = 'core/generic/list.html'
    context_object_name = 'persons'
    paginate_by = 10

    def get_queryset(self):
        filter_val = self.request.GET.get('filter', '')
        ordering = self.request.GET.get('ordering', 'first_name')
        if filter_val != None:
            new_queryset = self.model.objects.filter(
                first_name__icontains=filter_val).select_related().order_by(ordering)
        else:
            new_queryset = self.model.objects.all()
        return new_queryset

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        table_columns = ['Name', 'Address', 'Title', 'Email', 'Actions']
        context['table_columns'] = table_columns
        persons = context['persons']
        table_data = []
        for person in persons:
            table_row_data = []

            # data for the object we want to display for a row
            full_name = f"{person.first_name} {person.last_name}"
            full_address = (f"{person.address1}, {person.address2}, {person.zip}, {person.city},"
                            f"{person.state_province}, {person.country}")
            table_row_data.append(full_name)
            table_row_data.append(full_address)
            table_row_data.append(person.title)
            table_row_data.append(person.email)

            # dict containing the data, view and update url, primary key and obj
            # name to use in template
            table_row_info = {
                'table_row_data': table_row_data,
                'view_url': reverse_lazy('person_view', kwargs={'pk': person.pk}),
                'update_url': reverse_lazy('person_update', kwargs={'pk': person.pk}),
                'obj_name': str(person),
                'obj_pk': person.pk
            }
            table_data.append(table_row_info)

        context['add_url'] = reverse_lazy('person_add')
        context['table_data'] = table_data
        context['title'] = 'Person'
        return context


class PersonEdit():
    template_name = 'core/generic/edit_note.html'
    model = Person
    form_class = PersonForm
    #form_class_list = [PersonForm, NoteForm]
    success_url = reverse_lazy('person_list')

    #Note side
    context_object_name = 'person'
    NoteFormSet = modelformset_factory(Note, form=NoteForm,can_delete=True)

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        #Note side
        if 'person' in context:
            person = context['person']
            context['note_forms'] = self.NoteFormSet(
                queryset=Note.objects.filter(ref_note_uuid=person.pk),prefix='note')
            context['tag_form'] = TagXForm(
                initial = {'tag_uuid':
                    Tag_x.objects.filter(ref_tag_uuid=person.pk).values_list('tag_uuid', flat=True)})
        context['title'] = 'Person'
        return context


    def post(self, request, *args, **kwargs):
        #Note side
        NoteFormSet = self.NoteFormSet(request.POST or None,prefix='note')
        person = get_object_or_404(Person, pk=self.kwargs['pk'])

        # Loop through every note form
        for form in NoteFormSet:
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
                    note.ref_note_uuid = person.pk
                    note.save()
        NoteFormSet.save(commit=False)
        # Delete each note we marked in the formset
        for obj in NoteFormSet.deleted_objects:
            obj.delete()

        # Tag side
        TagForm = TagXForm(request.POST or None)
        # Loop through every tagX form
        # Only if the form has changed make an update, otherwise ignore
        if TagForm.has_changed() and TagForm.is_valid():
            if request.user.is_authenticated:
                # Before is UUID, After is object
                tag_queryset_before = Tag_x.objects.filter(ref_tag_uuid=person.pk).values_list('tag_uuid', flat=True)
                tag_queryset_after = TagForm.cleaned_data['tag_uuid']
                # If tag exist after post but not before, add corresponding tag_x
                for tag in tag_queryset_after:
                    if tag.tag_uuid not in tag_queryset_before:
                        addedTagX = Tag_x(ref_tag_uuid=person.pk,tag_uuid=tag)
                        addedTagX.save()
                # If tag exist before post but not after, delete corresponding tag_x
                for tag_uuid in tag_queryset_before:
                    if Tag.objects.get(tag_uuid=tag_uuid) not in tag_queryset_after:
                        tag_x_set = Tag_x.objects.filter(ref_tag_uuid=person.pk,tag_uuid=Tag.objects.get(tag_uuid=tag_uuid))
                        for tag_x in tag_x_set:
                            tag_x.delete()
        else:
            raise Exception("Form not changed or not valid")

        # Delete each tag we marked in the formset
        #TagForm.save(commit=False)

        # Choose which website we are redirected to
        if request.POST.get("Submit"):
            self.success_url = reverse_lazy('person_list')
        if request.POST.get('update'):
            self.success_url = reverse_lazy('person_update',kwargs={'pk': person.pk})

        return super().post(request, *args, **kwargs)


class PersonCreate(PersonEdit, CreateView):
    #Note side
    template_name = 'core/generic/edit.html'
    NoteFormSet = None


class PersonUpdate(PersonEdit, UpdateView):
    pass


class PersonDelete(DeleteView):
    model = Person
    success_url = reverse_lazy('person_list')


class PersonView(DetailView):
    model = Person
    template_name = 'core/generic/detail.html'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        obj = context['object']
        table_data = {

                'Full Name': f"{obj.first_name} {obj.middle_name} {obj.last_name}",
                'Address': (f" {obj.address1}, {obj.address2}, {obj.zip}, {obj.city},"
                                f" {obj.state_province}, {obj.country}"),
                'Phone': obj.phone,
                'Email': obj.email,
                'Title' : obj.title,
                'Suffix' : obj.suffix,
                'Organization' : obj.organization_full_name,
                'Add Date': obj.add_date,
                'Last Modification Date': obj.mod_date

        }
        context['title'] = 'Person'
        context['update_url'] = reverse_lazy(
            'person_update', kwargs={'pk': obj.pk})
        context['table_data'] = table_data
        return context