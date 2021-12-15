from django.http import HttpResponse, HttpRequest
from django.shortcuts import render
from django.contrib.messages import get_messages
from core.utilities.experiment_utils import get_action_parameter_querysets
from core.utilities.wf1_utils import generate_robot_file_wf1
from django.http.response import FileResponse, JsonResponse
from core.models.app_tables import ActionSequenceDesign


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


def save_action_sequence(request: HttpRequest) -> HttpResponse:
    if request.method == "POST":
        # print(request.POST.keys())
        print(request.POST)
        for i in range(len(request.POST)):
            if "activities[{}][id]".format(i) in request.POST.keys():
                prop = {}
                for key, val in request.POST.items():
                    if "activities[{}][state]".format(i) in key:
                        prop_type = str(key).split("[")[3].split("]")[0]
                        prop[prop_type] = val
                conn = {}
                conn["before"] = request.POST[
                    "connections[{}][sourceActivityId]".format(i)
                ]
                conn["after"] = request.POST[
                    "connections[{}][destinationActivityId]".format(i)
                ]

                id = request.POST["activities[{}][id]".format(i)]
                description = request.POST["activities[{}][type]".format(i)]
                properties = prop
                top_position = request.POST["activities[{}][top]".format(i)]
                left_position = request.POST["activities[{}][left]".format(i)]
                connections = conn

                a, created = ActionSequenceDesign.objects.create(
                    id=request.POST["activities[{}][id]".format(i)],
                    description=request.POST["activities[{}][type]".format(i)],
                    properties=prop,
                    top_position=request.POST["activities[{}][top]".format(i)],
                    left_position=request.POST["activities[{}][left]".format(i)],
                    connections=conn,
                )
                a.save()
    return JsonResponse(data={"message": "success"})


def parse_design_action_sequence(request: HttpRequest) -> HttpResponse:

    for i in range(len(request.POST)):
        if "activities[{}][id]".format(i) in request.POST.keys():
            prop = {}
            for key, val in request.POST.items():
                if "activities[{}][state]".format(i) in key:
                    prop[i] = val

            a, created = ActionSequenceDesign.objects.create(
                id=request.POST["activities[{}][id]".format(i)],
                description=request.POST["activities[{}][type]".format(i)],
                properties=prop,
                top_position=request.POST["activities[{}][top]".format(i)],
                left_position=request.POST["activities[{}][left]".format(i)],
            )
            a.save()
