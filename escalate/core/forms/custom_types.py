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


