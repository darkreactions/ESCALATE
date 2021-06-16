from django.db.models.query import QuerySet
from django.db.models import Q
from django.urls import reverse_lazy, reverse
from django.http import HttpResponse, HttpResponseRedirect, FileResponse
from django.views import View
from django.views.generic.detail import DetailView
from django.views.generic.list import ListView
# from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView
from core.models.view_tables import Note, Actor, TagAssign, Tag, Edocument
from core.models.core_tables import TypeDef
from core.forms.forms import NoteForm, TagSelectForm, UploadEdocForm
from django.forms import modelformset_factory
from django.shortcuts import get_object_or_404, render
from django.core.exceptions import FieldDoesNotExist
from core.utilities.view_utils import rgetattr

import csv
#import core.views.exports.file_types as export_file_types
import core

# class with generic classes to use in models


class GenericListView(ListView):

    def get_context_data(self, **kwargs):
        context = super(GenericListView, self).get_context_data(**kwargs)
        context['filter'] = self.request.GET.get('filter', '')
        return context

class GenericModelList(GenericListView):
    template_name = 'core/generic/list.html'

    # Override the 2 fields below in subclass
    model = None
    # lowercase, snake case and plural. Ex:tag_types or inventorys
    context_object_name = None

    # for get_context_data method.
    # Override 2 fields below in subclass
    table_columns = None  # list of strings of column names
    # should be a dictionary with keys from table_columns
    column_necessary_fields = None
    # and value should be a list of the field names (as strings)needed
    # to fill out the corresponding cell.
    # Fields in list of fields should be spelled exactly
    # Ex: {'Name': ['first_name','middle_name','last_name']}

    # for get_queryset method. Override the 2 fields below in subclass
    ordering = None  # Ex: ['first_name', etc...]
    field_contains = None  # Ex: 'Gary'. Use '' to show all

    # A related path that points to the organization this field belongs to
    org_related_path = None

    paginate_by = 10


    def header_to_necessary_fields(self, field_raw):
        # get the fields that make up the header column
        return self.column_necessary_fields[field_raw]

    def get_queryset(self):
        filter_val = self.request.GET.get('filter', self.field_contains)
        new_order = self.request.session.get(f'{self.context_object_name}_order', self.ordering)
        
        ordering = self.request.GET.get('ordering', new_order)
        
        #print(f'Order field: {self.order_field} in model {self.model}')

        # same as <field want to order by>__icontains = filter_val
        #filter_kwargs = {'{}__{}'.format(
        #    "".join(order_field.split('-')), 'icontains'): filter_val}
        order = "".join(ordering[0].split('-'))
        filter_kwargs = {f'{order}__icontains': filter_val}

        # Filter by organization if it exists in the model
        if 'current_org_id' in self.request.session:
            if self.org_related_path:
                org_filter_kwargs = {self.org_related_path : self.request.session['current_org_id']}
                base_query = self.model.objects.filter(**org_filter_kwargs)
            else:
                try:
                    #print(self.model._meta.get_fields())
                    org_field = self.model._meta.get_field('organization')
                    base_query = self.model.objects.filter(organization=self.request.session['current_org_id'])
                except FieldDoesNotExist:
                    base_query = self.model.objects.all()
        else:
            base_query = self.model.objects.none()


        if filter_val != None:
            new_queryset = base_query.filter(
                **filter_kwargs).select_related().order_by(*ordering)
        else:
            new_queryset = base_query.select_related().order_by(*ordering)

        # new_queryset = base_query
        return new_queryset

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['table_columns'] = self.table_columns
        models = context[self.context_object_name]
        model_name = self.context_object_name[:-1]  # Ex: tag_types -> tag_type
        table_data = []
        for model_instance in models:
            table_row_data = []

            # loop to get each column data for one row. [:-1] because table_columns has 'Actions'
            header_names = self.table_columns[:-1]
            for field_name in header_names:
                # get list of fields used to fill out one cell
                necessary_fields = self.column_necessary_fields[field_name]
                # get actual field value from the model
                fields_for_col = []
                for field in necessary_fields:
                    #not foreign key and manytomany
                    if field.split('.') == 1 and self.model._meta.get_field(field).__class__.__name__ == 'ManyToManyField':
                        to_add = '\n'.join([str(x) for x in getattr(model_instance, field).all()])
                    else:
                        #Ex: Person.organization.full_name
                        to_add = rgetattr(model_instance, field)
                        if to_add.__class__.__name__ == 'ManyRelatedManager':
                            #if what we get is a many to many object instead of a flat easy to stringify field value
                            #Ex: Model.foreignkey.manyToMany
                            to_add = '\n'.join([str(x) for x in getattr(model_instance, field).all()])
                    fields_for_col.append(to_add)
                # loop to change None to '' or non-string to string because join needs strings
                for k in range(0, len(fields_for_col)):
                    if fields_for_col[k] == None:
                        fields_for_col[k] = ''
                    if not isinstance(fields_for_col[k], str):
                        fields_for_col[k] = str(fields_for_col[k])
                col_data = " ".join(fields_for_col)
                # take away any leading and trailing whitespace
                col_data = col_data.strip()
                # change the cell data to be N/A if it is empty string at this point
                if len(col_data) == 0:
                    col_data = 'N/A'
                table_row_data.append(col_data)

            # dict containing the data, view and update url, primary key and obj
            # name to use in template
            table_row_info = {
                'table_row_data': table_row_data,
                'view_url': reverse_lazy(f'{model_name}_view', kwargs={'pk': model_instance.pk}),
                'update_url': reverse_lazy(f'{model_name}_update', kwargs={'pk': model_instance.pk}),
                'obj_name': str(model_instance),
                'obj_pk': model_instance.pk
            }
            if model_name=="edocument":
                table_row_info['download_url'] = reverse('edoc_download', args=(model_instance.pk,))
            table_data.append(table_row_info)

        context['add_url'] = reverse_lazy(f'{model_name}_add')
        context['table_data'] = table_data
        # get rid of underscores with spaces and capitalize
        context['title'] = model_name.replace('_', ' ').capitalize()

        export_urls = {}
        #for t in export_file_types.file_types:
        for t in core.views.exports.file_types.file_types:
            export_urls[t.upper()] = reverse_lazy(f'{model_name}_export_{t}')
        context['export_urls'] = export_urls
        return context

    def post(self, request, *args, **kwargs):
        if request.POST.get('sort',None) != None:
            order_raw = request.POST.get('sort').split('_')
            header, order, *_rest = order_raw
            if order == 'des':
                request.session[f'{self.context_object_name}_order'] = [f"-{f}" for f in self.header_to_necessary_fields(header)]
            else:
                request.session[f'{self.context_object_name}_order'] = self.header_to_necessary_fields(header)


        # break up cases on which one was clicked
        # should be one of table_columns
        # find index
        # go to same index in column_necessary_fields
        # order by 0th field for that one
        return HttpResponseRedirect(reverse(f'{self.context_object_name[:-1]}_list'))


