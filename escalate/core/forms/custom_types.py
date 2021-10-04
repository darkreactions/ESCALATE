from core.widgets import ValWidget
from django.forms import (Select, Form, ModelChoiceField, HiddenInput, 
                          CharField, ChoiceField, IntegerField, BaseFormSet, BaseModelFormSet,
                          ModelForm)
from core.models.core_tables import TypeDef
import core.models.view_tables as vt
from core.widgets import ValFormField
from .forms import dropdown_attrs
from crispy_forms.helper import FormHelper
from crispy_forms.layout import Layout, Submit, Row, Column, Hidden

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


class ExperimentNameForm(Form):
    exp_name = CharField(label='Experiment Name', max_length=100)

class ExperimentTemplateForm(Form):
    widget = Select(attrs={'class': 'selectpicker', 
                                 'data-style':"btn-dark",
                                 'data-live-search':'true'})
    select_experiment_template = ChoiceField(widget=widget)
    manual = IntegerField(label='Number of Manual Experiments', required=True, initial=0)
    automated = IntegerField(label='Number of Automated Experiments', required=True, initial=0)

    def __init__(self, *args, **kwargs):
        org_id = kwargs.pop('org_id')
        lab = vt.Actor.objects.get(organization=org_id, person__isnull=True)
        super().__init__(*args, **kwargs)
        #self.fields['organization'].queryset = OrganizationPassword.objects.all()
        self.fields['select_experiment_template'].choices = [(exp.uuid, exp.description) for exp in vt.ExperimentTemplate.objects.filter(lab=lab)]


class ReagentForm(Form):
    widget = Select(attrs={'class': 'selectpicker', 
                                 'data-style':"btn-dark",
                                 'data-live-search':'true', })
    chemical = ChoiceField(widget=widget, required=False)
    desired_concentration = ValFormField(required=False)
    reagent_template_uuid = CharField(widget=HiddenInput())
    material_type = CharField(widget=HiddenInput())

    def __init__(self, *args, **kwargs):
        material_types_list = kwargs.pop('mat_types_list')
        chemical_index = kwargs.pop('index')
        reagent_index = kwargs.pop('reagent_index')
        lab_uuid = kwargs.pop('lab_uuid')
        material_type = material_types_list[chemical_index]
        # TODO: Make inventory materials is being requested since the current inventory should be checked
        # For debugging, I am requesting data from materials directly
        inventory_materials = vt.InventoryMaterial.objects.filter(material__material_type=material_type)
        #inventory_materials = vt.Material.objects.filter(material_type=material_type)

        super().__init__(*args, **kwargs)
        # Uncomment below if switching back to inventory material
        #self.fields['chemical'].choices = [(im.material.uuid, im.material.description) for im in inventory_materials]
        self.fields['chemical'].choices = [(im.uuid, im.description) for im in inventory_materials]
        self.fields['chemical'].label = f'Chemical {chemical_index+1}: {material_type.description}'

class ReagentValueForm(ModelForm):

    def __init__(self, *args, **kwargs):
        disabled_fields = kwargs.pop('disabled_fields', [])
        lab_uuid = kwargs.pop('lab_uuid', None)
        material_types = kwargs.pop('material_types', None)
        index = kwargs.pop('index', None)
        super().__init__(*args, **kwargs)
        if lab_uuid is not None:
            inventory_materials = vt.InventoryMaterial.objects.filter(inventory__lab=lab_uuid)
            self.fields['material'].choices = [(im.uuid, im.description) for im in inventory_materials]
        for field in disabled_fields:
            self.fields[field].disabled = True
        self.fields['uuid'].widget = HiddenInput()

    @staticmethod
    def get_helper():
        fields = ['uuid', 'material_type', 'material', 'nominal_value', 'actual_value']
        #css = {field:'form-group col-md-6 mb-0' for field in fields}


        helper = FormHelper()
        helper.form_class = 'form-horizontal'
        helper.label_class = 'col-lg-2'
        helper.field_class = 'col-lg-8'
        helper.layout = Layout(
            Row(
                Column('material_type'),
                Column('material'),
            ),
            Row(
                Column('nominal_value'),
                Column('actual_value'),
            ),
            Row('uuid')
        )
        return helper

    class Meta:
        model = vt.ReagentInstance
        fields = '__all__'

class BaseReagentModelFormSet(BaseModelFormSet):
    def get_form_kwargs(self, index):
         kwargs = super().get_form_kwargs(index)
         kwargs['index'] = index
         return kwargs

class BaseReagentFormSet(BaseFormSet):
    def get_form_kwargs(self, index):
         kwargs = super().get_form_kwargs(index)
         kwargs['index'] = index
         return kwargs