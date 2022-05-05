from typing import Optional
from django.http import HttpResponse, HttpRequest 
from django.shortcuts import render, redirect
from django.contrib.messages import get_messages
from django.http.response import FileResponse, JsonResponse
from core.models.app_tables import ActionTemplateDesign
from core.models import (
    Action,
    ActionDef,
    ActionTemplate,
    ExperimentTemplate,
    ExperimentInstance,
    Vessel,
    VesselTemplate,
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
        filename=f"manual_{experiment_data.experiment_template.description}.xlsx",
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


def save_experiment_action_template(request: HttpRequest) -> HttpResponse:
    if request.method == "POST":

        exp_template = ExperimentTemplate.objects.get(uuid=request.POST["exp_template"])
        # exp_template = ExperimentTemplate.objects.get(
        # uuid=request.session["experiment_template_uuid"]
        # )

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
                                properties["destination_type"],
                                properties["destination_decomposable"],
                            )
                        )

                        # if properties["source"] == "":
                        # properties["source"] = None

                        for a in action_tuples:
                            action_def, created = ActionDef.objects.get_or_create(
                                description=description
                            )

                        source_vessel_template = None
                        source_vessel_decomposable = False
                        if properties["source"]:
                            default_vessel, created = Vessel.objects.get_or_create(
                                description="Generic Vessel"
                            )
                            (
                                source_vessel_template,
                                created,
                            ) = VesselTemplate.objects.get_or_create(
                                description=properties["source"],
                                outcome_vessel=False,
                                # decomposable=False,
                                default_vessel=default_vessel,
                            )

                            if created:
                                exp_template.vessel_templates.add(
                                    source_vessel_template
                                )

                        dest_vessel_template = None
                        dest_vessel_decomposable = False
                        if properties["destination_type"]:
                            default_vessel, created = Vessel.objects.get_or_create(
                                description="Generic Vessel"
                            )

                            if properties["destination_decomposable"] == True:
                                dest_vessel_decomposable = True
                            else:
                                dest_vessel_decomposable = False

                            if properties["destination_type"] == 'Outcome vessel': #outcome vessel
                            
                                (
                                    dest_vessel_template,
                                    created,
                                ) = VesselTemplate.objects.get_or_create(
                                    outcome_vessel=True,
                                    default_vessel=default_vessel,
                                )

                                if created:
                                    exp_template.vessel_templates.add(dest_vessel_template)
                            
                            elif properties["destination_type"] == 'Other': #not outcome vessel
                                (
                                    dest_vessel_template,
                                    created,
                                ) = VesselTemplate.objects.get_or_create(
                                    outcome_vessel=False,
                                    default_vessel=default_vessel,
                                )

                                if created:
                                    exp_template.vessel_templates.add(dest_vessel_template)

                        action_template, created = ActionTemplate.objects.get_or_create(
                            # action_sequence=action_sequences[action_seq],
                            description=description,
                            experiment_template=exp_template,
                            action_def=action_def,  # type: ignore
                            source_vessel_template=source_vessel_template,
                            source_vessel_decomposable=source_vessel_decomposable,
                            dest_vessel_template=dest_vessel_template,
                            dest_vessel_decomposable=dest_vessel_decomposable,
                        )

                        a, created = ActionTemplateDesign.objects.get_or_create(
                            action_template=action_template,
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

    return JsonResponse(data={"message": "success"})
