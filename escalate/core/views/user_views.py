# from escalate.core.models.app_tables import OrganizationPassword
from django.contrib import messages
from django.contrib.auth import update_session_auth_hash
from django.urls import reverse_lazy, reverse
from django.contrib.auth.forms import PasswordChangeForm
from django.contrib.auth.hashers import make_password, check_password
from django.shortcuts import render, redirect
from django.views import View
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView

from django.contrib.auth.mixins import LoginRequiredMixin

from core.forms.forms import (
    CustomUserCreationForm,
    PersonTableForm,
    JoinOrganizationForm,
    PersonForm,
)
from core.models.view_tables import Actor, Person, Organization, Edocument
from core.models.app_tables import CustomUser, OrganizationPassword
from core.models.core_tables import TypeDef
from core.forms.forms import UploadEdocForm
from django.forms import modelformset_factory


class CreateUserView(View):
    template_name = "core/accounts/create_user.html"

    def get(self, request, *args, **kwargs):
        user_form = CustomUserCreationForm()
        person_form = PersonTableForm()
        context = {"person_form": person_form, "user_form": user_form}
        return render(request, self.template_name, context=context)

    def post(self, request, *args, **kwargs):
        person_form = PersonForm(request.POST)
        user_form = CustomUserCreationForm(request.POST)
        if person_form.is_valid() and user_form.is_valid():
            person = person_form.save()
            p = Person.objects.get(pk=person.pk)

            user = user_form.save(commit=False)
            user.person = p
            user.save()

            messages.success(request, "Account created successfully")
            return redirect("login")

        else:
            return render(
                request,
                self.template_name,
                {"person_form": person_form, "user_form": user_form},
            )


def change_password(request):
    if request.method == "POST":
        form = PasswordChangeForm(request.user, request.POST)
        if form.is_valid():
            user = form.save()
            update_session_auth_hash(request, user)  # Important!
            messages.success(request, "Your password was successfully updated!")
            return redirect("change_password")
        else:
            messages.error(request, "Please correct the error below.")
    else:
        form = PasswordChangeForm(request.user)
    return render(request, "core/accounts/change_password.html", {"form": form})


class UserProfileView(LoginRequiredMixin, View):
    template_name = "core/accounts/user_profile.html"

    def get(self, request, *args, **kwargs):
        org_form = JoinOrganizationForm()
        vw_person = Person.objects.get(pk=request.user.person.pk)

        # get edocuments (profile picture)
        edocs_raw = Edocument.objects.filter(
            ref_edocument_uuid=request.user.person.pk,
            title=str(request.user.username) + "_avatar",
        )

        edocs = []
        for edoc in edocs_raw:
            filename = edoc.filename

            # redirect to api link to download
            download_url = reverse("edoc_download", args=(edoc.uuid,))
            edocs.append({"filename": filename, "download_url": download_url})

        context = {"org_form": org_form, "vw_person": vw_person}
        if len(edocs) > 0:
            context["profile_pic_edoc"] = edocs[0]
        else:
            context["profile_pic_edoc"] = None
        return render(request, self.template_name, context)

    def post(self, request, *args, **kwargs):
        if request.POST.get("add_org"):
            org_pwd = OrganizationPassword.objects.get(pk=request.POST["organization"])
            if check_password(request.POST["password"], org_pwd.password):
                person = Person.objects.get(pk=request.user.person.pk)
                organization = Organization.objects.get(pk=org_pwd.organization.pk)
                actor, created = Actor.objects.get_or_create(
                    person=person, organization=organization
                )
                if created:
                    messages.success(
                        request, f"Added to {org_pwd.organization} successfully"
                    )
                else:
                    messages.info(
                        request,
                        f"Already a member of {org_pwd.organization} no changes made",
                    )
            else:
                messages.error(
                    request,
                    f"Incorrect password for {org_pwd.organization}. Please contact admin for correct password",
                )
        elif request.POST.get("leave_org"):
            org_pwd = OrganizationPassword.objects.get(pk=request.POST["organization"])
            if check_password(request.POST["password"], org_pwd.password):
                person = Person.objects.get(pk=request.user.person.pk)
                organization = Organization.objects.get(pk=org_pwd.organization.pk)
                actor = Actor.objects.get(
                    person=person, organization=organization
                )
                actor.delete()
                #if created:
                #    messages.success(
                #        request, f"Removed from {org_pwd.organization} successfully"
                #    )
                #else:
                #    messages.info(
                #        request,
                #        f"Not a member of {org_pwd.organization} no changes made",
                #    )
            else:
                messages.error(
                    request,
                    f"Incorrect password for {org_pwd.organization}. Please contact admin for correct password",
                )
        
        return redirect("user_profile")


