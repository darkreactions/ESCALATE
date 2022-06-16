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
        helper.layout = Layout(
            Row(Column(Field("file"))),
        )
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
        # self.fields['select_rt'].choices = [(r.uuid, r.description) for r in vt.ReagentTemplate.objects.all()]

        # v_query = vt.Vessel.objects.all()
        # vessel = VesselForm(initial={'value': v_query[0]})
        # self.fields['select_vessel'].choices = [v for v in vessel]
        # self.fields['select_vessel'].choices = [(r.uuid, r.description) for r in vt.Vessel.objects.all()]
        # self.fields['select_materials'].choices = [(r.uuid, r.description) for r in vt.InventoryMaterial.objects.all()]


# ReagentCreateFormSet = formset_factory(ReagentTemplateCreateForm)


class ExperimentNameForm(Form):
    exp_name = CharField(label="Experiment Name", max_length=100)


class ExperimentTemplateNameForm(Form):
    exp_template_name = CharField(
        label="Experiment Template Name", max_length=100, required=True
    )


class ReagentSelectionForm(Form):
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
            (r.uuid, r.description) for r in ReagentTemplate.objects.all()
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
        ]


class OutcomeDefinitionForm(Form):

    # well_num = IntegerField(label="Number of Experiments", required=True, initial=96)
    # define_outcomes=ValFormField(label="Outcome", required=False)

    widget = Select(
        attrs={
            "class": "selectpicker",
            "data-style": "btn-dark",
            "data-live-search": "true",
            "id": "template",
        }
    )

    define_outcomes = CharField(label="Outcome", required=False, initial=None)
    outcome_type = ChoiceField(widget=widget)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
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

    # template_name = CharField(label="Experiment Template Name", required=True)

    num_reagents = IntegerField(label="Number of Reagents", required=True, initial=1)

    num_outcomes = IntegerField(
        label="Number of outcomes to measure", required=True, initial=1
    )

    def __init__(self, *args, **kwargs):
        org_id = kwargs.pop("org_id")
        lab = vt.Actor.objects.get(organization=org_id, person__isnull=True)
        super().__init__(*args, **kwargs)


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
            Row(
                Column(Field("chemical")),
                Column(Field("desired_concentration")),
            ),
            Field("reagent_template_uuid"),
            Field("material_type"),
        )
        return helper


'''class ReagentValueForm(Form):
    material_type = CharField(required=False)
    material = CharField(required=False)
    #nominal_value = ValFormField(required=False)
    #actual_value = ValFormField()
    uuid = CharField(widget=HiddenInput())

    def generate_valfields(self, property_index, data):
        for key, val in data["nominal_value"][property_index].items():
            description=key
            value=val
        self.fields[f"nominal_value_{property_index}"] = ValFormField(
            required=False, 
            label=description,
            initial=value,
            disabled=True)
        for key, val in data["actual_value"][property_index].items():
            description=key
            value=val
        self.fields[f"actual_value_{property_index}"] = ValFormField(
            label=description,
            initial=value,
        )

        self.fields[f"uuid_{property_index}"]= CharField(widget=HiddenInput(),
            initial=data["uuid"][property_index])

    def __init__(self, *args, **kwargs):
        disabled_fields = kwargs.pop("disabled_fields", [])
        chemical_index = kwargs.pop("index")
        super().__init__(*args, **kwargs)
        prop_count=len(kwargs["initial"]["nominal_value"])
        for i in range(prop_count):
            self.generate_valfields(i, kwargs["initial"])
        for field in disabled_fields:
            self.fields[field].disabled = True

        
        try:
            disabled_fields = kwargs.pop("disabled_fields", [])
            chemical_index = kwargs.pop("index")
        except KeyError:
            pass
        super().__init__(*args, **kwargs)
        try:
            prop_count=len(kwargs["initial"]["nominal_value"])
            for i in range(prop_count):
                self.generate_valfields(i, kwargs["initial"])
            for field in disabled_fields:
                self.fields[field].disabled = True
            #self.get_helper(prop_count)
        except KeyError:
            pass

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
            #Row("uuid"),
        #)
        return helper'''

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
                required=False, label=f"Desired {prop.description.capitalize()}", initial=prop.value
            )
            self.fields[f"actual_reagent_prop_{i}"] = ValFormField(
                required=False, label=f"Measured {prop.description.capitalize()}"
            )

    def generate_rmvi_fields(
        self,
        index: int,
        #material_type: str,
        rmi: vt.ReagentMaterial,
    ):
        # Material type
        self.fields[f"material_type_{index}"] = CharField(
            widget=self.widget, required=True, disabled= True, label="Material Type", initial=rmi.template.material_type,
        )
        # Material 
        self.fields[f"material_{index}"] = CharField(
            widget=self.widget, required=True, disabled= True, label="Material", initial=rmi.material,
        )
        # UUID of material 
        self.fields[f"reagent_material_uuid_{index}"] = CharField(
            widget=HiddenInput(), initial=rmi.uuid
        )

        # Loop through properties of the reagent material
        for prop_index, prop in enumerate(rmi.property_rm.all()):
            prop: vt.Property
            self.fields[f"nominal_reagent_material_prop_{index}_{prop_index}"] = ValFormField(
                required=False, label=f"Desired {prop.description.capitalize()}", initial = prop.value
            )

            self.fields[f"actual_reagent_material_prop_{index}_{prop_index}"] = ValFormField(
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
        #lab_uuid = UUID(kwargs.pop("lab_uuid"))
        #self.inventory_materials: "dict[str, QuerySet[vt.InventoryMaterial]]" = {}
        super().__init__(*args, **kwargs)
        self.generate_reagent_property_fields()
        
        '''if (self.material_index is not None) and (
            self.material_index in self.form_data
        ):
            self.material_types: "list[str]" = self.form_data[str(self.material_index)][
                "mat_types_list"
            ]
            self.data_current = self.form_data[str(self.material_index)]
            self.reagent_template: ReagentTemplate = self.data_current[
                "reagent_template"
            ]
            self.generate_reagent_property_fields()
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
                self.generate_rmvi_fields(i, rmt)'''
        #self.get_helper()
    
    @staticmethod
    def get_helper():
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-3"
        helper.field_class = "col-lg-8"
        '''rows = [Row(Field("reagent_template_uuid"))]
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

        helper.layout = Layout(*rows)'''
        helper.form_tag = False
        return helper


'''class PropertyForm(ModelForm):
    
    def __init__(self, *args, **kwargs):
        nominal_value_label = "Nominal Value"
        value_label = "Value"
        uuid = ' '
        try:
            if "nominal_value_label" in kwargs["initial"]:
                nominal_value_label = kwargs["initial"]["nominal_value_label"]#kwargs.pop("initial"["nominal_value_label"])
                nominal_value = kwargs["initial"]["instance"].value
            if "value_label" in kwargs["initial"]:
                value_label = kwargs["initial"]["value_label"]#kwargs.pop("value_label")
            if "instance" in kwargs["initial"]:
                uuid = kwargs["initial"]["instance"].uuid
            
            disabled_fields = kwargs.pop("disabled_fields", [])
            index = kwargs.pop("index")
        except KeyError:
            pass
        
        super().__init__(*args, **kwargs)

        self.fields["nominal_value"].label = nominal_value_label
        self.fields["value"].label = value_label
        self.fields["uuid"].initial = uuid

        try:
            self.fields["nominal_value"].initial = nominal_value
            for field in disabled_fields:
                self.fields[field].disabled = True
        except UnboundLocalError:
            pass
        

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
        widgets = {"nominal_value": ValWidget(), "value": ValWidget()}'''
