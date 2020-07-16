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
        fields = ['first_name', 'middle_name', 'last_name', 'address1',
                  'address2', 'city', 'state_province', 'zip', 'country',
                  'phone', 'email', 'title', 'suffix', 'organization_uuid']
        field_classes = {
                'first_name': forms.CharField,
                'middle_name': forms.CharField,
                'last_name': forms.CharField,
                'address1': forms.CharField,
                'address2': forms.CharField,
                'city': forms.CharField,
                'state_province': forms.CharField,
                'zip': forms.CharField,
                'country': forms.CharField,
                'phone': forms.CharField,
                'email': forms.EmailField,
                'title': forms.CharField,
                'suffix': forms.CharField
        }

        labels = {
            'first_name': 'First Name',
            'middle_name': 'Middle Name',
            'last_name': 'Last Name',
            'address1': 'Address Line 1',
            'address2': 'Address Line 2',
            'city': 'City',
            'state_province': 'State/Province',
            'zip': 'Zip',
            'country': 'Country',
            'phone': 'Phone',
            'email': 'E-mail',
            'title': 'Title',
            'suffix': 'Suffix',
            'organization_uuid': 'Organization'
        }

        help_texts = {
            'phone': 'Include extension number and/or country code if applicable',
            'organization_uuid': 'If applicable, select the organization this person belongs to'
        }

        widgets = {
            'first_name': forms.TextInput(attrs={'placeholder': 'Your first name'}),
            'middle_name': forms.TextInput(attrs={'placeholder': 'Your middle name'}),
            'last_name': forms.TextInput(attrs={'placeholder': 'Your last name'}),
            'address1': forms.TextInput(attrs={'placeholder': 'Ex: 123 Smith Street'}),
            'address2': forms.TextInput(attrs={'placeholder': 'Ex: Apt. 2c'}),
            'city': forms.TextInput(attrs={'placeholder': 'Ex: San Francisco'}),
            'state_province': forms.TextInput(attrs={'placeholder': 'Ex: CA'}),
            'zip': forms.TextInput(attrs={'placeholder': 'Ex: 12345/12345-6789'}),
            'country': forms.TextInput(attrs={'placeholder': 'Ex: United States of America'}),
            'phone': forms.TextInput(attrs={'placeholder': 'Ex: 1-234-567-8900/12345678900'}),
            'email': forms.TextInput(attrs={'placeholder': 'Ex: example@gmail.com'}),
            'title': forms.TextInput(attrs={'placeholder': 'Your title'}),
            'suffix': forms.TextInput(attrs={'placeholder': 'Your suffix'})
        }

class NoteForm(forms.ModelForm):
    class Meta:
        model = Note
        fields = ['notetext']


class MaterialForm(forms.ModelForm):
    class Meta:
        model = Material
        fields = ['chemical_name', 'abbreviation', 'inchi', 'inchikey',
                  'molecular_formula', 'smiles', 'create_date',
                  'material_status_uuid']
        field_classes = {
            'create_date': forms.SplitDateTimeField,
            'abbreviation': forms.CharField,
            'chemical_name': forms.CharField,
            'inchi': forms.CharField,
            'inchikey': forms.CharField,
            'molecular_formula': forms.CharField,
            'smiles': forms.CharField
        }
        labels = {
            'create_date': 'Create date',
            'abbreviation': 'Abbreviation',
            'chemical_name': 'Chemical name',
            'inchi': 'International Chemical Identifier (InChI)',
            'inchikey': 'International Chemical Identifier key (InChI key)',
            'molecular_formula': 'Molecular formula',
            'smiles': 'Smiles',
            'material_status_uuid': 'Status'
        }
        widgets = {
            'create_date': forms.SplitDateTimeWidget(
                                        date_format='%d-%m-%Y',
                                        date_attrs= {
                                            'placeholder':'DD-MM-YYYY'
                                        },
                                        time_format='%H:%M',
                                        time_attrs= {
                                            'placeholder':'HH-MM'
                                        }
                                                                ),
            'abbreviation': forms.TextInput(attrs={'placeholder': 'Ex: Water'}),
            'chemical_name': forms.TextInput(attrs={
                                    'placeholder': 'Ex: Dihydrogen Monoxide'}),
            'inchi': forms.TextInput(attrs={'placeholder': 'Ex: 1S/H2O/h1H2'}),
            'inchikey': forms.TextInput(attrs={
                             'placeholder': 'Ex: XLYOFNOQVPJJNP-UHFFFAOYSA-N'}),
            'molecular_formula': forms.TextInput(attrs={
                                                     'placeholder': 'Ex: H2O'}),
            'smiles': forms.TextInput(attrs={'placeholder': 'Ex: O'})
            }

