from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import Person
from core.forms import PersonForm
from core.views.menu import GenericListView


class PersonList(GenericListView):
    model = Person
    template_name = 'core/person/person_list.html'
    context_object_name = 'persons'
    paginate_by = 10

    def get_queryset(self):
        # return self.model.objects.all()
        # filter_val = self.request.GET.get('filter', '')
        # ordering = self.request.GET.get('ordering', 'lastname')
        # if filter_val != None:
        #     new_queryset = self.model.objects.filter(
        #         lastname__icontains=filter_val).select_related().order_by(ordering)
        # else:
        new_queryset = self.model.objects.all()
        return new_queryset

class PersonEdit:
    template_name = 'core/generic/edit.html'
    model = Person
    form_class = PersonForm
    success_url = reverse_lazy('person_list')

    def get_context_data(self,**kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = 'Person'
        return context


class PersonCreate(PersonEdit, CreateView):
    pass


class PersonUpdate(PersonEdit, UpdateView):
    pass


class PersonDelete(DeleteView):
    model = Person
    success_url = reverse_lazy('person_list')


class PersonView(DetailView):
    model = Person
    template_name = 'core/generic/detail.html'

    def get_context_data(self,**kwargs):
        context = super().get_context_data(**kwargs)
        obj = context['object']
        table_data = {
                'Full Name': f"{obj.first_name} {obj.middle_name} {obj.last_name}",
                'Address': (f"{obj.address1}, {obj.address2}, {obj.zip}, {obj.city},"
                                f"{obj.state_province}, {obj.country}"),
                'Phone': obj.phone,
                'Email': obj.email,
                'Organization': obj.organization_full_name,
                'Note': obj.notetext,
                'Edocument description': obj.edocument_descr,
                'Tag description': obj.tag_display_text
        }
        context['title'] = 'Person'
        context['update_url'] = reverse_lazy(
                    'person_update',kwargs={'pk':obj.pk})
        context['table_data'] = table_data
        return context
