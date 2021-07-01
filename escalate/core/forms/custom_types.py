from django.forms import Select, Form, ModelChoiceField, HiddenInput, CharField
from core.models.core_tables import TypeDef
import core.models.view_tables as vt
from core.widgets import ValFormField
from .forms import dropdown_attrs

class SingleValForm(Form):
    value = ValFormField(required=False)
    uuid = CharField(widget=HiddenInput)

    

class InventoryMaterialForm(Form):
    value = ModelChoiceField(queryset=vt.InventoryMaterial.objects.all())
    value.widget = Select(attrs=dropdown_attrs)
    uuid = CharField(widget=HiddenInput)

    def __init__(self, *args, org_uuid, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['value'].queryset = vt.InventoryMaterial.objects.filter(inventory__lab__organization=org_uuid)

class NominalActualForm(Form):
    value = ValFormField(required=False)
    actual_value = ValFormField(required=False)
    uuid = CharField(widget=HiddenInput)