
from django.forms import MultiWidget, TextInput, Select, Widget
from core.custom_types import Val
from core.validators import ValValidator
from core.models.core_tables import TypeDef
import json
import numpy as np
from django.forms import MultiWidget, TextInput, Select, MultiValueField, CharField, ChoiceField

class TableWidget(Widget):
    input_type = None  # Subclasses must define this.
    template_name = 'core/forms/table_widget.html'
    
    def __init__(self, attrs=None, *args, **kwargs):
        if attrs is not None:
            attrs = attrs.copy()
            self.rows = attrs.pop('rows', 5)
        #print(self.rows)
        attrs['class'] = 'table-editable'
        super().__init__(attrs)

    def get_context(self, name, value, attrs):
        context = super().get_context(name, value, attrs)
        #print(f'in get_context: {context}')
        #context['widget']['rows'] = [i+1 for i in range(self.rows)]
        context['widget']['is_hidden'] = True
        return context

class ValWidget(MultiWidget):
    def __init__(self, attrs={}):
        # value, unit and type
        data_types = TypeDef.objects.filter(category='data')
        try:
            data_type_choices = [(data_type.description, data_type.description) for data_type in data_types]
        except Exception as e:
            data_type_choices = [('num', 'num'), ('text', 'text'), ('bool', 'bool')]
        select_attrs = {'class': 'selectpicker',
                          'data-style': 'btn-outline-primary', 
                          'data-live-search': 'true', 
                          'placeholder': 'DataType'}
        if 'disable_select' in attrs:
            select_attrs['disabled'] = 'disabled'

        widgets = [
            TextInput(attrs={'placeholder': 'Value'}),
            TextInput(attrs={'placeholder': 'Unit'}),
            Select(attrs=select_attrs,
                   choices=data_type_choices),
            TableWidget(attrs={'rows': 5}),
        ]
        super().__init__(widgets, attrs)

    def decompress(self, value):
        if isinstance(value, Val):
            if not value.null:
                return [value.value, value.unit, str(value.val_type.description), value.value, ]

        return [None, None, None, None]

    def get_context(self, name, value, attrs):
        context = super().get_context(name, value, attrs)
        table_subwidget = context['widget']['subwidgets'][3]
        value_text_subwidget = context['widget']['subwidgets'][0]
        select_subwidget = context['widget']['subwidgets'][2]
        
        # Checking if the selected datatype has the term 'array' in it
        if [datatype for datatype in select_subwidget['value'] if 'array' in datatype]:
            table_subwidget['is_hidden'] = False
            value_text_subwidget['attrs']['hidden'] = True # Hide text box
            
            list_value = json.loads(value_text_subwidget['value'])
            list_value = np.array(list_value)
            num_rows = int(len(list_value)/8)
            num_cols = 8

            list_value.resize(num_rows*num_cols)
            list_value = np.reshape(list_value, (num_rows, num_cols))
            
            table_subwidget['rows'] = [i+1 for i in range(num_rows)]
            table_subwidget['values'] = list_value

        return context

class ValFormField(MultiValueField):
    widget = ValWidget()

    def __init__(self, *args, **kwargs):
        errors = self.default_error_messages.copy()
        if 'error_messages' in kwargs:
            errors.update(kwargs['error_messages'])
        data_types = TypeDef.objects.filter(category='data')
        try:
            data_type_choices = [(data_type.description, data_type.description) for data_type in data_types]
        except Exception as e:
            data_type_choices = [('num', 'num'), ('text', 'text'), ('bool', 'bool')]
        fields = (
            CharField(error_messages={
                'incomplete': 'Must enter a value',
            }),
            CharField(required=False),
            ChoiceField(choices=data_type_choices, initial='num')
        )
        if 'max_length' in kwargs:
            kwargs.pop('max_length')
            
        super().__init__(fields, *args, **kwargs)

    def compress(self, data_list):
        if data_list:
            value, unit, val_type_text = data_list
            val_type = TypeDef.objects.get(category='data', description=val_type_text)
            val = Val(val_type, value, unit)
            return val
        return Val(None, None, None, null=True)

    def validate(self, value):
        #print(f"validating {value}")
        validator = ValValidator()
        validator(value)