class UserProfileEdit(LoginRequiredMixin, View):
    template_name = "core/generic/edit.html"
    EdocFormSet = modelformset_factory(Edocument, form=UploadEdocForm, can_delete=True)

    def get(self, request, *args, **kwargs):
        # context = super().get_context_data(**kwargs)
        person_form = PersonTableForm(instance=request.user.person)
        profile_image_edoc = Edocument.objects.filter(
            ref_edocument_uuid=request.user.person.pk,
            title=str(request.user.username) + "_avatar",
        )
        # if user already has a picture, load the edocUpload form for that specific edocument picture
        # if not, create new form

        if len(profile_image_edoc) > 0:
            edoc_form = UploadEdocForm(instance=profile_image_edoc[0])
        else:
            edoc_form = UploadEdocForm()
        context = {"form": person_form}
        # upload profile image
        context["edoc_form"] = edoc_form
        return render(request, self.template_name, context=context)

    def post(self, request, *args, **kwargs):
        form = PersonTableForm(request.POST, instance=request.user.person)
        profile_image_edoc = Edocument.objects.get_or_create(
            ref_edocument_uuid=request.user.person.pk,
            title=str(request.user.username) + "_avatar",
        )
        edocumentForm = UploadEdocForm(
            request.POST, request.FILES, instance=profile_image_edoc[0]
        )

        if self.request.user.is_authenticated:
            if form.is_valid() and edocumentForm.is_valid():

                # process the data in form.cleaned_data as required (here we just write it to the model due_back field)
                profile_form = form.save(commit=False)

                profile_form.title = request.POST.getlist("title")[0]
                profile_form.save()

                edoc = edocumentForm.save(commit=False)
                edoc.title = str(request.user.username) + "_avatar"
                if edocumentForm.cleaned_data["file"]:
                    # New edoc or update file of existing edoc

                    file = edocumentForm.cleaned_data["file"]
                    # Hopefuly every file name is structed as <name>.<ext>
                    _file_name_detached, ext, *_ = file.name.split(".")

                    edoc.edocument = file.read()
                    edoc.filename = file.name

                    # file type that the user entered
                    file_type_user = edocumentForm.cleaned_data["file_type"]

                    # try to get the file_type from db that is spelled the same as the file extension
                    try:
                        file_type_db = TypeDef.objects.get(
                            category="file", description=ext
                        )
                    except TypeDef.DoesNotExist:
                        file_type_db = None

                    if file_type_db:
                        # found find file type corresponding to file extension
                        # use that file type instead of what user entered
                        edoc.doc_type_uuid = file_type_db
                    else:
                        # did not find file type corresponding to file extension
                        # use file type user entered in form
                        edoc.doc_type_uuid = file_type_user

                # Get the appropriate actor and then add it to the edoc
                actor = Actor.objects.get(
                    person=self.request.user.person.pk, organization=None
                )
                edoc.actor = actor
                # Get the appropriate uuid of the record being changed.
                edoc.ref_edocument_uuid = self.request.user.person.pk
                edoc.save()

        return redirect("user_profile")

    def form_valid(self, form):
        self.object = form.save()

        if self.EdocFormSet != None:
            actor = Actor.objects.get(
                person=self.request.user.person.pk, organization=None
            )
            formset = self.EdocFormSet(
                self.request.POST, self.request.FILES, prefix="edoc"
            )
            # Loop through every edoc form
            for form in formset:
                # Only if the form has changed make an update, otherwise ignore
                if form.has_changed() and form.is_valid():
                    if self.request.user.is_authenticated:
                        edoc = form.save(commit=False)
                        if form.cleaned_data["file"]:
                            # New edoc or update file of existing edoc

                            file = form.cleaned_data["file"]
                            # Hopefuly every file name is structed as <name>.<ext>
                            _file_name_detached, ext, *_ = file.name.split(".")

                            edoc.edocument = file.read()
                            edoc.filename = file.name

                            # file type that the user entered
                            file_type_user = form.cleaned_data["file_type"]

                            # try to get the file_type from db that is spelled the same as the file extension
                            try:
                                file_type_db = TypeDef.objects.get(
                                    category="file", description=ext
                                )
                            except TypeDef.DoesNotExist:
                                file_type_db = None

                            if file_type_db:
                                # found find file type corresponding to file extension
                                # use that file type instead of what user entered
                                edoc.doc_type_uuid = file_type_db
                            else:
                                # did not find file type corresponding to file extension
                                # use file type user entered in form
                                edoc.doc_type_uuid = file_type_user

                        # Get the appropriate actor and then add it to the edoc
                        edoc.actor = actor
                        # Get the appropriate uuid of the record being changed.
                        edoc.ref_edocument_uuid = self.object.pk
                        edoc.save()

            # Delete each note we marked in the formset
            formset.save(commit=False)
            for form in formset.deleted_forms:
                form.instance.delete()
            # Choose which website we are redirected to
            if self.request.POST.get("add_edoc"):
                self.success_url = reverse_lazy(
                    f"{self.context_object_name}_update", kwargs={"pk": self.object.pk}
                )

        return redirect("user_profile")

    def form_invalid(self, form):
        context = self.get_context_data()
        context["form"] = form
        return render(self.request, self.template_name, context)
