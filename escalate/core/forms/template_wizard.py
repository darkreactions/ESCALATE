from django.forms import (
    Select,
    CheckboxSelectMultiple,
    Form,
    CharField,
    ChoiceField,
    IntegerField,
    ValidationError,
)
from core.models.core_tables import TypeDef
import core.models.view_tables as vt
from crispy_forms.helper import FormHelper
from crispy_forms.layout import Layout, Row, Field


class ReagentTemplateCreateForm(Form):

    reagent_template_name = CharField(required=True)

    num_materials = IntegerField(
        label="Number of Materials", required=True, initial=1, min_value=1
    )

    def __init__(self, *args, **kwargs):
        try:
            self.reagent_index = kwargs.pop("index")

            colors = kwargs.pop("colors")
            self.data_current = {"color": colors[self.reagent_index]}
        except KeyError:
            self.reagent_index = 0
        super().__init__(*args, **kwargs)
        self.fields[
            "reagent_template_name"
        ].label = f"Reagent {str(int(self.reagent_index)+1)} Name"

        self.get_helper()

    def get_helper(self):
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-8"
        helper.field_class = "col-lg-8"

        helper.layout = Layout(
            Row((Field(f"reagent_template_name")), Field(f"num_materials")),
        )

        helper.form_tag = False
        self.helper = helper


class ReagentTemplateMaterialAddForm(Form):

    name = CharField(disabled=True, label="Reagent")

    def generate_subforms(self, i):
        self.fields[f"select_mt_{i}"] = ChoiceField(
            widget=Select(),
            required=True,
            label="Select Material Type",
        )

        self.fields[f"select_mt_{i}"].choices = [
            (r.uuid, r.description) for r in vt.MaterialType.objects.all()
        ]

    def __init__(self, *args, **kwargs):
        try:
            self.index = kwargs.pop("index")
            colors = kwargs.pop("colors")
            self.data_current = {"color": colors[self.index]}
        except KeyError:
            self.index = 0

        data = kwargs.pop("initial")

        super().__init__(*args, **kwargs)

        self.fields["name"].initial = list(data.keys())[0]
        for i in range(len(data[self.fields["name"].initial])):
            self.generate_subforms(i)

        self.get_helper()

    def get_helper(self):
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-8"
        helper.field_class = "col-lg-8"

        """helper.layout = Layout(
            # Row((Field(f"name")),),
            Row(Field(f"name")), 
            Row(Field(f'select_mt_{i}',),))
        #)"""
        helper.form_tag = False
        # return helper
        self.helper = helper


class ExperimentTemplateNameForm(Form):
    exp_template_name = CharField(
        label="Experiment Template Name", max_length=100, required=True
    )


class OutcomeDefinitionForm(Form):

    define_outcomes = CharField(label="Outcome", required=False, initial=None)
    outcome_type = ChoiceField(widget=Select())

    def __init__(self, *args, **kwargs):
        try:
            self.outcome_index = kwargs.pop("index")
            colors = kwargs.pop("colors")
            self.data_current = {"color": colors[self.outcome_index]}
        except KeyError:
            self.outcome_index = 0

        super().__init__(*args, **kwargs)
        self.fields[
            "define_outcomes"
        ].label = f"Outcome {str(int(self.outcome_index)+1)}"

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

        helper.layout = Layout(
            Row((Field(f"define_outcomes")), Field(f"outcome_type")),
        )

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
        label="Number of outcomes to measure", required=True, initial=1, min_value=0
    )

    def __init__(self, *args, **kwargs):
        org_id = kwargs.pop("org_id")
        lab = vt.Actor.objects.get(organization=org_id, person__isnull=True)
        super().__init__(*args, **kwargs)

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

        return cleaned_data