from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import TagType
from core.forms import TagTypeForm
from core.views.menu import GenericListView


class TagTypeList(GenericListView):
    model = TagType
    template_name = 'core/tag_type/tag_type_list.html'
    context_object_name = 'tag_types'
    paginate_by = 10

    def get_queryset(self):
        return self.model.objects.all()
        filter_val = self.request.GET.get('filter', '')
        ordering = self.request.GET.get('ordering', 'short_description')
        if filter_val != None:
            new_queryset = self.model.objects.filter(
                short_description__icontains=filter_val).select_related().order_by(ordering)
        else:
            new_queryset = self.model.objects.all()
        return new_queryset

class TagTypeEdit:
    template_name = 'core/tag_type/tag_type_edit.html'
    model = TagType
    form_class = TagTypeForm
    success_url = reverse_lazy('tag_type_list')


class TagTypeCreate(TagTypeEdit, CreateView):
    pass


class TagTypeUpdate(TagTypeEdit, UpdateView):
    pass


class TagTypeDelete(DeleteView):
    model = TagType
    success_url = reverse_lazy('tag_type_list')


class TagTypeView(DetailView):
    model = TagType
    template_name = 'core/tag_type/tag_type_detail.html'
