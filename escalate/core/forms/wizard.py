from uuid import UUID
from django.db.models import QuerySet
from django.forms import (
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
from crispy_forms.helper import FormHelper
from crispy_forms.layout import Layout, Submit, Row, Column, Hidden, Field
import pandas as pd

import core.models.view_tables as vt
from core.widgets import ValFormField
from core.models.view_tables.workflow import ExperimentTemplate
from core.widgets import ValWidget, TextInput
from .forms import dropdown_attrs
from plugins.sampler.base_sampler_plugin import SamplerPlugin


class NumberOfExperimentsForm(Form):
    experiment_name = CharField()
    manual = IntegerField(
        label="Number of Manual Experiments",
        required=True,
        initial=0,
        min_value=0,
    )
    automated = IntegerField(
        label="Number of Automated Experiments",
        required=True,
        initial=0,
        min_value=0,
    )
    outcome_vessel = ModelChoiceField(
        queryset=vt.Vessel.objects.filter(parent__isnull=True),
        label="Select Outcome Vessel",
    )
    outcome_vessel.widget = Select(attrs=dropdown_attrs)
    reagent_parameters = ModelChoiceField(
        queryset=vt.PropertyTemplate.objects.all(),
        label="Select reagent property to initialize",
        widget=Select(attrs=dropdown_attrs),
    )

    def __init__(self, *args, **kwargs):
        self.form_kwargs = kwargs.pop("form_kwargs")
        self.exp_template = self.form_kwargs.pop("experiment_template", None)
        super().__init__(*args, **kwargs)
        # self.fields["value"].queryset = vt.Vessel.objects.filter(parent__isnull=True)
        if self.exp_template:
            # Path to experiment template from PropertyTemplate:
            # PropertyTemplate -> ReagentMaterialTemplate -> ReagentTemplate -> ExperimentTemplate
            self.fields[
                "reagent_parameters"
            ].queryset = vt.PropertyTemplate.objects.filter(
                reagent_material_template_p__reagent_template__experiment_template_rt=self.exp_template
            ).distinct()

    def clean(self):
        cleaned_data = super().clean()

        if self.is_valid():
            total_experiments = cleaned_data["manual"] + cleaned_data["automated"]
            outcome_vessel = cleaned_data["outcome_vessel"]

            if (capacity := outcome_vessel.children.count()) == 0:
                capacity = 1
            if capacity < total_experiments:
                message = f"Number of experiments requested ({total_experiments}) is higher than the outcome vessel's capacity ({capacity})."
                self.add_error(
                    "outcome_vessel", ValidationError(message, code="invalid")
                )

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
    experiment_name = CharField()
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


class BaseReagentFormSet(BaseFormSet):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def get_form_kwargs(self, index):
        kwargs = super().get_form_kwargs(index)
        kwargs["index"] = index

        return kwargs


class ReagentForm(Form):
    widget = Select(
        attrs={
            "class": "selectpicker",
            "data-style": "btn-outline",
            "data-live-search": "true",
        }
    )

    def generate_reagent_fields(self):
        for i, prop in enumerate(self.reagent_template.properties.all()):
            self.fields[f"reagent_template_uuid_{self.material_index}_{i}"] = CharField(
                widget=HiddenInput(), initial=prop.uuid
            )
            self.fields[f"reagent_prop_{self.material_index}_{i}"] = ValFormField(
                required=False, label=prop.description.capitalize()
            )

    def generate_reagent_material_fields(self, index, material_type):
        self.fields[f"material_{self.material_index}_{index}"] = ChoiceField(
            widget=self.widget, required=False
        )
        self.fields[
            f"desired_concentration_{self.material_index}_{index}"
        ] = ValFormField(required=False)
        self.fields[
            f"reagent_material_template_uuid_{self.material_index}_{index}"
        ] = CharField(widget=HiddenInput())
        self.fields[f"material_type_{self.material_index}_{index}"] = CharField(
            widget=HiddenInput(), initial=material_type
        )

        self.fields[f"material_{self.material_index}_{index}"].choices = [
            (im.uuid, im.description) for im in self.inventory_materials[material_type]
        ]
        self.fields[
            f"material_{self.material_index}_{index}"
        ].label = f"Material {self.material_index+1}: {material_type}"

    def __init__(self, *args, **kwargs):
        self.material_index = kwargs.pop("index")
        self.data = kwargs.pop("form_data")
        self.material_types: "list[str]" = self.data[str(self.material_index)][
            "mat_types_list"
        ]
        self.data_current = self.data[str(self.material_index)]
        lab_uuid = UUID(kwargs.pop("lab_uuid"))

        # material_type = material_types_list[material_index]
        self.inventory_materials: "dict[str, QuerySet]" = {}
        super().__init__(*args, **kwargs)

        self.reagent_template = self.data_current["reagent_template"]
        self.generate_reagent_fields()

        for i, material_type in enumerate(self.material_types):
            if material_type in self.inventory_materials:
                continue
            self.inventory_materials[
                material_type
            ] = vt.InventoryMaterial.objects.filter(
                material__material_type__description=material_type,
                inventory__lab__organization=lab_uuid,
            )
            self.generate_reagent_material_fields(i, material_type)
        self.get_helper()

    def get_helper(self):
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-3"
        helper.field_class = "col-lg-8"
        rows = []
        for i, material_type in enumerate(self.material_types):
            rows.append(
                Row(
                    Column(Field(f"material_{self.material_index}_{i}")),
                    Column(Field(f"desired_concentration_{self.material_index}_{i}")),
                    Field(f"reagent_material_template_uuid_{self.material_index}_{i}"),
                    Field(f"material_type_{self.material_index}_{i}"),
                ),
            )

        for i, prop in enumerate(self.reagent_template.properties.all()):
            rows.append(
                Row(
                    Column(Field(f"reagent_prop_{self.material_index}_{i}")),
                    Field(f"reagent_template_uuid_{self.material_index}_{i}"),
                )
            )
        helper.layout = Layout(*rows)
        helper.form_tag = False
        # return helper
        self.helper = helper


class VesselForm(Form):
    v_query = vt.Vessel.objects.all()
    value = ModelChoiceField(queryset=v_query, label="Select Vessel")
    value.widget = Select(attrs=dropdown_attrs)
    template_uuid = CharField(widget=HiddenInput())

    def __init__(self, *args, **kwargs):
        self.vessel_index = kwargs.pop("index")
        self.data = kwargs.pop("vt_names")
        colors = kwargs.pop("colors")
        self.data_current = {"color": colors[self.vessel_index]}
        vt_name = self.data[self.vessel_index]
        super().__init__(*args, **kwargs)
        self.fields["value"].queryset = vt.Vessel.objects.filter(parent__isnull=True)
        self.fields["value"].label = vt_name

        self.get_helper()

    def get_helper(self):
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-3"
        helper.field_class = "col-lg-8"
        helper.layout = Layout(Row(Column(Field(f"value")), Field("template_uuid")))
        # return helper
        helper.form_tag = False
        self.helper = helper


class ActionParameterForm(Form):
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
            self.generate_action_parameter_fields(i, param_uuid)

        self.get_helper()

    def get_helper(self):
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-3"
        helper.field_class = "col-lg-8"
        rows = []
        for i, param_uuid in enumerate(self.action_parameter_list):
            rows.append(
                Row(
                    Column(Field(f"value_{self.action_index}_{i}")),
                    Field(f"parameter_uuid_{self.action_index}_{i}"),
                ),
            )
        helper.layout = Layout(*rows)
        # return helper
        helper.form_tag = False
        self.helper = helper


class ReadOnlyText(HiddenInput):
    input_type = "hidden"

    def render(self, name, value, attrs=None, renderer=None):
        if value is None:
            value = ""
        return value


class ManualExperimentForm(Form):
    file = FileField(label="Upload completed file")

    def __init__(self, *args, **kwargs):
        self.vessels = kwargs.pop("vessels")
        self.experiment_template_form_data = kwargs.pop("experiment_template")
        super().__init__(*args, **kwargs)
        self.get_helper()

    def _validate_uploaded_file(self, cleaned_data):
        uploaded_file = cleaned_data["file"]
        if not uploaded_file.name.endswith(".xlsx"):
            message = f"Uploaded file is not an excel file"
            self.add_error("file", ValidationError(message, code="invalid"))
        try:
            df_dict = pd.read_excel(uploaded_file, sheet_name=None)

            experiment_template = ExperimentTemplate.objects.get(
                uuid=self.experiment_template_form_data["select_experiment_template"]
            )

            if "meta_data" not in df_dict:
                raise InvalidInput("Sheet named 'meta_data' not found")
            if experiment_template.description not in df_dict:
                raise InvalidInput(
                    f"Sheet named {experiment_template.description} not found"
                )
        except Exception as e:
            message = f"Uploaded file is invalid. Reason: {e}"
            self.add_error("file", ValidationError(message, code="invalid"))

    def clean(self):
        cleaned_data = super().clean()
        if self.is_valid():
            self._validate_uploaded_file(cleaned_data)
        return cleaned_data

    def get_helper(self):
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-2"
        helper.field_class = "col-lg-8"
        helper.layout = Layout(
            Row(Column(Field("file"))),
        )
        helper.form_tag = False
        self.helper = helper


class AutomatedSpecificationForm(Form):
    widget = Select(
        attrs={
            "class": "selectpicker",
            "data-style": "btn-outline",
            "data-live-search": "true",
        }
    )
    automated = IntegerField(
        label="Number of Automated Experiments",
        required=True,
        initial=0,
        min_value=0,
    )
    select_experiment_sampler = ChoiceField(widget=widget, required=False)

    def __init__(self, *args, **kwargs):
        form_kwargs = kwargs.pop("form_kwargs")
        self.vessel_form_data = form_kwargs["vessel_form_data"]
        self.outcome_vessels = []
        for vessel_data in self.vessel_form_data:
            vessel_data["template"] = vt.VesselTemplate.objects.get(
                uuid=vessel_data["template_uuid"]
            )
            if vessel_data["template"].outcome_vessel:
                self.outcome_vessels.append(vessel_data["value"])
        super().__init__(*args, **kwargs)
        self._populate_samplers()

    def _populate_samplers(self):
        self.fields["select_experiment_sampler"].choices = [
            (None, "No sampler selected")
        ] + [
            (sampler_plugin.__name__, sampler_plugin.name)
            for sampler_plugin in SamplerPlugin.__subclasses__()
        ]

    def clean(self):
        cleaned_data = super().clean()

        if self.is_valid():
            total_experiments = cleaned_data["automated"]
            for outcome_vessel in self.outcome_vessels:
                if (capacity := outcome_vessel.children.count()) == 0:
                    capacity = 1
                if capacity < total_experiments:
                    message = f"Number of experiments requested ({total_experiments}) is higher than the outcome vessel's capacity ({capacity}) of Vessel: {outcome_vessel.description}."
                    self.add_error(
                        "outcome_vessel", ValidationError(message, code="invalid")
                    )

        return cleaned_data