from django.core.exceptions import ValidationError
# from django.utils.translation import gettext_lazy as _
import json
from core.models.core_tables import TypeDef


class ValValidator:
    """
    Class to handle validation of val custom type
    """
    message = 'Invalid data'
    code = 'invalid'

    def __init__(self, message=None, code=None, whitelist=None):
        if message is not None:
            self.message = message
        if code is not None:
            self.code = code
        if whitelist is not None:
            self.domain_whitelist = whitelist

    def __call__(self, value):
        if not value.null:
            if 'array' in value.val_type.description:
                value.value = self.convert_list_value(
                    value.val_type.description, value.value)
            else:
                value.value = self.convert_value(
                    value.val_type.description, value.value)

        # if value.val_type.description not in detected_types:
        #    raise ValidationError(f'Data type is {value.val_type.description} but value provided is {" or ".join(detected_types)}')

    def convert_value(self, description, value):
        primitives = {'bool': bool, 'int': int, 'num': float, 'text': str}
        reverse_primitives = {bool: 'bool',
                              int: 'int', float: 'num', str: 'text'}
        prim = primitives[description]
        try:
            result = prim(value)
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
