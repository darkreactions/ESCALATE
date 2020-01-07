from django import forms
from django.contrib.auth.forms import UserCreationForm, UserChangeForm
from .models import CustomUser, Person, Material, Inventory, Actor, Note


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
        fields = ['description', 'parent_material', 'status', 'notetext']


class InventoryForm(forms.ModelForm):
    class Meta:
        model = Inventory
        fields = ['description', 'material', 'actor', 'part_no', 'onhand_amt', 'unit',
                  'measure_id', 'create_date', 'inventory_location', 'status', 'document_id', 'note']


class ActorForm(forms.ModelForm):
    class Meta:
        model = Actor
        fields = ['person', 'organization', 'systemtool', 'description', 'status',
                  'note']
