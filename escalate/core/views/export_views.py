from django.urls import reverse_lazy
from django.views import View
from django.contrib.auth.mixins import LoginRequiredMixin

import core.models
import core.forms
from core.views.crud_view_methods.model_view_generic import GenericModelExport
from core.views.exports import export_methods
from core.views.exports import file_types as export_file_types

class LoginRequired(LoginRequiredMixin):
    login_url = '/'
    redirect_field_name = 'redirect_to'


def create_export_view(model_name, methods):
    for t in export_file_types.file_types:
        methods['file_type'] = t
        class_name = f'{model_name}Export{t.capitalize()}'
        globals()[class_name] = type(class_name,
                                          tuple([LoginRequired, GenericModelExport]), methods)

for model_name, methods_list in export_methods.methods.items():
    create_export_view(model_name, methods_list)