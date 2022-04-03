from django.http import HttpResponse, HttpRequest, HttpResponseRedirect
from django.shortcuts import render, redirect
from django.contrib.messages import get_messages
from core.utilities.experiment_utils import get_action_parameter_querysets
from core.utilities.utils import generate_vp_spec_file
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
from django.db.models import Q
import pandas as pd
import tempfile


def get_messages(request: HttpRequest) -> HttpResponse:
    if request.method == "GET":
        return render(
            request,
            "core/generic/message.html",
            context={"messages": get_messages(request)},
        )


def download_vp_spec_file(request: HttpRequest) -> HttpResponse:
    try:
        exp_uuid: str = request.session["experiment_template_uuid"]
        vessel = Vessel.objects.get(uuid=request.session["vessel"])
        f = generate_vp_spec_file(exp_uuid, {}, vessel.description, vessel.well_number)
        response = FileResponse(
            f, as_attachment=True, filename=f"manual_{exp_uuid}.xls"
        )
    except Exception as e:
        return JsonResponse({"Error": f"Unexpected {e=}, {type(e)=}"})
    return response


def download_manual_spec_file(request: HttpRequest) -> "FileResponse|JsonResponse":
    form_data = request.session["experiment_create_form_data"]
    exp_template = ExperimentTemplate.objects.get(
        uuid=form_data["experiment_template"]["select_experiment_template"]
    )
    # Get the form data entered in the wizard
    vessel_uuids = form_data["vessels"]
    table_data = {}
    meta_data = {}
    # Loop through every action template
    for i, action_template in enumerate(
        exp_template.action_template_et.filter(dest_vessel_decomposable=True)
    ):
        action_def = action_template.action_def
        parameter_defs = action_def.parameter_def.all()
        dest_vessel_uuid = vessel_uuids[str(action_template.dest_vessel_template.uuid)]
        dest_vessel = Vessel.objects.get(uuid=dest_vessel_uuid)
        # For every parameter def in the action def,
        # Save uuids to meta data dictionary
        # Add default data to table dictionary
        for pdef in parameter_defs:
            description_str = f"action: {action_template.description}"
            value_str = f"value: {pdef.description} {action_template.description}"
            unit_str = f"unit: {pdef.description} {action_template.description}"

            meta_data[description_str] = action_template.uuid
            meta_data[value_str] = f"value:{pdef.uuid}:{action_template.uuid}"
            meta_data[unit_str] = f"unit:{pdef.uuid}:{action_template.uuid}"

            table_data[description_str] = []
            table_data[value_str] = []
            table_data[unit_str] = []

            if dest_vessel.children.count() == 0:
                # If the destination vessel has no children, just add 1 row
                dest_description_str = f"vessel: {dest_vessel.description}"
                table_data[description_str].append(dest_description_str)
                table_data[value_str].append(f"{pdef.default_val.value}")
                table_data[unit_str].append(f"{pdef.default_val.unit}")
                meta_data[dest_description_str] = dest_vessel.uuid

            else:
                # Add as many rows there are as children
                for i, child in enumerate(
                    dest_vessel.children.all().order_by(
                        "description",
                    )
                ):
                    dest_description_str = (
                        f"vessel: {dest_vessel.description} : {child.description}"
                    )
                    table_data[description_str].append(dest_description_str)
                    table_data[value_str].append(f"{pdef.default_val.value}")
                    table_data[unit_str].append(f"{pdef.default_val.unit}")
                    meta_data[dest_description_str] = child.uuid

    temp = tempfile.TemporaryFile()
    excel_writer = pd.ExcelWriter(temp)
    outframe = pd.DataFrame(data=table_data)
    outframe.to_excel(
        excel_writer=excel_writer,
        sheet_name=exp_template.description,
        index=False,
    )

    m_data = {"keys": list(meta_data.keys()), "values": list(meta_data.values())}
    meta_dataframe = pd.DataFrame(data=m_data)
    meta_dataframe.to_excel(
        excel_writer,
        sheet_name="meta_data",
        index=False,
    )
    excel_writer.save()
    temp.seek(0)
    response = FileResponse(
        temp,
        as_attachment=True,
        filename=f"manual_{exp_template.description}.xlsx",
    )
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
                                properties["destination"],
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
                        if properties["destination"]:
                            default_vessel, created = Vessel.objects.get_or_create(
                                description="Generic Vessel"
                            )

                            if "wells" in properties["destination"]:
                                dest_vessel_decomposable = True
                            else:
                                dest_vessel_decomposable = False

                            (
                                dest_vessel_template,
                                created,
                            ) = VesselTemplate.objects.get_or_create(
                                description="Outcome vessel",
                                outcome_vessel=True,
                                default_vessel=default_vessel,
                            )

                            if created:
                                exp_template.vessel_templates.add(dest_vessel_template)

                        action_template, created = ActionTemplate.objects.get_or_create(
                            # action_sequence=action_sequences[action_seq],
                            description=description,
                            experiment_template=exp_template,
                            action_def=action_def,
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

        """for action_tuple in action_tuples:
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
        eas.save()"""

    return JsonResponse(data={"message": "success"})
