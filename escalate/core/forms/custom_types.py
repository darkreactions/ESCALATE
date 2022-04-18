from core.widgets import ValWidget, TextInput, MultiWidget
from django import forms
from django.forms import (
    MultiValueField,
    Select,
    SelectMultiple,
    CheckboxSelectMultiple,
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
    ValidationError,
)
from core.models.core_tables import TypeDef
import core.models.view_tables as vt
from core.widgets import ValFormField
from .forms import dropdown_attrs
from crispy_forms.helper import FormHelper
from crispy_forms.layout import Layout, Submit, Row, Column, Hidden, Field


from django.forms import inlineformset_factory

#from core.models.base_classes.chemistry_base_class import ReagentColumn, MaterialColumns

# from django.forms import formset_factory


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
    uuid = CharField(widget=HiddenInput, required=False)


class ManualSpecificationForm(Form):
    # title = CharField(max_length=50)
    file = FileField(label="Upload completed file")

    @staticmethod
    def get_helper():
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-2"
        helper.field_class = "col-lg-8"
        helper.layout = Layout(Row(Column(Field("file"))),)
        helper.form_tag = False
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
    value = ModelChoiceField(queryset=v_query, label="Select Vessel")
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

    reagent_template_name = CharField(required=True)

    num_materials = IntegerField(label="Number of Materials", required=True, initial=1, min_value=1)

    def __init__(self, *args, **kwargs):
        try:
            self.reagent_index = kwargs.pop("index")

            colors = kwargs.pop("colors")
            self.data_current = {"color": colors[self.reagent_index]}
        except KeyError:
            self.reagent_index=0
        super().__init__(*args, **kwargs)
        self.fields["reagent_template_name"].label = f"Reagent {str(int(self.reagent_index)+1)} Name"

        self.get_helper()

    def get_helper(self):
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-8"
        helper.field_class = "col-lg-8"
        # rows = []

        # rows.append(
        #    Row((Field(f"reagent_template_name")),), Row((Field(f"num_materials")),)
        # )
        helper.layout = Layout(
            # Row((Field(f"name")),),
            Row((Field(f"reagent_template_name")), Field(f"num_materials")),)
            #Row((Field(f"num_materials")),),
        #)
        helper.form_tag = False
        # return helper
        self.helper = helper

'''class ReagentTemplateNameForm(forms.ModelForm):
    class Meta:
        model = ReagentColumn
        fields = ('name',)

class ReagentTemplateMaterialAddForm(forms.ModelForm):
    class Meta:
        model = MaterialColumns
        fields = ('select_mt',)'''
class ReagentTemplateMaterialAddForm(Form):
    
    name = CharField(disabled=True, label="Reagent")
    
    #select_mt = MultipleChoiceField(
     #   widget=Select(), required=True, label="Select Material Type",
    #)

    def generate_subforms(self, i): #reagent_name):
        self.fields[f'select_mt_{i}'] = ChoiceField(
            widget=Select(), required=True, label="Select Material Type",
        )

        self.fields[f'select_mt_{i}'].choices = [
            (r.uuid, r.description) for r in vt.MaterialType.objects.all()
        ]

        #self.fields["select_mt"].label = f"{reagent_name}"  #: material {index}"'''

    def __init__(self, *args, **kwargs):
        #kwargs.pop("materials")
        try:
            self.index = kwargs.pop("index")
            colors = kwargs.pop("colors")
            self.data_current = {"color": colors[self.index]}
        except KeyError:
            self.index=0
        
        data = kwargs.pop("initial")

        # self.index = kwargs.pop("index")
        # self.lab_uuid = kwargs.pop("lab_uuid")
        # self.data = kwargs.pop("form_data")
        # self.action_parameter_list: "list[str]" = self.data[str(self.action_index)][
        # "action_parameter_list"
        # ]
        # self.data_current = self.data[str(self.index)]

        super().__init__(*args, **kwargs)

        #self.fields["select_mt"].choices = [
            #(r.uuid, r.description) for r in vt.MaterialType.objects.all()
        #]

        self.fields["name"].initial = list(data.keys())[0]
        for i in range(len(data[self.fields["name"].initial])):
            self.generate_subforms(i)

        self.get_helper()

    def get_helper(self):
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-8"
        helper.field_class = "col-lg-8"
        # rows = []

        # rows.append(
        #    Row((Field(f"reagent_template_name")),), Row((Field(f"num_materials")),)
        # )
        '''helper.layout = Layout(
            # Row((Field(f"name")),),
            Row(Field(f"name")), 
            Row(Field(f'select_mt_{i}',),))
        #)'''
        helper.form_tag = False
        # return helper
        self.helper = helper

        # for name, forms in self.data.items():
        #   self.generate_subforms(name)
