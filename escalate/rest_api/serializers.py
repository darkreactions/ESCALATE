#from core.models import (Actor, Material, Inventory,
#                         Person, Organization, Note)
from core.models.view_tables import Edocument, Note
from core.models.core_tables import TypeDef
from rest_framework.serializers import (SerializerMethodField, ModelSerializer, 
                                        HyperlinkedModelSerializer, JSONField, 
                                        FileField, CharField)
from rest_framework.reverse import reverse
import core.models
from .utils import rest_serializer_views
from core.models.custom_types import Val, ValField
from core.validators import ValValidator
from django.core.exceptions import ValidationError
import json


class ValSerializerField(JSONField):
    def __init__(self, **kwargs):
        self.validators.append(ValValidator())
        super().__init__(**kwargs)

    def to_representation(self, value):
        return value.to_dict()
    
    def to_internal_value(self, data):
        data = json.loads(data)
        return Val.from_dict(data)

class DynamicFieldsModelSerializer(HyperlinkedModelSerializer):
    """
    A ModelSerializer that takes an additional `fields` and 'exclude' arguments that
    controls which fields should be displayed.
    """
    
    def __init__(self, *args, **kwargs):
        # Don't pass the 'fields' arg up to the superclass
        self.serializer_field_mapping[ValField] = ValSerializerField
        fields = exclude = None
        if kwargs.get('context'):
            if 'fields' in kwargs['context']['request'].GET:
                fields = kwargs['context']['request'].GET['fields'].split(",")
            if 'exclude' in kwargs['context']['request'].GET:
                exclude = kwargs['context']['request'].GET['exclude'].split(",")

        # Instantiate the superclass normally
        super(DynamicFieldsModelSerializer, self).__init__(*args, **kwargs)

        if fields is not None:
            # Drop any fields that are not specified in the `fields` argument.
            allowed = set(fields)
            existing = set(self.fields)
            for field_name in existing - allowed:
                self.fields.pop(field_name)

        if exclude is not None:
            not_allowed = set(exclude)
            existing = set(self.fields)
            for field_name in not_allowed:
                if field_name in self.fields:
                    self.fields.pop(field_name)

class TagAssignSerializer(DynamicFieldsModelSerializer):
    tag_label = CharField(source='tag.display_text', read_only=True)
    class Meta:
        model = core.models.TagAssign
        fields = '__all__'
        read_only_fields = ['ref_tag']


class TagListSerializer(DynamicFieldsModelSerializer):
    tags = SerializerMethodField()
    def get_tags(self, obj):
        tags = core.models.TagAssign.objects.filter(ref_tag=obj.uuid)
        result_serializer = TagAssignSerializer(tags, many=True, context=self.context)
        return result_serializer.data

class NoteSerializer(DynamicFieldsModelSerializer):

    class Meta:
        model = core.models.Note
        fields = '__all__'
        read_only_fields = ['ref_note_uuid']


class NoteListSerializer(DynamicFieldsModelSerializer):
    notes = SerializerMethodField()
    def get_notes(self, obj):
        notes = core.models.Note.objects.filter(note_x_note__ref_note=obj.uuid)
        result_serializer = NoteSerializer(notes, many=True, context=self.context)
        return result_serializer.data


class EdocumentSerializer(TagListSerializer, 
                          NoteListSerializer, 
                          DynamicFieldsModelSerializer):
    download_link = SerializerMethodField()
    edocument = FileField(write_only=True)

    def get_download_link(self, obj):
        result = '{}'.format(reverse('edoc_download',
                                     args=[obj.uuid],
                                     request=self.context['request']))
        return result

    def validate_edoc_type(self, value):
        try:
            doc_type = TypeDef.objects.get(category='file', description=value)
        except TypeDef.DoesNotExist:
            val_types = TypeDef.objects.filter(category='file')
            options = [val.description for val in val_types]
            raise ValidationError(f'File type {value} does not exist. Options are: {", ".join(options)}', code='invalid')
        return value

    def create(self, validated_data):
        print(type(validated_data['edocument']))
        validated_data['filename'] = validated_data['edocument'].name
        validated_data['edocument'] = validated_data['edocument'].read()
        doc_type = TypeDef.objects.get(category='file', 
                                       description=validated_data['edoc_type'])
        validated_data['doc_type_uuid'] = doc_type
        edoc = Edocument(**validated_data)
        edoc.save()
        return edoc

    class Meta:
        model = core.models.Edocument
        fields = ('url', 'title', 'description', 'filename',
                  'source', 'edoc_type', 'download_link', 
                  'actor', 'actor_description', 'tags', 'notes', 'edocument', 
                  'ref_edocument_uuid')
        read_only_fields = ['ref_edocument_uuid', 'filename']

class EdocListSerializer(DynamicFieldsModelSerializer):
    edocs = SerializerMethodField()

    def get_edocs(self, obj):
        edocs = core.models.Edocument.objects.filter(ref_edocument_uuid=obj.uuid)
        result_serializer = EdocumentSerializer(edocs, many=True, context=self.context)
        return result_serializer.data

class ExperimentMeasureCalculationSerializer(DynamicFieldsModelSerializer):
    class Meta:
        model = core.models.ExperimentMeasureCalculation
        fields = ('uid', 'row_to_json')

for model_name in rest_serializer_views:
    meta_class = type('Meta', (), {'model': getattr(core.models, model_name),
                                   'fields': '__all__'})
    globals()[model_name+'Serializer'] = type(model_name+'Serializer', 
                                              tuple([EdocListSerializer, 
                                                     TagListSerializer, 
                                                     NoteListSerializer, 
                                                     DynamicFieldsModelSerializer]),
                                              {'Meta': meta_class})


class ActionDefSerializer(DynamicFieldsModelSerializer):
    parameter_def = ParameterDefSerializer(read_only=True, many=True)
    
    class Meta:
        model = core.models.ActionDef
        fields = '__all__'


class ActionSerializer(DynamicFieldsModelSerializer):
    parameter = ActionParameterSerializer(read_only=True, many=True)

    class Meta:
        model = core.models.Action
        fields = '__all__'


class WorkflowSerializer(DynamicFieldsModelSerializer):
    step = WorkflowStepSerializer(read_only=True, many=True)
    class Meta:
        model = core.models.Workflow
        fields = '__all__'

#class ParameterSerializer(DynamicFieldsModelSerializer):
