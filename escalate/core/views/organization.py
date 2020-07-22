from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import Organization, Note,Actor
from core.forms import OrganizationForm, NoteForm
from core.views.menu import GenericListView
#Note side
from django.forms import modelformset_factory
from django.shortcuts import get_object_or_404

class OrganizationList(GenericListView):
    model = Organization
    #template_name = 'core/organization/organization_list.html'
    template_name = 'core/generic/list.html'
    context_object_name = 'orgs'
    paginate_by = 10
    def get_queryset(self):
        filter_val = self.request.GET.get('filter', '')
        ordering = self.request.GET.get('ordering', 'full_name')
        if filter_val != None:
            new_queryset = self.model.objects.filter(
                full_name__icontains=filter_val).select_related().order_by(ordering)
        else:
            new_queryset = self.model.objects.all().select_related().order_by(ordering)
        return new_queryset

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        table_columns = ['Full Name', 'Address1', 'Website', 'Actions']
        context['table_columns'] = table_columns
        orgs = context['orgs']
        table_data = []
        for org in orgs:
            table_row_data = []

            # data for the object we want to display for a row
            table_row_data.append(org.full_name)
            table_row_data.append(org.address1)
            table_row_data.append(org.website_url)

            # dict containing the data, view and update url, primary key and obj
            # name to use in template
            table_row_info = {
                    'table_row_data' : table_row_data,
                    'view_url' : reverse_lazy('organization_view', kwargs={'pk': org.pk}),
                    'update_url' : reverse_lazy('organization_update', kwargs={'pk': org.pk}),
                    'obj_name' : str(org),
                    'obj_pk' : org.pk
                    }
            table_data.append(table_row_info)

        context['add_url'] = reverse_lazy('organization_add')
        context['table_data'] = table_data
        context['title'] = 'Organization'
        return context

class OrganizationEdit:
    #template_name = 'core/organization/organization_edit.html'
    template_name = 'core/generic/edit_note.html'
    model = Organization
    form_class = OrganizationForm
    success_url = reverse_lazy('organization_list')

    #Note side
    context_object_name = 'organization'
    NoteFormSet = modelformset_factory(Note, form=NoteForm,can_delete=True)


    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        #Note side
        if 'organization' in context:
            organization = context['organization']
            context['note_forms'] = self.NoteFormSet(
                queryset=Note.objects.filter(ref_note_uuid=organization.pk))

        context['title'] = 'Organization'
        return context

    def post(self, request, *args, **kwargs):
        #Note side
        if self.NoteFormSet != None:
            formset = self.NoteFormSet(request.POST)
            organization = get_object_or_404(Organization, pk=self.kwargs['pk'])
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
                        note.ref_note_uuid = organization.pk
                        note.save()
            # Delete each note we marked in the formset
            formset.save(commit=False)
            for obj in formset.deleted_objects:
                obj.delete()
            # Choose which website we are redirected to
        if request.POST.get("Submit"):
            self.success_url = reverse_lazy('organization_list')
        if request.POST.get('update'):
            self.success_url = reverse_lazy('organization_update',kwargs={'pk': organization.pk})

        return super().post(request, *args, **kwargs)


class OrganizationCreate(OrganizationEdit, CreateView):
    #Note side
    template_name = 'core/generic/edit.html'
    NoteFormSet = None


class OrganizationUpdate(OrganizationEdit, UpdateView):
    pass


class OrganizationDelete(DeleteView):
    model = Organization
    success_url = reverse_lazy('organization_list')


class OrganizationView(DetailView):
    model = Organization
    #queryset = Organization.objects.all()
    #template_name = 'core/organization/organization_detail.html'
    template_name = 'core/generic/detail.html'

    def get_context_data(self, **kwargs):
        # Call the base implementation first to get a context
        context = super().get_context_data(**kwargs)
        obj = context['object']
        table_data = {
                'Full Name': obj.full_name,
                'Short Name': obj.short_name,
                'Description': obj.description,
                'Address': f'{obj.address1}, {obj.address2}, {obj.city}, {obj.state_province}, {obj.zip}, {obj.country}',
                'Website': obj.website_url,
                'Phone': obj.phone,
                'Parent Organization': obj.parent_org_full_name,
                'Add Date': obj.add_date,
                'Last Modification Date': obj.mod_date
        }
        context['update_url'] = reverse_lazy(
            'organization_update', kwargs={'pk': obj.pk})
        context['title'] = 'Organization'
        context['table_data'] = table_data
        return context
