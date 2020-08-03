from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import Tag
from core.forms import TagForm
from core.views.menu import GenericListView

from .model_view_generic import GenericModelEdit, GenericModelList, GenericModelView


class TagList(GenericModelList):
    model = Tag
    context_object_name = 'tags'
    table_columns = ['Name', 'Description', 'Actor', 'Tag Type']
    column_necessary_fields = {
        'Name': ['display_text'],
        'Description': ['description'],
        'Actor': ['actor_description'],
        'Tag Type': ['tag_type_uuid']
    }
    order_field = 'display_text'
    field_contains = ''

    # Need this
    table_columns += ['Actions']


class TagEdit(GenericModelEdit):
    model = Tag
    context_object_name = 'tag'
    form_class = TagForm


class TagCreate(CreateView):
    template_name = 'core/generic/edit.html'
    model = Tag
    form_class = TagForm
    success_url = reverse_lazy('tag_list')


class TagUpdate(TagEdit, UpdateView):
    pass


class TagDelete(DeleteView):
    model = Tag
    success_url = reverse_lazy('tag_list')


class TagView(GenericModelView):
    model = Tag
    model_name = 'tag'
    detail_fields = ['Tag Name', 'Description', 'Actor', 'Add Date', 'Last Modification Date',
                     'Tag Type', 'Tag Type Description']
    detail_fields_need_fields = {
        'Tag Name': ['display_text'],
        'Description': ['description'],
        'Actor': ['actor_description'],
        'Add Date': ['add_date'],
        'Last Modification Date': ['mod_date'],
        'Tag Type': ['tag_type_short_descr'],
        'Tag Type Description': ['tag_type_description']
    }
