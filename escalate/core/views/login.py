from django.shortcuts import render, redirect
from django.http import HttpResponse
from django.views import View
from django.contrib import messages
from django.contrib.auth import login, authenticate, logout
from django.db import transaction, IntegrityError

from core.forms import CustomUserCreationForm, PersonForm, LoginForm
from core.models.view_tables import Actor, Person
from core.models.app_tables import CustomUser


def logout_view(request):
    logout(request)
    return redirect('login')


class LoginView(View):
    template_name = 'core/login_page.html'

    def get(self, request, *args, **kwargs):
        login_form = LoginForm()
        return render(request, self.template_name, {'login_form': login_form})

    def post(self, request, *args, **kwargs):
        login_form = LoginForm(request.POST)
        if login_form.is_valid():
            username = login_form.cleaned_data.get('username')
            raw_password = login_form.cleaned_data.get('password')
            user = authenticate(username=username, password=raw_password)
            if user:
                login(request, user)
            if request.user.is_authenticated:

                return redirect('main_menu')
            else:
                messages.error(request, 'Error logging in')
                return render(request, self.template_name, {'login_form': login_form})
        else:
            return render(request, self.template_name, {'login_form': login_form})


class CreateUserView(View):
    template_name = 'core/create_user.html'

    def get(self, request, *args, **kwargs):
        user_form = CustomUserCreationForm()
        person_form = PersonForm()
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
            p = Person.objects.filter(first_name=person.first_name,
                                      last_name=person.last_name).latest('add_date')

            user = user_form.save(commit=False)
            user.person = p
            user.save()

            messages.success(request, 'Account created successfully')
            return redirect('login')

        else:
            return render(request, self.template_name, {'person_form': person_form,
                                                        'user_form': user_form})
