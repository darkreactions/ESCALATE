from typing import Tuple, Any
from django.forms import (
    BooleanField,
    MultipleChoiceField,
    Select,
    CheckboxSelectMultiple,
    Form,
    CharField,
    ChoiceField,
    IntegerField,
    SelectMultiple,
    ValidationError,
)
from core.models.core_tables import TypeDef
import core.models.view_tables as vt
from crispy_forms.helper import FormHelper
from crispy_forms.layout import Layout, Row, Column, Field


class ReagentTemplateCreateForm(Form):

    widget_mc = CheckboxSelectMultiple(
        attrs={
            "class": "selectpicker",
            "data-style": "btn-dark",
            "data-live-search": "true",
        }
    )

    reagent_template_name = CharField(required=True)

    num_materials = IntegerField(
        label="Number of Materials", required=True, initial=1, min_value=1
    )

    properties = MultipleChoiceField(
        widget=SelectMultiple(),
        required=False,
        label="Select Reagent-Level Properties",
    )

    properties_add = CharField(required = False, label= "If desired properties are not listed, enter names separated by commas")

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
        self.fields["properties"].choices = [
            (pt.description, pt.description) for pt in vt.PropertyTemplate.objects.all()
        ]

        self.get_helper()

    def get_helper(self):
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-4"
        helper.field_class = "col-lg-6"

        helper.layout = Layout(
            Row(Column(Field(f"reagent_template_name")), Field(f"num_materials")),
            Row(Column(Field(f"properties"))),
            Row(Column(Field(f"properties_add"))),
        )

        helper.form_tag = False
        self.helper = helper


class ReagentTemplateMaterialAddForm(Form):

    name = CharField(disabled=True, label="Reagent")

    properties = MultipleChoiceField(
        widget=SelectMultiple(),
        required=False,
        label="Select Material-Level Properties (applies to each material)",
    )

    properties_add = CharField(required = False, label= "If desired properties are not listed, enter names separated by commas")

    def generate_subforms(self, mat_index): #reagent_index):
        #self.fields[f"select_mt_{mat_index}_{reagent_index}"] = ChoiceField(
        self.fields[f"select_mt_{mat_index}"] = ChoiceField(
            widget=Select(),
            required=False,
            label=f"Select Material Type: Material {mat_index+1}",
        )
        self.fields[f"add_type_{mat_index}"] = CharField(required = False, label= "If desired material type is not listed, enter name")

        #self.fields[f"select_mt_{mat_index}_{reagent_index}"].choices = [
        none_option: "list[Tuple[Any, str]]" = [(None, "No material type selected")]
        
        mat_type: "list[Tuple[Any, str]]" = [
           (r.uuid, r.description) for r in vt.MaterialType.objects.all()
        ]
        #self.fields[f"select_mt_{mat_index}"].choices = [
           # (r.uuid, r.description) for r in vt.MaterialType.objects.all()
        #]
        self.fields[f"select_mt_{mat_index}"].choices = none_option + mat_type


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
        self.fields["properties"].choices = [
            (pt.description, pt.description) for pt in vt.PropertyTemplate.objects.all()
        ]
        num_materials = len(data[self.fields["name"].initial])
        for i in range(num_materials):
            self.generate_subforms(i) #self.index)

        self.get_helper(num_materials)

    def get_helper(self, num_materials):
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-5"
        helper.field_class = "col-lg-6"
        rows = []

        rows.append(Row(Field(f"name")))
        
        rows.append(Row(Column(Field(f"properties")), Column(Field(f"properties_add"))))

        #rows.append(Row(
         #       Column(Field(f"properties_add"))))
        

        for i in range(num_materials):

            #rows.append(Row(Column(Field(f"select_mt_{i}_{self.index}"))))
            rows.append(Row(Column(Field(f"select_mt_{i}"))))
            rows.append(Row(Column(Field(f"add_type_{i}"))))
                
        helper.layout = Layout(*rows)
        helper.form_tag = False

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
 
        helper.layout = Layout(Row(Column(Field(f"define_outcomes")), Column(Field(f"outcome_type"))))

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