"""def __init__(self, *args, **kwargs):
        # org_id = kwargs.pop("org_id")
        # lab = vt.Actor.objects.get(organization=org_id, person__isnull=True)
        super().__init__(*args, **kwargs)
        self.fields["select_mt"].choices = [
            (r.uuid, r.description) for r in vt.MaterialType.objects.all()
        ]
        # self.fields['select_rt'].choices = [(r.uuid, r.description) for r in vt.ReagentTemplate.objects.all()]

    def generate_action_parameter_fields(self, index, param_uuid):
        self.fields[f"value_{self.action_index}_{index}"] = ValFormField(required=False)
        self.fields[f"parameter_uuid_{self.action_index}_{index}"] = CharField(
            widget=HiddenInput(), initial=param_uuid
        )
        parameter = vt.ParameterDef.objects.get(uuid=param_uuid)
        self.fields[
            f"value_{self.action_index}_{index}"
        ].label = parameter.description.capitalize()

    def __init__(self, *args, **kwargs):
        self.action_index = kwargs.pop("index")
        self.lab_uuid = kwargs.pop("lab_uuid")
        self.data = kwargs.pop("form_data")
        self.action_parameter_list: "list[str]" = self.data[str(self.action_index)][
            "action_parameter_list"
        ]
        self.data_current = self.data[str(self.action_index)]

        super().__init__(*args, **kwargs)

        for i, param_uuid in enumerate(self.action_parameter_list):
            self.generate_action_parameter_fields(i, param_uuid)"""


class ExperimentNameForm(Form):
    exp_name = CharField(label="Experiment Name", max_length=100)


class ExperimentTemplateNameForm(Form):
    exp_template_name = CharField(
        label="Experiment Template Name", max_length=100, required=True
    )


"""class ActionSequenceNameForm(Form):
    widget = TextInput(attrs={"id": "name"})

    name = CharField(
        label="Action Sequence Name", max_length=100, widget=widget, required=True
    )


class ActionSequenceSelectionForm(Form):
    # action_choices = [(a.uuid, a.description) for a in vt.ActionSequence.objects.all()]

    select_actions = MultipleChoiceField(
        # initial='0',
        widget=SelectMultiple(),
        required=True,
        label="Select Action Sequences",
    )

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields["select_actions"].choices = [
            (a.uuid, a.description) for a in vt.ActionSequence.objects.all()
        ]"""


"""class ReagentSelectionForm(Form):
    # reagent_choices = [(r.uuid, r.description) for r in vt.ReagentTemplate.objects.all()]

    select_rt = MultipleChoiceField(
        # initial='0',
        widget=SelectMultiple(),
        required=True,
        label="Select Reagent Templates",
    )

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields["select_rt"].choices = [
            (r.uuid, r.description) for r in vt.ReagentTemplate.objects.all()
        ]


class MaterialTypeSelectionForm(Form):
    # mt_choices = [(r.uuid, r.description) for r in vt.MaterialType.objects.all()]

    select_mt = MultipleChoiceField(
        # initial='0',
        widget=SelectMultiple(),
        required=True,
        label="Select Material Types",
    )

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields["select_mt"].choices = [
            (r.uuid, r.description) for r in vt.MaterialType.objects.all()
        ]"""


class OutcomeDefinitionForm(Form):

    # well_num = IntegerField(label="Number of Experiments", required=True, initial=96)
    # define_outcomes=ValFormField(label="Outcome", required=False)

    '''widget = Select(
        attrs={
            "class": "selectpicker",
            "data-style": "btn-dark",
            "data-live-search": "true",
            "id": "template",
        }
    )'''

    define_outcomes = CharField(label="Outcome", required=False, initial=None)
    outcome_type = ChoiceField(widget=Select())

    def __init__(self, *args, **kwargs):
        try:
            self.outcome_index = kwargs.pop("index")
            colors = kwargs.pop("colors")
            self.data_current = {"color": colors[self.outcome_index]}
        except KeyError:
            self.outcome_index=0

        super().__init__(*args, **kwargs)
        self.fields["define_outcomes"].label = f"Outcome {str(int(self.outcome_index)+1)}"
       
        try:
            data_types = TypeDef.objects.filter(category="data")
            data_type_choices = [
                (data_type.description, data_type.description)
                for data_type in data_types
            ]
            self.fields["outcome_type"].choices = data_type_choices
        except Exception as e:
            self.fields["outcome_type"].choices = [
                ("num", "num"),
                ("text", "text"),
                ("bool", "bool"),
            ]

        self.get_helper()

    def get_helper(self):
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-8"
        helper.field_class = "col-lg-8"
        # rows = []

        # rows.append(
        #    Row((Field(f"reagent_template_name")),), Row((Field(f"num_materials")),)
        # )
        helper.layout = Layout(
            Row((Field(f"define_outcomes")), Field(f"outcome_type")),)
        
        helper.form_tag = False
        # return helper
        self.helper = helper


