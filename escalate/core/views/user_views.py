#from escalate.core.models.app_tables import OrganizationPassword
from django.contrib import messages
from django.contrib.auth import update_session_auth_hash
from django.contrib.auth.forms import PasswordChangeForm
from django.contrib.auth.hashers import make_password, check_password
from django.shortcuts import render, redirect
from django.views import View
from django.views.generic.edit import FormView, CreateView, DeleteView, UpdateView
from django.contrib.auth.mixins import LoginRequiredMixin

from core.forms import (CustomUserCreationForm, PersonTableForm, 
                        JoinOrganizationForm, PersonForm)
from core.models.view_tables import Actor, Person, Organization
from core.models.app_tables import CustomUser, OrganizationPassword
from core.models.core_tables import PersonTable, OrganizationTable


class CreateUserView(View):
    template_name = 'core/accounts/create_user.html'

    def get(self, request, *args, **kwargs):
        user_form = CustomUserCreationForm()
        person_form = PersonTableForm()
        context = {'person_form': person_form,
                   'user_form': user_form}
        return render(request, self.template_name, context=context)

    def post(self, request, *args, **kwargs):
        person_form = PersonForm(request.POST)
        user_form = CustomUserCreationForm(request.POST)
        print('Person form is valid: {}'.format(person_form.is_valid()))
        if person_form.is_valid() and user_form.is_valid():
            print('User form is valid')
            person = person_form.save()
            print(person.pk)
            p = PersonTable.objects.get(pk=person.pk)

            user = user_form.save(commit=False)
            user.person = p
            user.save()

            messages.success(request, 'Account created successfully')
            return redirect('login')

        else:
            return render(request, self.template_name, {'person_form': person_form,
                                                        'user_form': user_form})

def change_password(request):
    if request.method == 'POST':
        form = PasswordChangeForm(request.user, request.POST)
        if form.is_valid():
            user = form.save()
            update_session_auth_hash(request, user)  # Important!
            messages.success(request, 'Your password was successfully updated!')
            return redirect('change_password')
        else:
            messages.error(request, 'Please correct the error below.')
    else:
        form = PasswordChangeForm(request.user)
    return render(request, 'core/accounts/change_password.html', {
        'form': form
    })

class UserProfileView(LoginRequiredMixin, View):
    template_name = 'core/accounts/user_profile.html'

    def get(self, request, *args, **kwargs):
        org_form = JoinOrganizationForm()
        vw_person = Person.objects.get(pk=request.user.person.pk)
        return render(request, self.template_name, {'org_form': org_form, 'vw_person': vw_person})

    def post(self, request, *args, **kwargs):
        if request.POST.get("add_org"):
            org_pwd = OrganizationPassword.objects.get(pk=request.POST['organization'])
            if check_password(request.POST['password'], org_pwd.password):
                person = Person.objects.get(pk=request.user.person.pk)
                organization = Organization.objects.get(pk=org_pwd.organization.pk)
                actor, created = Actor.objects.get_or_create(person=person, organization=organization)
                if created:
                    messages.success(request, f'Added to {org_pwd.organization} successfully')
                else:
                    messages.info(request, f'Already a member of {org_pwd.organization} no changes made')
            else:
                messages.error(request, f'Incorrect password for {org_pwd.organization}. Please contact admin for correct password')
            return redirect('user_profile')
            

class UserProfileEdit(LoginRequiredMixin, View):
    template_name = 'core/generic/edit.html'

    def get(self, request, *args, **kwargs):
        person_form = PersonTableForm(instance=request.user.person)
        context = {'form': person_form}
        return render(request, self.template_name, context=context)

    def post(self, request, *args, **kwargs):
        form = PersonTableForm(request.POST, instance=request.user.person)
        if form.is_valid():
            # process the data in form.cleaned_data as required (here we just write it to the model due_back field)
            form.save()

            # redirect to a new URL:
            return redirect('user_profile')
