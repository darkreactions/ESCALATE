from django.forms import MultiWidget, TextInput, Select, MultiValueField, CharField, ChoiceField, Form, ModelChoiceField
from core.models.core_tables import TypeDef
import core.models.view_tables as vt
from core.models.custom_types import ValFormField
from .forms import dropdown_attrs

class SingleValForm(Form):
    value = ValFormField()

class InventoryMaterialForm(Form):
    value = ModelChoiceField(queryset=vt.InventoryMaterial.objects.all())
    value.widget = Select(attrs=dropdown_attrs)

    def __init__(self, *args, org_uuid, **kwargs):
        #self.value = ModelChoiceField(queryset=vt.InventoryMaterial.objects.filter(inventory__lab__organization=org_uuid))
        super().__init__(*args, **kwargs)
        self.fields['value'].queryset = vt.InventoryMaterial.objects.filter(inventory__lab__organization=org_uuid)
        #self.
        


