from django.db import models
from core.models.core_tables import TypeDef
import json
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


class Val:
    positions = {
            'text' : 2,
            'array_text' : 3,
            'int' : 4,
            'array_int': 5,
            'num': 6,
            'array_num': 7,
            'bool': 10,
            'bool_array': 11
        }
    def __init__(self, val_type, value, unit):
        self.val_type = val_type
        self.type_uuid = val_type.uuid
        self.value = value
        self.unit = unit
    
    def to_db(self):
        string_list = ['']*12
        string_list[0] = str(self.val_type.uuid)
        string_list[1] = self.unit
        string_list[self.positions[self.val_type.description]] = str(self.value)
        return f"({','.join(string_list)})"
    
    @classmethod
    def from_db(cls, val_string):
        args = val_string[1:-1].split(',')
        type_uuid = args[0]
        unit = args[1]
        val_type = TypeDef.objects.get(pk=type_uuid)
        
        # Values should be from index 2 onwards.
        value = args[cls.positions[val_type.description]]
        value = json.loads(value)
        
        return cls(val_type, value, unit)
    """
    @classmethod
    def from_rest(cls, value, unit):
        value = json.loads(value)
        if isinstance(value, list):
    """
    def __str__(self):
        return f'{self.value} {self.unit}'

    
class ValAlt:
    def __init__(self, type_uuid='', value='', unit=''):
        self.type_uuid = type_uuid
        self.unit = unit
        self.value = value
        
def parse_val(val_string):
    args = val_string[1:-1].split(',')
    return Val(*args)


class ValField(models.Field):
    description = 'Data representation'

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def deconstruct(self):
        name, path, args, kwargs = super().deconstruct()

        return name, path, args, kwargs
    
    def db_type(self, connection):
        return 'val'
    
    def from_db_value(self, value, expression, connection):
        if value is None:
            return value 
        #return parse_val(value)
        return Val.from_db(value)

    def to_python(self, value):
        if isinstance(value, Val):
            return value
        
        if value is None:
            return value
        
        #return parse_val(value)
        return Val.from_db(value)

    def get_prep_value(self, value):
        return value.to_db()
        #return ''.join([''.join(l) for l in (value.type_uuid, value.value, value.unit)])
    
    def get_db_prep_value(self, value, connection, prepared=False):
        value = super().get_db_prep_value(value, connection, prepared)
        return value

    def get_db_prep_save(self, value, connection, prepared=False):
        value = super().get_db_prep_save(value, connection)
        return value

    def value_from_object(self, obj):
        obj = super().value_from_object(obj)
        if isinstance(obj, Val):
            #obj = obj.to_db()
            obj = obj.__str__
        return obj
        