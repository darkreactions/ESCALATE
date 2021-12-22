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
        print(request.POST)

        action_sequence_instance = ActionSequence.objects.create(
            description=request.POST["action_sequence_name"]
        )

        action_tuples = []

        ids = []
        # json.loads(request.POST["data"])
        for key, val in request.POST.items():
            if (
                "connections" in key
            ):  # more than one action - order sequentially based on connections
                index = key.split("[")[1].split("]")[0]
                id1 = request.POST["connections[{}][sourceActivityId]".format(index)]
                if id1 not in ids:
                    ids.append(id1)
                id2 = request.POST[
                    "connections[{}][destinationActivityId]".format(index)
                ]
                if id2 not in ids:
                    ids.append(id2)
            else:  # single action
                id1 = request.POST["activities[0][id]"]
                if id1 not in ids:
                    ids.append(id1)

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
                description=description,
                action_def=action_def,
                action_sequence=action_sequence_instance,
            )
            action.save()

            if source is not None:
                source_bbm = BaseBomMaterial.objects.create(description=source)
            else:
                source_bbm = None

            if "wells" in destination:  # individual well-level actions
                plate, created = Vessel.objects.get_or_create(
                    description=destination.split("wells")[0]
                )
                well_count = int(destination.split(" ")[0])
                well_list = make_well_labels_list(well_count=well_count, robot="True")
                plate_wells = {}
                for well in well_list:
                    plate_wells[well], created = Vessel.objects.get_or_create(
                        parent=plate, description=well
                    )
                for well_desc, well_vessel in plate_wells.items():
                    dest_bbm = BaseBomMaterial.objects.create(
                        description=f"{plate.description} : {well_desc}",
                        vessel=well_vessel,
                    )
                    if source_bbm:
                        description = f"{action.description} : {source_bbm.description} -> {dest_bbm.description}"
                    else:
                        description = f"{action.description} : {dest_bbm.description}"
                    au = ActionUnit.objects.create(
                        action=action,
                        source_material=source_bbm,
                        destination_material=dest_bbm,
                        description=description,
                    )
                    au.save()
            else:
                if "plate" in destination:  # plate-level actions
                    plate = Vessel.objects.get_or_create(description=destination)
                    dest_bbm = BaseBomMaterial.objects.create(
                        description=plate.description, vessel=plate
                    )
                    if source_bbm:
                        description = f"{action.description} : {source_bbm.description} -> {dest_bbm.description}"
                    else:
                        description = f"{action.description} : {dest_bbm.description}"

                    au = ActionUnit.objects.create(
                        action=action,
                        source_material=source_bbm,
                        description=description,
                        destination_material=dest_bbm,
                    )
                    au.save()

                else:
                    destination_bbm = BaseBomMaterial.objects.create(
                        description=destination
                    )
                    if source_bbm:
                        description = f"{action.description} : {source_bbm.description} -> {dest_bbm.description}"
                    else:
                        description = f"{action.description} : {dest_bbm.description}"
                    au = ActionUnit(
                        action=action,
                        source_material=source_bbm,
                        description=description,
                        destination_material=destination_bbm,
                    )

                    au.save()

            # if destination is not None:
            # destination_bbm = BaseBomMaterial.objects.create(
            # description=destination
            # )
            # else:
            # destination_bbm = None

            # au = ActionUnit.objects.create(
            # action=action,
            # source_material=source_bbm,
            # description=description,
            # destination_material=destination_bbm,
            # )

    return JsonResponse(data={"message": "success"})


def save_experiment_action_sequence(request: HttpRequest) -> HttpResponse:
    if request.method == "POST":
        print(request.POST)

        # experiment_action_sequence_instance = Workflow.objects.create(
        #   description="generalization_test"
        # )  # TODO: add option in UI to enter name upon saving

        exp_template = ExperimentTemplate.objects.get(uuid=request.POST["exp_template"])

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
                        uuid = request.POST["activities[{}][type]".format(index)]
                        top = request.POST["activities[{}][top]".format(index)]
                        left = request.POST["activities[{}][left]".format(index)]

                        a, created = ActionSequenceDesign.objects.get_or_create(
                            id=id,
                            description=uuid,
                            top_position=top,
                            left_position=left,
                        )
                        a.save()

                        action_sequence = ActionSequence.objects.get(uuid=uuid)
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