class GenericModelEdit:
    template_name = 'core/generic/edit_note_tag.html'

    # override in subclass
    model = None
    context_object_name = None
    form_class = None

    # success_url = reverse_lazy(f'{context_object_name}_list')
    NoteFormSet = modelformset_factory(
        Note, form=NoteForm, can_delete=True)

    EdocFormSet = modelformset_factory(
        Edocument, form=UploadEdocForm, can_delete=True
    )

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        
        if self.context_object_name in context:

            model = context[self.context_object_name]

            note_forms = self.NoteFormSet(
                queryset=Note.objects.filter(ref_note_uuid=model.pk),
                prefix='note')

            context['note_forms'] = note_forms

            edocuments = Edocument.objects.filter(ref_edocument_uuid=model.pk)
            edoc_forms = self.EdocFormSet(
                queryset=edocuments,
                prefix='edoc')
   
            context['edoc_forms'] = edoc_forms
            edoc_files = []
            for edoc in edocuments:
                filename = edoc.filename

                # redirect to api link to download
                download_url = reverse('edoc_download', args=(edoc.uuid,))
                edoc_files.append({
                    'filename': filename,
                    'download_url': download_url
                })
            context['edoc_files'] = edoc_files
            context['edoc_management_form'] = edoc_forms.management_form
            context['tag_select_form'] = TagSelectForm(model_pk=model.pk)
        else:
            context['note_forms'] = self.NoteFormSet(
                queryset=self.model.objects.none(),
                prefix='note')
