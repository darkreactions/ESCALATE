# from core.models import (Actor, Material, Inventory,
#                         Person, Organization, Note)

# from escalate.core.models.view_tables.workflow import Workflow, WorkflowStep, BillOfMaterials
from django.db.models.fields import related
from django.core.exceptions import ObjectDoesNotExist
from rest_framework import serializers
from core.models.view_tables import Edocument, Note
from core.models.core_tables import TypeDef
from rest_framework.serializers import (
    SerializerMethodField,
    ModelSerializer,
    HyperlinkedModelSerializer,
    FileField,
    CharField,
    URLField,
    ListSerializer,
    HyperlinkedRelatedField,
    PrimaryKeyRelatedField,
    Serializer,
)
import rest_framework.serializers
from rest_framework.reverse import reverse
from rest_flex_fields import FlexFieldsModelSerializer


from rest_api.endpoint_details import details

# import core.models
from core.models import *
from core.models.view_tables import *
from .utils import (
    rest_serializer_views,
    expandable_fields,
    excluded_fields,
    get_object_from_url,
)
from core.models.custom_types import Val, ValField
from core.validators import ValValidator
from django.core.exceptions import ValidationError
import json


class ValSerializerField(rest_framework.serializers.JSONField):
    def __init__(self, **kwargs):
        self.validators.append(ValValidator())
        super().__init__(**kwargs)

    def to_representation(self, value):
        return value.to_dict()

    def to_internal_value(self, data):
        # print(f"DATA!!: {data} : {type(data)}")
        if data == '"null"':
            data = "null"
        if not isinstance(data, dict):
            data = json.loads(data)
        return Val.from_dict(data)


class DynamicFieldsModelSerializer(
    FlexFieldsModelSerializer, HyperlinkedModelSerializer
):
    """
    A ModelSerializer that takes an additional `fields` and 'omit' arguments that
    controls which fields should be displayed.
    """

    uuid = serializers.UUIDField(read_only=True)

    def __init__(self, *args, **kwargs):
        self.serializer_field_mapping[ValField] = ValSerializerField
        # Don't pass the 'view_name' arg up to the superclass
        if "view_name" in kwargs:
            kwargs.pop("view_name")
        super(DynamicFieldsModelSerializer, self).__init__(*args, **kwargs)


class TagAssignSerializer(DynamicFieldsModelSerializer):
    tag_label = CharField(source="tag.display_text", read_only=True)

    class Meta:
        model = TagAssign
        fields = "__all__"
        read_only_fields = ["ref_tag"]


class TagListSerializer(DynamicFieldsModelSerializer):
    tags = SerializerMethodField()

    def get_tags(self, obj):
        tags = TagAssign.objects.filter(ref_tag=obj.uuid)
        result_serializer = TagAssignSerializer(tags, many=True, context=self.context)
        return result_serializer.data


class NoteSerializer(DynamicFieldsModelSerializer):
    class Meta:
        model = Note
        fields = "__all__"
        read_only_fields = ["ref_note_uuid"]


class NoteListSerializer(DynamicFieldsModelSerializer):
    notes = SerializerMethodField()

    def get_notes(self, obj):
        # notes = Note.objects.filter(note_x_note__ref_note=obj.uuid)
        notes = Note.objects.filter(ref_note_uuid=obj.uuid)
        result_serializer = NoteSerializer(notes, many=True, context=self.context)
        return result_serializer.data


class PropertySerializer(DynamicFieldsModelSerializer):
    class Meta:
        model = Property
        fields = "__all__"
        # read_only_fields = ['property_ref']
        read_only_fields = ["material"]


class PropertyListSerializer(DynamicFieldsModelSerializer):
    property = SerializerMethodField()

    def get_property(self, obj):
        property = Property.objects.filter(material=obj.uuid)
        result_serializer = PropertySerializer(
            property, many=True, context=self.context
        )
        return result_serializer.data


class ParameterSerializer(DynamicFieldsModelSerializer):
    class Meta:
        model = Parameter
        fields = "__all__"
        read_only_fields = ["action"]


class ParameterListSerializer(DynamicFieldsModelSerializer):
    parameter = SerializerMethodField()

    def get_parameter(self, obj):
        parameter = Parameter.objects.filter(action_unit=obj.uuid)
        result_serializer = ParameterSerializer(
            parameter, many=True, context=self.context
        )
        return result_serializer.data


class MeasureSerializer(DynamicFieldsModelSerializer):
    class Meta:
        model = Measure
        fields = "__all__"
        read_only_fields = ["ref_measure_uuid"]


class MeasureListSerializer(DynamicFieldsModelSerializer):
    measures = SerializerMethodField()

    def get_measures(self, obj):
        measures = Measure.objects.filter(measure_x_measure__ref_measure=obj.uuid)
        result_serializer = MeasureSerializer(measures, many=True, context=self.context)
        return result_serializer.data


