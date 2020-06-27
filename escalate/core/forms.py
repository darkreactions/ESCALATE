from django import forms
from django.contrib.auth.forms import UserCreationForm, UserChangeForm
from core.models import (CustomUser, Person, Material, Inventory, Actor, Note, Organization, LatestSystemtool, \
                         ViewSystemtoolType, UdfDef, Status, Tag, TagType, MaterialType)


class LoginForm(forms.Form):
    username = forms.CharField(max_length=100)
    password = forms.CharField(widget=forms.PasswordInput())


class CustomUserCreationForm(UserCreationForm):
    class Meta:
        model = CustomUser
        fields = ['username', 'password1', 'password2', 'email']


class PersonForm(forms.ModelForm):
    class Meta:
        model = Person
        fields = ['first_name', 'middle_name', 'last_name',
                  'address1', 'address2', 'city', 'state_province',
                  'phone', 'title', 'suffix',
                  'organization_uuid','edocument_uuid','tag_uuid','note_uuid']

        labels = {
            'firstname': 'First Name',
            'middlename': 'Middle Name',
            'lastname': 'Last Name',
            'address1': 'Address Line 1',
            'address2': 'Address Line 2',
            'stateprovince': 'State/Province',
            'organization_uuid':'Organization',
            'edocument_uuid':'Document',
            'tag_uuid':'Tag',
            'note_uuid':'Note'
        }


class NoteForm(forms.ModelForm):
    class Meta:
        model = Note
        fields = ['notetext']


class MaterialForm(forms.ModelForm):
    notetext = forms.CharField(
        max_length=255, empty_value=None, required=False)

    class Meta:
        model = Material
        fields = '__all__'


class InventoryForm(forms.ModelForm):
    class Meta:
        model = Inventory
        # fields = ['description', 'material', 'actor', 'part_no', 'onhand_amt', 'unit',
        #          'measure_id', 'create_date', 'inventory_location', 'status', 'document_id', 'note']
        fields = '__all__'


class ActorForm(forms.ModelForm):
    class Meta:
        model = Actor
        # fields = ['person', 'organization', 'systemtool', 'description', 'status',
        #          'note']
        fields = '__all__'


class OrganizationForm(forms.ModelForm):
    class Meta:
        model = Organization
        fields = ['full_name', 'short_name', 'address1', 'address2', 'city',
                  'state_province', 'zip', 'country', 'website_url', 'phone',
                  'parent_uuid', 'notetext', 'edocument_uuid', 'tag_uuid']
        labels = {
            'state_province': 'State/Province',
            'website_url': 'Website URL',
            'address1': 'Address Line 1',
            'address2': 'Address Line 2',
            'notetext': 'Note Text'
        }


class LatestSystemtoolForm(forms.ModelForm):
    class Meta:
        model = LatestSystemtool
        fields = ['systemtool_name', 'description', 'vendor_organization_uuid',
                  'systemtool_type_uuid', 'model', 'serial', 'notetext']
        labels = {
            'systemtool_name': 'System Tool Name',
            'vendor_organization_uuid': 'Organization',
            'systemtool_type_uuid': 'System Tool',
            'notetext': 'Note Text'
        }


class SystemtoolTypeForm(forms.ModelForm):
    class Meta:
        model = ViewSystemtoolType
        fields = ['description', 'notetext']
        labels = {
            'description': 'Description',
            'notetext': 'Note Text'
        }


class UdfDefForm(forms.ModelForm):
    class Meta:
        model = UdfDef
        fields = ['description', 'notetext']
        labels = {
            'description': 'Description',
            'notetext': 'Note Text'
        }


class StatusForm(forms.ModelForm):
    class Meta:
        model = Status
        fields = ['description']
        labels = {
            'description': 'Description',
        }


class TagForm(forms.ModelForm):
    class Meta:
        model = Tag
        fields = ['display_text', 'tag_type_uuid', 'actor_uuid', 'notetext']
        labels = {
            'description': 'Description',
            'tag_type_uuid': 'Tag Type',
            'actor_uuid': 'Actor',
            'notetext': 'Note'
        }


class TagTypeForm(forms.ModelForm):
    class Meta:
        model = TagType
        fields = ['short_description', 'description']
        labels = {
            'short_description': 'Short Description',
            'description': 'Description'
        }


class MaterialTypeForm(forms.ModelForm):
    class Meta:
        model = MaterialType
        fields = ['description', 'note_uuid','notetext']
        labels = {
            'description': 'Description',
            'note_uuid': 'Available Note Text',
            'notetext': 'New Note Text'
        }
