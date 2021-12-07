from django.forms.widgets import CheckboxSelectMultiple, SelectMultiple
from core.widgets import ValWidget
from django.forms import (
    Select,
    Form,
    ModelChoiceField,
    HiddenInput,
    CharField,
    ChoiceField,
    MultipleChoiceField,
    IntegerField,
    BaseFormSet,
    BaseModelFormSet,
    ModelForm,
    FileField,
    ClearableFileInput,
)
from core.models.core_tables import TypeDef
import core.models.view_tables as vt
from core.widgets import ValFormField
from .forms import dropdown_attrs
from crispy_forms.helper import FormHelper
from crispy_forms.layout import Layout, Submit, Row, Column, Hidden, Field


class UploadFileForm(Form):
    # title = CharField(max_length=50)
    file = FileField(label="Upload completed robot file")

    @staticmethod
    def get_helper():
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-2"
        helper.field_class = "col-lg-8"
        helper.layout = Layout(
            Row(Column(Field("file"))), Row(Column(Submit("robot_upload", "Submit"))),
        )
        return helper


class SingleValForm(Form):
    value = ValFormField(required=False)
    uuid = CharField(widget=HiddenInput)


class RobotForm(Form):
    # title = CharField(max_length=50)
    file = FileField(label="Upload completed robot file")

    @staticmethod
    def get_helper():
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-2"
        helper.field_class = "col-lg-8"
        helper.layout = Layout(
            Row(Column(Field("file"))), Row(Column(Submit("robot_upload", "Submit"))),
        )
        return helper


class UploadFileForm(Form):
    # title = CharField(max_length=50)
    file = FileField(label="Upload completed outcome file")
    outcome_files = FileField(
        label="Upload related files (images,xrd etc.)",
        widget=ClearableFileInput(attrs={"multiple": True}),
    )

    @staticmethod
    def get_helper():
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-2"
        helper.field_class = "col-lg-8"
        helper.layout = Layout(
            Row(Column(Field("file"))),
            Row(Column(Field("outcome_files"))),
            # Row(Column(Submit('outcome_upload', 'Submit'))),
        )
        return helper


class VesselForm(Form):
    v_query = vt.Vessel.objects.all()
    value = ModelChoiceField(queryset=v_query)
    value.widget = Select(attrs=dropdown_attrs)
    # uuid = CharField(widget=HiddenInput)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields["value"].queryset = vt.Vessel.objects.filter(parent__isnull=True)


