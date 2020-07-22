from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import UdfDef,Note,Actor
from core.forms import UdfDefForm,NoteForm
from core.views.menu import GenericListView

#Note side
from django.forms import modelformset_factory
from django.shortcuts import get_object_or_404

class UdfDefList(GenericListView):
    model = UdfDef
    template_name = 'core/generic/list.html'
    context_object_name = 'udf_defs'
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
        table_columns = [ 'Description','Value type','Actions']
        context['table_columns'] = table_columns
        udf_defs = context['udf_defs']
        table_data = []
        for udf_def in udf_defs:
            table_row_data = []

            # data for the object we want to display for a row
            table_row_data.append(udf_def.description)
            table_row_data.append(udf_def.valtype)
            # dict containing the data, view and update url, primary key and obj
            # name to use in template
            table_row_info = {
                'table_row_data': table_row_data,
                'view_url': reverse_lazy('udf_def_view', kwargs={'pk': udf_def.pk}),
                'update_url': reverse_lazy('udf_def_update', kwargs={'pk': udf_def.pk}),
                'obj_name': str(udf_def),
                'obj_pk': udf_def.pk
            }
            table_data.append(table_row_info)

        context['add_url'] = reverse_lazy('udf_def_add')
        context['table_data'] = table_data
        context['title'] = 'udf_def'
        return context


class UdfDefEdit:
    template_name = 'core/generic/edit_note.html'
    model = UdfDef
    form_class = UdfDefForm
    success_url = reverse_lazy('udf_def_list')
    #Note side
    context_object_name = 'udf_def'
    NoteFormSet = modelformset_factory(Note, form=NoteForm,can_delete=True)

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        if 'udf_def' in context:
            udf_def = context['udf_def']
            context['note_forms'] = self.NoteFormSet(
                queryset=Note.objects.filter(ref_note_uuid=udf_def.pk))
        context['title'] = 'udf_def'
        return context

    def post(self, request, *args, **kwargs):
        # Note side
        if self.NoteFormSet != None:
            formset = self.NoteFormSet(request.POST)
            udf_def = get_object_or_404(UdfDef, pk=self.kwargs['pk'])
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
                        # Conveniently in this case its udf_def, but we need to figure out an alternative
                        note.ref_note_uuid = udf_def.pk
                        note.save()
            # Delete each note we marked in the formset
            formset.save(commit=False)
            for obj in formset.deleted_objects:
                obj.delete()
            # Choose which website we are redirected to
        if request.POST.get("Submit"):
            self.success_url = reverse_lazy('udf_def_list')
        if request.POST.get('update'):
            self.success_url = reverse_lazy('udf_def_update', kwargs={'pk': udf_def.pk})

        return super().post(request, *args, **kwargs)


class UdfDefCreate(UdfDefEdit, CreateView):
    # Note side
    template_name = 'core/generic/edit.html'
    NoteFormSet = None


class UdfDefUpdate(UdfDefEdit, UpdateView):
    pass


class UdfDefDelete(DeleteView):
    model = UdfDef
    success_url = reverse_lazy('udf_def_list')


class UdfDefView(DetailView):
    model = UdfDef
    template_name = 'core/generic/detail.html'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        obj = context['object']
        table_data = {
                'User defined description': obj.description,
                'Value type': obj.valtype,
                'Add date': obj.add_date,
                'Modified date': obj.mod_date
        }
        context['update_url'] = reverse_lazy(
            'udf_def_update', kwargs={'pk': obj.pk})
        context['title'] = 'udf_def'
        context['table_data'] = table_data
        return context

