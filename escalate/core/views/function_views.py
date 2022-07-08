from typing import Optional, Dict, Any
import json
from django.http import HttpResponse, HttpRequest
from django.urls import reverse
from django.shortcuts import render, redirect
from django.contrib.messages import get_messages
from django.http.response import FileResponse, JsonResponse
from core.models import (
    ActionDef,
    ExperimentTemplate,
    ExperimentInstance,
    ParameterDef,
)
from core.dataclass import ExperimentData


def get_messages(request: HttpRequest) -> Optional[HttpResponse]:
    if request.method == "GET":
        return render(
            request,
            "core/generic/message.html",
            context={"messages": get_messages(request)},
        )


def download_manual_spec_file(request: HttpRequest) -> "FileResponse|JsonResponse":
    # form_data = request.session["experiment_create_form_data"]
    experiment_data: ExperimentData = request.session["experiment_data"]
    temp = experiment_data.generate_manual_spec_file()

    response = FileResponse(
        temp,
        as_attachment=True,
        filename=f"{experiment_data.experiment_name}_manual_{experiment_data.experiment_template.description}.xlsx",
    )
    return response


def experiment_invalid(request: HttpRequest, pk) -> Optional[HttpResponse]:
    """
    Experiment Invalid

    Used instead of default delete view to invalidate experiments in database.
    """
    if request.method == "POST":
        uuid = pk
        ExperimentInstance.objects.filter(uuid=uuid).update(completion_status="Invalid")

        if "experiment_pending_instance" in request.path:
            return redirect("experiment_pending_instance_list")
        elif "experiment_completed_instance" in request.path:
            return redirect("experiment_completed_instance_list")
        else:
            return JsonResponse(data={"message": "success"})


def create_action_def(request: HttpRequest) -> JsonResponse:
    if request.method == "POST":
        actiondef_desc = request.POST["actionDef_description"]
        try:
            ad, created = ActionDef.objects.get_or_create(description=actiondef_desc)

            for pdef_uuid in request.POST.getlist("parameterDefs"):
                pdef = ParameterDef.objects.get(uuid=pdef_uuid)
                ad.parameter_def.add(pdef)
            ad.save()
        except Exception as e:
            print(e)
            return JsonResponse(data={"message": "failure"})
        else:
            return JsonResponse(data={"message": "success"})


'''def parse_activity_data(activity_data: "Dict[str, Any]") -> str:
    activity_dict = {}
    start_nodes = 0
    end_nodes = 0
    for a in activity_data["activities"]:
        if a["type"] == "start":
            start_nodes += 1
        elif a["type"] == "end":
            end_nodes += 1
        else:
            activity_dict[a["id"]] = a
    if not start_nodes == 1 or not end_nodes == 1:
        return "ERROR: Action template not saved. Start or End nodes not found"

    for uid, a in activity_dict.items():
        a["state"]

    return "SUCCESS: Workflow successfully saved" '''


def save_experiment_action_template(request: HttpRequest) -> HttpResponse:
    if request.method == "POST":
        data = json.loads(request.POST["data"])
        exp_template = ExperimentTemplate.objects.get(uuid=data["exp_template"])
        # exp_template = ExperimentTemplate.objects.get(
        # uuid=request.session["experiment_template_uuid"]
        # )
        at_url = reverse("action_template", args=[str(exp_template.uuid)])
        exp_template.action_templates.add(at_url)
        return JsonResponse(data={"message": parse_activity_data(data)})

    return JsonResponse(data={"message": "success"})
