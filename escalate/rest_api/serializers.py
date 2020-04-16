from core.models import (Actor, Material, Inventory,
                         Person, Organization, Note)
from rest_framework.serializers import HyperlinkedModelSerializer, CharField, SerializerMethodField
from rest_framework.reverse import reverse
import core.models
from .utils import view_names


for model_name in view_names:
    meta_class = type('Meta', (), {'model': getattr(core.models, model_name),
                                   'fields': '__all__'})
    globals()[model_name+'Serializer'] = type(model_name+'Serializer', tuple([HyperlinkedModelSerializer]),
                                              {'Meta': meta_class})


class EdocumentSerializer(HyperlinkedModelSerializer):
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
