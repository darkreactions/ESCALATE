from core.views.crud_views import LoginRequired
from django.shortcuts import render
from django.views import View
import json


class WorkflowView(LoginRequired, View):
    template_name = "core/workflow.html"

    # @method_decorator(login_required)
    def get(self, request, *args, **kwargs):
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

        #components = mojito_components
        components = action_def_components

        # workflow = http_workflow
        #workflow = mojito_workflow
        workflow = action_def_workflow

        context = {"components": components, "workflow": workflow}

        return render(request, self.template_name, context=context)