#            context['edoc_forms'] = self.EdocFormSet(
#                querySet=Edocument.objects.none(),
#                prefix='edoc')
            context['edoc_files'] = []
            context['tag_select_form'] = TagSelectForm()

        context['title'] = self.context_object_name.capitalize()

        return context

    def post(self, request, *args, **kwargs):
        if 'pk' in self.kwargs:
            model = get_object_or_404(self.model, pk=self.kwargs['pk'])
        else:
            model = self.model()
        if request.POST.get('add_new_tag'):
            request.session['model_name'] = self.context_object_name
            self.success_url = reverse_lazy(
                'model_tag_create', kwargs={'pk': model.pk})
        if request.POST.get("Submit"):
            self.success_url = reverse(f'{self.context_object_name}_list')
        return super().post(request, *args, **kwargs)

    def form_valid(self, form):
        print('INSIDE FORM VALID')
        self.object = form.save()

        if self.object.pk is None:
            required_fields = [f.name for f in self.model._meta.get_fields(
            ) if not rgetattr(f, 'null', False) is True]

            required_fields = [f for f in required_fields if f not in [
                'add_date', 'mod_date', 'uuid']]


            query = {k: v for k, v in self.object.__dict__.items() if (
                k in required_fields)}


            self.object = self.model.objects.filter(**query).latest('mod_date')

        if self.request.POST.get('tags'):
            # tags from post
            submitted_tags = self.request.POST.getlist('tags')
            # tags from db with a TagAssign that connects the model and the tags
            existing_tags = Tag.objects.filter(pk__in=TagAssign.objects.filter(
                ref_tag=self.object.pk).values_list('tag', flat=True))
            for tag in existing_tags:
                if tag not in submitted_tags:
                    if self.request.user.is_authenticated:
                        #this tag is not assign to this model anymore
                        # delete TagAssign for existing tags that are no longer used
                        TagAssign.objects.filter(tag=tag).delete()
            for tag in submitted_tags:
                # make TagAssign for existing tags that are now used
                if tag not in existing_tags:
                    if self.request.user.is_authenticated:
                        # get actual tag obj with that uuid
                        tag_obj = Tag.objects.get(pk=tag)
                        tag_assign = TagAssign()
                        tag_assign.tag = tag_obj
                        tag_assign.ref_tag = self.object.pk
                        tag_assign.save()
        else:
            # no submitted tags
            # deleted all tags or actually submitted no tags
            existing_tags = Tag.objects.filter(pk__in=TagAssign.objects.filter(
                ref_tag=self.object.pk).values_list('tag', flat=True))
            if self.request.user.is_authenticated:
                for tag in existing_tags:
                    TagAssign.objects.filter(tag=tag).delete()

        if self.NoteFormSet != None:
            actor = Actor.objects.get(
                person=self.request.user.person.pk, organization=None)
            formset = self.NoteFormSet(self.request.POST, prefix='note')
            # Loop through every note form
            for form in formset:
                # Only if the form has changed make an update, otherwise ignore
                if form.has_changed() and form.is_valid():
                    if self.request.user.is_authenticated:
                        # Get the appropriate actor and then add it to the note
                        note = form.save(commit=False)
                        note.actor = actor
                        # Get the appropriate uuid of the record being changed.
                        note.ref_note_uuid = self.object.pk
                        note.save()

            # Delete each note we marked in the formset
            formset.save(commit=False)
            for form in formset.deleted_forms:
                form.instance.delete()
            # Choose which website we are redirected to
            if self.request.POST.get('add_note'):
                self.success_url = reverse_lazy(
                    f'{self.context_object_name}_update', kwargs={'pk': self.object.pk})
        
        if self.EdocFormSet != None:
            actor = Actor.objects.get(
                person=self.request.user.person.pk, organization=None)
            formset = self.EdocFormSet(self.request.POST, self.request.FILES, prefix='edoc')
            # Loop through every edoc form
            for form in formset:
                # Only if the form has changed make an update, otherwise ignore
                if form.has_changed() and form.is_valid():
                    if self.request.user.is_authenticated:
                        edoc = form.save(commit=False)
                        if form.cleaned_data['file']:
                            #New edoc or update file of existing edoc
                            
                            file = form.cleaned_data['file']
                            # Hopefuly every file name is structed as <name>.<ext>
                            _file_name_detached, ext, *_ = file.name.split('.')

                            edoc.edocument = file.read()
                            edoc.filename = file.name
                            
                            #file type that the user entered
                            file_type_user = form.cleaned_data['file_type']

                            #try to get the file_type from db that is spelled the same as the file extension
                            try:
                                file_type_db = TypeDef.objects.get(category="file",description=ext)
                            except TypeDef.DoesNotExist:
                                file_type_db = None

                            if file_type_db:
                                #found find file type corresponding to file extension
                                #use that file type instead of what user entered
                                edoc.doc_type_uuid = file_type_db
                            else:
                                #did not find file type corresponding to file extension
                                #use file type user entered in form

                                #default file type in case file ext is not in db and user did not 
                                #enter a file type
                                default_type = TypeDef.objects.get(category="file",description="text")
                                
                                edoc.doc_type_uuid = file_type_user if file_type_user else default_type
                        
                        # Get the appropriate actor and then add it to the edoc
                        edoc.actor = actor
                        # Get the appropriate uuid of the record being changed.
                        edoc.ref_edocument_uuid = self.object.pk
                        edoc.save()

            # Delete each note we marked in the formset
            formset.save(commit=False)
            for form in formset.deleted_forms:
                form.instance.delete()
            # Choose which website we are redirected to
            if self.request.POST.get('add_edoc'):
                self.success_url = reverse_lazy(
                    f'{self.context_object_name}_update', kwargs={'pk': self.object.pk})            

        return HttpResponseRedirect(self.get_success_url())

    def form_invalid(self, form):
        print('IN FORM INVALID!')
        context = self.get_context_data()
        context['form'] = form
        return render(self.request, self.template_name, context)


