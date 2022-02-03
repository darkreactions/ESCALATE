from django.shortcuts import render, redirect
from django.urls import reverse_lazy
from django.http import HttpResponse
from django.http import HttpResponseRedirect
from django.views import View
from django.urls import reverse


from django.contrib.auth.decorators import login_required
from django.utils.decorators import method_decorator

from plotly.offline import plot
from plotly.graph_objs import Scatter

from core.views.crud_views import LoginRequired
from core.models.view_tables import Actor, Person, Organization, ExperimentInstance


class SelectLabView(LoginRequired, View):
    template_name = "core/select_lab.html"

    def get(self, request):
        vw_person = Person.objects.get(pk=request.user.person.pk)
        # context = {"plot_div": plot_div, "user_person": vw_person}
        # return render(request, self.template_name, context=context)
        context = {"user_person": vw_person}
        return render(request, self.template_name, context=context)

    def post(self, request, *args, **kwargs):
        if "select_org" in request.POST:
            current_org = Organization.objects.get(pk=request.POST["org_select"])
            request.session["current_org_id"] = request.POST["org_select"]
            request.session["current_org_name"] = current_org.full_name
        # return render(request, self.template_name)
        return HttpResponseRedirect(reverse("main_menu"))


class MainMenuView(LoginRequired, View):
    template_name = "core/main_menu.html"

    # @method_decorator(login_required)
    def get(self, request, *args, **kwargs):
        users = Person.objects.count()
        experiments_created = ExperimentInstance.objects.count()
        experiments_completed = ExperimentInstance.objects.filter(completion_status="Completed").count()
        context = {"total_users": users, 
                   "total_experiments_created": experiments_created,
                   "total_experiments_completed": experiments_completed}
        return render(request, self.template_name, context=context)
