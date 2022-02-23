from django.http import HttpResponse, HttpRequest, HttpResponseRedirect
from django.shortcuts import render, redirect
from django.contrib.messages import get_messages
from core.utilities.experiment_utils import get_action_parameter_querysets
from core.utilities.utils import generate_vp_spec_file
from django.http.response import FileResponse, JsonResponse
from core.models.app_tables import ActionSequenceDesign
from core.models import (
    Action,
    ActionSequence,
    ActionDef,
    ExperimentActionSequence,
    ExperimentTemplate,
    ExperimentInstance,
    Vessel,
)


def get_messages(request: HttpRequest) -> HttpResponse:
    if request.method == "GET":
        return render(
            request,
            "core/generic/message.html",
            context={"messages": get_messages(request)},
        )


def download_vp_spec_file(request: HttpRequest) -> HttpResponse:
    exp_uuid: str = request.session["experiment_template_uuid"]
    vessel = Vessel.objects.get(uuid=request.session["vessel"])
    q1 = get_action_parameter_querysets(exp_uuid)  # volumes
    f = generate_vp_spec_file(q1, {}, vessel.description, vessel.well_number)
    # f = generate_robot_file_wf1(q1, {}, "Symyx_96_well_0003", 96)
    response = FileResponse(f, as_attachment=True, filename=f"manual_{exp_uuid}.xls")
    return response


def experiment_invalid(request: HttpRequest, pk):
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


def save_experiment_action_sequence(request: HttpRequest) -> HttpResponse:
    if request.method == "POST":
        print(request.POST)

        exp_template = ExperimentTemplate.objects.get(uuid=request.POST["exp_template"])
        # exp_template = ExperimentTemplate.objects.get(
        # uuid=request.session["experiment_template_uuid"]
        # )

        action_sequence_instance = ActionSequence.objects.create(
            description="{}_action_sequence".format(exp_template.description)
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

        if len(ids) == 0:  # single action
            id1 = request.POST["activities[0][id]"]
            if id1 not in ids:
                ids.append(id1)

        for num, entry in enumerate(ids):
            for key, val in request.POST.items():
                if "activities" in key:
                    if val == entry:
                        # action_sequence = action_sequence_instance.uuid
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

                        order = num
                        action_tuples.append(
                            (
                                id,
                                description,
                                properties["source"],
                                properties["destination"],
                            )
                        )

                        if properties["source"] == "":
                            properties["source"] = None

                        a, created = ActionSequenceDesign.objects.get_or_create(
                            action_sequence=action_sequence_instance,
                            id=id,
                            description=description,
                            # properties=properties,
                            source=properties["source"],
                            destination=properties["destination"],
                            top_position=top,
                            left_position=left,
                            order=order,
                        )
                        a.save()

        for action_tuple in action_tuples:
            id, description, source, destination = action_tuple
            action_def, created = ActionDef.objects.get_or_create(
                description=description
            )
            action = Action.objects.get_or_create(
                description=description,
                action_def=action_def,
                action_sequence=action_sequence_instance,
            )
            # action.save()
        # for i, a in enumerate(action_sequences):
        # ac_sq = ActionSequence.objects.filter(description=a)[0]

        eas = ExperimentActionSequence(
            experiment_template=exp_template,
            experiment_action_sequence_seq=0,
            action_sequence=action_sequence_instance,
        )
        eas.save()

    return JsonResponse(data={"message": "success"})

