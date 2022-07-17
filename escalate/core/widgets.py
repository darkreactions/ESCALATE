from typing import List, Any
from django.forms import MultiWidget, TextInput, Select, Widget
from core.custom_types import Val
from core.validators import ValValidator
from core.models.core_tables import TypeDef
import json
import numpy as np
from django.forms import (
    MultiWidget,
    TextInput,
    Select,
    MultiValueField,
    CharField,
    ChoiceField,
)
from django.utils.safestring import mark_safe
from django.forms import widgets
from django.conf import settings
from django.urls import reverse


class RelatedFieldWidgetCanAdd(widgets.Select):
    def __init__(
        self, related_model, related_url=None, related_instance=None, *args, **kwargs
    ):
        super().__init__(*args, **kwargs)
        if not related_url:
            rel_to = related_model
            info = (rel_to._meta.app_label, rel_to._meta.object_name.lower())
            related_url = "admin:%s_%s_add" % info

        # Be careful that here "reverse" is not allowed
        self.related_base_url = related_url
        self.related_model = related_model
        self.related_instance = related_instance

    def render(self, name, value, *args, **kwargs):
        self.related_base_url = reverse(self.related_base_url)
        if self.related_instance is not None:
            # Add a GET parameter so that the correct value is filled
            self.related_url = (
                self.related_base_url + f"?related_uuid={self.related_instance.uuid}"
            )
        else:
            self.related_url = self.related_base_url

        output: "List[Any]" = [super().render(name, value, *args, **kwargs)]
        output.append(f'<a href="{self.related_url}" id="add_id_{name}">')
        output.append(
            f'<i class="fa fa-plus" aria-hidden="true"> Add another {self.related_model._meta.object_name}</i></a>'
        )
        if self.choices:
            output.append(
                f"""<a class="add-another" id="edit_id_{name}" onclick="edit_{name}()"><br>
                <i class="fa fa-edit" aria-hidden="true"> Edit selected {self.related_model._meta.object_name}</i></a><br>
                <a class="add-another" id="delete_id_{name}" onclick="delete_{name}()"><i class="fa fa-trash" aria-hidden="true"> Delete selected {self.related_model._meta.object_name}</i></a>"""
            )
            output.append(
                f"""<script>
                    function edit_{name}() 
                        {{ 
                            var e = document.getElementById("{kwargs["attrs"]["id"]}"); 
                            var uuid = e.value; 
                            window.location.href = "{self.related_base_url}" + uuid
                        }}
                    function delete_{name}() 
                    {{
                        var e = document.getElementById("{kwargs["attrs"]["id"]}"); 
                        var uuid = e.value;
                        const description = e.options[e.selectedIndex].text;
                        $('#deleteModalmessage').html('Are you sure you want to delete the entry: <br>' + description + '?');
                        $("#delete_form").attr("action", {self.related_base_url} + uuid + "/delete");
                        $("#deleteModal").modal();
                    }}
                    </script>"""
            )
        return mark_safe(f"".join(output))


class ValWidget(MultiWidget):
    def __init__(self, attrs={}):
        # value, unit and type
        data_types = TypeDef.objects.filter(category="data")
        try:
            data_type_choices = [
                (data_type.description, data_type.description)
                for data_type in data_types
            ]
        except Exception as e:
            data_type_choices = [("num", "num"), ("text", "text"), ("bool", "bool")]
        select_attrs = {
            "class": "selectpicker",
            "data-style": "btn-primary",
            "data-live-search": "true",
            "placeholder": "DataType",
        }
        if "disable_select" in attrs:
            select_attrs["disabled"] = "disabled"

        widgets = [
            TextInput(attrs={"placeholder": "Value"}),
            TextInput(attrs={"placeholder": "Unit"}),
            Select(attrs=select_attrs, choices=data_type_choices),
        ]
        super().__init__(widgets, attrs)

    def decompress(self, value):
        if isinstance(value, Val):
            if not value.null:
                return [
                    value.value,
                    value.unit,
                    str(value.val_type.description),
                    value.value,
                ]

        return [None, None, None, None]

    def get_context(self, name, value, attrs):
        context = super().get_context(name, value, attrs)
        # table_subwidget = context["widget"]["subwidgets"][3]
        value_text_subwidget = context["widget"]["subwidgets"][0]
        select_subwidget = context["widget"]["subwidgets"][2]

        # Checking if the selected datatype has the term 'array' in it
        if [datatype for datatype in select_subwidget["value"] if "array" in datatype]:
            # table_subwidget["is_hidden"] = False
            value_text_subwidget["attrs"]["hidden"] = True  # Hide text box

            list_value = json.loads(value_text_subwidget["value"])
            list_value = np.array(list_value)
            num_rows = int(len(list_value) / 8)
            num_cols = 8

            list_value.resize(num_rows * num_cols)
            list_value = np.reshape(list_value, (num_rows, num_cols))

            # table_subwidget["rows"] = [i + 1 for i in range(num_rows)]
            # table_subwidget["values"] = list_value

        return context


class ValFormField(MultiValueField):
    widget = ValWidget()

    def __init__(self, *args, **kwargs):
        errors = self.default_error_messages.copy()
        if "error_messages" in kwargs:
            errors.update(kwargs["error_messages"])
        data_types = TypeDef.objects.filter(category="data")
        try:
            data_type_choices = [
                (data_type.description, data_type.description)
                for data_type in data_types
            ]
        except Exception as e:
            data_type_choices = [("num", "num"), ("text", "text"), ("bool", "bool")]
        fields = (
            CharField(
                error_messages={
                    "incomplete": "Must enter a value",
                }
            ),
            CharField(required=False),
            ChoiceField(choices=data_type_choices, initial="num"),
        )
        if "max_length" in kwargs:
            kwargs.pop("max_length")

        super().__init__(fields, *args, **kwargs)

    def compress(self, data_list):
        if data_list:
            value, unit, val_type_text = data_list
            val_type = TypeDef.objects.get(category="data", description=val_type_text)
            val = Val(val_type, value, unit)
            return val
        return Val(None, None, None, null=True)

    def validate(self, value):
        # print(f"validating {value}")
        validator = ValValidator()
        validator(value)
