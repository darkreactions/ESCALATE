# from core.models import (Actor, Material, Inventory,
#                         Person, Organization, Note)

from django.db.models.fields import related
from rest_framework import serializers
from core.models.view_tables import Edocument, Note
from core.models.core_tables import TypeDef
from rest_framework.serializers import (SerializerMethodField, ModelSerializer,
                                        HyperlinkedModelSerializer, JSONField,
                                        FileField, CharField, ListSerializer,
                                        HyperlinkedRelatedField, PrimaryKeyRelatedField)
from rest_framework.reverse import reverse
from rest_flex_fields import FlexFieldsModelSerializer


from rest_api.endpoint_details import details
#import core.models
from core.models import *
from core.models.view_tables import *
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


class DynamicFieldsModelSerializer(FlexFieldsModelSerializer, HyperlinkedModelSerializer):
    """
    A ModelSerializer that takes an additional `fields` and 'omit' arguments that
    controls which fields should be displayed.
    """

    def __init__(self, *args, **kwargs):
        self.serializer_field_mapping[ValField] = ValSerializerField
        # Don't pass the 'view_name' arg up to the superclass
        if 'view_name' in kwargs:
            kwargs.pop('view_name')
        super(DynamicFieldsModelSerializer, self).__init__(*args, **kwargs)


class TagAssignSerializer(DynamicFieldsModelSerializer):
    tag_label = CharField(source='tag.display_text', read_only=True)

    class Meta:
        model = TagAssign
        fields = '__all__'
        read_only_fields = ['ref_tag']


class TagListSerializer(DynamicFieldsModelSerializer):
    tags = SerializerMethodField()

    def get_tags(self, obj):
        tags = TagAssign.objects.filter(ref_tag=obj.uuid)
        result_serializer = TagAssignSerializer(
            tags, many=True, context=self.context)
        return result_serializer.data


class NoteSerializer(DynamicFieldsModelSerializer):

    class Meta:
        model = Note
        fields = '__all__'
        read_only_fields = ['ref_note_uuid']


class NoteListSerializer(DynamicFieldsModelSerializer):
    notes = SerializerMethodField()

    def get_notes(self, obj):
        notes = Note.objects.filter(note_x_note__ref_note=obj.uuid)
        result_serializer = NoteSerializer(
            notes, many=True, context=self.context)
        return result_serializer.data

class MeasureSerializer(DynamicFieldsModelSerializer):

    class Meta:
        model = Measure
        fields = '__all__'
        read_only_fields = ['ref_measure_uuid']


class MeasureListSerializer(DynamicFieldsModelSerializer):
    measures = SerializerMethodField()

    def get_measures(self, obj):
        measures = Measure.objects.filter(measure_x_measure__ref_measure=obj.uuid)
        result_serializer = MeasureSerializer(
            measures, many=True, context=self.context)
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
            raise ValidationError(
                f'File type {value} does not exist. Options are: {", ".join(options)}', code='invalid')
        return value

    def create(self, validated_data):
        
        validated_data['filename'] = validated_data['edocument'].name
        validated_data['edocument'] = validated_data['edocument'].read()
        doc_type = TypeDef.objects.get(category='file',
                                       description=validated_data['edoc_type'])
        validated_data['doc_type_uuid'] = doc_type
        edoc = Edocument(**validated_data)
        edoc.save()
        return edoc

    class Meta:
        model = Edocument
        fields = ('url', 'title', 'description', 'filename',
                  'source', 'edoc_type', 'download_link',
                  'actor', 'actor_description', 'tags', 'notes', 'edocument',
                  'ref_edocument_uuid')
        read_only_fields = ['ref_edocument_uuid', 'filename']


class EdocListSerializer(DynamicFieldsModelSerializer):
    edocs = SerializerMethodField()

    def get_edocs(self, obj):
        edocs = Edocument.objects.filter(
            ref_edocument_uuid=obj.uuid)
        result_serializer = EdocumentSerializer(
            edocs, many=True, context=self.context)
        return result_serializer.data


