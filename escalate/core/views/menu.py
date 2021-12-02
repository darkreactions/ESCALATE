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
from core.models.view_tables import Actor, Person, Organization


class SelectLabView(LoginRequired, View):
    template_name = "core/select_lab.html"

    def get(self, request):
        vw_person = Person.objects.get(pk=request.user.person.pk)
        #context = {"plot_div": plot_div, "user_person": vw_person}
        #return render(request, self.template_name, context=context)
        context = {"user_person": vw_person}
        return render(request, self.template_name, context=context)
    
    def post(self, request, *args, **kwargs):
            if "select_org" in request.POST:
                current_org = Organization.objects.get(pk=request.POST["org_select"])
                request.session["current_org_id"] = request.POST["org_select"]
                request.session["current_org_name"] = current_org.full_name
            #return render(request, self.template_name)
            return HttpResponseRedirect(reverse("main_menu"))

class MainMenuView(LoginRequired, View):
    template_name = "core/main_menu.html"

    # @method_decorator(login_required)
    def get(self, request, *args, **kwargs):
        x_data = [0, 1, 2, 3]
        y_data = [x ** 2 for x in x_data]
        plot_div = plot(
            [
                Scatter(
                    x=x_data,
                    y=y_data,
                    mode="lines",
                    name="test",
                    opacity=0.8,
                    marker_color="green",
                )
            ],
            output_type="div",
            include_plotlyjs=False,
        )
        #vw_person = Person.objects.get(pk=request.user.person.pk)
        context = {"plot_div": plot_div} #, "user_person": vw_person}
        return render(request, self.template_name, context=context)

