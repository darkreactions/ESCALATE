from django import forms
from django.contrib.auth.forms import UserCreationForm, UserChangeForm
from core.models import (CustomUser, Person, Material, Inventory, Actor, Note, Organization, LatestSystemtool,
                         SystemtoolType, UdfDef, Status, Tag, Tag_X, TagType, MaterialType)


dropdown_attrs = {'class': 'selectpicker',
                  'data-style': 'btn-dark', 'data-live-search': 'true'}


class LoginForm(forms.Form):
    username = forms.CharField(max_length=100)
    password = forms.CharField(widget=forms.PasswordInput())


class CustomUserCreationForm(UserCreationForm):
    class Meta:
        model = CustomUser
        fields = ['username', 'password1', 'password2']


class NoteForm(forms.ModelForm):
    class Meta:
        model = Note
        fields = ['notetext']
        widgets = {
            'notetext': forms.Textarea(attrs={'rows': 3}),
        }


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
            'suffix': forms.TextInput(attrs={'placeholder': 'Your suffix'}),
            'organization_uuid': forms.Select(attrs=dropdown_attrs)
        }


class MaterialForm(forms.ModelForm):
    class Meta:
        model = Material
        fields = ['chemical_name', 'abbreviation', 'inchi', 'inchikey',
                  'molecular_formula', 'smiles',
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
                date_attrs={
                    'placeholder': 'DD-MM-YYYY'
                },
                time_format='%H:%M',
                time_attrs={
                    'placeholder': 'HH-MM'
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
            'smiles': forms.TextInput(attrs={'placeholder': 'Ex: O'}),
            'material_status_uuid': forms.Select(attrs=dropdown_attrs),
        }


class InventoryForm(forms.ModelForm):
    class Meta:
        model = Inventory
        fields = ['material_uuid', 'actor_uuid', 'part_no',
                  'onhand_amt', 'unit', 'expiration_date',
                  'inventory_location', 'status_uuid']

        field_classes = {
            'description': forms.CharField,
            'part_no': forms.CharField,
            'onhand_amt': forms.DecimalField,
            'unit': forms.CharField,
            'expiration_date': forms.SplitDateTimeField,
            'inventory_location': forms.CharField
        }
        labels = {
            'description': 'Description',
            'material_uuid': 'Material',
            'actor_uuid': 'Actor',
            'part_no': 'Part Number',
            'onhand_amt': 'On hand amount',
            'unit': 'Unit',
            'expiration_date': 'Expiration date',
            'inventory_location': 'Inventory location'
        }
        widgets = {
            'material_uuid': forms.Select(attrs=dropdown_attrs),
            'actor_uuid': forms.Select(attrs=dropdown_attrs),
            'description': forms.Textarea(attrs={'rows': '3',
                                                 'cols': '10',
                                                 'placeholder': 'Description'}),

            'part_no': forms.TextInput(attrs={'placeholder': 'Part number'}),
            'onhand_amt': forms.NumberInput(attrs={'value': '0.01',
                                                   'min': '0.00',
                                                   'step': '0.01'}),
            'unit': forms.TextInput(attrs={'placeholder': 'Ex: g for grams'}),
            'expiration_date': forms.SplitDateTimeWidget(
                date_format='%d-%m-%Y',
                date_attrs={
                    'placeholder': 'DD-MM-YYYY'
                },
                time_format='%H:%M',
                time_attrs={
                    'placeholder': 'HH-MM'
                }
            ),
            'inventory_location': forms.TextInput(attrs={
                'placeholder': 'Location'}),
            'status_uuid': forms.Select(attrs=dropdown_attrs),
        }


class ActorForm(forms.ModelForm):
    class Meta:
        model = Actor

        fields = ['person_uuid', 'organization_uuid', 'systemtool_uuid',
                  'description', 'status_uuid']

        field_classes = {
            'description': forms.CharField
        }
        labels = {
            'person_uuid': 'Person',
            'organization_uuid': 'Organization',
            'systemtool_uuid': 'Systemtool',
            'description': 'Actor description',
            'status_uuid': 'Actor status'
        }
        help_texts = {
            'person_uuid': 'Select if actor is a person',
            'organization_uuid': 'Select if actor is an organization',
            'systemtool_uuid': 'Select if actor is a systemtool'
        }
        widgets = {

            'description': forms.Textarea(attrs={
                'rows': '3',
                'cols': '10',
                'placeholder': 'Your description'}),
            'person_uuid': forms.Select(attrs=dropdown_attrs),
            'organization_uuid': forms.Select(attrs=dropdown_attrs),
            'systemtool_uuid': forms.Select(attrs=dropdown_attrs),
            'status_uuid': forms.Select(attrs=dropdown_attrs),

        }


class OrganizationForm(forms.ModelForm):
    class Meta:
        model = Organization
        fields = ['full_name', 'short_name', 'description', 'address1',
                  'address2', 'city', 'state_province', 'zip', 'country',
                  'website_url', 'phone', 'parent_uuid']
        field_classes = {
            'full_name': forms.CharField,
            'short_name': forms.CharField,
            'description': forms.CharField,
            'address1': forms.CharField,
            'address2': forms.CharField,
            'city': forms.CharField,
            'state_province': forms.CharField,
            'zip': forms.CharField,
            'country': forms.CharField,
            'website_url': forms.URLField,
            'phone': forms.CharField

        }
        labels = {
            'full_name': 'Full name',
            'short_name': 'Short name',
            'description': 'Description',
            'address1': 'Address Line 1',
            'address2': 'Address Line 2',
            'city': 'City',
            'state_province': 'State/Province',
            'zip': 'Zip',
            'country': 'Country',
            'website_url': 'Website URL',
            'phone': 'Phone',
            'parent_uuid': 'Parent Organization',
            'parent_org_full_name': 'Parent Organization full name'

        }
        help_texts = {
            'website_url': 'Make sure to include https:// or http:// or www(1-9)'
        }
        widgets = {
            'full_name': forms.TextInput(attrs={
                'placeholder': 'Ex: Some Full Organization Name'
            }),
            'short_name': forms.TextInput(attrs={
                'placeholder': 'Ex: S.F.O.N'}),
            'description': forms.Textarea(attrs={
                'cols': '10',
                'rows': '3',
                'placeholder': 'Your organization description'
            }),
            'address1': forms.TextInput(attrs={
                'placeholder': 'Ex: 123 Smith Street'}),
            'address2': forms.TextInput(attrs={
                'placeholder': 'Ex: Apt. 2c'}),
            'city': forms.TextInput(attrs={
                'placeholder': 'Ex: San Francisco'}),
            'state_province': forms.TextInput(attrs={
                'cols': 3,
                'placeholder': 'Ex: CA'}),
            'zip': forms.TextInput(attrs={
                'placeholder': 'Ex: 12345/12345-6789'}),
            'country': forms.TextInput(attrs={
                'placeholder': 'Ex: United States of America'}),
            'website_url': forms.URLInput(attrs={
                'placeholder': 'Ex: https://example.com'}),
            'phone': forms.TextInput(attrs={
                'placeholder': 'Ex: 1-234-567-8900/12345678900'}),
            'parent_uuid': forms.Select(attrs=dropdown_attrs),
        }


class LatestSystemtoolForm(forms.ModelForm):
    class Meta:
        model = LatestSystemtool
        fields = ['systemtool_name', 'description', 'systemtool_type_uuid',
                  'vendor_organization_uuid', 'model', 'serial', 'ver']
        field_classes = {
            'systemtool_name': forms.CharField,
            'description': forms.CharField,
            'model': forms.CharField,
            'serial': forms.CharField,
            'ver': forms.CharField
        }
        labels = {
            'systemtool_name': 'System tool name',
            'description': 'Description',
            'model': 'Model',
            'serial': 'Serial number',
            'ver': 'Version',
            'systemtool_type_uuid': 'System tool type',
            'vendor_organization_uuid': 'Vendor Organization'
        }
       # help_texts = {
      #  }
        widgets = {
            'systemtool_name': forms.TextInput(attrs={
                'placeholder': 'Ex: Command Line'
            }),
            'description': forms.Textarea(attrs={
                'cols': '10',
                'rows': '3',
                'placeholder': 'Your system tool description'
            }),
            'model': forms.TextInput(attrs={
                'placeholder': 'Ex: left to be done'}),
            'serial': forms.TextInput(attrs={
                'placeholder': 'Your system tool serial number Ex:Y291325'}),
            'ver': forms.TextInput(attrs={
                'placeholder': 'Your system tool current version Ex: 1.06'}),
            'systemtool_type_uuid': forms.Select(attrs=dropdown_attrs),
        }


class SystemtoolTypeForm(forms.ModelForm):
    class Meta:
        model = SystemtoolType
        fields = ['description']
        labels = {
            'description': 'Description'
        }
        widgets = {
            'description': forms.Textarea(attrs={
                'cols': '10',
                'rows': '3',
                'placeholder': 'Your system tool type description'
            })
        }


class UdfDefForm(forms.ModelForm):
    class Meta:
        model = UdfDef
        fields = ['description', 'valtype']
        labels = {
            'description': 'Description',
            'valtype': 'Value type'
        }
        CHOICES = (('1', 'int'), ('2', 'array_int'), ('3', 'num'), ('4', 'array_num'),
                   ('5', 'text'), ('6', 'array_text'), ('7',
                                                        'blob_text'), ('8', 'blob_svg'),
                   ('9', 'blob_jpg'), ('10', 'blob_png'), ('11', 'blob_xrd'))
        widgets = {
            'description': forms.Textarea(attrs={
                'cols': '10',
                'rows': '3',
                'placeholder': 'Your system tool type description'
            }),
            'valtype': forms.Select(attrs={
                'placeholder': 'Ex: text, image'}, choices=CHOICES)
        }


class StatusForm(forms.ModelForm):
    class Meta:
        model = Status
        fields = ['description']
        labels = {
            'description': 'Status Description'
        }
        widgets = {
            'description': forms.Textarea(attrs={
                'cols': '10',
                'rows': '3',
                'placeholder': 'Your status description'
            })
        }


class TagForm(forms.ModelForm):
    class Meta:
        model = Tag
        fields = ['display_text', 'description', 'actor_uuid', 'tag_type_uuid']
        labels = {
            'display_text': 'Tag Name',
            'description': 'Tag Description',
            'actor_uuid': 'Actor',
            'tag_type_uuid': 'Tag Type Name'
        }
        widgets = {
            'display_text': forms.TextInput(attrs={
                'placeholder': 'Enter your name of the tag Ex: acid'}),
            'description': forms.Textarea(attrs={
                'cols': '10',
                'rows': '3',
                'placeholder': 'Detail description for your tag type'
            })
        }


class TagTypeForm(forms.ModelForm):
    class Meta:
        model = TagType
        fields = ['short_description', 'description']
        labels = {
            'short_description': 'Tag Type Short Description',
            'description': 'Tag Type Long Description'
        }
        widgets = {
            'short_description': forms.TextInput(attrs={
                'placeholder': 'Enter your name of the tag type'}),
            'description': forms.Textarea(attrs={
                'cols': '10',
                'rows': '3',
                'placeholder': 'Detail description for your tag type'
            })
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


class TagSelectForm(forms.Form):
    def __init__(self, *args, **kwargs):
        # pk of model that is passed in to filter for tags belonging to the model
        if 'model_pk' in kwargs:
            model_pk = kwargs.pop('model_pk')
            current_tags = Tag.objects.filter(pk__in=Tag_X.objects.filter(
                ref_tag_uuid=model_pk).values_list('tag_uuid', flat=True))
        else:
            current_tags = Tag.objects.none()
        super(TagSelectForm, self).__init__(*args, **kwargs)

        self.fields['tags'] = forms.ModelMultipleChoiceField(
            initial=current_tags, required=False, queryset=Tag.objects.all())
        # self.fields['tags'].widget.attrs.update({'data-live-search': 'true'})
        self.fields['tags'].widget.attrs.update(dropdown_attrs)
