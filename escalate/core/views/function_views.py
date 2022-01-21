from django.http import HttpResponse, HttpRequest
from django.shortcuts import render
from django.contrib.messages import get_messages
from core.utilities.experiment_utils import get_action_parameter_querysets
from core.utilities.wf1_utils import generate_robot_file_wf1, make_well_labels_list
from django.http.response import FileResponse, JsonResponse
from core.models.app_tables import ActionSequenceDesign
from core.models import (
    Action,
    ActionSequence,
    ActionDef,
    ActionUnit,
    BaseBomMaterial,
    ExperimentActionSequence,
    ExperimentTemplate,
    Vessel,
)

# import json

# from escalate.core.models.view_tables.workflow import Workflow


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

        new_action_sequence = ActionSequence.objects.create(
            description="test"
        )  # TODO: add name/description upon saving a workflow in UI
        action_tuples = []

        # actions = [ # List of tuples (Description, Action def description, source_bommaterial, destination_bommaterial)``
        #    ('Preheat Plate', 'bring_to_temperature', (None, None), ('vessel', '96 Well Plate well'), 'Preheat Plate'),
        #    # Prepare stock A
        #   ('Add Solvent to Stock A', 'dispense', (None, 'Solvent'), (None, 'Stock A Vial'), 'Prepare stock A'),
        #     ('Add Organic to Stock A', 'dispense', (None, 'Organic'), (None, 'Stock A Vial'), 'Prepare stock A'),
        #    ('Add Inorganic to Stock A', 'dispense', (None, 'Inorganic'), (None, 'Stock A Vial'), 'Prepare stock A'),

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

                id=request.POST["activities[{}][id]".format(i)],
                    description=request.POST["activities[{}][type]".format(i)],
                    properties=prop,
                    top_position=request.POST["activities[{}][top]".format(i)],
                    left_position=request.POST["activities[{}][left]".format(i)],
                    connections=conn,

                a, created = ActionSequenceDesign.objects.create(
                    id=request.POST["activities[{}][id]".format(i)],
                    description=request.POST["activities[{}][type]".format(i)],
                    properties=prop,
                    top_position=request.POST["activities[{}][top]".format(i)],
                    left_position=request.POST["activities[{}][left]".format(i)],
                    connections=conn,
                )
                a.save()
                action_tuples.append()
    return JsonResponse(data={"message": "success"})

