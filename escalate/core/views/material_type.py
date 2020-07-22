from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import MaterialType, Note, Actor
from core.forms import MaterialTypeForm, NoteForm
from core.views.menu import GenericListView
#Note side
from django.forms import modelformset_factory
from django.shortcuts import get_object_or_404




class MaterialTypeList(GenericListView):
    model = MaterialType
    #template_name = 'core/material_type/material_type_list.html'
    template_name = 'core/generic/list.html'
    context_object_name = 'material_types'
    paginate_by = 10

    def get_queryset(self):
        return self.model.objects.all()
        filter_val = self.request.GET.get('filter', '')
        ordering = self.request.GET.get('ordering', 'description')
        if filter_val != None:
            new_queryset = self.model.objects.filter(
                description__icontains=filter_val).select_related().order_by(ordering)
        else:
            new_queryset = self.model.objects.all()
        return new_queryset

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        table_columns = ['Description', 'Actions']
        context['table_columns'] = table_columns
        material_types = context['material_types']
        table_data = []
        for material_type in material_types:
            table_row_data = []

            # data for the object we want to display for a row
            table_row_data.append(material_type.description)

            # dict containing the data, view and update url, primary key and obj
            # name to use in template
            table_row_info = {
                    'table_row_data' : table_row_data,
                    'view_url' : reverse_lazy('material_type_view', kwargs={'pk': material_type.pk}),
                    'update_url' : reverse_lazy('material_type_update', kwargs={'pk': material_type.pk}),
                    'obj_name' : str(material_type),
                    'obj_pk' : material_type.pk
                    }
            table_data.append(table_row_info)

        context['add_url'] = reverse_lazy('material_type_add')
        context['table_data'] = table_data
        context['title'] = 'material_type'
        return context


class MaterialTypeEdit:
    template_name = 'core/generic/edit_note.html'
    model = MaterialType
    form_class = MaterialTypeForm
    success_url = reverse_lazy('material_type_list')

    #Note side
    context_object_name = 'material_type'
    NoteFormSet = modelformset_factory(Note, form=NoteForm,can_delete=True)

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        #Note side
        if 'material_type' in context:
            material_type = context['material_type']
            context['note_forms'] = self.NoteFormSet(
                queryset=Note.objects.filter(ref_note_uuid=material_type.pk))

        context['title'] = 'Material_Type'
        return context

    def post(self, request, *args, **kwargs):
        #Note side
        if self.NoteFormSet != None:
            formset = self.NoteFormSet(request.POST)
            material_type = get_object_or_404(MaterialType, pk=self.kwargs['pk'])
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
                        note.ref_note_uuid = material_type.pk
                        note.save()
            # Delete each note we marked in the formset
            formset.save(commit=False)
            for obj in formset.deleted_objects:
                obj.delete()
            # Choose which website we are redirected to
        if request.POST.get("Submit"):
            self.success_url = reverse_lazy('material_type_list')
        if request.POST.get('update'):
            self.success_url = reverse_lazy('material_type_update',kwargs={'pk': material_type.pk})

        return super().post(request, *args, **kwargs)



class MaterialTypeCreate(MaterialTypeEdit, CreateView):
    #Note side
    template_name = 'core/generic/edit.html'
    NoteFormSet = None


class MaterialTypeUpdate(MaterialTypeEdit, UpdateView):
    pass


class MaterialTypeDelete(DeleteView):
    model = MaterialType
    success_url = reverse_lazy('material_type_list')


class MaterialTypeView(DetailView):
    model = MaterialType
    template_name = 'core/generic/detail.html'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        obj = context['object']
        table_data = {
                'Description': obj.description,
                'Add Date': obj.add_date,
                'Last Modification Date': obj.mod_date
        }
        context['update_url'] = reverse_lazy('material_type_update', kwargs={'pk':obj.pk})
        context['title'] = 'Material Type'
        context['table_data'] = table_data
        return context
