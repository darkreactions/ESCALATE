from django.urls import reverse_lazy
from django.views import View
from django.contrib.auth.mixins import LoginRequiredMixin

import core.models
import core.forms
from core.views.exports import (
    GenericModelExport,
    export_methods,
    file_types as export_file_types
)

class LoginRequired(LoginRequiredMixin):
    login_url = '/'
    redirect_field_name = 'redirect_to'


def create_export_view(model_name, methods):
    for file_type in export_file_types:
        methods['file_type'] = file_type
        class_name = f'{model_name}Export{file_type.capitalize()}'
        globals()[class_name] = type(class_name,
                                          tuple([LoginRequired, GenericModelExport]), methods)

for model_name, methods_list in export_methods.methods.items():
    create_export_view(model_name, methods_list)