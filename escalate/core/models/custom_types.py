from collections.abc import Iterable
from django.db import models
#from core.models.core_tables import TypeDef
from core.models.core_tables import TypeDef
import json
from django.core.exceptions import ValidationError
import csv
from django.contrib.postgres.fields import ArrayField
from django.forms import MultiWidget, TextInput, Select, MultiValueField, CharField, ChoiceField
from core.validators import ValValidator


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

class CustomArrayField(ArrayField):
    def _from_db_value(self, value, expression, connection):
        
        if value is None:
            return value
        value = list(csv.reader([value[1:-1]]))[0]        
        return [
            self.base_field.from_db_value(item, expression, connection)
            for item in value
        ]

class Val:
    positions = {
            'text' : 2, 'array_text' : 3, 'int' : 4, 'array_int': 5, 'num': 6,
            'array_num': 7, 'blob': 8, 'blob_array': 9, 'bool': 10,
            'bool_array': 11
        }
    def __init__(self, val_type, value, unit, null=False, raw_string=''):
        self.null = null
        self.unit = None
        if isinstance(value, str):
            if len(value) == 0:
                print(raw_string)
        if not self.null:
            self.val_type = val_type
            if not isinstance(val_type, str):
                self.type_uuid = val_type.uuid
            else:
                val_type = self.validate_type(val_type)
            self.value = value
            self.value = self.convert_value()
            self.unit = unit
    
    def to_db(self):
        if not self.null:
            string_list = ['']*12
            string_list[0] = str(self.val_type.uuid)
            string_list[1] = self.unit
            string_list[self.positions[self.val_type.description]] = str(self.value)
            return f"({','.join(string_list)})"
        else:
            return None
    
    def convert_value(self):
        # Converts self.value from string to its primitive type. Used in validator and initialization
        converted_value = None
        if not self.null:
            if 'array' in self.val_type.description:
                converted_value = self.convert_list_value(
                    self.val_type.description, self.value)
            else:
                converted_value = self.convert_single_value(
                    self.val_type.description, self.value)
        return converted_value
    
    def convert_single_value(self, description, value):
        primitives = {'bool': bool, 'int': int, 'num': float, 'text': str, 'blob': str}
        reverse_primitives = {bool: 'bool',
                              int: 'int', float: 'num', str: 'text'}
        prim = primitives[description]
        try:
            if len(value) > 0: 
                result = prim(value)
            else:
                #print(f'Before converting {self.unit}')
                #print(f'{description} : {value}')
                result = value
        except Exception as e:
            print(e)
            raise ValidationError(
                f'Data type mismatch, type provided is "{description}" but value is of type "{reverse_primitives[type(value)]}"')
        return result

    def convert_list_value(self, description, value):
        primitives = {'array_bool': bool, 'array_int': int,
                      'array_num': float, 'array_text': str}
        prim = primitives[description]
        try:
            result = [prim(val) for val in value]
        except Exception as e:
            raise ValidationError(
                f'Data type mismatch, type provided is {description} but exception occured: {e}')

        table = str.maketrans('[]', '{}')
        result = json.dumps(result).translate(table)
        return result
    
    def __str__(self):
        return f'{self.value} {self.unit}'

    def to_dict(self):
        if not self.null:
            return {'value': self.value, 'unit': self.unit, 'type': self.val_type.description}
        else:
            return 'null'

    @classmethod
    def from_db(cls, val_string):
        #print(val_string)
        args = list(csv.reader([val_string[1:-1]]))[0]
        #print(args)
        type_uuid = args[0]
        unit = args[1]
        val_type = TypeDef.objects.get(pk=type_uuid)
        
        # Values should be from index 2 onwards.
        value = args[cls.positions[val_type.description]]
        
        if val_type.description == 'text':
            value = str(value)
        elif 'array' in val_type.description:
            table = str.maketrans('{}', '[]')
            value = value.translate(table)
            value = json.loads(value)
        if 'bool' in val_type.description:
            table = str.maketrans({'t': 'true', 'f':'false', 'T':'true', 'F':'false'})
            value = value.translate(table)
            #value = json.loads(value)
        return cls(val_type, value, unit, raw_string=val_string)

    @classmethod
    def from_dict(cls, json_data):
        if json_data is None:
            return cls(None, None, None, null=True)
        else:
            required_keys = set(['type', 'value', 'unit'])
            # Check if all keys are present in 
            if not all(k in json_data for k in required_keys):
                    raise ValidationError(f'Missing key "{required_keys - set(json_data.keys())}". ', 'invalid')
            
            val_type = cls.validate_type(json_data["type"])
            return cls(val_type, json_data['value'], json_data['unit'])
    
    @classmethod
    def validate_type(cls, type_string):
        # Check if type exists in database
        try:
            val_type = TypeDef.objects.get(category='data', description=type_string)
        except TypeDef.DoesNotExist:
            val_types = TypeDef.objects.filter(category='data')
            options = [val.description for val in val_types]
            raise ValidationError(f'Data type {type_string} does not exist. Options are: {", ".join(options)}', code='invalid')
        return val_type

class ValField(models.Field):
    description = 'Data representation'

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


class ValWidget(MultiWidget):
    def __init__(self, attrs=None):
        #value, unit and type
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
            return [value.value, value.unit, value.val_type]
        
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
            CharField(error_messages = {
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
        
        