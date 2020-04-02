from core.models import (Actor, Material, Inventory,
                         Person, Organization, Note)
from rest_framework.serializers import HyperlinkedModelSerializer, CharField
import core.models


class ActorSerializer(HyperlinkedModelSerializer):

    class Meta:
        model = Actor
        #fields = ['description', 'person']
        fields = '__all__'


class PersonSerializer(HyperlinkedModelSerializer):
    class Meta:
        model = Person
        # fields = ['person_id', 'person_uuid', 'firstname', 'lastname',
        #          'middlename', 'address1', 'city', 'stateprovince', 'phone',
        #          'email', 'title', 'suffix', 'organization', 'note_uuid']
        fields = '__all__'


class OrganizationSerializer(HyperlinkedModelSerializer):
    #note_text = CharField(source='note')

    class Meta:
        model = Organization
        # fields = ['organization_id', 'organization_uuid', 'description',
        #          'full_name', 'short_name', 'address1', 'address2', 'city',
        #          'state_province', 'zip', 'country', 'website_url', 'phone',
        #          'note_text', 'add_date', 'mod_date']
        fields = '__all__'


class MaterialSerializer(HyperlinkedModelSerializer):
    #note_text = CharField(source='note')
    #status_description = CharField(source='status')

    class Meta:
        model = Material
        # fields = ['material_id', 'material_uuid', 'description',
        #          'parent_material', 'status_description', 'note_text',
        #          'add_date', 'mod_date']
        fields = '__all__'


class InventorySerializer(HyperlinkedModelSerializer):
    #note_text = CharField(source='note')
    #status_description = CharField(source='status')

    class Meta:
        model = Inventory
        # fields = ['inventory_id', 'inventory_uuid', 'description', 'material',
        #          'actor', 'part_no', 'onhand_amt', 'unit', 'measure_id',
        #          'create_date', 'expiration_dt', 'inventory_location',
        #          'status_description', 'document_id', 'note_text', 'add_date',
        #          'mod_date']
        fields = '__all__'


model_names = ['MDescriptor', 'MDescriptorClass', 'MDescriptorDef',
               'MaterialType',
               'Measure', 'MeasureType', 'Status', 'Systemtool',
               'SystemtoolType', 'Tag', 'TagType', 'ViewInventory']

for model_name in model_names:
    meta_class = type('Meta', (), {'model': getattr(core.models, model_name),
                                   'fields': '__all__'})
    globals()[model_name+'Serializer'] = type(model_name+'Serializer', tuple([HyperlinkedModelSerializer]),
                                              {'Meta': meta_class})
