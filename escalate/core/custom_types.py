import csv
import json
from django.core.exceptions import ValidationError
from core.models.core_tables import TypeDef

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
            #self.value = self.convert_value()
            self.unit = unit
            #print(self.val_type.description, self.value, self.unit)
    
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
            #if len(value) > 0: 
                result = prim(value)
            #else:
                #print(f'Before converting {self.unit}')
                #print(f'{description} : {value}')
            #    result = value
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
        if not self.null:
            return f'{self.value} {self.unit} {self.val_type.description}'
        else:
            return 'null'
    
    def __repr__(self):
        if not self.null:
            return f'{self.value} {self.unit} {self.val_type.description}'
        else:
            return 'null'

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
            #import pdb; pdb.set_trace()
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

