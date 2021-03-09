from django import forms
from django.contrib.auth.forms import UserCreationForm, UserChangeForm
from django.contrib.auth.hashers import make_password
from django.contrib.admin import widgets
from core.models import (CustomUser,  PersonTable, OrganizationPassword, )
from core.models.view_tables import (Person, Material, Inventory, Actor, Note,
                         Organization, Systemtool, SystemtoolType,
                         UdfDef, Status, Tag, TagAssign, TagType, MaterialType,
                         Edocument, InventoryMaterial)

from packaging import version
import django
if version.parse(django.__version__) < version.parse('3.1'):
    from django.contrib.postgres.forms import JSONField
else:
    from django.forms import JSONField

dropdown_attrs = {'class': 'selectpicker',
                  'data-style': 'btn-outline-primary', 'data-live-search': 'true'}


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


class PersonFormData:
    class Meta:
        fields = ['first_name', 'middle_name', 'last_name', 'address1',
                  'address2', 'city', 'state_province', 'zip', 'country',
                  'phone', 'email', 'title', 'suffix', 'organization']
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
            'organization': 'Organization'
        }

        help_texts = {
            'phone': 'Include extension number and/or country code if applicable',
            'organization': 'If applicable, select the organization this person belongs to',

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
            'title': forms.TextInput(attrs={'placeholder': ''}),
            'suffix': forms.TextInput(attrs={'placeholder': ''}),
            'organization': forms.Select(attrs=dropdown_attrs)
        }


class PersonForm(PersonFormData, forms.ModelForm):
    class Meta(PersonFormData.Meta):
        model = Person


class PersonTableForm(PersonFormData, forms.ModelForm):
    class Meta(PersonFormData.Meta):
        model = PersonTable


class MaterialForm(forms.ModelForm):
    class Meta:
        model = Material
        fields = ['status']
        """
            'abbreviation': forms.CharField,
            'chemical_name': forms.CharField,
            'inchi': forms.CharField,
            'inchikey': forms.CharField,
            'molecular_formula': forms.CharField,
            'smiles': forms.CharField
        """
        field_classes = {
            'create_date': forms.SplitDateTimeField,

        }
        """
                    'abbreviation': 'Abbreviation',
            'chemical_name': 'Chemical name',
            'inchi': 'International Chemical Identifier (InChI)',
            'inchikey': 'International Chemical Identifier key (InChI key)',
            'molecular_formula': 'Molecular formula',
            'smiles': 'Smiles',
        """
        labels = {
            'create_date': 'Create date',
            'material_status': 'Status'
        }
        """
        'abbreviation': forms.TextInput(attrs={'placeholder': 'Ex: Water'}),
            'chemical_name': forms.TextInput(attrs={
                'placeholder': 'Ex: Dihydrogen Monoxide'}),
            'inchi': forms.TextInput(attrs={'placeholder': 'Ex: 1S/H2O/h1H2'}),
            'inchikey': forms.TextInput(attrs={
                'placeholder': 'Ex: XLYOFNOQVPJJNP-UHFFFAOYSA-N'}),
            'molecular_formula': forms.TextInput(attrs={
                'placeholder': 'Ex: H2O'}),
            'smiles': forms.TextInput(attrs={'placeholder': 'Ex: O'}),
        """
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

            'material_status': forms.Select(attrs=dropdown_attrs),
        }


class InventoryForm(forms.ModelForm):

    class Meta:
        model = Inventory
        fields = ['description', 'owner', 'operator', 'lab', 'status', 'actor']

        field_classes = {
            'description': forms.CharField,
            'part_no': forms.CharField,
            'onhand_amt': JSONField,
            'expiration_date': forms.SplitDateTimeField,
            'location': forms.CharField
        }
        labels = {
            'description': 'Description',
            'material': 'Material',
            'actor': 'Actor',
            'part_no': 'Part Number',
            'onhand_amt': 'On hand amount',
            'expiration_date': 'Expiration date',
            'location': 'Inventory location'
        }
        widgets = {
            'material': forms.Select(attrs=dropdown_attrs),
            'actor': forms.Select(attrs=dropdown_attrs),
            'description': forms.Textarea(attrs={'rows': '3',
                                                 'cols': '10',
                                                 'placeholder': 'Description'}),

            'part_no': forms.TextInput(attrs={'placeholder': 'Part number'}),
            'onhand_amt': forms.TextInput(attrs={'placeholder': 'On hand amount'}),
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
            'location': forms.TextInput(attrs={
                'placeholder': 'Location'}),
            'status': forms.Select(attrs=dropdown_attrs),
        }


