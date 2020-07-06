from django import forms
from django.contrib.auth.forms import UserCreationForm, UserChangeForm
from core.models import CustomUser, Person, Material, Inventory, Actor, Note, Organization


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
        fields = ['firstname', 'middlename', 'lastname',
                  'address1', 'address2', 'city', 'stateprovince',
                  'phone', 'title', 'suffix', 'organization', ]

        labels = {
            'firstname': 'First Name',
            'middlename': 'Middle Name',
            'lastname': 'Last Name',
            'address1': 'Address Line 1',
            'address2': 'Address Line 2',
            'stateprovince': 'State/Province'

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
                  'parent', 'notetext', 'edocument', 'tag']
        labels = {
            'state_province': 'State/Province',
            'website_url': 'Website URL',
            'address1': 'Address Line 1',
            'address2': 'Address Line 2',
            'notetext': 'Note Text'
        }


class AddReagentForm(forms.Form):
    reagent = forms.ModelMultipleChoiceField(queryset=Material.objects.all())
    reagent.widget.attrs.update({'data-live-search': 'true'})
    reagent.widget.attrs.update({'class': 'selectpicker form-control'})