class GenericModelView(DetailView):
    # Override below 2 in subclass
    model = None
    model_name = None  # lowercase, snake case. Ex:tag_type or inventory

    template_name = 'core/generic/detail.html'

    # Override below 2 in subclass
    # list of strings of detail fields (does not need to be same as field names in model)
    detail_fields = None
    detail_fields_need_fields = None  # should be a dictionary with keys detail_fields
    # and value should be a list of the field names (as strings)needed
    # to fill out the corresponding cell.
    # Fields in list of fields should be spelled exactly
    # Ex: {'Name': ['first_name','middle_name','last_name']}

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        obj = context['object']
        # dict of detail field names to their value
        detail_data = {}

        # loop to get each detail data for one detail field
        for field_verbose in self.detail_fields:
            # get list of fields used to fill out one detail field
            necessary_fields = self.detail_fields_need_fields[field_verbose]
            # get actual field value from the model
            fields_for_field = []
            for field in necessary_fields:
                #not foreign key and manytomany
                if field.split('.') == 1 and self.model._meta.get_field(field).__class__.__name__ == 'ManyToManyField':
                    to_add = '\n'.join([str(x) for x in getattr(obj, field).all()])
                else:
                    #Ex: Person.organization.full_name
                    to_add = rgetattr(obj, field)
                    if to_add.__class__.__name__ == 'ManyRelatedManager':
                        #if value is many to many obj get the values
                        #Ex: Model.foreignkey.manyToMany
                        to_add = '\n'.join([str(x) for x in getattr(obj, field).all()])
                fields_for_field.append(to_add)
            # loop to change None to '' or non-string to string because join needs strings
            for i in range(0, len(fields_for_field)):
                if fields_for_field[i] == None:
                    fields_for_field[i] = ''
                elif not isinstance(fields_for_field[i], str):
                    fields_for_field[i] = str(fields_for_field[i])
                else:
                    continue
            obj_detail = ' '.join(fields_for_field)
            obj_detail = obj_detail.strip()
            if len(obj_detail) == 0:
                obj_detail = 'N/A'
            detail_data[field_verbose] = obj_detail

        # get notes
        notes_raw = Note.objects.filter(ref_note_uuid=obj.pk)
        notes = []
        for note in notes_raw:
            notes.append('-' + note.notetext)
        context['Notes'] = notes

        # get tags
        tags_raw = Tag.objects.filter(pk__in=TagAssign.objects.filter(
            ref_tag=obj.pk).values_list('tag', flat=True))
        tags = []
        for tag in tags_raw:
            tags.append(tag.display_text.strip())
        detail_data['Tags'] = ', '.join(tags)

        # get edocuments
        edocs_raw = Edocument.objects.filter(ref_edocument_uuid=obj.pk)
        edocs = []
        for edoc in edocs_raw:
            filename = edoc.filename

            # redirect to api link to download
            download_url = reverse('edoc_download', args=(edoc.uuid,))
            edocs.append({
                'filename': filename,
                'download_url': download_url
            })
        context['Edocs'] = edocs
            

        context['title'] = self.model_name.replace('_', " ").capitalize()
        context['update_url'] = reverse_lazy(
            f'{self.model_name}_update', kwargs={'pk': obj.pk})
            
        if self.model_name=="edocument":
            context['download_url'] = reverse('edoc_download', args=(obj.pk,))
        context['detail_data'] = detail_data
        return context

