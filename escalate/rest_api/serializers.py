from core.models import Actor, Material, Inventory, Person, Organization, Note
from rest_framework import serializers


class ActorSerializer(serializers.HyperlinkedModelSerializer):

    class Meta:
        model = Actor
        fields = ['description', 'person']
        # fields = ['person', 'organization', 'systemtool', 'description',
        #           'status', 'note']


class PersonSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Person
        fields = ['person_id', 'person_uuid', 'firstname', 'lastname',
                  'middlename', 'address1', 'city', 'stateprovince', 'phone',
                  'email', 'title', 'suffix', 'organization', 'note']


class OrganizationSerializer(serializers.HyperlinkedModelSerializer):
    note_text = serializers.CharField(source='note')

    class Meta:
        model = Organization
        fields = ['organization_id', 'organization_uuid', 'description',
                  'full_name', 'short_name', 'address1', 'address2', 'city',
                  'state_province', 'zip', 'country', 'website_url', 'phone',
                  'note_text', 'add_date', 'mod_date']


class MaterialSerializer(serializers.HyperlinkedModelSerializer):
    note_text = serializers.CharField(source='note')
    status_description = serializers.CharField(source='status')

    class Meta:
        model = Material
        fields = ['material_id', 'material_uuid', 'description', 'parent_material',
                  'status_description', 'note_text', 'add_date', 'mod_date']


class InventorySerializer(serializers.HyperlinkedModelSerializer):
    note_text = serializers.CharField(source='note')
    status_description = serializers.CharField(source='status')

    class Meta:
        model = Inventory
        fields = ['inventory_id', 'inventory_uuid', 'description', 'material',
                  'actor', 'part_no', 'onhand_amt', 'unit', 'measure_id', 'create_date',
                  'expiration_dt', 'inventory_location', 'status_description', 'document_id',
                  'note_text', 'add_date', 'mod_date']
