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
                  'address1', 'address2', 'city', 'state_province', 'zip', 'country',
                  'phone', 'email', 'title', 'suffix',
                  'organization_uuid']
        labels = {
            'first_name': 'First Name',
            'middle_name': 'Middle Name',
            'last_name': 'Last Name',
            'address1': 'Address Line 1',
            'address2': 'Address Line 2',
            'stateprovince': 'State/Province',
            'city': 'City',
            'state_province': 'State/Province',
            'phone': 'Phone',
            'email': 'E-mail',
            'title': 'Title',
            'suffix': 'Suffix',
            'organization_uuid': 'Organization'
        }
        widgets = {
            'first_name': forms.TextInput(attrs={'placeholder': 'Your first name'}),
            'middle_name': forms.TextInput(attrs={'placeholder': 'Your middle name'}),
            'last_name': forms.TextInput(attrs={'placeholder': 'Your last name'}),
            'address1': forms.TextInput(attrs={'placeholder': 'Ex: 123 Smith Street'}),
            'address2': forms.TextInput(attrs={'placeholder': 'Ex: Apt. 2c'}),
            'city': forms.TextInput(attrs={'placeholder': 'Ex: San Francisco'}),
            'state_province': forms.TextInput(attrs={'cols': 3,
                                                      'placeholder': 'Ex: CA'}),
            'zip': forms.TextInput(attrs={'placeholder': 'Ex: 12345/12345-6789'}),
            'country': forms.TextInput(attrs={'placeholder': 'Ex: United States of America'}),
            'phone': forms.TextInput(attrs={'placeholder': 'Ex: 1-234-567-8900/12345678900'}),
            'email': forms.EmailInput(attrs={'pattern': "^[a-zA-Z0-9_\.\-\+]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$",
                                              # Regex mocdified from https://stackoverflow.com/a/719543
                                              'title': 'Please check for invalid or missing characters',
                                              'placeholder': 'Ex: example@gmail.com'}),
            'title': forms.TextInput(attrs={'placeholder': 'Your title'}),
            'suffix': forms.TextInput(attrs={'placeholder': 'Your suffix'})
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
        exclude = ['material_uuid']
        labels = {
            'material_status': 'Status',
            'create_date': 'Create date',
            'abbreviation': 'Abbreviation',
            'chemical_name': 'Chemical name',
            'inchi': 'International Chemical Identifier (InChI)',
            'inchikey': 'International Chemical Identifier key (InChI key)',
            'molecular_formula': 'Molecular formula',
            'smiles': 'Smiles'
        }
        widgets = {
            'material_status': forms.TextInput(attrs={'placeholder': 'Ex: Active or Not active'}),
            # 'create_date': forms.TextInput(attrs={'placeholder': 'yyyy-MM-dd HH:mm:ss',
            #                                       'pattern': ("^\d{4}\-(0[1-9]|1[0-2])"
            #                                                   "\-([0-2][0-9]|3[0-1])\s"
            #                                                   "+([0-1][0-9]|2[0-3]):(["
            #                                                   "0-5]\d):([0-5]\d)$"),
            #                                       'title': 'Check the year,month,day,hour,minute,seconds format'}),
            'abbreviation': forms.TextInput(attrs={'placeholder': 'Ex: Water'}),
            'chemical_name': forms.TextInput(attrs={'placeholder': 'Ex: Dihydrogen Monoxide'}),
            'inchi': forms.TextInput(attrs={'placeholder': 'Ex: 1S/H2O/h1H2'}),
            'inchikey': forms.TextInput(attrs={'placeholder': 'Ex: XLYOFNOQVPJJNP-UHFFFAOYSA-N'}),
            'molecular_formula': forms.TextInput(attrs={'placeholder': 'Ex: H2O'}),
            'smiles': forms.TextInput(attrs={'placeholder': 'Ex: O'})
            }

class InventoryForm(forms.ModelForm):
    class Meta:
        model = Inventory
        fields = ['description', 'material_uuid', 'actor_uuid', 'part_no', 'onhand_amt',
                  'unit', 'create_date', 'expiration_date',
                  'inventory_location', 'status']
        labels = {
            'description': 'Description',
            'material_uuid': 'Material',
            'actor_uuid': 'Actor',
            'part_no': 'Part Number',
            'onhand_amt': 'On hand amount',
            'unit': 'Unit',
            'create_date': 'Create date',
            'expiration_date': 'Expiration date',
            'inventory_location': 'Inventory location',
            'status': 'Status'
        }
        widgets = {
            'description': forms.Textarea(attrs={'rows': '3',
                                                 'cols': '10',
                                                 'placeholder': 'Description'}),
            'part_no': forms.TextInput(attrs={'placeholder': 'Part number'}),
            'onhand_amt': forms.NumberInput(attrs={'value': '1',
                                                   'min': '0',
                                                   'step': '1'}),
            'unit': forms.TextInput(attrs={'placeholder': 'Ex: g for grams'}),
            'create_date': forms.TextInput(attrs={'placeholder': 'yyyy-MM-dd HH:mm:ss',
                                                  'pattern': ("^\d{4}\-(0[1-9]|1[0-2])"
                                                              "\-([0-2][0-9]|3[0-1])\s"
                                                              "+([0-1][0-9]|2[0-3]):(["
                                                              "0-5]\d):([0-5]\d)$"),
                                                  'title': 'Check the year,month,day,hour,minute,seconds format'}),
            'expiration_date': forms.TextInput(attrs={'placeholder': 'yyyy-MM-dd HH:mm:ss',
                                                  'pattern': ("^\d{4}\-(0[1-9]|1[0-2])"
                                                              "\-([0-2][0-9]|3[0-1])\s"
                                                              "+([0-1][0-9]|2[0-3]):(["
                                                              "0-5]\d):([0-5]\d)$"),
                                                  'title': 'Check the year,month,day,hour,minute,seconds format'}),
            'inventory_location': forms.TextInput(attrs={'placeholder': 'Location'})
        }


class ActorForm(forms.ModelForm):
    class Meta:
        model = Actor
        fields = ['person_uuid', 'organization_uuid', 'systemtool_uuid', 'actor_description',
                'actor_status']
        labels = {
            'person_uuid': 'Person',
            'organization_uuid': 'Organization',
            'systemtool_uuid': 'Systemtool',
            'actor_description': 'Actor description',
            'actor_status': 'Actor status'
        }
        widgets = {
            'actor_description': forms.TextInput(attrs={'placeholder': 'Description'}),
            'actor_status': forms.TextInput(attrs={'placeholder': 'Ex: Active/Not active'})
        }


class OrganizationForm(forms.ModelForm):
    class Meta:
        model = Organization
        fields = ['full_name', 'short_name', 'address1', 'address2', 'city',
                  'state_province', 'zip', 'country', 'website_url', 'phone',
                  'parent_uuid']
        labels = {
            'full_name' : 'Full name',
            'short_name' : 'Short name',
            'address1': 'Address Line 1',
            'address2': 'Address Line 2',
            'city' : 'City',
            'state_province': 'State/Province',
            'zip' : 'Zip',
            'country' : 'Country',
            'website_url': 'Website URL',
            'phone' : 'Phone',
            'edocument_uuid': 'Document'
        }
        widgets = {
            'full_name' : forms.TextInput(attrs={'placeholder': 'Ex: Full Organization Name',
                                                 'title': 'Enter please'}),
            'short_name' : forms.TextInput(attrs={'placeholder': 'Ex: F.O.N'}),
            'address1' : forms.TextInput(attrs={'placeholder': 'Ex: 123 Smith Street'}),
            'address2' : forms.TextInput(attrs={'placeholder': 'Ex: Apt. 2c'}),
            'city' : forms.TextInput(attrs={'placeholder': 'Ex: San Francisco'}),
            'state_province' : forms.TextInput(attrs={'cols' : 3,
                                                      'placeholder': 'Ex: CA'}),
            'zip' : forms.TextInput(attrs={'placeholder': 'Ex: 12345/12345-6789'}),
            'country' : forms.TextInput(attrs={'placeholder': 'Ex: United States of America'}),
            'website_url' : forms.TextInput(attrs={'pattern': ("^(http:\/\/www\.|https:\/\/www\.|"
                                                               "http:\/\/|https:\/\/|www\.)[a-z0-"
                                                               "9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2"
                                                               ",5}(:[0-9]{1,5})?(\/.*)?$"),
                                                   #Regex modified from https://www.regextester.com/93652
                                                   'title': 'Make sure protocol and domain name is correct',
                                                   'placeholder': 'https:// or http:// or www(1-9) required'}),
            'phone' : forms.TextInput(attrs={'placeholder': 'Ex: 1-234-567-8900/12345678900'})
        }


class LatestSystemtoolForm(forms.ModelForm):
    class Meta:
        model = LatestSystemtool
        fields = ['systemtool_name', 'description', 'vendor_organization_uuid',
                  'systemtool_type_uuid', 'model', 'serial']
        labels = {
            'systemtool_name': 'System Tool Name',
            'vendor_organization_uuid': 'Organization',
            'systemtool_type_uuid': 'System Tool'
        }


class SystemtoolTypeForm(forms.ModelForm):
    class Meta:
        model = ViewSystemtoolType
        fields = ['description']
        labels = {
            'description': 'Description'
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
        fields = ['description']
        labels = {
            'description': 'Description'
        }
