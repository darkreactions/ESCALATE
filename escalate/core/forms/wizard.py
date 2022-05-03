from typing import Tuple, Any
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
from crispy_forms.layout import Layout, Submit, Row, Column, Hidden, Field, HTML
from crispy_forms.bootstrap import Tab, TabHolder
import pandas as pd

import core.models.view_tables as vt
from core.models.view_tables import ReagentTemplate, VesselTemplate, PropertyTemplate
from core.widgets import ValFormField
from core.models.view_tables.workflow import ExperimentTemplate
from core.widgets import ValWidget, TextInput
from .forms import dropdown_attrs
from plugins.sampler.base_sampler_plugin import BaseSamplerPlugin
from plugins.postprocessing.base_post_processing_plugin import PostProcessPlugin
from core.dataclass import METADATA


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
            prop: PropertyTemplate
            self.fields[f"reagent_prop_uuid_{i}"] = CharField(
                widget=HiddenInput(), initial=prop.uuid
            )
            self.fields[f"reagent_prop_{i}"] = ValFormField(
                required=False, label=prop.description.capitalize()
            )

    def generate_reagent_material_fields(
        self,
        index: int,
        material_type: str,
        rmt: vt.ReagentMaterialTemplate,
    ):
        # Select material
        self.fields[f"material_{index}"] = ChoiceField(
            widget=self.widget, required=True, label="Select Material"
        )
        # UUID of material template
        self.fields[f"reagent_material_template_uuid_{index}"] = CharField(
            widget=HiddenInput(), initial=rmt.uuid
        )
        # UUID of material type
        self.fields[f"material_type_{index}"] = CharField(
            widget=HiddenInput(), initial=material_type
        )

        # Loop through properties of the reagent material
        for prop_index, prop in enumerate(rmt.properties.all()):
            prop: vt.PropertyTemplate
            self.fields[f"reagent_material_prop_{index}_{prop_index}"] = ValFormField(
                required=False, label=prop.description.capitalize()
            )

            self.fields[f"reagent_material_prop_uuid_{index}_{prop_index}"] = CharField(
                widget=HiddenInput(), initial=prop.uuid
            )
        self.fields[f"material_{index}"].choices = [
            (im.uuid, im.description) for im in self.inventory_materials[material_type]
        ]
        # self.fields[
        #    f"material_{index}"
        # ].label = f"Reagent {int(self.material_index)+1}: {material_type}"

    def __init__(self, *args, **kwargs):
        self.material_index = str(kwargs.pop("index"))
        self.experiment_template = kwargs.pop("experiment_template")
        self.form_data = kwargs.pop("form_data")
        lab_uuid = UUID(kwargs.pop("lab_uuid"))
        self.inventory_materials: "dict[str, QuerySet[vt.InventoryMaterial]]" = {}
        super().__init__(*args, **kwargs)
        if (self.material_index is not None) and (
            self.material_index in self.form_data
        ):
            self.material_types: "list[str]" = self.form_data[str(self.material_index)][
                "mat_types_list"
            ]
            self.data_current = self.form_data[str(self.material_index)]
            self.reagent_template: ReagentTemplate = self.data_current[
                "reagent_template"
            ]
            self.generate_reagent_fields()
            self.fields[f"reagent_template_uuid"] = CharField(
                widget=HiddenInput(), initial=self.reagent_template.uuid
            )
            for i, rmt in enumerate(
                self.reagent_template.reagent_material_template_rt.all().order_by(
                    "material_type__description"
                )
            ):
                material_type = rmt.material_type.description
                if material_type not in self.inventory_materials:
                    self.inventory_materials[
                        material_type
                    ] = vt.InventoryMaterial.objects.filter(
                        material__material_type__description=material_type,
                        inventory__lab__organization=lab_uuid,
                    )
                self.generate_reagent_material_fields(i, material_type, rmt)
        self.get_helper()

    def get_helper(self):
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-3"
        helper.field_class = "col-lg-8"
        rows = [Row(Field("reagent_template_uuid"))]
        tabs = []
        for i, prop in enumerate(self.reagent_template.properties.all()):
            rows.append(
                Row(
                    Column(Field(f"reagent_prop_{i}")),
                    Field(f"reagent_prop_uuid_{i}"),
                    HTML("</br>"),
                )
            )

        if self.material_index is not None and (self.material_index in self.form_data):
            for i, rmt in enumerate(
                self.reagent_template.reagent_material_template_rt.all().order_by(
                    "material_type__description"
                )
            ):
                rmt: vt.ReagentMaterialTemplate
                material_type: str = rmt.material_type.description
                tabs.append(
                    Tab(
                        f"Material {i+1}: {material_type.capitalize()}",  # - {i}_{self.material_index}",
                        Column(Field(f"material_{i}")),
                        *[
                            Column(
                                Field(f"reagent_material_prop_{i}_{j}"),
                                Field(f"reagent_material_prop_uuid_{i}_{j}"),
                            )
                            for j, prop in enumerate(rmt.properties.all())
                        ],
                        Field(f"reagent_material_template_uuid_{i}"),
                        Field(f"material_type_{i}"),
                        css_id=f"reagent-{self.material_index}-material-{i}",
                    ),
                )
            rows.append(TabHolder(*tabs))  # type: ignore

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

        data = kwargs.pop("vt_names")
        colors = kwargs.pop("colors")
        vessel_index = kwargs.pop("index")
        super().__init__(*args, **kwargs)
        if vessel_index is not None:
            self.vessel_index = vessel_index
            self.data_current = {"color": colors[self.vessel_index]}
            vt_name = data[self.vessel_index]
            self.fields["value"].queryset = vt.Vessel.objects.filter(
                parent__isnull=True
            )
            self.fields["value"].label = vt_name
            self.get_helper()

    def get_helper(self, error_message=None):
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-3"
        helper.field_class = "col-lg-8"
        if error_message is None:
            helper.layout = Layout(Row(Column(Field(f"value")), Field("template_uuid")))
        else:
            helper.layout = Layout(HTML(f"<h2>{error_message}</h2>"))

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
        self.form_data = kwargs.pop("form_data")
        super().__init__(*args, **kwargs)
        if self.form_data:
            self.action_parameter_list: "list[str]" = self.form_data[
                str(self.action_index)
            ]["action_parameter_list"]
            self.data_current = self.form_data[str(self.action_index)]
            self.fields["action_template_uuid"] = CharField(
                widget=HiddenInput(), initial=self.data_current["action_template_uuid"]
            )
            for i, param_uuid in enumerate(self.action_parameter_list):
                self.generate_action_parameter_fields(i, param_uuid)

        self.get_helper()

    def get_helper(self):
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-3"
        helper.field_class = "col-lg-8"
        rows = [Row(Field("action_template_uuid"))]
        if self.form_data:
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
    file = FileField(label="Upload completed file", required=False)

    def __init__(self, *args, **kwargs):
        self.vessels = kwargs.pop("vessels")
        self.experiment_template_form_data = kwargs.pop("experiment_template")
        super().__init__(*args, **kwargs)
        self.get_helper()

    def _validate_uploaded_file(self, cleaned_data):
        uploaded_file = cleaned_data["file"]
        if uploaded_file:
            if not uploaded_file.name.endswith(".xlsx"):
                message = f"Uploaded file is not an excel file"
                self.add_error("file", ValidationError(message, code="invalid"))
            try:
                df_dict = pd.read_excel(uploaded_file, sheet_name=None)

                experiment_template = ExperimentTemplate.objects.get(
                    uuid=self.experiment_template_form_data[
                        "select_experiment_template"
                    ]
                )

                if METADATA not in df_dict:
                    raise Exception(f"Sheet named '{METADATA}' not found")
                if experiment_template.description not in df_dict:
                    raise Exception(
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
            vessel_data["template"] = VesselTemplate.objects.get(
                uuid=vessel_data["template_uuid"]
            )
            if vessel_data["template"].outcome_vessel:
                self.outcome_vessels.append(vessel_data["value"])
        super().__init__(*args, **kwargs)
        self._populate_samplers()

    def _populate_samplers(self):
        none_option: "list[Tuple[Any, str]]" = [(None, "No sampler selected")]
        samplers: "list[Tuple[Any, str]]" = [
            (sampler_plugin.__name__, sampler_plugin.name)
            for sampler_plugin in BaseSamplerPlugin.__subclasses__()
        ]
        self.fields["select_experiment_sampler"].choices = none_option + samplers

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


class PostProcessForm(Form):
    widget = Select(
        attrs={
            "class": "selectpicker",
            "data-style": "btn-outline",
            "data-live-search": "true",
        }
    )

    def __init__(self, *args, **kwargs):
        index = kwargs.pop("index")
        experiment_template = kwargs.pop("experiment_template")
        super().__init__(*args, **kwargs)
        self._populate_post_processors()
        self.get_helper()

    def get_helper(self):
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-3"
        helper.field_class = "col-lg-8"
        rows = []
        # for i, param_uuid in enumerate(self.action_parameter_list):
        rows.append(
            Column(Field(f"select_post_processor")),
        )
        helper.layout = Layout(*rows)
        # helper.add_input(
        #    Submit("add_post_processor", "Add Post Processor", css_class="btn-primary")
        # )
        # return helper
        helper.form_tag = False
        self.helper = helper

    def _populate_post_processors(self):
        self.fields["select_post_processor"] = ChoiceField(
            widget=self.widget, required=False
        )
        none_option: "list[Tuple[Any, str]]" = [(None, "No preprocessor selected")]
        self.fields["select_post_processor"].choices = none_option + [
            (post_processor_plugin.__name__, post_processor_plugin.name)
            for post_processor_plugin in PostProcessPlugin.__subclasses__()
        ]
