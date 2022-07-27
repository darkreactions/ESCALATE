import django
from core.models import CustomUser, OrganizationPassword
from core.models.core_tables import TypeDef
from core.models.view_tables import (
    Actor,
    Edocument,
    Inventory,
    Note,
    Person,
    SystemtoolType,
    Tag,
    TagAssign,
    TagType,
)
from crispy_forms.layout import Submit
from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.hashers import make_password
from django.urls import reverse_lazy
from packaging import version

if version.parse(django.__version__) < version.parse("3.1"):
    from django.contrib.postgres.forms import JSONField
else:
    from django.forms import JSONField

from crispy_forms.helper import FormHelper
from crispy_forms.layout import Column, Field, Layout, Row

dropdown_attrs = {
    "class": "selectpicker",
    "data-style": "btn-outline-primary",
    "data-live-search": "true",
}


class LoginForm(forms.Form):
    username = forms.CharField(max_length=100)
    password = forms.CharField(widget=forms.PasswordInput())


class CustomUserCreationForm(UserCreationForm):
    class Meta:
        model = CustomUser
        fields = ["username", "password1", "password2"]


class NoteForm(forms.ModelForm):
    class Meta:
        model = Note
        fields = ["notetext"]
        widgets = {
            "notetext": forms.Textarea(attrs={"rows": 3}),
        }


class PersonFormData:
    class Meta:
        fields = [
            "first_name",
            "middle_name",
            "last_name",
            "address1",
            "address2",
            "city",
            "state_province",
            "zip",
            "country",
            "phone",
            "email",
            "title",
            "suffix",
            "organization",
        ]
        field_classes = {
            "first_name": forms.CharField,
            "middle_name": forms.CharField,
            "last_name": forms.CharField,
            "address1": forms.CharField,
            "address2": forms.CharField,
            "city": forms.CharField,
            "state_province": forms.CharField,
            "zip": forms.CharField,
            "country": forms.CharField,
            "phone": forms.CharField,
            "email": forms.EmailField,
            "title": forms.CharField,
            "suffix": forms.CharField,
        }

        labels = {
            "first_name": "First Name",
            "middle_name": "Middle Name",
            "last_name": "Last Name",
            "address1": "Address Line 1",
            "address2": "Address Line 2",
            "city": "City",
            "state_province": "State/Province",
            "zip": "Zip",
            "country": "Country",
            "phone": "Phone",
            "email": "E-mail",
            "title": "Title",
            "suffix": "Suffix",
            "organization": "Organization",
        }

        help_texts = {
            "phone": "Include extension number and/or country code if applicable",
            "organization": "If applicable, select the organization this person belongs to",
        }

        widgets = {
            "first_name": forms.TextInput(attrs={"placeholder": "Your first name"}),
            "middle_name": forms.TextInput(attrs={"placeholder": "Your middle name"}),
            "last_name": forms.TextInput(attrs={"placeholder": "Your last name"}),
            "address1": forms.TextInput(attrs={"placeholder": "Ex: 123 Smith Street"}),
            "address2": forms.TextInput(attrs={"placeholder": "Ex: Apt. 2c"}),
            "city": forms.TextInput(attrs={"placeholder": "Ex: San Francisco"}),
            "state_province": forms.TextInput(attrs={"placeholder": "Ex: CA"}),
            "zip": forms.TextInput(attrs={"placeholder": "Ex: 12345/12345-6789"}),
            "country": forms.TextInput(
                attrs={"placeholder": "Ex: United States of America"}
            ),
            "phone": forms.TextInput(
                attrs={"placeholder": "Ex: 1-234-567-8900/12345678900"}
            ),
            "email": forms.TextInput(attrs={"placeholder": "Ex: example@gmail.com"}),
            "title": forms.TextInput(attrs={"placeholder": ""}),
            "suffix": forms.TextInput(attrs={"placeholder": ""}),
            "organization": forms.Select(attrs=dropdown_attrs),
        }


class PersonForm(PersonFormData, forms.ModelForm):
    class Meta(PersonFormData.Meta):
        model = Person


