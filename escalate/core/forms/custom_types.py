from django.forms import MultiWidget, TextInput, Select, MultiValueField, CharField, ChoiceField, Form
from core.models.core_tables import TypeDef
from core.custom_types import Val
from core.validators import ValValidator

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
            #print(value.val_type.description)
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

class SingleValForm(Form):
    value = ValFormField()


