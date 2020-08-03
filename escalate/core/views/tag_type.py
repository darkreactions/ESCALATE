from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import TagType
from core.forms import TagTypeForm
from core.views.menu import GenericListView

from .model_view_generic import GenericModelEdit, GenericModelList, GenericModelView


class TagTypeList(GenericModelList):
    model = TagType
    context_object_name = 'tag_types'
    table_columns = ['Short Description', 'Description']
    column_necessary_fields = {
        'Short Description': ['short_description'],
        'Description': ['description']
    }
    order_field = 'short_description'
    field_contains = ''

    # Need this
    table_columns += ['Actions']


class TagTypeEdit(GenericModelEdit):
    model = TagType
    context_object_name = 'tag_type'
    form_class = TagTypeForm


class TagTypeCreate(CreateView):
    template_name = 'core/generic/edit.html'
    model = TagType
    form_class = TagTypeForm
    success_url = reverse_lazy('tag_type_list')


class TagTypeUpdate(TagTypeEdit, UpdateView):
    pass


class TagTypeDelete(DeleteView):
    model = TagType
    success_url = reverse_lazy('tag_type_list')


class TagTypeView(GenericModelView):
    model = TagType
    model_name = 'tag_type'
    detail_fields = ['Short Description', 'Long Description', 'Add Date',
                     'Last Modification Date']
    detail_fields_need_fields = {
        'Short Description': ['short_description'],
        'Long Description': ['description'],
        'Add Date': ['add_date'],
        'Last Modification Date': ['mod_date']
    }