class PersonTableForm(PersonFormData, forms.ModelForm):
    class Meta(PersonFormData.Meta):
        model = Person


class InventoryForm(forms.ModelForm):
    class Meta:
        model = Inventory
        fields = ["description", "owner", "operator", "lab", "status", "actor"]

        field_classes = {
            "description": forms.CharField,
            "part_no": forms.CharField,
            "onhand_amt": JSONField,
            "expiration_date": forms.SplitDateTimeField,
            "location": forms.CharField,
        }
        labels = {
            "description": "Description",
            "material": "Material",
            "actor": "Actor",
            "part_no": "Part Number",
            "onhand_amt": "On hand amount",
            "expiration_date": "Expiration date",
            "location": "Inventory location",
        }
        widgets = {
            "material": forms.Select(attrs=dropdown_attrs),
            "actor": forms.Select(attrs=dropdown_attrs),
            "description": forms.Textarea(
                attrs={"rows": "3", "cols": "10", "placeholder": "Description"}
            ),
            "part_no": forms.TextInput(attrs={"placeholder": "Part number"}),
            "onhand_amt": forms.TextInput(attrs={"placeholder": "On hand amount"}),
            "expiration_date": forms.SplitDateTimeWidget(
                date_format="%d-%m-%Y",
                date_attrs={"placeholder": "DD-MM-YYYY"},
                time_format="%H:%M",
                time_attrs={"placeholder": "HH-MM"},
            ),
            "location": forms.TextInput(attrs={"placeholder": "Location"}),
            "status": forms.Select(attrs=dropdown_attrs),
        }


class ActorForm(forms.ModelForm):
    class Meta:
        model = Actor

        fields = ["person", "organization", "systemtool", "description", "status"]

        field_classes = {"description": forms.CharField}
        labels = {
            "person": "Person",
            "organization": "Organization",
            "systemtool": "Systemtool",
            "description": "Actor description",
            "status": "Actor status",
        }
        help_texts = {
            "person": "Select if actor is a person",
            "organization": "Select if actor is an organization",
            "systemtool": "Select if actor is a systemtool",
        }
        widgets = {
            "description": forms.Textarea(
                attrs={"rows": "3", "cols": "10", "placeholder": "Your description"}
            ),
            "person": forms.Select(attrs=dropdown_attrs),
            "organization": forms.Select(attrs=dropdown_attrs),
            "systemtool": forms.Select(attrs=dropdown_attrs),
            "status": forms.Select(attrs=dropdown_attrs),
        }


class SystemtoolTypeForm(forms.ModelForm):
    class Meta:
        model = SystemtoolType
        fields = ["description"]
        labels = {"description": "Description"}
        widgets = {
            "description": forms.Textarea(
                attrs={
                    "cols": "10",
                    "rows": "3",
                    "placeholder": "Your system tool type description",
                }
            )
        }


class TagTypeForm(forms.ModelForm):
    class Meta:
        model = TagType
        fields = ["type", "description"]
        labels = {
            "type": "Tag Type Short Description",
            "description": "Tag Type Long Description",
        }
        widgets = {
            "type": forms.TextInput(
                attrs={"placeholder": "Enter your name of the tag type"}
            ),
            "description": forms.Textarea(
                attrs={
                    "cols": "10",
                    "rows": "3",
                    "placeholder": "Detail description for your tag type",
                }
            ),
        }


