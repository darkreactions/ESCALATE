from django.shortcuts import render, redirect
from django.http import HttpResponse
from django.views import View
from django.contrib import messages
from django.contrib.auth import login, authenticate
from django.db import transaction, IntegrityError

from core.forms import CustomUserCreationForm, PersonForm, LoginForm
from core.models.view_tables import Actor, Person
from core.models.app_tables import CustomUser

# Create your views here.


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
            p = Person.objects.filter(first_name=person.first_name,
                                      last_name=person.last_name).latest('add_date')

            user = user_form.save(commit=False)
            user.person = p
            user.save()

            actor = Actor(person_uuid=p,
                          actor_description=f'{p.first_name} {p.last_name}')
            actor.save()
            messages.success(request, 'Account created successfully')
            return redirect('login')

        else:
            return render(request, self.template_name, {'person_form': person_form,
                                                        'user_form': user_form})


"""
class LoginView(FormView):

    form_class = AuthenticationForm
    redirect_field_name = REDIRECT_FIELD_NAME
    template_name = 'registration/login.html'

    @method_decorator(csrf_protect)
    @method_decorator(never_cache)
    def dispatch(self, *args, **kwargs):
        return super(LoginView, self).dispatch(*args, **kwargs)

    def form_valid(self, form):

        login(self.request, form.get_user())
        return HttpResponseRedirect(self.get_success_url())

    def get_success_url(self):
        if self.success_url:
            redirect_to = self.success_url
        else:
            redirect_to = self.request.REQUEST.get(
                self.redirect_field_name, '')

        netloc = urlparse.urlparse(redirect_to)[1]
        if not redirect_to:
            redirect_to = settings.LOGIN_REDIRECT_URL
        # Security check -- don't allow redirection to a different host.
        elif netloc and netloc != self.request.get_host():
            redirect_to = settings.LOGIN_REDIRECT_URL
        return redirect_to

    def set_test_cookie(self):
        self.request.session.set_test_cookie()

    def check_and_delete_test_cookie(self):
        if self.request.session.test_cookie_worked():
            self.request.session.delete_test_cookie()
            return True
        return False

    def get(self, request, *args, **kwargs):
 
        self.set_test_cookie()
        return super(LoginView, self).get(request, *args, **kwargs)

    def post(self, request, *args, **kwargs):

        form_class = self.get_form_class()
        form = self.get_form(form_class)
        if form.is_valid():
            self.check_and_delete_test_cookie()
            return self.form_valid(form)
        else:
            self.set_test_cookie()
            return self.form_invalid(form)
"""
