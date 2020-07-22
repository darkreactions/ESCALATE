from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView
from django import forms

from ..models import Material,Note, Actor
from ..forms import MaterialForm, NoteForm
from .menu import GenericListView
#Note side
from django.forms import modelformset_factory
from django.shortcuts import get_object_or_404



class MaterialsList(GenericListView):
    model = Material
    #template_name = 'core/material/material_list.html'
    template_name = 'core/generic/list.html'
    context_object_name = 'materials'
    paginate_by = 10
    def get_queryset(self):
        filter_val = self.request.GET.get('filter', '')
        ordering = self.request.GET.get('ordering', 'material_uuid')
        if filter_val != None:
            new_queryset = self.model.objects.filter(
                material_uuid__icontains=filter_val).select_related().order_by(ordering)
        else:
            new_queryset = self.model.objects.all().select_related().order_by(ordering)
        return new_queryset

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        table_columns = ['Chemical Name', 'Abbreviation', 'Status', 'Actions']
        context['table_columns'] = table_columns
        materials = context['materials']
        table_data = []
        for material in materials:
            table_row_data = []

            # data for the object we want to display for a row
            table_row_data.append(material.chemical_name)
            table_row_data.append(material.abbreviation)
            table_row_data.append(material.material_status_description)

            # dict containing the data, view and update url, primary key and obj
            # name to use in template
            table_row_info = {
                    'table_row_data' : table_row_data,
                    'view_url' : reverse_lazy('material_view', kwargs={'pk': material.pk}),
                    'update_url' : reverse_lazy('material_update', kwargs={'pk': material.pk}),
                    'obj_name' : str(material),
                    'obj_pk' : material.pk
                    }
            table_data.append(table_row_info)

        context['add_url'] = reverse_lazy('material_add')
        context['table_data'] = table_data
        context['title'] = 'material'
        return context


class MaterialEdit:
    template_name = 'core/generic/edit_note.html'
    model = Material
    form_class = MaterialForm
    success_url = reverse_lazy('material_list')

    #Note side
    context_object_name = 'material'
    NoteFormSet = modelformset_factory(Note, form=NoteForm,can_delete=True)


    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        if 'material' in context:
            material = context['material']
            context['note_forms'] = self.NoteFormSet(
                queryset=Note.objects.filter(ref_note_uuid=material.pk))
        context['title'] = 'Material'
        return context

    def post(self, request, *args, **kwargs):
        #Note side
        if self.NoteFormSet != None:
            formset = self.NoteFormSet(request.POST)
            material = get_object_or_404(Material, pk=self.kwargs['pk'])
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
                        note.ref_note_uuid = material.pk
                        note.save()
            # Delete each note we marked in the formset
            formset.save(commit=False)
            for obj in formset.deleted_objects:
                obj.delete()
            # Choose which website we are redirected to
        if request.POST.get("Submit"):
            self.success_url = reverse_lazy('material_list')
        if request.POST.get('update'):
            self.success_url = reverse_lazy('material_update',kwargs={'pk': material.pk})

        return super().post(request, *args, **kwargs)


class MaterialCreate(MaterialEdit, CreateView):
    #Note side
    template_name = 'core/generic/edit.html'
    NoteFormSet = None


class MaterialUpdate(MaterialEdit, UpdateView):
    pass


class MaterialDelete(DeleteView):
    model = Material
    success_url = reverse_lazy('material_list')


class MaterialView(DetailView):
    template_name = 'core/generic/detail.html'
    model = Material
    #queryset = Material.objects.select_related()

    def get_context_data(self,**kwargs):
        context = super().get_context_data(**kwargs)
        obj = context['object']
        table_data = {
                'Chemical name': obj.chemical_name,
                'Abbreviation': obj.abbreviation,
                'Moledular formula': obj.molecular_formula,
                'InChI': obj.inchi,
                'InChI key': obj.inchikey,
                'Smiles': obj.smiles,
                'Create Date': obj.create_date,
                'Status': obj.material_status_description
        }
        context['update_url'] = reverse_lazy(
            'material_update', kwargs={'pk': obj.pk})
        context['title'] = 'Material'
        context['table_data'] = table_data
        return context
