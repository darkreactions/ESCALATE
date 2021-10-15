from core.widgets import ValWidget
from django.forms import (Select, Form, ModelChoiceField, HiddenInput, 
                          CharField, ChoiceField, IntegerField, BaseFormSet, BaseModelFormSet,
                          ModelForm)
from core.models.core_tables import TypeDef
import core.models.view_tables as vt
from core.widgets import ValFormField
from .forms import dropdown_attrs
from crispy_forms.helper import FormHelper
from crispy_forms.layout import Layout, Submit, Row, Column, Hidden, Field

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


class QueueStatusForm(Form):
    widget = Select(attrs={'class': 'selectpicker',
                           'data-style': 'btn-light',
                           'data-live-search': 'false'})
    select_queue_status = ChoiceField(widget=widget)
    select_queue_priority = ChoiceField(widget=widget)

    def __init__(self, experiment, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['select_queue_status'].choices = [('Pending', 'Pending'),
                                                      ('Running' ,'Running'),
                                                      ('Completed', 'Completed')]
        self.fields['select_queue_status'].initial = experiment.completion_status
        self.fields['select_queue_priority'].choices = [('1', '1'),
                                                        ('2' ,'2'),
                                                        ('3', '3')]
        self.fields['select_queue_priority'].initial = experiment.priority

    @staticmethod
    def get_helper():
        helper = FormHelper()
        helper.form_class = 'form-horizontal'
        helper.label_class = 'col-lg-3'
        helper.field_class = 'col-lg-8'
        helper.layout = Layout(
            Row(
                Column(Field('select_queue_status'))
            ),
            Row(
                Column(Field('select_queue_priority'))
            ),
        )
        return helper

class ReagentForm(Form):
    widget = Select(attrs={'class': 'selectpicker', 
                                 'data-style':"btn-outline",
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
        inventory_materials = vt.InventoryMaterial.objects.filter(material__material_type=material_type, inventory__lab__organization=lab_uuid)
        #inventory_materials = vt.Material.objects.filter(material_type=material_type)

        super().__init__(*args, **kwargs)
        # Uncomment below if switching back to inventory material
        #self.fields['chemical'].choices = [(im.material.uuid, im.material.description) for im in inventory_materials]
        self.fields['chemical'].choices = [(im.uuid, im.description) for im in inventory_materials]
        self.fields['chemical'].label = f'Chemical {chemical_index+1}: {material_type.description}'

    @staticmethod
    def get_helper():
        helper = FormHelper()
        helper.form_class = 'form-horizontal'
        helper.label_class = 'col-lg-3'
        helper.field_class = 'col-lg-8'
        helper.layout = Layout(
            Row(
                Column(Field('chemical')),
                Column(Field('desired_concentration')),
            ),
            Field('reagent_template_uuid'),
            Field('material_type')
        )
        return helper


class ReagentValueForm(Form):
    material_type = CharField(required=False)
    material = CharField(required=False)
    nominal_value = ValFormField(required=False)
    actual_value = ValFormField()
    uuid = CharField(widget=HiddenInput())

    def __init__(self, *args, **kwargs):
        disabled_fields = kwargs.pop('disabled_fields', [])
        chemical_index = kwargs.pop('index')
        super().__init__(*args, **kwargs)
        for field in disabled_fields:
            self.fields[field].disabled = True

    @staticmethod
    def get_helper(readonly_fields=[]):
        #fields = ['uuid', 'material_type', 'material', 'nominal_value', 'actual_value']
        #css = {field:'form-group col-md-6 mb-0' for field in fields}
        def is_readonly(field):
            return True if field in readonly_fields else False

        helper = FormHelper()
        helper.form_class = 'form-horizontal'
        helper.label_class = 'col-lg-2'
        helper.field_class = 'col-lg-8'
        helper.layout = Layout(
            Row(
                Column(Field('material_type', readonly=is_readonly('material_type'), css_class='form-control-plaintext')),
                Column(Field('material', readonly=is_readonly('material'), css_class='form-control-plaintext')),
            ),
            Row(
                Column(Field('nominal_value', readonly=is_readonly('nominal_value'))),
                Column(Field('actual_value')),
            ),
            Row('uuid')
        )
        return helper

    #class Meta:
    #    model = vt.ReagentMaterial
    #    fields = '__all__'


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


class OutcomeInstanceForm(ModelForm):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if self.instance:
            self.fields['actual_value'].label = f'Outcome of: {self.instance.description}'
        self.fields['file'].required = False

    @staticmethod
    def get_helper(readonly_fields=[]):
        helper = FormHelper()
        helper.form_class = 'form-horizontal'
        helper.label_class = 'col-lg-4'
        helper.field_class = 'col-lg-6'
        helper.layout = Layout(
            Row(
                Column(Field('actual_value')),
                Column(Field('file')),
            ),
        )
        return helper

    class Meta:
        model = vt.OutcomeInstance
        fields = ['actual_value', 'file']
