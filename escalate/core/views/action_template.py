from core.views.crud_views import LoginRequired
from django.shortcuts import render
from django.views import View
import json
import core.models.view_tables as vt
from core.utilities import generate_action_def_json
from core.forms.custom_types import ExperimentTemplateSelectForm, ActionSequenceNameForm
from django.http.request import HttpRequest
from django.http import HttpResponseRedirect
from django.urls import reverse
from django.contrib import messages

from pathlib import Path

# from core.views.function_views import save_experiment_action_sequence


class ActionTemplateView(LoginRequired, View):
    template_name = "core/action_template.html"
    form_class = ExperimentTemplateSelectForm
    # form_class = ActionSequenceNameForm

    def get_context_data(self, **kwargs):
        context = {}
        if "current_org_id" in self.request.session:
            org_id = self.request.session["current_org_id"]
            lab = vt.Actor.objects.get(organization=org_id, person__isnull=True)
            context["lab"] = lab
        return context

    # @method_decorator(login_required)
    def get(self, request, *args, **kwargs):

        context = self.get_context_data(**kwargs)

        if "current_org_id" in self.request.session:
            org_id = self.request.session["current_org_id"]
            # context["experiment_template_select_form"] = ExperimentTemplateSelectForm(
            # org_id=org_id
            # )
        else:
            messages.error(request, "Please select a lab to continue")
            return HttpResponseRedirect(reverse("main_menu"))

        # context["action_sequence_name_form"] = ActionSequenceNameForm
        # return render(request, self.template_name, context)

        base_path = Path("./core/static/json/")
        base_path2 = Path("./escalate/core/static/json/")
        """
        with base_path / Path("http_components.json").open("r") as f:
            http_components = f.read()

        with open("./core/static/json/http_workflow.json", "r") as f:
            http_workflow = f.read()

        with open("./core/static/json/mojito_components.json", "r") as f:
            mojito_components = f.read()

        with open("./core/static/json/mojito_workflow.json", "r") as f:
            mojito_workflow = f.read()

        with open("./core/static/json/action_def_components.json", "r") as f:
            action_def_components = f.read()
        """

        path = base_path / Path("action_def_workflow.json")
        if not path.exists():
            path = base_path2 / Path("action_def_workflow.json")

        with path.open("r") as f:
            action_def_workflow = f.read()

        workflow = action_def_workflow

        action_defs = [a for a in vt.ActionDef.objects.all()]
        # exp_template = vt.ExperimentTemplate(uuid=request.META["PATH_INFO"].split("/"))
        exp_template_uuid = kwargs["pk"]
        temp = generate_action_def_json(action_defs, exp_template_uuid)

        components = json.dumps(temp)

        context["components"] = components
        context["workflow"] = workflow
        context["exp_template"] = exp_template_uuid

        return render(request, self.template_name, context=context)