class GenericModelExport(View):
    model = None
    file_type = None
    column_names = None
    column_necessary_fields = None
    # A related path that points to the organization this field belongs to
    org_related_path = None

    def get(self, request, *args, **kwargs):
        if self.file_type == 'csv':
            return self.export_csv()
        else:
            return HttpResponse('Failed to get requested file')

    def get_queryset(self):
        if 'current_org_id' in self.request.session:
            if self.org_related_path:
                org_filter_kwargs = {self.org_related_path : self.request.session['current_org_id']}
                base_query = self.model.objects.filter(**org_filter_kwargs)
            else:
                try:
                    #print(self.model._meta.get_fields())
                    org_field = self.model._meta.get_field('organization')
                    base_query = self.model.objects.filter(organization=self.request.session['current_org_id'])
                except FieldDoesNotExist:
                    base_query = self.model.objects.all()
        else:
            base_query = self.model.objects.none()
        return base_query

    def export_csv(self):
        response = HttpResponse(content_type="text/csv")
        model_string_name = self.model.__name__
        filename = f'{model_string_name.capitalize()}.csv'
        response['Content-Disposition'] = f'attachment; filename={filename}'

        writer = csv.writer(response)
        writer.writerow([*self.column_names])

        model_objects = self.get_queryset()

        for obj in model_objects:
            row = []
            for col_name in self.column_names:
                cell_data = ""
                fields_for_cell = [rgetattr(obj, field) for field in self.column_necessary_fields[col_name]]
                for k in range(len(fields_for_cell)):
                    if fields_for_cell[k] == None:
                        fields_for_cell[k] = ''
                    if not isinstance(fields_for_cell[k], str):
                        fields_for_cell[k] = str(fields_for_cell[k])

                    cell_data = " ".join(fields_for_cell)
                    cell_data = cell_data.strip()
                row.append(cell_data)
            writer.writerow(row)
        return response


