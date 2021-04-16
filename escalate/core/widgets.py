
from django.forms import MultiWidget, TextInput, Select, Widget
from core.custom_types import Val
from core.validators import ValValidator
from core.models.core_tables import TypeDef

class TableWidget(Widget):
    input_type = None  # Subclasses must define this.
    template_name = 'core/forms/table_widget.html'
    
    def __init__(self, attrs=None, *args, **kwargs):
        if attrs is not None:
            attrs = attrs.copy()
            self.rows = attrs.pop('rows', 5)
        print('self.rows')
        super().__init__(attrs)

    def get_context(self, name, value, attrs):
        context = super().get_context(name, value, attrs)
        context['widget']['rows'] = [i+1 for i in range(self.rows)]
        return context

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
                   choices=data_type_choices),
            TableWidget(attrs={'rows': 5})
        ]
        super().__init__(widgets, attrs)

    def decompress(self, value):
        if isinstance(value, Val):
            return [value.value, value.unit, str(value.val_type.description)]

        return [None, None, None]




