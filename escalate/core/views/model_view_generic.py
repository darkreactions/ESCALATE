from django.urls import reverse_lazy
from django.http import HttpResponse
#from django.views.generic.detail import DetailView
#from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView
from core.models import Note, Actor, Tag_X, Tag
from core.forms import NoteForm, TagSelectForm
#from core.views.menu import GenericListView
from django.forms import modelformset_factory
from django.shortcuts import get_object_or_404
from core.views.menu import GenericListView

#class with generic classes to use in models

class GenericModelList(GenericListView):
    template_name = 'core/generic/list.html'

    #Override the 2 fields below in subclass
    model = None
    context_object_name = None #lowercase, snake case and plural. Ex:tag_types or inventorys

    #for get_context_data method.
    # Override 2 fields below in subclass
    table_columns = None    #list of strings of column names
    column_necessary_fields = None    #should be a dictionary with keys from table_columns
                            #and value should be a list of the field names (as strings)needed
                            #to fill out the corresponding cell.
                            #Fields in list of fields should be spelled exactly
                            # Ex: {'Name': ['first_name','middle_name','last_name']}

    #for get_queryset method. Override the 2 fields below in subclass
    order_field = None  #Ex: 'first_name'
    field_contains = None   #Ex: 'Gary'. Use '' to show all

    paginate_by = 10

    def get_queryset(self):
        filter_val = self.request.GET.get('filter', self.field_contains)
        ordering = self.request.GET.get('ordering', self.order_field)

        #same as <field want to order by>__icontains = filter_val
        filter_kwargs = {'{}__{}'.format(self.order_field, 'icontains'):filter_val}

        if filter_val != None:
            new_queryset = self.model.objects.filter(
                **filter_kwargs).select_related().order_by(ordering)
        else:
            new_queryset = self.model.objects.all()
        return new_queryset

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['table_columns'] = self.table_columns
        models = context[self.context_object_name]
        model_name = self.context_object_name[:-1] #Ex: tag_types -> tag_type
        table_data = []
        for model in models:
            table_row_data = []

            #loop to get each column data for one row
            for i in range(0,len(self.table_columns)-1):
                #get list of fields used to fill out one cell
                necessary_fields = self.column_necessary_fields[self.table_columns[i]]
                #get actual field value from the model
                fields_for_col = [getattr(model,field) for field in necessary_fields]
                #loop to change None to '' or non-string to string because join needs strings
                for k in range(0, len(fields_for_col)):
                    if fields_for_col[k] == None:
                        fields_for_col[k] = ''
                    if not isinstance(fields_for_col[k],str):
                        fields_for_col[k] = str(fields_for_col[k])
                col_data = " ".join(fields_for_col)
                #take away any leading and trailing whitespace
                col_data = col_data.strip()
                #change the cell data to be N/A if it is empty string at this point
                if len(col_data) == 0:
                    col_data = 'N/A'
                table_row_data.append(col_data)


            # dict containing the data, view and update url, primary key and obj
            # name to use in template
            table_row_info = {
                'table_row_data': table_row_data,
                'view_url': reverse_lazy(f'{model_name}_view', kwargs={'pk': model.pk}),
                'update_url': reverse_lazy(f'{model_name}_update', kwargs={'pk': model.pk}),
                'obj_name': str(model),
                'obj_pk': model.pk
            }
            table_data.append(table_row_info)

        context['add_url'] = reverse_lazy(f'{model_name}_add')
        context['table_data'] = table_data
        # get rid of underscores with spaces and capitalize
        context['title'] = model_name.replace('_',' ').capitalize()
        return context

class GenericModelEdit:
    template_name = 'core/generic/edit_note_tag.html'

    #override in subclass
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
