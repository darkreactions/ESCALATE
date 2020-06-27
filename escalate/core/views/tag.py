from django.urls import reverse_lazy
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from core.models import Tag
from core.forms import TagForm
from core.views.menu import GenericListView


class TagList(GenericListView):
    model = Tag
    template_name = 'core/tag/tag_list.html'
    context_object_name = 'tags'
    paginate_by = 10

    def get_queryset(self):
        return self.model.objects.all()
        filter_val = self.request.GET.get('filter', '')
        ordering = self.request.GET.get('ordering', 'display_text')
        if filter_val != None:
            new_queryset = self.model.objects.filter(
                display_text__icontains=filter_val).select_related().order_by(ordering)
        else:
            new_queryset = self.model.objects.all()
        return new_queryset


class TagEdit:
    template_name = 'core/tag/tag_edit.html'
    model = Tag
    form_class = TagForm
    success_url = reverse_lazy('tag_list')


class TagCreate(TagEdit, CreateView):
    pass


class TagUpdate(TagEdit, UpdateView):
    pass


class TagDelete(DeleteView):
    model = Tag
    success_url = reverse_lazy('tag_list')


class TagView(DetailView):
    model = Tag
    template_name = 'core/tag/tag_detail.html'