class InventoryMaterialForm(Form):
    value = ModelChoiceField(queryset=vt.InventoryMaterial.objects.all())
    value.widget = Select(attrs=dropdown_attrs)
    uuid = CharField(widget=HiddenInput)

    def __init__(self, *args, org_uuid, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields["value"].queryset = vt.InventoryMaterial.objects.filter(
            inventory__lab__organization=org_uuid
        )


class NominalActualForm(Form):
    value = ValFormField(required=False)
    actual_value = ValFormField(required=False)
    uuid = CharField(widget=HiddenInput)

class ReagentTemplateCreateForm(Form):
    widget = Select(attrs={'class': 'selectpicker', 
                                 'data-style':"btn-dark",
                                 'data-live-search':'true'})
    
    widget_mc = CheckboxSelectMultiple(attrs={'class': 'selectpicker', 
                            'data-style':"btn-dark",
                            'data-live-search':'true'})
    
    template_name= CharField(label='Reagent Template Name', required=True)

    mt_choices = [(r.uuid, r.description) for r in vt.MaterialType.objects.all()]

    select_mt = MultipleChoiceField(
            choices=mt_choices,
            #initial='0',
            widget=SelectMultiple(),
            required=True,
            label='Select Material Types',
        )
    
    def __init__(self, *args, **kwargs):
        org_id = kwargs.pop('org_id')
        lab = vt.Actor.objects.get(organization=org_id, person__isnull=True)
        super().__init__(*args, **kwargs)
        #self.fields['select_rt'].choices = [(r.uuid, r.description) for r in vt.ReagentTemplate.objects.all()]
        
        #v_query = vt.Vessel.objects.all()
        #vessel = VesselForm(initial={'value': v_query[0]})
        #self.fields['select_vessel'].choices = [v for v in vessel]
        #self.fields['select_vessel'].choices = [(r.uuid, r.description) for r in vt.Vessel.objects.all()]
        #self.fields['select_materials'].choices = [(r.uuid, r.description) for r in vt.InventoryMaterial.objects.all()]


class ExperimentNameForm(Form):
    exp_name = CharField(label="Experiment Name", max_length=100)


class ActionSequenceSelectionForm(Form):
    action_choices = [(a.uuid, a.description) for a in vt.ActionSequence.objects.all()]

    select_actions = MultipleChoiceField(
            choices=action_choices,
            #initial='0',
            widget=SelectMultiple(),
            required=True,
            label='Select Action Sequences',
        )

class ReagentSelectionForm(Form):
    reagent_choices = [(r.uuid, r.description) for r in vt.ReagentTemplate.objects.all()]

    select_rt = MultipleChoiceField(
            choices=reagent_choices,
            #initial='0',
            widget=SelectMultiple(),
            required=True,
            label='Select Reagent Templates',
        )

class MaterialTypeSelectionForm(Form):
    mt_choices = [(r.uuid, r.description) for r in vt.MaterialType.objects.all()]

    select_mt = MultipleChoiceField(
            choices=mt_choices,
            #initial='0',
            widget=SelectMultiple(),
            required=True,
            label='Select Material Types',
        )

class ExperimentTemplateCreateForm(Form):

    widget = Select(attrs={'class': 'selectpicker', 
                                 'data-style':"btn-dark",
                                 'data-live-search':'true'})
    
    widget_mc = CheckboxSelectMultiple(attrs={'class': 'selectpicker', 
                            'data-style':"btn-dark",
                            'data-live-search':'true'})
    
    template_name= CharField(label='Experiment Template Name', required=True)
    #reagent_num = IntegerField(label='Number of Reagents', required=True, initial=0)
    
    reagent_choices = [(r.uuid, r.description) for r in vt.ReagentTemplate.objects.all()]

    select_rt = MultipleChoiceField(
            choices=reagent_choices,
            #initial='0',
            widget=SelectMultiple(),
            required=True,
            label='Select Reagent Templates',
        )
    
    #select_rt = SelectMultiple([(r.uuid, r.description) for r in vt.ReagentTemplate.objects.all()])
        #label='Select Reagent Templates')
    #, widget=widget_mc)

    # MultipleChoiceField(label='Select Reagent Templates', widget=widget_mc)
    
    #column_order= CharField(label='Column Order', required=False, initial='ACEGBDFH')
    #rows = IntegerField(label='Number of Rows', required=False, initial=12)
    #select_vessel = ChoiceField(label='Select Vessel', widget=widget)

    action_choices = [(a.uuid, a.description) for a in vt.ActionSequence.objects.all()]
    
    select_actions = MultipleChoiceField(
            choices=action_choices,
            #initial='0',
            widget=SelectMultiple(),
            required=True,
            label='Select Action Sequences',
        )
    well_num = IntegerField(label='Number of Wells', required=True, initial=96)
    
    define_outcomes = CharField(label='Outcome to Measure', required=True, initial='Crystal score')
    
    def __init__(self, *args, **kwargs):
        org_id = kwargs.pop('org_id')
        lab = vt.Actor.objects.get(organization=org_id, person__isnull=True)
        super().__init__(*args, **kwargs)
        #self.fields['select_rt'].choices = [(r.uuid, r.description) for r in vt.ReagentTemplate.objects.all()]
        
        #v_query = vt.Vessel.objects.all()
        #vessel = VesselForm(initial={'value': v_query[0]})
        #self.fields['select_vessel'].choices = [v for v in vessel]
        #self.fields['select_vessel'].choices = [(r.uuid, r.description) for r in vt.Vessel.objects.all()]
        #self.fields['select_materials'].choices = [(r.uuid, r.description) for r in vt.InventoryMaterial.objects.all()]

class ExperimentTemplateForm(Form):
    widget = Select(
        attrs={
            "class": "selectpicker",
            "data-style": "btn-dark",
            "data-live-search": "true",
        }
    )
    select_experiment_template = ChoiceField(widget=widget)
    manual = IntegerField(
        label="Number of Manual Experiments", required=True, initial=0
    )
    automated = IntegerField(
        label="Number of Automated Experiments", required=True, initial=0
    )

    def __init__(self, *args, **kwargs):
        org_id = kwargs.pop('org_id')
        if not org_id:
            raise ValueError('Please select a lab to continue')
        lab = vt.Actor.objects.get(organization=org_id, person__isnull=True)
        super().__init__(*args, **kwargs)
        # self.fields['organization'].queryset = OrganizationPassword.objects.all()
        self.fields["select_experiment_template"].choices = [
            (exp.uuid, exp.description)
            for exp in vt.ExperimentTemplate.objects.filter(lab=lab)
        ]


class QueueStatusForm(Form):
    widget = Select(
        attrs={
            "class": "selectpicker",
            "data-style": "btn-light",
            "data-live-search": "false",
        }
    )
    select_queue_status = ChoiceField(widget=widget)
    select_queue_priority = ChoiceField(widget=widget)

    def __init__(self, experiment, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields["select_queue_status"].choices = [
            ("Pending", "Pending"),
            ("Running", "Running"),
            ("Completed", "Completed"),
        ]
        self.fields["select_queue_status"].initial = experiment.completion_status
        self.fields["select_queue_priority"].choices = [
            ("1", "1"),
            ("2", "2"),
            ("3", "3"),
        ]
        self.fields["select_queue_priority"].initial = experiment.priority

    @staticmethod
    def get_helper():
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-3"
        helper.field_class = "col-lg-8"
        helper.layout = Layout(
            Row(Column(Field("select_queue_status"))),
            Row(Column(Field("select_queue_priority"))),
        )
        return helper


class ReactionParameterForm(Form):
    value = ValFormField(required=False, label="")
    uuid = CharField(widget=HiddenInput())


class ReagentForm(Form):
    widget = Select(
        attrs={
            "class": "selectpicker",
            "data-style": "btn-outline",
            "data-live-search": "true",
        }
    )
    chemical = ChoiceField(widget=widget, required=False)
    desired_concentration = ValFormField(required=False)
    reagent_template_uuid = CharField(widget=HiddenInput())
    material_type = CharField(widget=HiddenInput())

    def __init__(self, *args, **kwargs):
        material_types_list = kwargs.pop("mat_types_list")
        chemical_index = kwargs.pop("index")
        reagent_index = kwargs.pop("reagent_index")
        lab_uuid = kwargs.pop("lab_uuid")
        material_type = material_types_list[chemical_index]
        # TODO: Make inventory materials is being requested since the current inventory should be checked
        # For debugging, I am requesting data from materials directly
        inventory_materials = vt.InventoryMaterial.objects.filter(
            material__material_type=material_type, inventory__lab__organization=lab_uuid
        )
        # inventory_materials = vt.Material.objects.filter(material_type=material_type)

        super().__init__(*args, **kwargs)
        # Uncomment below if switching back to inventory material
        # self.fields['chemical'].choices = [(im.material.uuid, im.material.description) for im in inventory_materials]
        self.fields["chemical"].choices = [
            (im.uuid, im.description) for im in inventory_materials
        ]
        self.fields[
            "chemical"
        ].label = f"Chemical {chemical_index+1}: {material_type.description}"

    @staticmethod
    def get_helper():
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-3"
        helper.field_class = "col-lg-8"
        helper.layout = Layout(
            Row(Column(Field("chemical")), Column(Field("desired_concentration")),),
            Field("reagent_template_uuid"),
            Field("material_type"),
        )
        return helper


class ReagentValueForm(Form):
    material_type = CharField(required=False)
    material = CharField(required=False)
    nominal_value = ValFormField(required=False)
    actual_value = ValFormField()
    uuid = CharField(widget=HiddenInput())

    def __init__(self, *args, **kwargs):
        disabled_fields = kwargs.pop("disabled_fields", [])
        chemical_index = kwargs.pop("index")
        super().__init__(*args, **kwargs)
        for field in disabled_fields:
            self.fields[field].disabled = True

    @staticmethod
    def get_helper(readonly_fields=[]):
        # fields = ['uuid', 'material_type', 'material', 'nominal_value', 'actual_value']
        # css = {field:'form-group col-md-6 mb-0' for field in fields}
        def is_readonly(field):
            return True if field in readonly_fields else False

        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-2"
        helper.field_class = "col-lg-8"
        helper.layout = Layout(
            Row(
                Column(
                    Field(
                        "material_type",
                        readonly=is_readonly("material_type"),
                        css_class="form-control-plaintext",
                    )
                ),
                Column(
                    Field(
                        "material",
                        readonly=is_readonly("material"),
                        css_class="form-control-plaintext",
                    )
                ),
            ),
            Row(
                Column(Field("nominal_value", readonly=is_readonly("nominal_value"))),
                Column(Field("actual_value")),
            ),
            Row("uuid"),
        )
        return helper

    # class Meta:
    #    model = vt.ReagentMaterial
    #    fields = '__all__'


class BaseReagentModelFormSet(BaseModelFormSet):
    def get_form_kwargs(self, index):
        kwargs = super().get_form_kwargs(index)
        kwargs["index"] = index
        return kwargs


class BaseReagentFormSet(BaseFormSet):
    def get_form_kwargs(self, index):
        kwargs = super().get_form_kwargs(index)
        kwargs["index"] = index
        return kwargs


class OutcomeInstanceForm(ModelForm):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if self.instance:
            self.fields[
                "actual_value"
            ].label = f"Outcome of: {self.instance.description}"
        self.fields["file"].required = False

    @staticmethod
    def get_helper():
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-3"
        helper.field_class = "col-lg-8"
        helper.layout = Layout(Row(Column(Field("actual_value")), Row(Field("file")),),)
        return helper

    class Meta:
        model = vt.OutcomeInstance
        fields = ["actual_value", "file"]


class PropertyForm(ModelForm):
    def __init__(self, *args, **kwargs):
        nominal_value_label = "Nominal Value"
        value_label = "Value"
        if "nominal_value_label" in kwargs:
            nominal_value_label = kwargs.pop("nominal_value_label")
        if "value_label" in kwargs:
            value_label = kwargs.pop("value_label")

        disabled_fields = kwargs.pop("disabled_fields", [])

        super().__init__(*args, **kwargs)

        self.fields["nominal_value"].label = nominal_value_label
        self.fields["value"].label = value_label
        for field in disabled_fields:
            self.fields[field].disabled = True

    @staticmethod
    def get_helper(readonly_fields=[]):
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-3"
        helper.field_class = "col-lg-8"
        helper.layout = Layout(
            Row(Column(Field("nominal_value", readonly=True)), Column(Field("value")),),
        )
        return helper

    class Meta:
        model = vt.Property
        fields = ["nominal_value", "value"]
        widgets = {"nominal_value": ValWidget(), "value": ValWidget()}
