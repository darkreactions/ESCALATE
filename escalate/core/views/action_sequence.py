from core.views.crud_views import LoginRequired
from django.shortcuts import render
from django.views import View
import json
import core.models.view_tables as vt
from core.utilities import generate_action_def_json, generate_action_sequence_json
from core.forms.custom_types import ExperimentTemplateSelectForm, ActionSequenceNameForm
from django.http.request import HttpRequest
from django.http import HttpResponseRedirect
from django.urls import reverse
from django.contrib import messages
from core.views.function_views import save_experiment_action_sequence


class ActionSequenceView(LoginRequired, View):
    template_name = "core/action_sequence.html"
    form_class = ActionSequenceNameForm

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

        context["action_sequence_name_form"] = ActionSequenceNameForm
        # return render(request, self.template_name, context)

        with open("./core/static/json/http_components.json", "r") as f:
            http_components = f.read()

        with open("./core/static/json/http_workflow.json", "r") as f:
            http_workflow = f.read()

        with open("./core/static/json/mojito_components.json", "r") as f:
            mojito_components = f.read()

        with open("./core/static/json/mojito_workflow.json", "r") as f:
            mojito_workflow = f.read()

        with open("./core/static/json/action_def_components.json", "r") as f:
            action_def_components = f.read()

        with open("./core/static/json/action_def_workflow.json", "r") as f:
            action_def_workflow = f.read()

        # components = mojito_components
        # components = action_def_components

        # workflow = http_workflow
        # workflow = mojito_workflow
        workflow = action_def_workflow

        action_defs = [a for a in vt.ActionDef.objects.all()]
        temp = generate_action_def_json(action_defs)
        components = json.dumps(temp)

        context["components"] = components
        context["workflow"] = workflow

        return render(request, self.template_name, context=context)


class ExperimentActionSequenceView(LoginRequired, View):
    template_name = "core/experiment_action_sequence.html"
    form_class = ExperimentTemplateSelectForm

    def get_context_data(self, **kwargs):
        # Select materials that belong to the current lab
        context = {}
        if "current_org_id" in self.request.session:
            org_id = self.request.session["current_org_id"]
            lab = vt.Actor.objects.get(organization=org_id, person__isnull=True)
            # self.all_materials = InventoryMaterial.inventory.objects.filter(lab=lab)
            context["lab"] = lab
        # self.all_materials = InventoryMaterial.objects.all()
        # context['all_materials'] = self.all_materials
        return context

    # @method_decorator(login_required)
    def get(self, request, *args, **kwargs):

        context = self.get_context_data(**kwargs)

        if "current_org_id" in self.request.session:
            org_id = self.request.session["current_org_id"]
            context["experiment_template_select_form"] = ExperimentTemplateSelectForm(
                org_id=org_id
            )
        else:
            messages.error(request, "Please select a lab to continue")
            return HttpResponseRedirect(reverse("main_menu"))
            # return render(request, self.template_name, context)

        with open("./core/static/json/action_seq_workflow.json", "r") as f:
            action_seq_workflow = f.read()

        workflow = action_seq_workflow

        action_seqs = [a for a in vt.ActionSequence.objects.all()]
        temp = generate_action_sequence_json(action_seqs)
        components = json.dumps(temp)

        # context = {"components": components, "workflow": workflow}
        context["components"] = components
        context["workflow"] = workflow

        return render(request, self.template_name, context=context)
