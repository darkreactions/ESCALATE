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
    FileInput,
)
from uuid import UUID
from django.db.models import QuerySet
from core.models.core_tables import TypeDef
import core.models.view_tables as vt
from core.models.view_tables import ReagentTemplate, Reagent
from core.widgets import ValFormField
from crispy_forms.helper import FormHelper
from crispy_forms.layout import Layout, Submit, Row, Column, Hidden, Field, HTML, Div
from crispy_forms.bootstrap import UneditableField
from crispy_forms.bootstrap import Tab, TabHolder


# from django.forms import formset_factory
dropdown_attrs = {
    "class": "selectpicker",
    "data-style": "btn-outline-primary",
    "data-live-search": "true",
}


class UploadFileForm(Form):
    # title = CharField(max_length=50)
    outcome_def_file = FileField(
        label="Upload outcome definition file",
        # widget=FileInput(attrs={"multiple": True}),
    )
    # mydropzone =

    # class Media:
    #    css = {"all": ("css/dropzone.css",)}
    #    js = ("js/dropzone.min.js",)

    @staticmethod
    def get_helper():
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-2"
        helper.field_class = "col-lg-8"
        helper.layout = Layout(
            Row(Column(Field("outcome_def_file"))),
            Row(
                Column(
                    Div("outcome_files", css_class="dropzone needsclick dz-clickable")
                )
            ),
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


class BaseIndexedFormSet(BaseFormSet):
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

    def generate_reagent_fields(self):
        for i, prop in enumerate(self.reagent.property_r.all()):
            prop: vt.Property
            self.fields[f"reagent_prop_uuid_{i}"] = CharField(
                widget=HiddenInput(), initial=prop.uuid
            )
            self.fields[f"reagent_prop_{i}"] = ValFormField(
                required=False,
                label=f"{prop.template.description.capitalize()} actual value",
            )
            self.fields[f"reagent_prop_nom_{i}"] = ValFormField(
                required=False,
                label=f"{prop.template.description.capitalize()} expected value",
            )

    def generate_reagent_material_fields(
        self,
        index: int,
        material_type: str,
        rm: vt.ReagentMaterial,
    ):
        # Select material
        self.fields[f"material_{index}"] = ChoiceField(
            widget=self.widget, required=False, label="Select Material"
        )
        # UUID of material template
        self.fields[f"reagent_material_template_uuid_{index}"] = CharField(
            widget=HiddenInput(), initial=rm.uuid
        )
        # UUID of material type
        self.fields[f"material_type_{index}"] = CharField(
            widget=HiddenInput(), initial=material_type
        )

        self.fields[f"material_{index}"].choices = [
            (rm.material.uuid, rm.material.description)
        ]

        # Loop through properties of the reagent material
        for prop_index, prop in enumerate(rm.property_rm.all()):
            prop: vt.Property
            self.fields[f"reagent_material_prop_{index}_{prop_index}"] = ValFormField(
                required=False, label=f"{prop.template.description.capitalize()} actual"
            )
            self.fields[
                f"reagent_material_prop_nom_{index}_{prop_index}"
            ] = ValFormField(
                required=False,
                label=f"{prop.template.description.capitalize()} nominal",
            )

            self.fields[f"reagent_material_prop_uuid_{index}_{prop_index}"] = CharField(
                widget=HiddenInput(), initial=prop.uuid
            )

    def __init__(self, *args, **kwargs):
        self.material_index = str(kwargs.pop("index"))
        if "form_kwargs" in kwargs:
            self.form_kwargs = kwargs.pop("form_kwargs")

        self.experiment_template = self.form_kwargs["experiment_instance"]
        self.form_data = self.form_kwargs["form_data"]
        lab_uuid = UUID(self.form_kwargs["lab_uuid"])
        self.inventory_materials: "dict[str, QuerySet[vt.InventoryMaterial]]" = {}
        super().__init__(*args, **kwargs)
        if (self.material_index is not None) and (
            self.material_index in self.form_data
        ):
            self.material_types: "list[str]" = self.form_data[str(self.material_index)][
                "mat_types_list"
            ]
            self.data_current = self.form_data[str(self.material_index)]
            self.reagent: Reagent = self.data_current["reagent_template"]
            self.generate_reagent_fields()
            self.fields[f"reagent_uuid"] = CharField(
                widget=HiddenInput(), initial=self.reagent.uuid
            )
            for i, rm in enumerate(
                self.reagent.reagent_material_r.all().order_by(
                    "template__material_type__description"
                )
            ):
                material_type = rm.template.material_type.description
                if material_type not in self.inventory_materials:
                    self.inventory_materials[
                        material_type
                    ] = vt.InventoryMaterial.objects.filter(
                        material__material_type__description=material_type,
                        inventory__lab__organization=lab_uuid,
                    )
                self.generate_reagent_material_fields(i, material_type, rm)
        self.get_helper()

    def get_helper(self):
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-3"
        helper.field_class = "col-lg-8"
        rows = [Row(Field("reagent_uuid"))]
        tabs = []
        for i, prop in enumerate(self.reagent.property_r.all()):
            rows.append(
                Row(
                    Column(UneditableField(f"reagent_prop_nom_{i}")),
                    Column(Field(f"reagent_prop_{i}")),
                    Field(f"reagent_prop_uuid_{i}"),
                    HTML("</br>"),
                )
            )

        if self.material_index is not None and (self.material_index in self.form_data):
            for i, rmt in enumerate(
                self.reagent.template.reagent_material_template_rt.all().order_by(
                    "material_type__description"
                )
            ):
                rmt: vt.ReagentMaterialTemplate
                material_type: str = rmt.material_type.description
                tabs.append(
                    Tab(
                        f"Material {i+1}: {material_type.capitalize()}",  # - {i}_{self.material_index}",
                        Column(UneditableField(f"material_{i}")),
                        *[
                            Row(
                                Column(
                                    UneditableField(
                                        f"reagent_material_prop_nom_{i}_{j}"
                                    ),
                                    Field(f"reagent_material_prop_uuid_{i}_{j}"),
                                ),
                                Column(Field(f"reagent_material_prop_{i}_{j}")),
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