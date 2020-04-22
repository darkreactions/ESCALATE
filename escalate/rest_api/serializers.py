from core.models import (Actor, Material, Inventory,
                         Person, Organization, Note)
from rest_framework.serializers import HyperlinkedModelSerializer, CharField, SerializerMethodField
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
        fields = ('edocument_uuid', 'title', 'description', 'filename',
                  'source', 'type', 'download_link', 'actor', 'actor_description')

    def get_download_link(self, obj):
        result = '{}'.format(reverse('edoc_download',
                                     args=[obj.edocument_uuid],
                                     request=self.context['request']))
        return result
