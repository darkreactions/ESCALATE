from django.urls import reverse_lazy, reverse
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
    template_name = 'core/person/person_edit.html'
    model = Person
    form_class = PersonForm
    labels = {
        'stateprovince': 'State/Province',
        'address1': 'Address Line 1',
        'address2': 'Address Line 2',
        'notetext': 'Note Text'
    }
    success_url = reverse_lazy('person_list')


class PersonCreate(PersonEdit, CreateView):
    pass


class PersonUpdate(PersonEdit, UpdateView):
    pass


class PersonDelete(DeleteView):
    model = Person
    success_url = reverse_lazy('person_list')


class PersonView(DetailView):
    model = Person
    #template_name = 'core/person/person_detail.html'
    template_name = 'core/generic/detail.html'

    def get_context_data(self, **kwargs):
        # Call the base implementation first to get a context
        context = super().get_context_data(**kwargs)
        obj = context['object']
        table_data = {'Full Name': f'{obj.firstname} {obj.lastname}',
                      'Address': f'{obj.address1}, {obj.address2}, {obj.city}, {obj.stateprovince}, {obj.zip}, {obj.country}',
                      'Phone': obj.phone,
                      'Note': obj.notetext,
                      'Edocument description': obj.edocument_descr,
                      'Tag description': obj.tag_short_descr
                      }
        context['update_url'] = reverse('person_update', kwargs={'pk': obj.pk})
        #context['update_url'] = 'person_update'
        context['title'] = 'Person'
        context['table_data'] = table_data
        return context
