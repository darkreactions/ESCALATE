from core.models import (Actor, Material, Inventory,
                         Person, Organization, Note)
from rest_framework.serializers import HyperlinkedModelSerializer, CharField, SerializerMethodField, ReadOnlyField
from rest_framework.reverse import reverse
import core.models
from .utils import view_names


class DynamicFieldsModelSerializer(HyperlinkedModelSerializer):
    """
    A ModelSerializer that takes an additional `fields` and 'exclude' arguments that
    controls which fields should be displayed.
    """

    def __init__(self, *args, **kwargs):
        # Don't pass the 'fields' arg up to the superclass
        if 'fields' in kwargs['context']['request'].GET:
            fields = kwargs['context']['request'].GET['fields'].split(",")
        else:
            fields = None

        if 'exclude' in kwargs['context']['request'].GET:
            exclude = kwargs['context']['request'].GET['exclude'].split(",")
        else:
            exclude = None

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


for model_name in view_names:
    meta_class = type('Meta', (), {'model': getattr(core.models, model_name),
                                   'fields': '__all__'})
    globals()[model_name+'Serializer'] = type(model_name+'Serializer', tuple([DynamicFieldsModelSerializer]),
                                              {'Meta': meta_class})


class EdocumentSerializer(DynamicFieldsModelSerializer):
    download_link = SerializerMethodField()

    class Meta:
        model = core.models.Edocument
        fields = ('uuid', 'title', 'description', 'filename',
                  'source', 'edoc_type', 'download_link', 'actor_uuid', 'actor_description')

    def get_download_link(self, obj):
        result = '{}'.format(reverse('edoc_download',
                                     args=[obj.uuid],
                                     request=self.context['request']))
        return result


class ExperimentMeasureCalculationSerializer(DynamicFieldsModelSerializer):
    class Meta:
        model = core.models.ExperimentMeasureCalculation
        fields = ('uid', 'row_to_json')


class PropertyDefSerializer(DynamicFieldsModelSerializer):

    class Meta:
        model = core.models.PropertyDef
        fields = ("uuid", "description", "short_description", "val_type", "val_unit", "actor_uuid", "actor_description",
                  "status_uuid", "status_description", "add_date", "mod_date")
    uuid = ReadOnlyField()
    actor_uuid = ReadOnlyField()
    actor_description = ReadOnlyField()