class ExperimentTemplateCreateForm(Form):

    widget = Select(
        attrs={
            "class": "selectpicker",
            "data-style": "btn-dark",
            "data-live-search": "true",
        }
    )

    widget_mc = CheckboxSelectMultiple(
        attrs={
            "class": "selectpicker",
            "data-style": "btn-dark",
            "data-live-search": "true",
        }
    )

    template_name = CharField(label="Experiment Template Name", required=True)

    num_reagents = IntegerField(
        label="Number of Reagents", required=True, initial=1, min_value=0
    )

    num_outcomes = IntegerField(
        label="Number of outcomes to measure", required="True", initial=1, min_value=0
    )

    # select_rt = MultipleChoiceField(
    #  initial="0",
    # widget=SelectMultiple(),
    #  required=True,
    # label="Select Reagent Templates",
    # )

    # select_rt = SelectMultiple([(r.uuid, r.description) for r in vt.ReagentTemplate.objects.all()])
    # label='Select Reagent Templates')
    # , widget=widget_mc)

    # select_actions = MultipleChoiceField(
    # initial='0',
    # widget=SelectMultiple(),
    # required=True,
    # label='Select Action Sequences',
    # )
    # well_num = IntegerField(label="Number of Wells", required=True, initial=96)

    # define_outcomes = CharField(
    # label="Outcome to Measure", required=True, initial="Crystal score"
    # )

    def __init__(self, *args, **kwargs):
        org_id = kwargs.pop("org_id")
        lab = vt.Actor.objects.get(organization=org_id, person__isnull=True)
        super().__init__(*args, **kwargs)
        # self.fields["select_rt"].choices = [
        #  (r.uuid, r.description) for r in vt.ReagentTemplate.objects.all()
        # ]
        # self.fields['select_actions'].choices = [(a.uuid, a.description) for a in vt.ActionSequence.objects.all()]

    def clean(self):
        cleaned_data = super().clean()

        if self.is_valid():
            template_name = cleaned_data["template_name"]

            num_templates = vt.ExperimentTemplate.objects.filter(
                description=template_name
            ).count()

            if num_templates > 0:
                message = f"Template with name {template_name} already exists. Please enter a new name."
                self.add_error(
                    "template_name", ValidationError(message, code="invalid")
                )
            """
            total_experiments = cleaned_data["manual"] + cleaned_data["automated"]
            outcome_vessel = cleaned_data["outcome_vessel"]

            if (capacity := outcome_vessel.children.count()) == 0:
                capacity = 1
            if capacity < total_experiments:
                message = f"Number of experiments requested ({total_experiments}) is higher than the outcome vessel's capacity ({capacity})."
                self.add_error(
                    "outcome_vessel", ValidationError(message, code="invalid")
                )"""

        return cleaned_data


class ExperimentTemplateSelectForm(Form):

    widget = Select(
        attrs={
            "class": "selectpicker",
            "data-style": "btn-dark",
            "data-live-search": "true",
            "id": "template",
        }
    )
    select_experiment_template = ChoiceField(widget=widget)

    def __init__(self, *args, **kwargs):
        org_id = kwargs.pop("org_id")
        if not org_id:
            raise ValueError("Please select a lab to continue")
        lab = vt.Actor.objects.get(organization=org_id, person__isnull=True)
        super().__init__(*args, **kwargs)
        # self.fields['organization'].queryset = OrganizationPassword.objects.all()
        self.fields["select_experiment_template"].choices = [
            (exp.uuid, exp.description)
            for exp in vt.ExperimentTemplate.objects.filter(lab=lab)
        ]


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
        org_id = kwargs.pop("org_id")
        if not org_id:
            raise ValueError("Please select a lab to continue")
        lab = vt.Actor.objects.get(organization=org_id, person__isnull=True)
        super().__init__(*args, **kwargs)
        # self.fields['organization'].queryset = OrganizationPassword.objects.all()
        self.fields["select_experiment_template"].choices = [
            (exp.uuid, exp.description)
            for exp in vt.ExperimentTemplate.objects.filter(lab=lab)
        ]


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
    concentration = ValFormField(required=False)
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
                Column(
                    Field(
                        "concentration",
                        readonly=is_readonly("concentration"),
                        # css_class="form-control-plaintext",
                    )
                ),
                Row(
                    Column(
                        Field("nominal_value", readonly=is_readonly("nominal_value"))
                    ),
                    Column(Field("actual_value")),
                ),
                Row("uuid"),
            ),
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
            Row(
                Column(Field("uuid"), hidden=True),
                Column(Field("nominal_value", readonly=True)),
                Column(Field("value")),
            ),
        )
        return helper

    class Meta:
        model = vt.Property
        fields = ["uuid", "nominal_value", "value"]
        widgets = {"nominal_value": ValWidget(), "value": ValWidget()}
