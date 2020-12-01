from django.db import models
"""
v_type_uuid uuid,
v_unit character varying,
v_text character varying,
v_text_array character varying[],
v_int bigint,
v_int_array bigint[],
v_num numeric,
v_num_array numeric[],
v_edocument_uuid uuid,
v_source_uuid uuid,
v_bool boolean,
v_bool_array boolean[]
"""


class Val:
    def __init__(self, type_uuid='', unit='', text='', text_array='', 
                 integer='', int_array='', num='', num_array='', edoc_uuid='', 
                 source_uuid='', boolean='', bool_array=''):
        self.type_uuid = type_uuid
        self.unit = unit
        self.value = num
        """
        self.text = text
        self.text_array = text_array
        self.integer = integer
        self.int_array = int_array
        self.num = num
        self.num_array = num_array
        self.edoc_uuid = edoc_uuid
        self.source_uuid = source_uuid
        self.boolean = boolean
        self.bool_array = bool_array
        """

    
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
        return parse_val(value)

    def to_python(self, value):
        if isinstance(value, Val):
            return value
        
        if value is None:
            return value
        
        return parse_val(value)

    def get_prep_value(self, value):
        return ''.join([''.join(l) for l in (value.type_uuid, value.value, value.unit)])
    
    def get_db_prep_value(self, value, connection, prepared=False):
        value = super().get_db_prep_value(value, connection, prepared)
        return value

    def get_db_prep_save(self, value, connection, prepared=False):
        value = super().get_db_prep_save(value, connection, prepared)
        return value

    def value_from_object(self, obj):
        obj = super().value_from_object(obj)
        if isinstance(obj, Val):
            obj = f'{obj.type_uuid} - {obj.unit} - {obj.value}'
        return obj
        