from django.http import HttpResponse, HttpRequest
from django.shortcuts import render
from django.contrib.messages import get_messages
from core.utilities.experiment_utils import get_action_parameter_querysets
from core.utilities.wf1_utils import generate_robot_file_wf1
from django.http.response import FileResponse


def get_messages(request: HttpRequest) -> HttpResponse:
    if request.method == "GET":
        return render(
            request,
            "core/generic/message.html",
            context={"messages": get_messages(request)},
        )


def download_robot_file(request: HttpRequest) -> HttpResponse:
    exp_uuid: str = request.session["experiment_template_uuid"]
    q1 = get_action_parameter_querysets(exp_uuid)  # volumes
    f = generate_robot_file_wf1(q1, {}, "Symyx_96_well_0003", 96)
    response = FileResponse(f, as_attachment=True, filename=f"robot_{exp_uuid}.xls")
    return response
