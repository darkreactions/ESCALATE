from django.http import HttpResponse, HttpRequest
from django.shortcuts import render
from django.contrib.messages import get_messages
from core.utilities.experiment_utils import get_action_parameter_querysets
from core.utilities.wf1_utils import generate_robot_file_wf1
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
)

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
        print(request.POST)

        action_sequence_instance = ActionSequence.objects.create(
            description="generalization_test"
        )  # TODO: add option in UI to enter name upon saving

        action_tuples = []

        ids = []
        for key, val in request.POST.items():
            if "connections" in key:
                index = key.split("[")[1].split("]")[0]
                id1 = request.POST["connections[{}][sourceActivityId]".format(index)]
                if id1 not in ids:
                    ids.append(id1)
                id2 = request.POST[
                    "connections[{}][destinationActivityId]".format(index)
                ]
                if id2 not in ids:
                    ids.append(id2)

        for entry in ids:
            for key, val in request.POST.items():
                if "activities" in key:
                    if val == entry:
                        id = entry
                        index = key.split("[")[1].split("]")[0]
                        description = request.POST["activities[{}][type]".format(index)]
                        top = request.POST["activities[{}][top]".format(index)]
                        left = request.POST["activities[{}][left]".format(index)]
                        properties = {}
                        for key, val in request.POST.items():
                            if "activities[{}][state]".format(index) in key:
                                property_type = str(key).split("[")[3].split("]")[0]
                                properties[property_type] = val

                        action_tuples.append(
                            (
                                id,
                                description,
                                properties["source"],
                                properties["destination"],
                            )
                        )

                        a, created = ActionSequenceDesign.objects.get_or_create(
                            id=id,
                            description=description,
                            properties=properties,
                            top_position=top,
                            left_position=left,
                        )
                        a.save()

        for action_tuple in action_tuples:
            id, description, source, destination = action_tuple
            action_def, created = ActionDef.objects.get_or_create(
                description=description
            )
            action = Action.objects.create(
                description="generalization_test",
                action_def=action_def,
                action_sequence=action_sequence_instance,
            )
            action.save()

            if source is not None:
                source_bbm = BaseBomMaterial.objects.create(description=source)
            else:
                source_bbm = None

            if destination is not None:
                destination_bbm = BaseBomMaterial.objects.create(
                    description=destination
                )
            else:
                destination_bbm = None

            au = ActionUnit.objects.create(
                action=action,
                source_material=source_bbm,
                description=description,
                destination_material=destination_bbm,
            )

            au.save()

    return JsonResponse(data={"message": "success"})


def save_experiment_action_sequence(request: HttpRequest) -> HttpResponse:
    if request.method == "POST":
        print(request.POST)

        # experiment_action_sequence_instance = Workflow.objects.create(
        #   description="generalization_test"
        # )  # TODO: add option in UI to enter name upon saving

        exp_template = ExperimentTemplate.objects.filter(description="test")[0]

        action_sequences = []

        ids = []
        for key, val in request.POST.items():
            if "connections" in key:
                index = key.split("[")[1].split("]")[0]
                id1 = request.POST["connections[{}][sourceActivityId]".format(index)]
                if id1 not in ids:
                    ids.append(id1)
                id2 = request.POST[
                    "connections[{}][destinationActivityId]".format(index)
                ]
                if id2 not in ids:
                    ids.append(id2)

        for entry in ids:
            for key, val in request.POST.items():
                if "activities" in key:
                    if val == entry:
                        id = entry
                        index = key.split("[")[1].split("]")[0]
                        description = request.POST["activities[{}][type]".format(index)]
                        top = request.POST["activities[{}][top]".format(index)]
                        left = request.POST["activities[{}][left]".format(index)]

                        a, created = ActionSequenceDesign.objects.get_or_create(
                            id=id,
                            description=description,
                            top_position=top,
                            left_position=left,
                        )
                        a.save()

                        action_sequence = ActionSequence.objects.filter(
                            description=description
                        )[0]
                        action_sequences.append(action_sequence)

        for i, a in enumerate(action_sequences):
            ac_sq = ActionSequence.objects.filter(description=a)[0]
            eas = ExperimentActionSequence(
                experiment_template=exp_template,
                experiment_action_sequence_seq=i,
                action_sequence=ac_sq,
            )
            eas.save()

    return JsonResponse(data={"message": "success"})
