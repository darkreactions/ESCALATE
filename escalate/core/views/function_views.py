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
    '''
    Create a new action def if missing from database

    included here for url patterns. see functions within action_template.py for functionality
    '''
    return JsonResponse(data={"message": "success"})


def save_experiment_action_template(request: HttpRequest) -> HttpResponse:
    '''
    Save action template from workflow designer
    
    included here for url patterns. see functions within action_template.py for functionality
    '''
    return JsonResponse(data={"message": "success"})
