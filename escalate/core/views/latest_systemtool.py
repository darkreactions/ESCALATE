from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import LatestSystemtool,Note,Actor
from core.forms import LatestSystemtoolForm,NoteForm
from core.views.menu import GenericListView

#Note side
from django.forms import modelformset_factory
from django.shortcuts import get_object_or_404


class SystemtoolList(GenericListView):
    model = LatestSystemtool
    template_name = 'core/generic/list.html'
    context_object_name = 'systemtools'
    paginate_by = 10

    def get_queryset(self):
        return self.model.objects.all()
        filter_val = self.request.GET.get('filter', '')
        ordering = self.request.GET.get('ordering', 'systemtool_name')
        if filter_val != None:
            new_queryset = self.model.objects.filter(
                systemtool_name__icontains=filter_val).select_related().order_by(ordering)
        else:
            new_queryset = self.model.objects.all()
        return new_queryset

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        table_columns = ['Name', 'Description', 'System Tool Type', 'Vendor Organization', 'Actions']
        context['table_columns'] = table_columns
        systemtools = context['systemtools']
        table_data = []
        for systemtool in systemtools:
            table_row_data = []

            # data for the object we want to display for a row
            table_row_data.append(systemtool.systemtool_name)
            table_row_data.append(systemtool.description)
            table_row_data.append(systemtool.systemtool_type_uuid)
            table_row_data.append(systemtool.vendor_organization_uuid)

            # dict containing the data, view and update url, primary key and obj
            # name to use in template
            table_row_info = {
                'table_row_data': table_row_data,
                'view_url': reverse_lazy('systemtool_view', kwargs={'pk': systemtool.pk}),
                'update_url': reverse_lazy('systemtool_update', kwargs={'pk': systemtool.pk}),
                'obj_name': str(systemtool),
                'obj_pk': systemtool.pk
            }
            table_data.append(table_row_info)

        context['add_url'] = reverse_lazy('systemtool_add')
        context['table_data'] = table_data
        context['title'] = 'systemtool'
        return context


class SystemtoolEdit:
    template_name = 'core/generic/edit_note.html'
    model = LatestSystemtool
    form_class = LatestSystemtoolForm
    success_url = reverse_lazy('systemtool_list')

    #Note side
    context_object_name = 'systemtool'
    NoteFormSet = modelformset_factory(Note, form=NoteForm,can_delete=True)


    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        if 'systemtool' in context:
            systemtool = context['systemtool']
            context['note_forms'] = self.NoteFormSet(
                queryset=Note.objects.filter(ref_note_uuid=systemtool.pk))

        context['title'] = 'SystemTool'
        return context


    def post(self, request, *args, **kwargs):
        #Note side
        if self.NoteFormSet != None:
            formset = self.NoteFormSet(request.POST)
            systemtool = get_object_or_404(LatestSystemtool, pk=self.kwargs['pk'])
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
                        note.ref_note_uuid = systemtool.pk
                        note.save()
            # Delete each note we marked in the formset
            formset.save(commit=False)
            for obj in formset.deleted_objects:
                obj.delete()
            # Choose which website we are redirected to
        if request.POST.get("Submit"):
            self.success_url = reverse_lazy('systemtool_list')
        if request.POST.get('update'):
            self.success_url = reverse_lazy('systemtool_update',kwargs={'pk': systemtool.pk})

        return super().post(request, *args, **kwargs)


class SystemtoolCreate(SystemtoolEdit, CreateView):
    #Note side
    template_name = 'core/generic/edit.html'
    NoteFormSet = None



class SystemtoolUpdate(SystemtoolEdit, UpdateView):
    pass


class SystemtoolDelete(DeleteView):
    model = LatestSystemtool
    success_url = reverse_lazy('systemtool_list')


class SystemtoolView(DetailView):
    model = LatestSystemtool
    template_name = 'core/generic/detail.html'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        obj = context['object']
        table_data = {
                'Systemtool name': obj.systemtool_name,
                'Systemtool description': obj.description,
                'Systemtool type': obj.systemtool_type_uuid,
                'Systemtool vendor': obj.vendor_organization_uuid,
                'Systemtool model': obj.model,
                'Systemtool serial': obj.serial,
                'Systemtool version': obj.ver
        }
        context['update_url'] = reverse_lazy(
            'systemtool_update', kwargs={'pk': obj.pk})
        context['title'] = 'systemtool'
        context['table_data'] = table_data
        return context