class EdocumentSerializer(
    TagListSerializer, NoteListSerializer, DynamicFieldsModelSerializer
):
    download_link = SerializerMethodField()
    edocument = FileField(write_only=True)

    def get_download_link(self, obj):
        result = "{}".format(
            reverse("edoc_download", args=[obj.uuid], request=self.context["request"])
        )
        return result

    def validate_edoc_type(self, value):
        try:
            doc_type = TypeDef.objects.get(category="file", description=value)
        except TypeDef.DoesNotExist:
            val_types = TypeDef.objects.filter(category="file")
            options = [val.description for val in val_types]
            raise ValidationError(
                f'File type {value} does not exist. Options are: {", ".join(options)}',
                code="invalid",
            )
        return value

    def create(self, validated_data):
        validated_data["filename"] = validated_data["edocument"].name
        validated_data["edocument"] = validated_data["edocument"].read()
        doc_type = TypeDef.objects.get(
            category="file", description=validated_data["edoc_type"]
        )
        validated_data["edoc_type_uuid"] = doc_type
        edoc = Edocument(**validated_data)
        edoc.save()
        return edoc

    class Meta:
        model = Edocument
        fields = (
            "url",
            "title",
            "description",
            "filename",
            "source",
            "edoc_type",
            "download_link",
            "actor",
            "tags",
            "notes",
            "edocument",
            "ref_edocument_uuid",
        )
        read_only_fields = ["ref_edocument_uuid", "filename"]


class EdocListSerializer(DynamicFieldsModelSerializer):
    edocs = SerializerMethodField()

    def get_edocs(self, obj):
        edocs = Edocument.objects.filter(ref_edocument_uuid=obj.uuid)
        result_serializer = EdocumentSerializer(edocs, many=True, context=self.context)
        return result_serializer.data


# Create serializers with non-expandable fields

for model_name in rest_serializer_views:
    model = globals()[model_name]
    meta_class_params = {
        "model": model,
    }
    # Remove excluded fields from the model
    current_excluded_fields = set(excluded_fields).intersection(
        set(model._meta.get_fields())
    )
    if current_excluded_fields:
        meta_class_params["exclude"] = list(current_excluded_fields)
    else:
        meta_class_params["fields"] = "__all__"

    meta_class = type(
        "Meta",
        (),
        meta_class_params,
    )
    base_serializers = [
        EdocListSerializer,
        TagListSerializer,
        NoteListSerializer,
        DynamicFieldsModelSerializer,
    ]
    if model_name == "Material" or model_name == "Mixture":
        base_serializers.insert(3, PropertyListSerializer)
    if model_name == "ActionUnit":
        base_serializers.insert(3, ParameterListSerializer)
    globals()[model_name + "Serializer"] = type(
        model_name + "Serializer", tuple(base_serializers), {"Meta": meta_class}
    )

# Create serializers with expandable fields

for model_name, data in expandable_fields.items():
    fields = data["fields"]
    options = data["options"]

    model = globals()[model_name]
    meta_class_params = {
        "model": model,
        "expandable_fields": fields,
    }
    # Remove excluded fields from the model
    current_excluded_fields = set(excluded_fields).intersection(
        set(model._meta.get_fields())
    )
    if current_excluded_fields:
        meta_class_params["exclude"] = list(current_excluded_fields)
    else:
        meta_class_params["fields"] = "__all__"
    meta_class = type(
        "Meta",
        (),
        meta_class_params,
    )

    extra_fields = {}

    for field_name, field_data in fields.items():
        if field_name not in options.get("many_to_many", []):
            kwargs = field_data[1]
            extra_fields[field_name] = HyperlinkedRelatedField(**kwargs)

    extra_fields["Meta"] = meta_class

    globals()[model_name + "Serializer"] = type(
        model_name + "Serializer",
        tuple(
            [
                EdocListSerializer,
                TagListSerializer,
                NoteListSerializer,
                DynamicFieldsModelSerializer,
            ]
        ),  # type: ignore
        extra_fields,
    )


class OutcomeTemplateSerializer(DynamicFieldsModelSerializer):
    class Meta:
        model = OutcomeTemplate
        fields = "__all__"


class BomSerializer(DynamicFieldsModelSerializer):

    bill_of_materials = SerializerMethodField()

    def get_bill_of_materials(self, obj):
        boms = BillOfMaterials.objects.filter(experiment_id=obj.uuid)
        result_serializer = BillOfMaterialsSerializer(  # type: ignore
            boms, many=True, context=self.context
        )
        return result_serializer.data


class BomMaterialSerializer(DynamicFieldsModelSerializer):
    url = serializers.HyperlinkedIdentityField(view_name="basebommaterial-detail")

    class Meta:
        model = BomMaterial
        fields = [
            "url",
            "description",
            "inventory_material",
            "alloc_amt_val",
            "used_amt_val",
            "putback_amt_val",
            "status",
            "actor",
            "bom",
            "add_date",
            "mod_date",
        ]