for model_name in rest_serializer_views:
    meta_class = type('Meta', (), {'model': globals()[model_name],
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
        model = ActionDef
        fields = '__all__'


class ActionSerializer(DynamicFieldsModelSerializer):
    parameter = ActionParameterSerializer(read_only=True, many=True)

    class Meta:
        model = Action
        fields = '__all__'

class OutcomeSerializer(MeasureListSerializer, DynamicFieldsModelSerializer):
    
    class Meta:
        model = Outcome
        fields = '__all__'


class FilteredListSerializer(ListSerializer):
    def to_representation(self, data):
        data = data.filter(bom_material_composite__isnull=True)
        return super().to_representation(data)


class BomMaterialCompositeSerializer(EdocListSerializer,
                                     TagListSerializer,
                                     NoteListSerializer,
                                     DynamicFieldsModelSerializer):
    class Meta:
        model = BomCompositeMaterial
        fields = '__all__'


class BomMaterialSerializer(EdocListSerializer,
                            TagListSerializer,
                            NoteListSerializer,
                            DynamicFieldsModelSerializer):
    bom_material_composite = BomMaterialCompositeSerializer(
        read_only=True, many=True, source='bom_composite_material_bom_material')

    class Meta:
        #list_serializer_class = FilteredListSerializer
        model = BomMaterial
        fields = '__all__'


class BillOfMaterialsSerializer(EdocListSerializer,
                                TagListSerializer,
                                NoteListSerializer,
                                DynamicFieldsModelSerializer):
    #bom_serializer_params = {'source': 'bom_material_bom',
    #                         'many': True,
    #                         'read_only': True, }
    #bom_material = BomMaterialSerializer(**bom_serializer_params)

    class Meta:
        model = BillOfMaterials
        fields = '__all__'


expandable_fields = {
    'BomCompositeMaterial': {
        'composite_material': ('rest_api.CompositeMaterialSerializer', 
                                {
                                    'read_only': True,
                                    'view_name': 'compositematerial-detail'

                                })
    },
    'BomMaterial': {
        'bom_composite_material': ('rest_api.BomCompositeMaterialSerializer',
                                    {
                                        'source': 'bom_composite_material_bom_material',
                                        'many': True,
                                        'read_only': True,
                                        'view_name': 'bomcompositematerial-detail'
                                    }
        )
    },
    'BillOfMaterials': {
        'bom_material': ('rest_api.BomMaterialSerializer',
                            {
                             'source': 'bom_material_bom',
                             'many': True,
                             'read_only': True,
                             'view_name': 'bommaterial-detail'   
                            })
    },
    'WorkflowObject': {
        'action': ('rest_api.ActionSerializer',
                    {
                        'read_only': True,
                        'view_name': 'action-detail'
                    })
    },
    'WorkflowStep': {
        'workflow_object': ('rest_api.WorkflowObjectSerializer',
                            {
                                'read_only': True,
                                'view_name': 'workflowobject-detail'
                            })
    },
    'Workflow': {
        'step': ('rest_api.WorkflowStepSerializer',
                  {
                      'source': 'workflow_step_workflow',
                      'many': True,
                      'read_only': True,
                      'view_name': 'workflowstep-detail'
                  })
    },
    'ExperimentWorkflow': {
        'workflow': ('rest_api.WorkflowSerializer',
                     {
                         'read_only': True,
                         'view_name': 'workflow-detail'
                     })
    },
    'Experiment': {
        'bill_of_materials': ('rest_api.BillOfMaterialsSerializer',
                              {
                                  'source': 'bom_experiment',
                                  'many': True,
                                  'read_only': True,
                                  'view_name': 'billofmaterials-detail'
                              }),
        'workflow': ('rest_api.ExperimentWorkflowSerializer',
                     {
                         'source': 'experiment_workflow_experiment',
                         'many': True,
                         'read_only': True,
                         'view_name': 'experimentworkflow-detail'
                     }),
        'outcome': ('rest_api.OutcomeSerializer',
                    {
                        'source': 'outcome_experiment',
                        'many': True,
                        'read_only': True,
                        'view_name': 'outcome-detail'
                    })
    }

}


for model_name, fields in expandable_fields.items():
    #model = getattr(core.models, model_name)
    model = globals()[model_name]
    meta_class = type(
        'Meta', (), {'model': model, 'fields': '__all__', 'expandable_fields': fields})

    extra_fields = {}

    for field_name, data in fields.items():
        kwargs = data[1]
        extra_fields[field_name] = HyperlinkedRelatedField(**kwargs)

    extra_fields['Meta'] = meta_class

    globals()[model_name+'Serializer'] = type(model_name+'Serializer',
                                              tuple([EdocListSerializer,
                                                     TagListSerializer,
                                                     NoteListSerializer,
                                                     DynamicFieldsModelSerializer]),
                                              extra_fields)
