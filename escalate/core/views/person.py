from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import Person
from core.forms import PersonForm
from core.views.menu import GenericListView


class PersonList(GenericListView):
    model = Person
    #template_name = 'core/person/person_list.html'
    template_name = 'core/generic/list.html'
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

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        table_columns = ['Name', 'Address', 'Title', 'Email', 'Actions']
        context['table_columns'] = table_columns
        persons = context['persons']
        table_data = []
        for person in persons:
            table_row_data = []

            # data for the object we want to display for a row
            full_name = f"{person.first_name} {person.middle_name} {person.last_name}"
            full_address = (f"{person.address1}, {person.address2}, {person.zip}, {person.city},"
                            f"{person.state_province}, {person.country}")
            table_row_data.append(full_name)
            table_row_data.append(full_address)
            table_row_data.append(person.title)
            table_row_data.append(person.email)

            # dict containing the data, view and update url, primary key and obj
            # name to use in template
            table_row_info = {
                    'table_row_data' : table_row_data,
                    'view_url' : reverse_lazy('person_view', kwargs={'pk': person.pk}),
                    'update_url' : reverse_lazy('person_update', kwargs={'pk': person.pk}),
                    'obj_name' : str(person),
                    'obj_pk' : person.pk
                    }
            table_data.append(table_row_info)

        context['add_url'] = reverse_lazy('person_add')
        context['table_data'] = table_data
        context['title'] = 'Person'
        return context



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
                'Email': obj.email
        }
        context['title'] = 'Person'
        context['update_url'] = reverse_lazy(
                    'person_update',kwargs={'pk':obj.pk})
        context['table_data'] = table_data
        return context
