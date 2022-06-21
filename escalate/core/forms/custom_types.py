from core.widgets import ValWidget, TextInput
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
)
from core.models.core_tables import TypeDef
import core.models.view_tables as vt
from core.models.view_tables import ReagentTemplate
from core.widgets import ValFormField
from crispy_forms.helper import FormHelper
from crispy_forms.layout import Layout, Submit, Row, Column, Hidden, Field
from crispy_forms.bootstrap import Tab, TabHolder


# from django.forms import formset_factory
dropdown_attrs = {
    "class": "selectpicker",
    "data-style": "btn-outline-primary",
    "data-live-search": "true",
}


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


class NominalActualForm(Form):
    value = ValFormField(required=False)
    actual_value = ValFormField(required=False)
    uuid = CharField(widget=HiddenInput)


class ReagentTemplateCreateForm(Form):
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

    reagent_template_name = CharField(label="Reagent Name", required=True)

    select_mt = MultipleChoiceField(
        widget=SelectMultiple(),
        required=True,
        label="Select Material Types",
    )

    def __init__(self, *args, **kwargs):
        # org_id = kwargs.pop("org_id")
        # lab = vt.Actor.objects.get(organization=org_id, person__isnull=True)
        super().__init__(*args, **kwargs)
        self.fields["select_mt"].choices = [
            (r.uuid, r.description) for r in vt.MaterialType.objects.all()
        ]


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


class BaseReagentFormSet(BaseFormSet):
    def get_form_kwargs(self, index):
        kwargs = super().get_form_kwargs(index)
        kwargs["index"] = index
        return kwargs


class OutcomeForm(ModelForm):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if self.instance:
            self.fields[
                "actual_value"
            ].label = f"Outcome of: {self.instance.description}"
        # self.fields["file"].required = False

    @staticmethod
    def get_helper():
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-3"
        helper.field_class = "col-lg-8"
        helper.layout = Layout(
            Row(
                Column(Field("actual_value")),
                Row(Field("file")),
            ),
        )
        return helper

    class Meta:
        model = vt.Outcome
        fields = ["actual_value"]


class ReagentRMVIForm(Form):
    widget = Select(
        attrs={
            "class": "selectpicker",
            "data-style": "btn-outline",
            "data-live-search": "true",
        }
    )

    def generate_reagent_property_fields(self):
        for i, prop in enumerate(self.reagent_template.properties.all()):
            prop: vt.Property
            self.fields[f"reagent_prop_uuid_{i}"] = CharField(
                widget=HiddenInput(), initial=prop.uuid
            )
            self.fields[f"nominal_reagent_prop_{i}"] = ValFormField(
                required=False,
                label=f"Desired {prop.description.capitalize()}",
                initial=prop.value,
            )
            self.fields[f"actual_reagent_prop_{i}"] = ValFormField(
                required=False, label=f"Measured {prop.description.capitalize()}"
            )

    def generate_rmvi_fields(
        self,
        index: int,
        # material_type: str,
        rmi: vt.ReagentMaterial,
    ):
        # Material type
        self.fields[f"material_type_{index}"] = CharField(
            widget=self.widget,
            required=True,
            disabled=True,
            label="Material Type",
            initial=rmi.template.material_type,
        )
        # Material
        self.fields[f"material_{index}"] = CharField(
            widget=self.widget,
            required=True,
            disabled=True,
            label="Material",
            initial=rmi.material,
        )
        # UUID of material
        self.fields[f"reagent_material_uuid_{index}"] = CharField(
            widget=HiddenInput(), initial=rmi.uuid
        )

        # Loop through properties of the reagent material
        for prop_index, prop in enumerate(rmi.property_rm.all()):
            prop: vt.Property
            self.fields[
                f"nominal_reagent_material_prop_{index}_{prop_index}"
            ] = ValFormField(
                required=False,
                label=f"Desired {prop.description.capitalize()}",
                initial=prop.value,
            )

            self.fields[
                f"actual_reagent_material_prop_{index}_{prop_index}"
            ] = ValFormField(
                required=False, label=f"Measured {prop.description.capitalize()}"
            )

            self.fields[f"reagent_material_prop_uuid_{index}_{prop_index}"] = CharField(
                widget=HiddenInput(), initial=prop.uuid
            )

        # self.fields[
        #    f"material_{index}"
        # ].label = f"Reagent {int(self.material_index)+1}: {material_type}"

    def __init__(self, *args, **kwargs):
        self.index = str(kwargs.pop("index"))
        self.form_data = kwargs.pop("form_data")
        # lab_uuid = UUID(kwargs.pop("lab_uuid"))
        # self.inventory_materials: "dict[str, QuerySet[vt.InventoryMaterial]]" = {}
        super().__init__(*args, **kwargs)
        self.generate_reagent_property_fields()

    @staticmethod
    def get_helper():
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-3"
        helper.field_class = "col-lg-8"
        helper.form_tag = False
        return helper