class BomCompositeMaterialSerializer(DynamicFieldsModelSerializer):
    url = serializers.HyperlinkedIdentityField(view_name="basebommaterial-detail")

    class Meta:
        model = BomCompositeMaterial
        fields = [
            "url",
            "description",
            "status",
            "actor",
            "mixture",
            "bom_material",
            "add_date",
            "mod_date",
        ]


class ExperimentTemplateSerializer(
    EdocListSerializer,
    TagListSerializer,
    NoteListSerializer,
    BomSerializer,
    DynamicFieldsModelSerializer,
):
    # url = serializers.HyperlinkedIdentityField(view_name='experiment-detail')

    class Meta:
        model = ExperimentTemplate
        fields = "__all__"

    expandable_fields = expandable_fields["ExperimentTemplate"]["fields"]


class ExperimentQuerySerializer(Serializer):
    object_description = CharField(
        max_length=255, min_length=None, allow_blank=False, trim_whitespace=True
    )
    parameter_def_description = CharField(
        max_length=255, min_length=None, allow_blank=False, trim_whitespace=True
    )
    nominal_value = ValSerializerField()
    actual_value = ValSerializerField()


class ExperimentMaterialSerializer(Serializer):
    material_name = CharField(
        max_length=255, min_length=None, allow_blank=False, trim_whitespace=True
    )
    value = CharField(
        max_length=255, min_length=None, allow_blank=False, trim_whitespace=True
    )


class ExperimentDetailSerializer(Serializer):
    experiment_name = CharField(
        max_length=255, min_length=None, allow_blank=False, trim_whitespace=True
    )
    material_parameters = ExperimentMaterialSerializer(many=True)
    experiment_parameters_1 = ExperimentQuerySerializer(many=True)
    # experiment_parameters_2 = ExperimentQuerySerializer(many=True)
    # experiment_parameters_3 = ExperimentQuerySerializer(many=True)

    class Meta:
        fields = "__all__"


class VesselTemplateCreateSerializer(Serializer):
    vessel_template_description = CharField(
        max_length=500,
        allow_blank=True,
        trim_whitespace=True,
        read_only=True,
        allow_null=True,
    )
    vessel_template = URLField(
        max_length=500,
        allow_blank=True,
        allow_null=True,
    )
    vessel = URLField(max_length=500, min_length=None, allow_blank=False, required=True)

    def validate(self, attrs):
        if attrs["vessel"]:
            try:
                self.vessel_obj = get_object_from_url(attrs["vessel"], Vessel)
                self.vessel_template_obj = get_object_from_url(
                    attrs["vessel_template"], VesselTemplate
                )
            except Exception as e:
                raise serializers.ValidationError(f"Exception parsing vessel data: {e}")
        return super().validate(attrs)

    def create(self, validated_data):
        assert hasattr(self, "vessel_obj"), "Vessel object not found"
        assert hasattr(self, "vessel_template_obj"), "Vessel template object not found"


class PropertyTemplateCreateSerializer(Serializer):
    property_template_description = CharField(
        max_length=500,
        allow_blank=True,
        trim_whitespace=True,
        read_only=True,
        allow_null=True,
    )
    property_template = CharField(
        max_length=500,
        allow_blank=True,
        trim_whitespace=True,
        read_only=True,
        allow_null=True,
    )
    property_nominal_value = ValSerializerField()


class ReagentMaterialTemplateCreateSerializer(Serializer):
    reagent_material_template_description = CharField(
        max_length=500,
        allow_blank=True,
        trim_whitespace=True,
        read_only=True,
        allow_null=True,
    )
    reagent_material_template = CharField(
        max_length=500,
        allow_blank=True,
        trim_whitespace=True,
        read_only=True,
        allow_null=True,
    )
    properties = PropertyTemplateCreateSerializer(many=True)


class ReagentTemplateCreateSerializer(Serializer):
    reagent_template_description = CharField(
        max_length=500,
        allow_blank=True,
        trim_whitespace=True,
        read_only=True,
        allow_null=True,
    )
    reagent_template = CharField(
        max_length=500,
        allow_blank=True,
        trim_whitespace=True,
        read_only=True,
        allow_null=True,
    )
    properties = PropertyTemplateCreateSerializer(many=True)
    reagent_materials = ReagentMaterialTemplateCreateSerializer(many=True)


class ExperimentTemplateCreateSerializer(Serializer):
    experiment_name = CharField(
        max_length=255, min_length=None, allow_blank=False, trim_whitespace=True
    )
    vessel_templates = VesselTemplateCreateSerializer(many=True)
    # reagent_templates = ReagentTemplateCreateSerializer(many=True)
    # action_templates = ActionTemplateCreateSerializer(many=True)