class ActorForm(forms.ModelForm):
    class Meta:
        model = Actor

        fields = ['person', 'organization', 'systemtool',
                  'description', 'status']

        field_classes = {
            'description': forms.CharField
        }
        labels = {
            'person': 'Person',
            'organization': 'Organization',
            'systemtool': 'Systemtool',
            'description': 'Actor description',
            'status': 'Actor status'
        }
        help_texts = {
            'person': 'Select if actor is a person',
            'organization': 'Select if actor is an organization',
            'systemtool': 'Select if actor is a systemtool'
        }
        widgets = {

            'description': forms.Textarea(attrs={
                'rows': '3',
                'cols': '10',
                'placeholder': 'Your description'}),
            'person': forms.Select(attrs=dropdown_attrs),
            'organization': forms.Select(attrs=dropdown_attrs),
            'systemtool': forms.Select(attrs=dropdown_attrs),
            'status': forms.Select(attrs=dropdown_attrs),

        }


class OrganizationForm(forms.ModelForm):
    class Meta:
        model = Organization
        fields = ['full_name', 'short_name', 'description', 'address1',
                  'address2', 'city', 'state_province', 'zip', 'country',
                  'website_url', 'phone', 'parent']
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
            'parent': 'Parent Organization',
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
            'parent': forms.Select(attrs=dropdown_attrs),
        }


class LatestSystemtoolForm(forms.ModelForm):
    class Meta:
        model = Systemtool
        fields = ['systemtool_name', 'description', 'systemtool_type',
                  'vendor_organization', 'model', 'serial', 'ver']
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
            'systemtool_type': 'System tool type',
            'vendor_organization': 'Vendor Organization'
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
            'systemtool_type': forms.Select(attrs=dropdown_attrs),
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
        fields = ['description', 'val_type_description']
        labels = {
            'description': 'Description',
            'val_type_description': 'Value type'
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
            'val_type_description': forms.Select(attrs={
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
        fields = ['display_text', 'description', 'actor', 'tag_type']
        labels = {
            'display_text': 'Tag Name',
            'description': 'Tag Description',
            'actor': 'Actor',
            'tag_type': 'Tag Type Name'
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
        fields = ['type', 'description']
        labels = {
            'type': 'Tag Type Short Description',
            'description': 'Tag Type Long Description'
        }
        widgets = {
            'type': forms.TextInput(attrs={
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
            current_tags = Tag.objects.filter(pk__in=TagAssign.objects.filter(
                ref_tag=model_pk).values_list('tag', flat=True))
        else:
            current_tags = Tag.objects.none()
        super(TagSelectForm, self).__init__(*args, **kwargs)

        self.fields['tags'] = forms.ModelMultipleChoiceField(
            initial=current_tags, required=False, queryset=Tag.objects.all())
        # self.fields['tags'].widget.attrs.update({'data-live-search': 'true'})
        self.fields['tags'].widget.attrs.update(dropdown_attrs)


class UploadEdocForm(forms.ModelForm):
    class Meta:
        model = Edocument
        fields = ['title', 'description', 'source']
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


class JoinOrganizationForm(forms.ModelForm):
    def __init__(self, *args, **kwargs):
        super(JoinOrganizationForm, self).__init__(*args, **kwargs)
        self.fields['organization'].queryset = OrganizationPassword.objects.all()

    class Meta:
        model = OrganizationPassword
        fields = ['organization', 'password']
        widgets = {
            'password': forms.PasswordInput()
        }


class CreateOrganizationPasswordForm(forms.ModelForm):
    
    def save(self, commit=True):
        instance = super(CreateOrganizationPasswordForm, self).save(commit=False)
        instance.password = make_password(instance.password)
        if commit:
            instance.save()
        return instance
    
    class Meta:
        model = OrganizationPassword
        fields = ['organization', 'password']
        widgets = {
            'password': forms.PasswordInput()
        }

class InventoryMaterialForm(forms.ModelForm):
    class Meta:
        model = InventoryMaterial
        fields = ['description', 'inventory', 'material', 
                  'material_consumable', 'material_composite_flg', 
                  'part_no', 'onhand_amt', 'expiration_date',
                  'location', 'status',]

        field_classes = {
            'description': forms.CharField,
            'part_no': forms.CharField,
            #'onhand_amt': ValFormField,
            #'onhand_amt': forms.CharField,
            'expiration_date': forms.SplitDateTimeField,
            'location': forms.CharField,
        }
        labels = {
            'description': 'Description',
            'material': 'Material',
            'actor': 'Actor',
            'part_no': 'Part Number',
            'onhand_amt': 'Amount on hand',
            'expiration_date': 'Expiration date',
            'location': 'Inventory location',
            'material_consumable': 'Consumable',
            'material_composite_flg': 'Composite Material'
        }
        widgets = {
            'material': forms.Select(attrs=dropdown_attrs),
            'actor': forms.Select(attrs=dropdown_attrs),
            'inventory': forms.Select(attrs=dropdown_attrs),
            'description': forms.Textarea(attrs={'rows': '3',
                                                 'cols': '10',
                                                 'placeholder': 'Description'}),

            'part_no': forms.TextInput(attrs={'placeholder': 'Part number'}),
            'expiration_date': widgets.AdminSplitDateTime(),
            'location': forms.TextInput(attrs={
                'placeholder': 'Location'}),
            'status': forms.Select(attrs=dropdown_attrs),
        }

class ExperimentNameForm(forms.Form):
    exp_name = forms.CharField(label='Experiment Name', max_length=100)