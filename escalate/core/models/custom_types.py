from collections.abc import Iterable
from django.db import models

import json
from django.core.exceptions import ValidationError
import csv
from django.contrib.postgres.fields import ArrayField
from django.forms import MultiWidget, TextInput, Select, MultiValueField, CharField, ChoiceField
from core.custom_types import Val
from core.validators import ValValidator
from core.models.core_tables import TypeDef


"""
v_type_uuid uuid, 0
v_unit character varying, 1
v_text character varying, 2
v_text_array character varying[], 3
v_int bigint, 4
v_int_array bigint[], 5
v_num numeric, 6
v_num_array numeric[], 7
v_edocument_uuid uuid, 8
v_source_uuid uuid, 9
v_bool boolean, 10
v_bool_array boolean[] 11
"""


class ValWidget(MultiWidget):
    def __init__(self, attrs=None):
        # value, unit and type
        data_types = TypeDef.objects.filter(category='data')
        data_type_choices = [(data_type.description, data_type.description) for data_type in data_types]

        widgets = [
            TextInput(attrs={'placeholder': 'Value'}),
            TextInput(attrs={'placeholder': 'Unit'}),
            Select(attrs={'class': 'selectpicker',
                          'data-style': 'btn-outline-primary', 'data-live-search': 'true', 'placeholder': 'DataType'},
                   choices=data_type_choices)
        ]
        super().__init__(widgets, attrs)

    def decompress(self, value):
        if isinstance(value, Val):
            # print(value.val_type.description)
            return [value.value, value.unit, str(value.val_type.description)]

        return [None, None, None]


class ValFormField(MultiValueField):
    widget = ValWidget()

    def __init__(self, *args, **kwargs):
        errors = self.default_error_messages.copy()
        if 'error_messages' in kwargs:
            errors.update(kwargs['error_messages'])
        data_types = TypeDef.objects.filter(category='data')
        data_type_choices = [(data_type.description, data_type.description) for data_type in data_types]
        fields = (
            CharField(error_messages={
                'incomplete': 'Must enter a value',
            }),
            CharField(required=False),
            ChoiceField(choices=data_type_choices, initial='num')
        )
        super().__init__(fields, *args, **kwargs)

    def compress(self, data_list):
        if data_list:
            value, unit, val_type_text = data_list
            val_type = TypeDef.objects.get(category='data', description=val_type_text)
            val = Val(val_type, value, unit)
            return val
        return Val(null=True)

    def validate(self, value):
        print(f"validating {value}")
        validator = ValValidator()
        validator(value)

class CustomArrayField(ArrayField):
    def _from_db_value(self, value, expression, connection):
        
        if value is None:
            return value
        value = list(csv.reader([value[1:-1]], delimiter=',', quotechar='"', escapechar='\\'))[0]        
        return [
            self.base_field.from_db_value(item, expression, connection)
            for item in value
        ]

class ValField(models.Field):
    description = 'Data representation'
    formfield = ValFormField()
    def __init__(self, *args, **kwargs):
        self.list = kwargs.pop('list', False)
        super().__init__(*args, **kwargs)

    def deconstruct(self):
        name, path, args, kwargs = super().deconstruct()

        return name, path, args, kwargs
    
    def db_type(self, connection):
        return 'val'
    
    def from_db_value(self, value, expression, connection):
        if value is None:
            return value 
        
        return Val.from_db(value)

    def to_python(self, value):
        if isinstance(value, Val):
            return value
        elif isinstance(value, (list, tuple)):
            return Val(*value)
        
        if value is None:
            return value
        
        return Val.from_db(value)

    def get_prep_value(self, value):
        return value.to_db()
    
    def get_db_prep_value(self, value, connection, prepared=False):
        value = super().get_db_prep_value(value, connection, prepared)
        return value

    def get_db_prep_save(self, value, connection, prepared=False):
        value = super().get_db_prep_save(value, connection)
        return value

    def value_from_object(self, obj):
        obj = super().value_from_object(obj)
        return obj

    def formfield(self, **kwargs):
        # This is a fairly standard way to set up some defaults
        # while letting the caller override them.
        defaults = {'form_class': ValFormField}
        defaults.update(kwargs)
        return super().formfield(**defaults)



        