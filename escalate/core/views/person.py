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

        filter_val = self.request.GET.get('filter', '')
        ordering = self.request.GET.get('ordering', 'lastname')
        if filter_val != None:
            new_queryset = self.model.objects.filter(
                lastname__icontains=filter_val).select_related().order_by(ordering)
        else:
            new_queryset = self.model.objects.all().select_related().order_by(ordering)
        print(new_queryset, f"length= {new_queryset.count()}")

        return new_queryset

class PersonEdit:
    template_name = 'core/person/person_edit.html'
    model = Person
    form_class = PersonForm
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
    template_name = 'core/person/person_detail.html'
