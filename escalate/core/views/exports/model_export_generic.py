from django.http import HttpResponse, HttpResponseRedirect, FileResponse
from django.core.exceptions import FieldDoesNotExist
from django.views import View
import functools
from core.utils_no_dependencies.view_utils import get_all_related_fields, get_model_of_related_field
from core.models.core_tables import custom_slugify
from django.db.models import Count, Q
from django.core import serializers
from core.utils_no_dependencies.misc import rgetattr
import csv

class GenericModelExport(View):
    model = None
    file_type = None
    column_names = None
    column_necessary_fields = None
    # A related path that points to the organization this field belongs to
    org_related_path = None
    field_contains = ''
    ordering = None

    def get(self, request, *args, **kwargs):
        if self.file_type == 'csv':
            return self.export_csv()
        else:
            return HttpResponse('Failed to get requested file')

    def header_to_necessary_fields(self, field_raw):
        # get the fields that make up the header column
        return self.column_necessary_fields[field_raw]

    def get_queryset(self):
        filter_val = self.request.GET.get('filter', self.field_contains).strip()
    
        #Ex: [('first_name_sort', 'asc'),...]
        ui_order_raw = list(
            filter(lambda k_v: k_v[0].endswith('_sort') and k_v[0].replace('_sort', '') in self.table_columns,
            list(self.request.GET.items())
            ))
        #Ex: {'first_name':'asc'}
        ui_order_dict = {k_v[0].replace('_sort',''):k_v[1] for k_v in ui_order_raw}

        ui_order = []
        for col_name, order in ui_order_dict.items():
            col_necessary_fields = self.header_to_necessary_fields(col_name)
            # replaces . with __ so django orm can read it
            col_necessary_fields_as_query = [
                "__".join(f.split(".")) for f in col_necessary_fields]
            if order == 'asc' or order == None:
                ui_order = [*ui_order, *col_necessary_fields_as_query]
            else:
                # des
                ui_order = [*ui_order,
                            *[f'-{f}' for f in col_necessary_fields_as_query]]

        ordering = ui_order if len(ui_order) > 0 else self.ordering

        _all_necessary_fields_dot = [fields[i] for fields in self.column_necessary_fields.values() for i in range(len(fields))]
        all_necessary_fields_dunder = ['__'.join(field.split('.')) for field in _all_necessary_fields_dot]
        filter_kwargs = {
            f'{f}__icontains': filter_val for f in all_necessary_fields_dunder}

        # might not need to do this, maybe order by number of m2m

        # Filter by organization if it exists in the model
        if self.request.user.is_superuser:
            base_query = self.model.objects.all()
        else:
            if 'current_org_id' in self.request.session:
                if self.org_related_path:
                    org_filter_kwargs = {
                        self.org_related_path: self.request.session['current_org_id']}
                    base_query = self.model.objects.filter(**org_filter_kwargs)
                else:
                    try:
                        org_field = self.model._meta.get_field('organization')
                        base_query = self.model.objects.filter(
                            organization=self.request.session['current_org_id'])
                    except FieldDoesNotExist:
                        base_query = self.model.objects.all()
            else:
                base_query = self.model.objects.none()

        all_related_fields = get_all_related_fields(self.model)
        # filter
        if filter_val != None:
            new_queryset = base_query
            for related_field_query in list(filter_kwargs.keys()):
                related_field = related_field_query.replace(
                    '__icontains', '')
                final_field_model = get_model_of_related_field(
                    self.model, related_field, all_related_fields=all_related_fields)
                final_field = related_field.split('__')[-1]
                final_field_class_name = final_field_model._meta.get_field(
                    final_field).__class__.__name__
                if final_field_class_name == 'ManyToManyField':
                    filter_kwargs.pop(related_field_query)
                    filter_kwargs[f'{related_field}__internal_slug__icontains'] = custom_slugify(filter_val)
            filter_query = functools.reduce(lambda q1, q2: q1 | q2, [
                Q(**{k: v}) for k, v in filter_kwargs.items()]) if len(filter_kwargs) > 0 else Q()
            new_queryset = new_queryset.filter(filter_query).distict()
        else:
            new_queryset = base_query

        # order
        if ordering != None and len(ordering) > 0:
            for i in range(len(ordering)):
                related_field = ordering[i]
                final_field_model = get_model_of_related_field(
                    self.model, related_field, all_related_fields=all_related_fields)
                final_field = related_field.split('__')[-1].strip('-')
                final_field_class_name = final_field_model._meta.get_field(
                    final_field).__class__.__name__
                if final_field_class_name == 'ManyToManyField':
                    new_queryset = new_queryset.annotate(
                        **{f"{related_field.strip('-')}_count": Count(related_field.strip('-'))})
                    ordering[i] = f"{related_field}_count"
            new_queryset = new_queryset.order_by(*ordering)
        return new_queryset.select_related()

    def export_csv(self):
        response = HttpResponse(content_type="text/csv")
        model_string_name = self.model.__name__
        filename = f'{model_string_name}.csv'
        response['Content-Disposition'] = f'attachment; filename={filename}'

        writer = csv.writer(response)
        writer.writerow([*self.column_names])
        
        model_name = self.model.__name__.lower()
        if (queryset_serialized := self.request.session.get(f'{model_name}_queryset_serialized', None)) != None:
            model_objects = [serialized_obj.object for serialized_obj in serializers.deserialize('json', queryset_serialized)]
        else:
            model_objects = self.get_queryset()

        for obj in model_objects:
            row = []
            for col_name in self.column_names:
                cell_data = ""
                necessary_fields = self.column_necessary_fields[col_name]
                fields_for_cell = []
                for field in necessary_fields:
                    # not foreign key and manytomany
                    if field.split('.') == 1 and self.model._meta.get_field(field).__class__.__name__ == 'ManyToManyField':
                        to_add = '\n'.join([str(x)
                                        for x in getattr(obj, field).all()])
                    else:
                        # Ex: Person.organization.full_name
                        to_add = rgetattr(obj, field)
                        if to_add.__class__.__name__ == 'ManyRelatedManager':
                            # if value is many to many obj get the values
                            # Ex: Model.foreignkey.manyToMany
                            to_add = ','.join([str(x)
                                            for x in getattr(obj, field).all()])
                    fields_for_cell.append(to_add)
                # loop to change None to '' or non-string to string because join needs strings
                for i in range(0, len(fields_for_cell)):
                    if fields_for_cell[i] == None:
                        fields_for_cell[i] = ''
                    elif not isinstance(fields_for_cell[i], str):
                        fields_for_cell[i] = str(fields_for_cell[i])
                    else:
                        continue
                cell_data = ' '.join(fields_for_cell)
                cell_data = cell_data.strip()
                row.append(cell_data)
            writer.writerow(row)
        return response