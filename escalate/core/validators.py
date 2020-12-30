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
        value.convert_value()

        # if value.val_type.description not in detected_types:
        #    raise ValidationError(f'Data type is {value.val_type.description} but value provided is {" or ".join(detected_types)}')

    
