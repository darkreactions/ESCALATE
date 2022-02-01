from django.http import HttpResponse, HttpRequest
from django.shortcuts import render
from django.contrib.messages import get_messages
from core.utilities.experiment_utils import get_action_parameter_querysets
from core.utilities.wf1_utils import (
    generate_robot_file_wf1,
    generate_general_robot_file,
    make_well_labels_list,
)
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
    f = generate_general_robot_file(q1, {}, None, 96)
    # f = generate_robot_file_wf1(q1, {}, "Symyx_96_well_0003", 96)
    response = FileResponse(f, as_attachment=True, filename=f"robot_{exp_uuid}.xls")
    return response


"""def save_action_sequence(request: HttpRequest) -> HttpResponse:
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

    return JsonResponse(data={"message": "success"})"""


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
            action.save()

        """ if source is not None:
                source_bbm = BaseBomMaterial.objects.create(description=source)
            else:
                source_bbm = None

            if "- wells" in destination:  # individual well-level actions
                plate = Vessel.objects.get(description=destination.split(" -")[0])
                # plate, created = Vessel.objects.get_or_create(
                # description=destination.split("wells")[0]
                # )
                # well_count = int(destination.split(" ")[0])
                well_list = make_well_labels_list(
                    well_count=plate.well_number,
                    column_order=plate.column_order,
                    robot="True",
                )
                plate_wells = {}
                for well in well_list:
                    plate_wells[well], created = Vessel.objects.get_or_create(
                        parent=plate, description=well
                    )
                for well_desc, well_vessel in plate_wells.items():
                    destination_bbm = BaseBomMaterial.objects.create(
                        description=f"{plate.description} : {well_desc}",
                        vessel=well_vessel,
                    )
                    if source_bbm:
                        description = f"{action.description} : {source_bbm.description} -> {destination_bbm.description}"
                    else:
                        description = (
                            f"{action.description} : {destination_bbm.description}"
                        )
                    au = ActionUnit.objects.create(
                        action=action,
                        source_material=source_bbm,
                        destination_material=destination_bbm,
                        description=description,
                    )
                    au.save()
            else:
                if "Plate" in destination:  # plate-level actions

                    vessel = Vessel.objects.get(description=destination.split(" -")[0])

                    # if "plate" in destination:  # plate-level actions
                    # plate, created = Vessel.objects.get_or_create(
                    # description=destination
                    # )
                    destination_bbm = BaseBomMaterial.objects.create(
                        description=plate.description, vessel=vessel
                    )
                    if source_bbm:
                        description = f"{action.description} : {source_bbm.description} -> {destination_bbm.description}"
                    else:
                        description = (
                            f"{action.description} : {destination_bbm.description}"
                        )

                    au = ActionUnit.objects.create(
                        action=action,
                        source_material=source_bbm,
                        description=description,
                        destination_material=destination_bbm,
                    )
                    au.save()

                else:
                    # if destination is not a vessel
                    destination_bbm = BaseBomMaterial.objects.create(
                        description=destination
                    )
                    if source_bbm:
                        description = f"{action.description} : {source_bbm.description} -> {destination_bbm.description}"
                    else:
                        description = (
                            f"{action.description} : {destination_bbm.description}"
                        )
                    au = ActionUnit(
                        action=action,
                        source_material=source_bbm,
                        description=description,
                        destination_material=destination_bbm,
                    )

                    au.save()"""

        # for i, a in enumerate(action_sequences):
        # ac_sq = ActionSequence.objects.filter(description=a)[0]

        eas = ExperimentActionSequence(
            experiment_template=exp_template,
            experiment_action_sequence_seq=0,
            action_sequence=action_sequence_instance,
        )
        eas.save()

    return JsonResponse(data={"message": "success"})