class InventoryForm(forms.ModelForm):
    class Meta:
        model = Inventory
        fields = ['material_uuid', 'actor_uuid', 'part_no',
                  'onhand_amt', 'unit', 'create_date', 'expiration_date',
                  'inventory_location', 'status_uuid']
        field_classes = {
            'inventory_description': forms.CharField,
            'part_no': forms.CharField,
            'onhand_amt': forms.DecimalField,
            'unit': forms.CharField,
            'create_date': forms.SplitDateTimeField,
            'expiration_date': forms.SplitDateTimeField,
            'inventory_location': forms.CharField
        }
        labels = {
            'inventory_description': 'Description',
            'material_uuid': 'Material',
            'actor_uuid': 'Actor',
            'part_no': 'Part Number',
            'onhand_amt': 'On hand amount',
            'unit': 'Unit',
            'create_date': 'Create date',
            'expiration_date': 'Expiration date',
            'inventory_location': 'Inventory location'
        }
        widgets = {
            'inventory_description': forms.Textarea(attrs={'rows': '3',
                                                 'cols': '10',
                                                 'placeholder': 'Description'}),
            'part_no': forms.TextInput(attrs={'placeholder': 'Part number'}),
            'onhand_amt': forms.NumberInput(attrs={'value': '0.01',
                                                   'min': '0.00',
                                                   'step': '0.01'}),
            'unit': forms.TextInput(attrs={'placeholder': 'Ex: g for grams'}),
            'create_date': forms.SplitDateTimeWidget(
                                        date_format='%d-%m-%Y',
                                        date_attrs= {
                                            'placeholder':'DD-MM-YYYY'
                                        },
                                        time_format='%H:%M',
                                        time_attrs= {
                                            'placeholder':'HH-MM'
                                        }
                                                                ),
            'expiration_date': forms.SplitDateTimeWidget(
                                        date_format='%d-%m-%Y',
                                        date_attrs= {
                                            'placeholder':'DD-MM-YYYY'
                                        },
                                        time_format='%H:%M',
                                        time_attrs= {
                                            'placeholder':'HH-MM'
                                        }
                                                                ),
            'inventory_location': forms.TextInput(attrs={
                                                    'placeholder': 'Location'})
        }


class ActorForm(forms.ModelForm):
    class Meta:
        model = Actor
        fields = ['person_uuid', 'organization_uuid', 'systemtool_uuid',
                  'actor_description', 'actor_status_uuid']
        field_classes = {
            'actor_description': forms.CharField
        }
        labels = {
            'person_uuid': 'Person',
            'organization_uuid': 'Organization',
            'systemtool_uuid': 'Systemtool',
            'actor_description': 'Actor description',
            'actor_status_uuid': 'Actor status'
        }
        help_texts = {
            'person_uuid': 'Select if actor is a person',
            'organization_uuid': 'Select if actor is an organization',
            'systemtool_uuid': 'Select if actor is a systemtool'
        }
        widgets = {
            'actor_description': forms.Textarea(attrs={
                                            'rows': '3',
                                            'cols': '10',
                                            'placeholder': 'Your description'})
        }


class OrganizationForm(forms.ModelForm):
    class Meta:
        model = Organization
        fields = ['full_name', 'short_name', 'description', 'address1',
                  'address2', 'city', 'state_province', 'zip', 'country',
                  'website_url', 'phone', 'parent_uuid']
        field_classes = {
            'full_name' : forms.CharField,
            'short_name' : forms.CharField,
            'description' : forms.CharField,
            'address1': forms.CharField,
            'address2': forms.CharField,
            'city' : forms.CharField,
            'state_province': forms.CharField,
            'zip' : forms.CharField,
            'country' : forms.CharField,
            'website_url': forms.URLField,
            'phone' : forms.CharField
        }
        labels = {
            'full_name' : 'Full name',
            'short_name' : 'Short name',
            'description' : 'Description',
            'address1': 'Address Line 1',
            'address2': 'Address Line 2',
            'city' : 'City',
            'state_province': 'State/Province',
            'zip' : 'Zip',
            'country' : 'Country',
            'website_url': 'Website URL',
            'phone' : 'Phone',
            'parent_uuid' : 'Parent Organization'
        }
        help_texts = {
            'website_url': 'Make sure to include https:// or http:// or www(1-9)'
        }
        widgets = {
            'full_name' : forms.TextInput(attrs={
                                'placeholder': 'Ex: Some Full Organization Name',
                                }),
            'short_name' : forms.TextInput(attrs={
                                                'placeholder': 'Ex: S.F.O.N'}),
            'description': forms.Textarea(attrs={
                                    'cols': '10',
                                    'rows': '3',
                                    'placeholder': 'Your organization description'
            }),
            'address1' : forms.TextInput(attrs={
                                        'placeholder': 'Ex: 123 Smith Street'}),
            'address2' : forms.TextInput(attrs={
                                        'placeholder': 'Ex: Apt. 2c'}),
            'city' : forms.TextInput(attrs={
                                        'placeholder': 'Ex: San Francisco'}),
            'state_province' : forms.TextInput(attrs={
                                        'cols' : 3,
                                        'placeholder': 'Ex: CA'}),
            'zip' : forms.TextInput(attrs={
                                        'placeholder': 'Ex: 12345/12345-6789'}),
            'country' : forms.TextInput(attrs={
                                'placeholder': 'Ex: United States of America'}),
            'website_url' : forms.URLInput(attrs={
                    'placeholder': 'Ex: https://example.com'}),
            'phone' : forms.TextInput(attrs={
                              'placeholder': 'Ex: 1-234-567-8900/12345678900'})
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
        field_classes = {
        'description': forms.CharField
        }
        labels = {
            'description': 'Description'
        }
        widgets = {
            'description': forms.Textarea(attrs={
                                'cols': '10',
                                'rows': '3',
                                'placeholder': 'Your material type description'
                                        })
        }
