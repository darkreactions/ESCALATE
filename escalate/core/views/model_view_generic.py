from django.urls import reverse_lazy
from django.http import HttpResponse
#from django.views.generic.detail import DetailView
#from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView
from core.models import Note, Actor, Tag_X, Tag
from core.forms import NoteForm, TagSelectForm
#from core.views.menu import GenericListView
from django.forms import modelformset_factory
from django.shortcuts import get_object_or_404



class GenericModelEdit:
    template_name = 'core/generic/edit_note_tag.html'
    model = None
    context_object_name = None
    form_class = None
    success_url = reverse_lazy(f'{context_object_name}_list')
    NoteFormSet = modelformset_factory(Note, form=NoteForm,can_delete=True)


    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        if self.context_object_name in context:
            model = context[self.context_object_name]
            context['note_forms'] = self.NoteFormSet(
                queryset=Note.objects.filter(ref_note_uuid=model.pk),prefix='note')
            context['tag_select_form'] = TagSelectForm(model_pk=model.pk)
        context['title'] = self.context_object_name.capitalize()
        return context

    def post(self, request, *args, **kwargs):
        actor = Actor.objects.get(
            person_uuid=request.user.person.pk)
        model = get_object_or_404(self.model, pk=self.kwargs['pk'])
        if self.NoteFormSet != None:
            formset = self.NoteFormSet(request.POST,prefix='note')
            # Loop through every note form
            for form in formset:
                # Only if the form has changed make an update, otherwise ignore
                if form.has_changed() and form.is_valid():
                    if request.user.is_authenticated:
                        # Get the appropriate actor and then add it to the note
                        note = form.save(commit=False)
                        note.actor_uuid = actor
                        # Get the appropriate uuid of the record being changed.
                        note.ref_note_uuid = model.pk
                        note.save()
            # Delete each note we marked in the formset
            formset.save(commit=False)
            for form in formset.deleted_forms:
                form.instance.delete()
            # Choose which website we are redirected to
            if request.POST.get('add_note'):
                self.success_url = reverse_lazy(f'{self.context_object_name}_update',kwargs={'pk': model.pk})
        if request.POST.get('tags'):
            #tags from post
            submitted_tags = request.POST.getlist('tags')
            #tags from db with a tag_x that connects the model and the tags
            existing_tags = Tag.objects.filter(pk__in=Tag_X.objects.filter(ref_tag_uuid=model.pk).values_list('tag_uuid',flat=True))
            for tag in existing_tags:
                if tag not in submitted_tags:
                #delete tag_x for existing tags that are no longer used
                    Tag_X.objects.filter(tag_uuid=tag).delete()
            for tag in submitted_tags:
                #make tag_x for existing tags that are now used
                if tag not in existing_tags:
                    #for some reason tags from post are the uuid as a string
                    tag_obj = Tag.objects.get(pk=tag) #get actual tag obj with that uuid
                    tag_x = Tag_X()
                    tag_x.tag_uuid=tag_obj
                    tag_x.ref_tag_uuid=model.pk
                    tag_x.add_date=tag_obj.add_date
                    tag_x.mod_date=tag_obj.mod_date
                    tag_x.save()
        if request.POST.get('add_new_tag'):
            request.session['model_name'] = self.context_object_name
            self.success_url = reverse_lazy('model_tag_create', kwargs={'pk':model.pk})
        if request.POST.get("Submit"):
            self.success_url = reverse_lazy(f'{self.context_object_name}_list')
        return super().post(request, *args, **kwargs)
