from django.urls import reverse_lazy, reverse
from django.shortcuts import redirect
from django.views.generic.detail import DetailView
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView
from django.http import Http404, FileResponse, HttpResponseRedirect


from core.models import Edocument, Actor
from core.forms.forms import ActorForm
from core.views.crud_view_methods.model_view_generic import GenericListView

import tempfile


class EdocumentList(GenericListView):
    template_name = 'core/generic/list.html'
    paginate_by = 10
    context_object_name = 'edocument'

    model = Edocument

    def get_queryset(self):

        # added get_queryset method
        filter_val = self.request.GET.get('filter', '')
        ordering = self.request.GET.get('ordering', 'title')
        # order by description
        if filter_val != None:
            new_queryset = self.model.objects.filter(
                title__icontains=filter_val).select_related().order_by(ordering)
            # filter by decription being a empty/nonempty string
        else:
            new_queryset = self.model.objects.all().select_related().order_by(ordering)
        return new_queryset

    # def download_trial(self, uuid):
    #     return HttpResponseRedirect(reverse('edoc_download', args=(uuid,)))

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        table_columns = ['Title',  'Version', 'UUID']  # 'File Type',
        context['table_columns'] = table_columns
        edocument = context['edocument']
        table_data = []
        for item in edocument:
            table_row_data = []

            # data for the object we want to display for a row
            table_row_data.append(item.title)
            # table_row_data.append(item.doc_type_description)
            table_row_data.append(item.doc_ver)

            table_row_data.append(item.uuid)

            # dict containing the data, view and update url, primary key and obj
            # name to use in template
            table_row_info = {
                'table_row_data': table_row_data,
                # reverse_lazy('inventory_view', kwargs={'pk': item.pk}),
                'download_url': reverse('edoc_download', args=(item.uuid,)),
                # reverse_lazy('inventory_view', kwargs={'pk': item.pk}),
                'view_url': reverse_lazy('edocument_view',  args=(item.uuid,)),
                # reverse_lazy('inventory_update', kwargs={'pk': item.pk}),
                'update_url': redirect('https://google.com'),
                'obj_name': str(item),
                'obj_pk': item.pk
            }
            table_data.append(table_row_info)

        #context['add_url'] = reverse_lazy('inventory_add')
        context['table_data'] = table_data
        context['title'] = 'Edocuments'
        return context

    """
    context_object_name = 'actors'
    table_columns = ['Name', 'Organization', 'Systemtool', 'Status']
    column_necessary_fields = {
        'Name': ['person_first_name', 'person_last_name'],
        'Organization': ['org_full_name'],
        'Systemtool': ['systemtool_name'],
        'Status': ['actor_status_description']
    }
    order_field = 'actor_description'
    field_contains = ''

    # Need this
    table_columns += ['Actions']
    """

    def post(self, *args, **kwargs):
        return HttpResponseRedirect(reverse(f'edocument_list'))


class EdocumentDetailView(DetailView):

    model = Edocument
    template_name = 'core/generic/detail.html'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        obj = context['object']
        detail_data = {}
        detail_data["UUID"] = obj.uuid
        detail_data["Title"] = obj.title
        detail_data["Description"] = obj.description
        detail_data["Actor"] = obj.actor_description
        # all_docs = Edocument.objects.filter(ref_document_uuid=obj.uuid)
        # print(all_docs)
        context['title'] = obj.title
        context['detail_data'] = detail_data
        # context['download_url'] = reverse('edoc_download', args=(obj.uuid,))

        return context
