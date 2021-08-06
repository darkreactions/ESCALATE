from django.http import HttpResponse, HttpResponseRedirect, FileResponse
from django.core.exceptions import FieldDoesNotExist
from django.views import View
import functools
from core.views.crud_view_methods.model_view_generic import GenericModelListBase
from core.utils_no_dependencies.view_utils import get_all_related_fields, get_model_of_related_field
from core.models.core_tables import custom_slugify
from django.db.models import Count, Q
from django.core import serializers
from core.utils_no_dependencies.misc import rgetattr
import csv

class GenericModelExport(GenericModelListBase, View):
    model = None
    column_names = None
    column_necessary_fields = None
    # A related path that points to the organization this field belongs to
    org_related_path = None
    field_contains = ''
    ordering = None
    default_filter_kwargs = None

    def get(self, request, *args, **kwargs):
        if self.file_type == 'csv':
            return self.export_csv()
        else:
            return HttpResponse('Failed to get requested file')

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