class TagSelectForm(forms.Form):
    def __init__(self, *args, **kwargs):
        # pk of model that is passed in to filter for tags belonging to the model
        if "model_pk" in kwargs:
            self.model_pk = kwargs.pop("model_pk")
            current_tags = Tag.objects.filter(
                pk__in=TagAssign.objects.filter(ref_tag=self.model_pk).values_list(
                    "tag", flat=True
                )
            )
        else:
            current_tags = Tag.objects.none()

        if "queryset" in kwargs:
            queryset = kwargs.pop("queryset")
        else:
            queryset = Tag.objects.all()
        super(TagSelectForm, self).__init__(*args, **kwargs)

        self.fields["tags"] = forms.ModelMultipleChoiceField(
            initial=current_tags, required=False, queryset=queryset
        )
        # self.fields['tags'].widget.attrs.update({'data-live-search': 'true'})
        self.fields["tags"].widget.attrs.update(dropdown_attrs)
        self.fields[
            "tags"
        ].help_text = (
            f'To create a new tag, <a href="{reverse_lazy("tag_add")}">click here</a>'
        )
        self.get_helper()

    def update_tags(self):
        """
        Call this function to update the selected tags to the model assigned
        """
        submitted_tags = self.cleaned_data["tags"]
        # tags from db with a TagAssign that connects the model and the tags
        existing_tags = Tag.objects.filter(
            pk__in=TagAssign.objects.filter(ref_tag=self.model_pk).values_list(
                "tag", flat=True
            )
        )
        for tag in existing_tags:
            if tag not in submitted_tags:
                # this tag is not assign to this model anymore
                # delete TagAssign for existing tags that are no longer used
                TagAssign.objects.filter(tag=tag).delete()
        for tag in submitted_tags:
            # make TagAssign for existing tags that are now used
            if tag not in existing_tags:
                tag_assign = TagAssign.objects.create(tag=tag, ref_tag=self.model_pk)

    def get_helper(self):
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-3"
        helper.field_class = "col-lg-8"
        helper.form_tag = False
        self.helper = helper


class UploadEdocForm(forms.ModelForm):
    def __init__(self, *args, **kwargs):
        super(UploadEdocForm, self).__init__(*args, **kwargs)

        self.fields["title"].required = True
        current_file_type = self.instance.edoc_type_uuid if self.instance else None

        # file needs to be not required because it can't have an initial value
        # so, if it is required, django will say the form is invalid even though
        # a form is preloaded from an existing edocument from the db
        self.fields["file"] = forms.FileField(required=False)
        self.fields["file_type"] = forms.ModelChoiceField(
            initial=current_file_type,
            required=False,
            queryset=TypeDef.objects.filter(category="file"),
        )
        self.fields["file_type"].widget.attrs.update(dropdown_attrs)

    class Meta:
        model = Edocument
        fields = ["title", "description", "source"]
        field_classes = {"description": forms.CharField}
        labels = {"title": "Document Title", "description": "Description"}
        widgets = {
            "description": forms.Textarea(
                attrs={
                    "cols": "10",
                    "rows": "3",
                    "placeholder": "Your file description",
                }
            )
        }


class UploadFileForm(forms.Form):
    file = forms.FileField(label="Upload file", required=False)
    # upload_edoc = forms.Select(label='Submit')
    @staticmethod
    def get_helper():
        helper = FormHelper()
        helper.form_class = "form-horizontal"
        helper.label_class = "col-lg-2"
        helper.field_class = "col-lg-8"
        helper.layout = Layout(
            Row(Column(Field("file"))),
            # Row(Column(Submit('upload_edoc', 'Submit'))),
        )
        return helper


class JoinOrganizationForm(forms.ModelForm):
    def __init__(self, *args, **kwargs):
        super(JoinOrganizationForm, self).__init__(*args, **kwargs)
        self.fields["organization"].queryset = OrganizationPassword.objects.all()

    class Meta:
        model = OrganizationPassword
        fields = ["organization", "password"]
        widgets = {"password": forms.PasswordInput()}


class LeaveOrganizationForm(forms.ModelForm):
    def __init__(self, *args, **kwargs):
        super(LeaveOrganizationForm, self).__init__(*args, **kwargs)
        self.fields["organization"].queryset = OrganizationPassword.objects.all()

    class Meta:
        model = OrganizationPassword
        fields = ["organization", "password"]
        widgets = {"password": forms.PasswordInput()}


class CreateOrganizationPasswordForm(forms.ModelForm):
    def save(self, commit=True):
        instance = super(CreateOrganizationPasswordForm, self).save(commit=False)
        instance.password = make_password(instance.password)
        if commit:
            instance.save()
        return instance

    class Meta:
        model = OrganizationPassword
        fields = ["organization", "password"]
        widgets = {"password": forms.PasswordInput()}
